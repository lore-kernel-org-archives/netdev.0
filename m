From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Sun, 07 Nov 2004 18:02:52 +0100
Message-ID: <418E553C.2070006@trash.net>
References: <20041105175812.GZ12289@postel.suug.ch> <418BC40E.8080402@trash.net> <20041105194303.GA12289@postel.suug.ch> <20041106011843.GI12289@postel.suug.ch> <418C2D40.9020300@trash.net> <20041106015931.GA28715@postel.suug.ch> <20041106145036.GB28715@postel.suug.ch> <418DE37E.2050504@trash.net> <20041107140015.GA31969@postel.suug.ch> <418E4B2E.1070407@trash.net> <20041107163330.GB31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041107163330.GB31969@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>I might have misunderstood you in this point, so you increment a
>refcnt in qdisc_lookup and decrement in once you're done with
>the reference? I thought you wanted to to bh spin locks. I'm not
>sure how you want to do this without creating races.
>
>Example:
>
>We get a RTM_DELQDISC request so you'll increment refcnt in
>qdisc_lookup and decrement it right before you call qdisc_destroy
>so it actually can be deleted. The rcu callback works fine
>and will set up a another rcu callback for the destroying of
>the inner qdiscs. Right at this time you get a RTM_GETQDISC for
>that inner qdisc so you'll lock on it, then the rcu callback
>comes in and cannot delete the inner qdisc anymore. Do you want
>to sleep in softirq context?
>
This can't happen. Once the inner qdiscs refcnt drops to zero
they are removed from the list, before the rcu callback is scheduled.
Once the RCU callback is scheduled it can't be found anymore.

BTW: An alternative, quite unintrusive solution is to prevent anyone
from finding the inner qdiscs after the outer one has been destroyed.
This can be done be keeping inner qdiscs on qdisc->qdisc_list and only
keep the top-level qdisc in struct net_device. Of course, this makes
walking all qdiscs more complicated. A generation counter for the
top-level qdisc should also work.

Regards
Patrick
