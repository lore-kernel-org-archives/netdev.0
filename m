From: Patrick McHardy <kaber@trash.net>
Subject: Re: bad networking related lag in v2.6.22-rc2
Date: Wed, 23 May 2007 12:56:04 +0200
Message-ID: <46541DC4.4090501@trash.net>
References: <20070517174533.GA538@elte.hu> <200705221147.56571.kernel@prachanda.hub> <20070522062233.GA20002@elte.hu> <200705231110.44526.kernel@prachanda.hub> <20070523063052.GB26814@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020605000307020501070300"
Cc: Anant Nitya <kernel@prachanda.info>, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39068 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758439AbXEWK7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 06:59:06 -0400
In-Reply-To: <20070523063052.GB26814@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020605000307020501070300
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Ingo Molnar wrote:
> if you feel inclined to try the git-bisection then by all means please 
> do it (it will certainly be helpful and educative), but it's optional: i 
> dont think you should 'need' to go through extra debugging chores, my 
> analysis based on the excellent trace you provided still holds and 
> whoever modified htb_dequeue()'s logic recently ought to be able to 
> figure that out (or send you a debug patch to further narrow the problem 
> down).
>
> The trace shows a _clearly_ anomalous loop: for example there's 56396 
> (!) calls to rb_first() in htb_dequeue() [without the kernel ever 
> exiting that function]:
> 
>   earth4:~/s> grep rb_first trace-to-ingo.txt  | wc -l
>   56396


How is this trace to be understood? Is it simply a call trace in
execution-order? If thats the case than we are exiting htb_dequeue,
each call to qdisc_watchdog_schedule happens at the very end of
that function, which would imply a bug in __qdisc_run.

Looking at the recent changes to __qdisc_run, this indeed seems
to be the case, when the qdisc is throttled and has packets queued
we return a value != 0, causing __qdisc_run to loop until all
packets have been sent, which may be a long time.

Anant, can you please verify by testing the attached patch? Thanks.

--------------020605000307020501070300
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f28bb2d..f536060 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -174,7 +174,7 @@ requeue:
 
 out:
 	BUG_ON((int) q->q.qlen < 0);
-	return q->q.qlen;
+	return skb ? q->q.qlen : 0;
 }
 
 void __qdisc_run(struct net_device *dev)

--------------020605000307020501070300--
