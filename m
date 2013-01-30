From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] via-rhine: NOHZ: local_softirq_pending 08
Date: Tue, 29 Jan 2013 22:53:28 -0500 (EST)
Message-ID: <20130129.225328.896248042332851696.davem@davemloft.net>
References: <51007b84.03ab640a.1cde.fffff62a@mx.google.com>
	<20130129.174702.196275387733819730.davem@davemloft.net>
	<20130130000432.GA28621@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamie.gloudon@gmail.com, netdev@vger.kernel.org, rl@hellgate.ch
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033Ab3A3Dxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 22:53:32 -0500
In-Reply-To: <20130130000432.GA28621@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 30 Jan 2013 01:04:32 +0100

> David Miller <davem@davemloft.net> :
> [...]
>> I don't think you can't keep using dev_kfree_skb_irq() there.
>> 
>> Francois any objections to this patch?
> 
> None.
> 
> I have almost surely broken via-rhine with NOHZ as I broke the r8169
> driver before 7dbb491878a2c51d372a8890fa45a8ff80358af1. Something like
> the patch below could be needed as well (quick shot before bed time
> and ~24h delay if Jamie wants to try something now).

Good catch, Jamie can you test this combined patch for us?

====================
via-rhine: Fix bugs in NAPI support.

1) rhine_tx() should use dev_kfree_skb() not dev_kfree_skb_irq()

2) rhine_slow_event_task's NAPI triggering logic is racey, it
   should just hit the interrupt mask register.  This is the
   same as commit 7dbb491878a2c51d372a8890fa45a8ff80358af1
   ("r8169: avoid NAPI scheduling delay.") made to fix the same
   problem in the r8169 driver.  From Francois Romieu.

Reported-by: Jamie Gloudon <jamie.gloudon@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 7992b3e..78ace59 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1801,7 +1801,7 @@ static void rhine_tx(struct net_device *dev)
 					 rp->tx_skbuff[entry]->len,
 					 PCI_DMA_TODEVICE);
 		}
-		dev_kfree_skb_irq(rp->tx_skbuff[entry]);
+		dev_kfree_skb(rp->tx_skbuff[entry]);
 		rp->tx_skbuff[entry] = NULL;
 		entry = (++rp->dirty_tx) % TX_RING_SIZE;
 	}
@@ -2010,11 +2010,7 @@ static void rhine_slow_event_task(struct work_struct *work)
 	if (intr_status & IntrPCIErr)
 		netif_warn(rp, hw, dev, "PCI error\n");
 
-	napi_disable(&rp->napi);
-	rhine_irq_disable(rp);
-	/* Slow and safe. Consider __napi_schedule as a replacement ? */
-	napi_enable(&rp->napi);
-	napi_schedule(&rp->napi);
+	iowrite16(RHINE_EVENT & 0xffff, rp->base + IntrEnable);
 
 out_unlock:
 	mutex_unlock(&rp->task_lock);
