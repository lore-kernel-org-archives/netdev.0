From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Sun, 7 Nov 2004 17:33:30 +0100
Message-ID: <20041107163330.GB31969@postel.suug.ch>
References: <20041105175812.GZ12289@postel.suug.ch> <418BC40E.8080402@trash.net> <20041105194303.GA12289@postel.suug.ch> <20041106011843.GI12289@postel.suug.ch> <418C2D40.9020300@trash.net> <20041106015931.GA28715@postel.suug.ch> <20041106145036.GB28715@postel.suug.ch> <418DE37E.2050504@trash.net> <20041107140015.GA31969@postel.suug.ch> <418E4B2E.1070407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <418E4B2E.1070407@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Who cares about huge sections while holding reference counts ?
> qdisc_destroy won't destroy the qdisc until all references have
> been dropped, that's the whole point of it.

I might have misunderstood you in this point, so you increment a
refcnt in qdisc_lookup and decrement in once you're done with
the reference? I thought you wanted to to bh spin locks. I'm not
sure how you want to do this without creating races.

Example:

We get a RTM_DELQDISC request so you'll increment refcnt in
qdisc_lookup and decrement it right before you call qdisc_destroy
so it actually can be deleted. The rcu callback works fine
and will set up a another rcu callback for the destroying of
the inner qdiscs. Right at this time you get a RTM_GETQDISC for
that inner qdisc so you'll lock on it, then the rcu callback
comes in and cannot delete the inner qdisc anymore. Do you want
to sleep in softirq context?
