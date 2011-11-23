From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH net-next v2 0/4] e1000e: ethtool setfeatures fixes + loopback
Date: Tue, 22 Nov 2011 17:56:42 -0800
Message-ID: <CAHo-OowGhZX7u_qQgg8qDs+eo+7MJcRn0zGh8ohcC7nsv67t1A@mail.gmail.com>
References: <cover.1321989502.git.david.decotigny@google.com>
	<1321994813.2304.90.camel@jtkirshe-mobl>
	<CAG88wWY_6o_1Ecxe6+XiA8ga6+t4ua+L6fZ8AOOFyrKgZ8LDMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: jeffrey.t.kirsher@intel.com,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Mahesh Bandewar <maheshb@google.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG88wWY_6o_1Ecxe6+XiA8ga6+t4ua+L6fZ8AOOFyrKgZ8LDMQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David, could you test the trivial-forward-port patch I sent out and
verify that it continues to work correctly (was there anything you had
to fix in my patch?), a quick glance at the driver doesn't seem to
show any changes between 2.6.34 and now that would cause it to break
in unexpected ways... but who knows...?

There's a few features of it that I prefer to your version of the patch:
- it should be more robust to e1e_rphy timeout failures
- it checks loopback later, which makes that more robust, and can
check it multiple times.
- fixed up comments, variable renames, etc. better readability (IMHO)

Obviously it should probably be split into a separate patch to fix
bugs, and a separate one to implement loopback carrier faking.

The basic problem is that normally e1e_rphy() succeeds very quickly,
but in actuality the code is kind of more like:
  e1e_rphy() {
    for (i = 0; i < MAX_ITER; ++i) {
      try to read register
      on success return value
      pause
    }
    return failure;
  }

There is potential for the read to fail due to the firmware having
locked you out, hence the delay loop.  Unfortunately in certain cases
this fails for longer then MAX_ITER * pause_time, causing e1e_rphy()
as a whole to fail.

However, once it succeeds, subsequent reads are also very likely to
succeed and be very fast as well (ie. failures are _very_
time-correlated).

Hence, you cannot check for anything only once and expect it to
reliably behave.  This is the reason why in my patch loopback
detection was deeper in the loop instead of the first thing one does
(this also causes loopback detection code to not trigger on the normal
case of link up, so it's faster in the normal case).

There's also a lot of places where intervals == 0 on call, which is
why my patch has the extra read before the loop - it makes the
intervals == 0 case just slightly more likely to succeed.

Remember e1e_rphy() has 3 cases:
  timeout
  success after time < timeout
  immediate success.

And in practice, failed reads are more likely to be back-to-back than random.

A relatively likely scenario is 3 reads behaving like so:
  timeout, success after time < timeout, immediate success.
