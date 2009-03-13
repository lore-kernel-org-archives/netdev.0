From: Dave Jones <davej@redhat.com>
Subject: a2065 skb_padto cleanups
Date: Fri, 13 Mar 2009 16:52:16 -0400
Message-ID: <20090313205216.GA6898@redhat.com>
References: <49B89385.4090005@cosmosbay.com> <20090312045657.GB7132@redhat.com> <49B89A33.2030207@cosmosbay.com> <20090313.133640.130060599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54076 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759528AbZCMUwh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 16:52:37 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n2DKqXEC026128
	for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 16:52:33 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n2DKqIqm015313
	for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 16:52:18 -0400
Received: from gelk.kernelslacker.org (vpn-12-86.rdu.redhat.com [10.11.12.86])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n2DKqHXx020334
	for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 16:52:18 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.14.3/8.14.3) with ESMTP id n2DKqGvF012643
	for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 16:52:16 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.3/8.14.3/Submit) id n2DKqG4Q012639
	for netdev@vger.kernel.org; Fri, 13 Mar 2009 16:52:16 -0400
Content-Disposition: inline
In-Reply-To: <20090313.133640.130060599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whilst looking for other instances of the bug that was in velocity,
I noticed a few possible cleanups in a2065.  I don't have this
hardware, so extra review appreciated.

	Dave
--- 

Remove unnecessary check (skb_padto does the same check)
Remove unnecessary duplicate variable
Remove unnecessary clearing of padded part of skb.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index 7a60bdd..d0d0c2f 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -552,18 +552,13 @@ static int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 	volatile struct lance_init_block *ib = lp->init_block;
-	int entry, skblen, len;
+	int entry, skblen;
 	int status = 0;
 	unsigned long flags;
 
-	skblen = skb->len;
-	len = skblen;
-
-	if (len < ETH_ZLEN) {
-		len = ETH_ZLEN;
-		if (skb_padto(skb, ETH_ZLEN))
-			return 0;
-	}
+	if (skb_padto(skb, ETH_ZLEN))
+		return 0;
+	skblen = max_t(unsigned, skb->len, ETH_ZLEN);
 
 	local_irq_save(flags);
 
@@ -586,15 +581,11 @@ static int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	}
 #endif
 	entry = lp->tx_new & lp->tx_ring_mod_mask;
-	ib->btx_ring [entry].length = (-len) | 0xf000;
+	ib->btx_ring [entry].length = (-skblen) | 0xf000;
 	ib->btx_ring [entry].misc = 0;
 
 	skb_copy_from_linear_data(skb, (void *)&ib->tx_buf [entry][0], skblen);
 
-	/* Clear the slack of the packet, do I need this? */
-	if (len != skblen)
-		memset ((void *) &ib->tx_buf [entry][skblen], 0, len - skblen);
-
 	/* Now, give the packet to the lance */
 	ib->btx_ring [entry].tmd1_bits = (LE_T1_POK|LE_T1_OWN);
 	lp->tx_new = (lp->tx_new+1) & lp->tx_ring_mod_mask;

-- 
http://www.codemonkey.org.uk
