From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] 8139cp: set intr mask after its handler is registered
Date: Thu, 12 Apr 2012 16:10:54 +0800
Message-ID: <20120412081053.25774.41676.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We set intr mask before its handler is registered, this does not work well when
8139cp is sharing irq line with other devices. As the irq could be enabled by
the device before 8139cp's hander is registered which may lead unhandled
irq. Fix this by introducing an helper cp_irq_enable() and call it after
request_irq().

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/ethernet/realtek/8139cp.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index abc7907..b3287c0 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -958,6 +958,11 @@ static inline void cp_start_hw (struct cp_private *cp)
 	cpw8(Cmd, RxOn | TxOn);
 }
 
+static void cp_enable_irq(struct cp_private *cp)
+{
+	cpw16_f(IntrMask, cp_intr_mask);
+}
+
 static void cp_init_hw (struct cp_private *cp)
 {
 	struct net_device *dev = cp->dev;
@@ -997,8 +1002,6 @@ static void cp_init_hw (struct cp_private *cp)
 
 	cpw16(MultiIntr, 0);
 
-	cpw16_f(IntrMask, cp_intr_mask);
-
 	cpw8_f(Cfg9346, Cfg9346_Lock);
 }
 
@@ -1130,6 +1133,8 @@ static int cp_open (struct net_device *dev)
 	if (rc)
 		goto err_out_hw;
 
+	cp_enable_irq(cp);
+
 	netif_carrier_off(dev);
 	mii_check_media(&cp->mii_if, netif_msg_link(cp), true);
 	netif_start_queue(dev);
@@ -2031,6 +2036,7 @@ static int cp_resume (struct pci_dev *pdev)
 	/* FIXME: sh*t may happen if the Rx ring buffer is depleted */
 	cp_init_rings_index (cp);
 	cp_init_hw (cp);
+	cp_enable_irq(cp);
 	netif_start_queue (dev);
 
 	spin_lock_irqsave (&cp->lock, flags);
