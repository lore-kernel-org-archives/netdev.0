From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/2] r8169: Rx FIFO overflow fixes.
Date: Mon, 5 Dec 2011 07:30:45 +0100
Message-ID: <20111205063045.GA3103@electric-eye.fr.zoreil.com>
References: <1322280423.10212.3.camel@edumazet-laptop> <20111127092808.GE21635@elie.hsd1.il.comcast.net> <4ED2A573.1020807@wolke7.net> <20111127231147.GA1784@electric-eye.fr.zoreil.com> <D95C09DB1A7E493E89FE5A0B3879CEB0@realtek.com.tw> <20111129105440.GA2410@electric-eye.fr.zoreil.com> <4ED538EC.4010509@wolke7.net> <20111201102000.GA14013@electric-eye.fr.zoreil.com> <4ED7E6AB.6050308@wolke7.net> <20111201222612.GA27998@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang <hayeswang@realtek.com>,
	"'Jonathan Nieder'" <jrnieder@gmail.com>,
	"'Eric Dumazet'" <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"'nic_swsd'" <nic_swsd@realtek.com>, linux-kernel@vger.kernel.org,
	"'Armin Kazmi'" <armin.kazmi@tu-dortmund.de>
To: booster@wolke7.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111201222612.GA27998@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Realtek has specified that the post 8168c gigabit chips and the post
8105e fast ethernet chips recover automatically from a Rx FIFO overflow.
The driver does not need to clear the RxFIFOOver bit of IntrStatus and
it should rather avoid messing it.

The implementation deserves some explanation:
1. events outside of the intr_event bit mask are now ignored. It enforces
   a no-processing policy for the events that either should not be there
   or should be ignored.

2. RxFIFOOver was already ignored in rtl_cfg_infos[RTL_CFG_1] for the
   whole 8168 line of chips with two exceptions:
   - RTL_GIGA_MAC_VER_22 since b5ba6d12bdac21bc0620a5089e0f24e362645efd
     ("use RxFIFO overflow workaround for 8168c chipset.").
     This one should now be correctly handled.
   - RTL_GIGA_MAC_VER_11 (8168b) which requires a different Rx FIFO
     overflow processing.

   Though it does not conform to Realtek suggestion above, the updated
   driver includes no change for RTL_GIGA_MAC_VER_12 and RTL_GIGA_MAC_VER_17.
   Both are 8168b. RTL_GIGA_MAC_VER_12 is common and a bit old so I'd rather
   wait for experimental evidence that the change suggested by Realtek really
   helps or does not hurt in unexpected ways.

   Removed case statements in rtl8169_interrupt are only 8168 relevant.

3. RxFIFOOver is masked for post 8105e 810x chips, namely the sole 8105e
   (RTL_GIGA_MAC_VER_30) itself.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: hayeswang <hayeswang@realtek.com>
---

 Gerd, can you add your Tested-by: to this patch ? Thanks.

 drivers/net/ethernet/realtek/r8169.c |   42 +++++++++++++--------------------
 1 files changed, 17 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6f06aa1..7a1e3a6 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1183,11 +1183,13 @@ static u8 rtl8168d_efuse_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
-static void rtl8169_irq_mask_and_ack(void __iomem *ioaddr)
+static void rtl8169_irq_mask_and_ack(struct rtl8169_private *tp)
 {
-	RTL_W16(IntrMask, 0x0000);
+	void __iomem *ioaddr = tp->mmio_addr;
 
-	RTL_W16(IntrStatus, 0xffff);
+	RTL_W16(IntrMask, 0x0000);
+	RTL_W16(IntrStatus, tp->intr_event);
+	RTL_R8(ChipCmd);
 }
 
 static unsigned int rtl8169_tbi_reset_pending(struct rtl8169_private *tp)
@@ -4339,7 +4341,7 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	void __iomem *ioaddr = tp->mmio_addr;
 
 	/* Disable interrupts */
-	rtl8169_irq_mask_and_ack(ioaddr);
+	rtl8169_irq_mask_and_ack(tp);
 
 	rtl_rx_close(tp);
 
@@ -4885,8 +4887,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	RTL_W16(IntrMitigate, 0x5151);
 
 	/* Work around for RxFIFO overflow. */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_11 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_22) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
 		tp->intr_event |= RxFIFOOver | PCSTimeout;
 		tp->intr_event &= ~RxOverflow;
 	}
@@ -5076,6 +5077,11 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
 
+	if (tp->mac_version >= RTL_GIGA_MAC_VER_30) {
+		tp->intr_event &= ~RxFIFOOver;
+		tp->napi_event &= ~RxFIFOOver;
+	}
+
 	if (tp->mac_version == RTL_GIGA_MAC_VER_13 ||
 	    tp->mac_version == RTL_GIGA_MAC_VER_16) {
 		int cap = pci_pcie_cap(pdev);
@@ -5342,7 +5348,7 @@ static void rtl8169_wait_for_quiescence(struct net_device *dev)
 	/* Wait for any pending NAPI task to complete */
 	napi_disable(&tp->napi);
 
-	rtl8169_irq_mask_and_ack(ioaddr);
+	rtl8169_irq_mask_and_ack(tp);
 
 	tp->intr_mask = 0xffff;
 	RTL_W16(IntrMask, tp->intr_event);
@@ -5804,6 +5810,10 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 	 */
 	status = RTL_R16(IntrStatus);
 	while (status && status != 0xffff) {
+		status &= tp->intr_event;
+		if (!status)
+			break;
+
 		handled = 1;
 
 		/* Handle all of the error cases first. These will reset
@@ -5818,27 +5828,9 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			switch (tp->mac_version) {
 			/* Work around for rx fifo overflow */
 			case RTL_GIGA_MAC_VER_11:
-			case RTL_GIGA_MAC_VER_22:
-			case RTL_GIGA_MAC_VER_26:
 				netif_stop_queue(dev);
 				rtl8169_tx_timeout(dev);
 				goto done;
-			/* Testers needed. */
-			case RTL_GIGA_MAC_VER_17:
-			case RTL_GIGA_MAC_VER_19:
-			case RTL_GIGA_MAC_VER_20:
-			case RTL_GIGA_MAC_VER_21:
-			case RTL_GIGA_MAC_VER_23:
-			case RTL_GIGA_MAC_VER_24:
-			case RTL_GIGA_MAC_VER_27:
-			case RTL_GIGA_MAC_VER_28:
-			case RTL_GIGA_MAC_VER_31:
-			/* Experimental science. Pktgen proof. */
-			case RTL_GIGA_MAC_VER_12:
-			case RTL_GIGA_MAC_VER_25:
-				if (status == RxFIFOOver)
-					goto done;
-				break;
 			default:
 				break;
 			}
-- 
1.7.6.4
