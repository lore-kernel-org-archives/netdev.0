From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH] tg3: 5701 DMA corruption fix
Date: Fri, 18 Apr 2008 17:59:52 -0700
Message-ID: <20080419005952.GB8729@localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net, "Tony Battersby" <tonyb@cybernetics.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4697 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbYDSA54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 20:57:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu's commit fb93134dfc2a6e6fbedc7c270a31da03fce88db9, entitled
"[TCP]: Fix size calculation in sk_stream_alloc_pskb", has triggered a
bug in the 5701 where the 5701 DMA engine will corrupt outgoing
packets.  This problem only happens when the starting address of the
packet matches a certain range of offsets and only when the 5701 is
placed downstream of a particular Intel bridge.

This patch detects the problematic bridge and if present, readjusts the
starting address of the packet data to a dword aligned boundary.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 96043c5..bc4c62b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.90"
-#define DRV_MODULE_RELDATE	"April 12, 2008"
+#define DRV_MODULE_VERSION	"3.91"
+#define DRV_MODULE_RELDATE	"April 18, 2008"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -4135,11 +4135,21 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
 				       u32 last_plus_one, u32 *start,
 				       u32 base_flags, u32 mss)
 {
-	struct sk_buff *new_skb = skb_copy(skb, GFP_ATOMIC);
+	struct sk_buff *new_skb;
 	dma_addr_t new_addr = 0;
 	u32 entry = *start;
 	int i, ret = 0;
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701)
+		new_skb = skb_copy(skb, GFP_ATOMIC);
+	else {
+		int more_headroom = 4 - ((unsigned long)skb->data & 3);
+
+		new_skb = skb_copy_expand(skb,
+					  skb_headroom(skb) + more_headroom,
+					  skb_tailroom(skb), GFP_ATOMIC);
+	}
+
 	if (!new_skb) {
 		ret = -1;
 	} else {
@@ -4462,7 +4472,9 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 
 	would_hit_hwbug = 0;
 
-	if (tg3_4g_overflow_test(mapping, len))
+	if (tp->tg3_flags3 & TG3_FLG3_5701_DMA_BUG)
+		would_hit_hwbug = 1;
+	else if (tg3_4g_overflow_test(mapping, len))
 		would_hit_hwbug = 1;
 
 	tg3_set_txd(tp, entry, mapping, len, base_flags,
@@ -11339,6 +11351,38 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		}
 	}
 
+	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)) {
+		static struct tg3_dev_id {
+			u32	vendor;
+			u32	device;
+		} bridge_chipsets[] = {
+			{ PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_PXH_0 },
+			{ PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_PXH_1 },
+			{ },
+		};
+		struct tg3_dev_id *pci_id = &bridge_chipsets[0];
+		struct pci_dev *bridge = NULL;
+
+		while (pci_id->vendor != 0) {
+			bridge = pci_get_device(pci_id->vendor,
+						pci_id->device,
+						bridge);
+			if (!bridge) {
+				pci_id++;
+				continue;
+			}
+			if (bridge->subordinate &&
+			    (bridge->subordinate->number <=
+			     tp->pdev->bus->number) &&
+			    (bridge->subordinate->subordinate >=
+			     tp->pdev->bus->number)) {
+				tp->tg3_flags3 |= TG3_FLG3_5701_DMA_BUG;
+				pci_dev_put(bridge);
+				break;
+			}
+		}
+	}
+
 	/* The EPB bridge inside 5714, 5715, and 5780 cannot support
 	 * DMA addresses > 40-bit. This bridge may have other additional
 	 * 57xx devices behind it in some 4-port NIC designs for example.
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index c1075a7..c688c3a 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2476,6 +2476,7 @@ struct tg3 {
 #define TG3_FLG3_NO_NVRAM_ADDR_TRANS	0x00000001
 #define TG3_FLG3_ENABLE_APE		0x00000002
 #define TG3_FLG3_5761_5784_AX_FIXES	0x00000004
+#define TG3_FLG3_5701_DMA_BUG		0x00000008
 
 	struct timer_list		timer;
 	u16				timer_counter;


