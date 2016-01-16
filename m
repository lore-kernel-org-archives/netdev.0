From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: hang in ip_finish_output
Date: Fri, 15 Jan 2016 23:29:56 -0800
Message-ID: <1452929396.1223.202.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+bdpCR_rmiDAUi8ge3iecBOpaAat6S3o_GDjt-p2c53BA@mail.gmail.com>
	 <CAEfhGixTRfTviSiaiqYHPDxxz2af4Xbm198WuM1dR6BQKojPxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEfhGixTRfTviSiaiqYHPDxxz2af4Xbm198WuM1dR6BQKojPxQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-01-15 at 19:20 -0500, Craig Gallek wrote:

> I wasn't able to reproduce this exact stack trace, but I was able to
> cause soft lockup messages with a fork bomb of your test program.  It
> is certainly related to my recent SO_REUSEPORT change (reverting it
> seems to fix the problem).  I haven't completely figured out the exact
> cause yet, though.  Could you please post your configuration and
> exactly how you are running this 'parallel loop'?

There is a problem in the lookup functions (udp4_lib_lookup2() &
__udp4_lib_lookup())

Because of RCU SLAB_DESTROY_BY_RCU semantics (check
Documentation/RCU/rculist_nulls.txt for some details), you should not
call reuseport_select_sock(sk, ...) without taking a stable reference on
the sk socket. (and checking the lookup keys again)

This is because sk could be freed, re-used by a totally different UDP
socket on a different port, and the incoming frame(s) could be delivered
on the wrong socket/channel/application :(

Note that we discussed some time ago to remove SLAB_DESTROY_BY_RCU for
UDP sockets (and freeing them after rcu grace period instead), so make
UDP rx path faster, as we would no longer need to increment/decrement
the socket refcount. This also would remove the added false sharing on
sk_refcnt for the case the UDP socket serves as a tunnel (up->encap_rcv
being non NULL)
