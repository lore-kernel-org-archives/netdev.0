From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Tue, 11 Nov 2008 16:18:49 -0800 (PST)
Message-ID: <20081111.161849.251632080.davem@davemloft.net>
References: <1225809909.10206.90.camel@localhost.localdomain>
	<4919DAB4.7050009@krogh.cc>
	<20081111.155041.90523159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, netdev@vger.kernel.org
To: jesper@krogh.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44393
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751852AbYKLASu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 19:18:50 -0500
In-Reply-To: <20081111.155041.90523159.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 11 Nov 2008 15:50:41 -0800 (PST)

> If you could run those test patches when I post them and give
> the log messages they produce, I'd appreciate it.

Ok, let's start with this debugging patch below.

When the chip gets a TX timeout it's going to dump a lot of
state.  First it will dump the state of the logic device group
interrupt vectors (both hardware and software copies).

Then, for each TX ring, it will dump the TX_CS register (both
software and hardware copies), the mapping from that TX ring
to logical-device number and logical device group.  It will
also print out how many packets are in the ring but not freed
up yet.

Please post the dump that results when the condition triggers.
Just provide the first dump the kernel spits out.

Thanks.

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2c3bb36..beffbc5 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6070,12 +6070,79 @@ static void niu_reset_task(struct work_struct *work)
 	spin_unlock_irqrestore(&np->lock, flags);
 }
 
+static void niu_dump_ldg_vecs(struct net_device *dev)
+{
+	struct niu *np = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < np->num_ldg; i++) {
+		struct niu_ldg *lp = &np->ldg[i];
+		u64 v0, v1, v2;
+
+		v0 = nr64(LDSV0(lp->ldg_num));
+		v1 = nr64(LDSV1(lp->ldg_num));
+		v2 = nr64(LDSV2(lp->ldg_num));
+
+		dev_err(np->device, PFX "%s: LDG[idx(%d):num(%u)] "
+			"V0[sw(0x%llx)hw(0x%llx)] "
+			"V1[sw(0x%llx)hw(0x%llx)] "
+			"V2[sw(0x%llx)hw(0x%llx)]\n",
+			dev->name, i, lp->ldg_num,
+			(unsigned long long) lp->v0,
+			(unsigned long long) v0,
+			(unsigned long long) lp->v1,
+			(unsigned long long) v1,
+			(unsigned long long) lp->v2,
+			(unsigned long long) v2);
+	}
+}
+
+static void niu_dump_one_tx_ring(struct net_device *dev,
+				 struct niu *np, int index)
+{
+	struct tx_ring_info *rp = &np->tx_rings[index];
+	struct niu_parent *parent = np->parent;
+	int ldn = LDN_TXDMA(rp->tx_channel);
+	int i, num_pending_skbs = 0;
+
+	dev_err(np->device, PFX "%s: TX_RING[%2u] CHANNEL %u LDN %u\n",
+		dev->name, index, rp->tx_channel, ldn);
+
+	dev_err(np->device, PFX "%s: TX_RING[%2u] parent->lgd_map[ldn] %u\n",
+		dev->name, index, parent->ldg_map[ldn]);
+
+	for (i = 0; i < MAX_TX_RING_SIZE; i++) {
+		if (rp->tx_buffs[i].skb)
+			num_pending_skbs++;
+	}
+	dev_err(np->device, PFX "%s: TX_RING[%2u] Num pending TX SKBs: %d\n",
+		dev->name, index, num_pending_skbs);
+	dev_err(np->device, PFX "%s: TX_RING[%2u] TX_CS sw[%016llx] "
+		"hw[%016llx]\n",
+		dev->name, index,
+		(unsigned long long) rp->tx_cs,
+		(unsigned long long) nr64(TX_CS(rp->tx_channel)));
+}
+
+static void niu_dump_tx_state(struct net_device *dev)
+{
+	struct niu *np = netdev_priv(dev);
+	int i;
+
+	dev_err(np->device, PFX "%s: Dumping transmitter state.\n",
+		dev->name);
+	for (i = 0; i < np->num_tx_rings; i++)
+		niu_dump_one_tx_ring(dev, np, i);
+}
+
 static void niu_tx_timeout(struct net_device *dev)
 {
 	struct niu *np = netdev_priv(dev);
 
 	dev_err(np->device, PFX "%s: Transmit timed out, resetting\n",
 		dev->name);
+	niu_dump_ldg_vecs(dev);
+	niu_dump_tx_state(dev);
 
 	schedule_work(&np->reset_task);
 }
