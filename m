From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: LOCKDEP complaints in l2tp_xmit_skb()
Date: Thu, 28 Jun 2012 13:22:31 +0200
Message-ID: <1340882551.13187.96.camel@edumazet-glaptop>
References: <20120627111152.GA2531@raven>
	 <1340866572.26242.312.camel@edumazet-glaptop>
	 <1340873862.13187.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63171 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910Ab2F1LWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 07:22:34 -0400
Received: by mail-ey0-f174.google.com with SMTP id k11so739639eaa.19
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 04:22:33 -0700 (PDT)
In-Reply-To: <1340873862.13187.5.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-28 at 10:57 +0200, Eric Dumazet wrote:
> On Thu, 2012-06-28 at 08:56 +0200, Eric Dumazet wrote:
> 
> > [PATCH] net: Qdisc busylock gets its own lockdep class
> > 
> > Tom Parkin reported following LOCKDEP splat :
> ..
> > 
> > Instruct lockdep that each Qdisc busylock is independant, or else
> > bonding or various tunnels can trigger a splat.
> > 
> > Reported-by: Tom Parkin <tparkin@katalix.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
> 
> I reproduced the bug using a bond0 device, adding a qdisc on it,
> (one Qdisc on bond0, and a Qdisc on the slave too)
> 
> Problem with this patch is I have following message :
> 
> BUG: key ffff88..... not in .data!
> 
> No more LOCKDEP splat, but patch not good as is.

I tested the alternative following patch with my bonding setup,
could you test it with l2tp ?

 net/core/dev.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6df2140..d265c67 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2412,13 +2412,13 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 
 		qdisc_bstats_update(q, skb);
 
-		if (sch_direct_xmit(skb, q, dev, txq, root_lock)) {
-			if (unlikely(contended)) {
-				spin_unlock(&q->busylock);
-				contended = false;
-			}
+		if (unlikely(contended)) {
+			spin_unlock(&q->busylock);
+			contended = false;
+		}
+		if (sch_direct_xmit(skb, q, dev, txq, root_lock))
 			__qdisc_run(q);
-		} else
+		else
 			qdisc_run_end(q);
 
 		rc = NET_XMIT_SUCCESS;
