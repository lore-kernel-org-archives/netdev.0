From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Fri, 5 Nov 2004 17:39:51 +0100
Message-ID: <20041105163951.GY12289@postel.suug.ch>
References: <418B4C7C.8000402@crocom.com.pl> <20041105115430.GP19714@rei.reeler.org> <418B4C7C.8000402@crocom.com.pl> <20041105141640.GQ19714@rei.reeler.org> <418BA66A.60804@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <418BA66A.60804@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <418BA66A.60804@trash.net> 2004-11-05 17:12
> Nice catch. I can't understand how you triggered that oops,
> though. The noop- and noqueue-qdiscs used without qdisc_create_*
> are not refcounted, so I would expect:
> 
> void qdisc_destroy(struct Qdisc *qdisc)
> {
>        if (!atomic_dec_and_test(&qdisc->refcnt))
>                return;
> 
> to underflow and return until refcnt finally reaches 0 again.
> Can you explain, please ?

Right, this is indeed the case. This doesn't fix the oops reported
but will prevent the oops you are referring to which was triggerd
after 2h stress testing on my machine. I haven't had the time to
check if incrementing the refcnt of builtin qdiscs causes
any problems but initializing the list is good in any case.

I found huge locking problems from qidsc_destroy calling contexts though.
Almost all calling paths to qdisc_destroy invoked from qdiscs are messed up.
I am resolving those now. I have a theoretical path that could cause the
reported oops which is htb_put -> htb_destroy_class -> qdisc_destroy
not bh locking dev->queue_lock and thus the list unlinking could
take place during a walk/lookup and thus lead to POISON value in the
next pointer. I could not reproduce this so far though.
