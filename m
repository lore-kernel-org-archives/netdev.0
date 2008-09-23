From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Tue, 23 Sep 2008 08:02:40 +0000
Message-ID: <20080923080240.GA4692@ff.dom.local>
References: <20080921095705.GA2551@ami.dom.local> <20080921.031829.86500526.davem@davemloft.net> <20080921111551.GB2551@ami.dom.local> <20080922.221658.221283630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:47171 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbYIWICs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 04:02:48 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1648281fgg.17
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 01:02:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080922.221658.221283630.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2008 at 10:16:58PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 21 Sep 2008 13:15:51 +0200
> 
> > That's why I think you should reconsider this simple solution for now,
> > until somebody proves this is wrong or something else is better.
> 
> Ok, that sounds reasonable.  I've added those three patches to net-next-2.6
> and will push those out after some build tests.

OK, then we have to say B and try this all. BTW, I guess, after this
change we could have similar effect as reported by Alexander Duyck
while testing his solution for this problem, namely the higher drop
rate in some cases, which I can only explain as: less time in
requeuing more time for new enqueuing. Of course, if I'm right, this
"bug" should be rather "fixed" with longer queues or some other
throttle mechanism.

Thanks,
Jarek P.

-------------------->

pkt_sched: Remove the tx queue state check in qdisc_run()

The current check wrongly uses the state of one (currently the first)
tx queue for all tx queues in case of non-default qdiscs. This check
mainly prevented requeuing loop with __netif_schedule(), but now it's
controlled inside __qdisc_run(), while dequeuing. The wrongness of
this check was first noticed by Herbert Xu.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 include/net/pkt_sched.h |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index b786a5b..4082f39 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -90,10 +90,7 @@ extern void __qdisc_run(struct Qdisc *q);
 
 static inline void qdisc_run(struct Qdisc *q)
 {
-	struct netdev_queue *txq = q->dev_queue;
-
-	if (!netif_tx_queue_stopped(txq) &&
-	    !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
+	if (!test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
 		__qdisc_run(q);
 }
 
