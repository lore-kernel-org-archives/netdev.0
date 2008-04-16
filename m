From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Wed, 16 Apr 2008 13:17:59 -0700
Message-ID: <20080416201759.GB19724@localdomain>
References: <20080415.203108.55491723.davem@davemloft.net>
 <1551EAE59135BE47B544934E30FC4FC002AABC73@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Michael Chan" <mchan@broadcom.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	gregkh@suse.de, linux-kernel@vger.kernel.org
To: tonyb@cybernetics.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751880AbYDPUQi@vger.kernel.org>
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AABC73@nt-irva-0751.brcm.ad.broadcom.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2008 at 08:40:25AM -0700, Michael Chan wrote:
> David Miller wrote:
> 
> > Matt, skb->mac_header is either a pointer or an integer offset
> > depending upon whether we are building 32-bit or 64-bit.
> > 
> > Testing skb->mac_header is therefore wrong, because it's an
> > offset from a pointer in the 64-bit case and therefore it's
> > alignment does not indicate correctly the actual final alignment
> > of skb->head + skb->max_header.
> > 
> > Therefore you should test skb_mac_header(skb) and cast it with
> > (unsigned long).
> 
> Isn't it better to test for skb->data?  That's where we tell
> the hardware to start transmitting.
> 
> > 
> > Please respin this fix with that correction so I can apply it
> > and get this bug fixed, thanks!
> > 
> > 
> 
> We think that this problem is unique in Tony's environment because
> of the PCIE-to-PCI bridge that he is using.  We therefore want to
> test for that bridge and apply the workaround only when it's present.
> We've never seen this problem in the last 6 or 7 years during the
> lifetime of the 5701.
> 
> We'll try to get this done ASAP.
> 
> Thanks.

Tony,

Below is a patch that attempts to limit the workaround to the bridge you
have on your system.  Can you test it and verify that the workaround is
still enabled?


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 96043c5..52a44c6 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
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
@@ -11339,6 +11351,41 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
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
+		while (pci_id->vendor != 0 &&
+		       !(tp->tg3_flags3 & TG3_FLG3_5701_DMA_BUG)) {
+			while (1) {
+				bridge = pci_get_device(pci_id->vendor,
+							pci_id->device,
+							bridge);
+				if (!bridge) {
+					pci_id++;
+					break;
+				}
+				if (bridge->subordinate &&
+				    (bridge->subordinate->number <=
+				     tp->pdev->bus->number) &&
+				    (bridge->subordinate->subordinate >=
+				     tp->pdev->bus->number)) {
+					tp->tg3_flags3 |= TG3_FLG3_5701_DMA_BUG;
+					pci_dev_put(bridge);
+					break;
+				}
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
