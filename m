From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH RFT net-next #2 0/6] via-rhine receive buffers rework
Date: Wed, 8 Apr 2015 23:50:51 +0200
Message-ID: <20150408215051.GA25326@electric-eye.fr.zoreil.com>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
 <87vbh6364u.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: Nix <nix@esperi.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57867 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbbDHVvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 17:51:05 -0400
Content-Disposition: inline
In-Reply-To: <87vbh6364u.fsf@spindle.srvr.nix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nix <nix@esperi.org.uk> :
[...]
> I am sorry to report that I just had a watchdog-triggered autoreboot
> during testing of this patch series :( with no log messages of any kind.
> looks like the underlying bug is still there, or another bug with the
> same symptoms (i.e. some way to crash inside the rx handler). I qwish I
> could get some debugging output when this happens!

You may add the patch below on top of the current stack. I don't expect
much difference. Increasing RX_RING_SIZE could be a different story.

Did you keep netconsole disabled and did you increse via-rhine verbosity
level ?

No shared IRQ ?

> However, to give some good news, CPU usage is much lower than before the
> patch: si ~10%, rather than ~80% with spikes of full CPU usage:
> ksoftirqd's CPU usage is steady at about 3% rather than 40--60% with
> spikes to 100%, and some of that will be USB interrupts from the
> continuous USB traffic from my entropy key.

Huuuuh ? Which entropy key ?

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 3e6fdbb..d441d8c 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1849,7 +1849,7 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 
 	netdev_sent_queue(dev, skb->len);
 	/* lock eth irq */
-	wmb();
+	dma_wmb();
 	rp->tx_ring[entry].tx_status |= cpu_to_le32(DescOwn);
 	wmb();
 
@@ -1996,6 +1996,7 @@ static inline u16 rhine_get_vlan_tci(struct sk_buff *skb, int data_size)
 static inline void rhine_rx_vlan_tag(struct sk_buff *skb, struct rx_desc *desc,
 				     int data_size)
 {
+	dma_rmb();
 	if (unlikely(desc->desc_length & cpu_to_le32(DescTag))) {
 		u16 vlan_tci;
 
@@ -2161,6 +2162,7 @@ static void rhine_slow_event_task(struct work_struct *work)
 		container_of(work, struct rhine_private, slow_event_task);
 	struct net_device *dev = rp->dev;
 	u32 intr_status;
+	u16 enable_mask;
 
 	mutex_lock(&rp->task_lock);
 
@@ -2176,7 +2178,12 @@ static void rhine_slow_event_task(struct work_struct *work)
 	if (intr_status & IntrPCIErr)
 		netif_warn(rp, hw, dev, "PCI error\n");
 
-	iowrite16(RHINE_EVENT & 0xffff, rp->base + IntrEnable);
+	napi_disable(&rp->napi);
+
+	enable_mask = ioread16(rp->base + IntrEnable) | RHINE_EVENT_SLOW;
+	iowrite16(enable_mask, rp->base + IntrEnable);
+
+	napi_enable(&rp->napi);
 
 out_unlock:
 	mutex_unlock(&rp->task_lock);
