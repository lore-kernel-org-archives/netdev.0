From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad networking related lag in v2.6.22-rc2
Date: Wed, 23 May 2007 21:25:59 +1000
Message-ID: <20070523112559.GA24604@gondor.apana.org.au>
References: <20070517174533.GA538@elte.hu> <200705221147.56571.kernel@prachanda.hub> <20070522062233.GA20002@elte.hu> <200705231110.44526.kernel@prachanda.hub> <20070523063052.GB26814@elte.hu> <46541DC4.4090501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Anant Nitya <kernel@prachanda.info>,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3464 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755885AbXEWL1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 07:27:20 -0400
Content-Disposition: inline
In-Reply-To: <46541DC4.4090501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 23, 2007 at 12:56:04PM +0200, Patrick McHardy wrote:
> 
> Looking at the recent changes to __qdisc_run, this indeed seems
> to be the case, when the qdisc is throttled and has packets queued
> we return a value != 0, causing __qdisc_run to loop until all
> packets have been sent, which may be a long time.

Good catch! I was obviously half awake at the time :)

We could also fix it this way:

[NET_SCHED]: Fix qdisc_restart return value when dequeue is empty

My previous patch that changed the return value of qdisc_restart
incorrectly made the case where dequeue returns empty continue
processing packets.

This patch is based on diagnosis and fix by Patrick McHardy.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f28bb2d..cbefe22 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -169,8 +169,8 @@ requeue:
 		else
 			q->ops->requeue(skb, q);
 		netif_schedule(dev);
-		return 0;
 	}
+	return 0;
 
 out:
 	BUG_ON((int) q->q.qlen < 0);
