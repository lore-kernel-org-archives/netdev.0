From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [bug?] r8169: hangs under heavy load
Date: Tue, 29 Nov 2011 11:54:40 +0100
Message-ID: <20111129105440.GA2410@electric-eye.fr.zoreil.com>
References: <20111125201936.GA26692@elie.hsd1.il.comcast.net> <1322253122.2550.3.camel@edumazet-laptop> <20111125222211.GA13719@electric-eye.fr.zoreil.com> <1322262357.2550.12.camel@edumazet-laptop> <20111126004447.GA14744@electric-eye.fr.zoreil.com> <1322280423.10212.3.camel@edumazet-laptop> <20111127092808.GE21635@elie.hsd1.il.comcast.net> <4ED2A573.1020807@wolke7.net> <20111127231147.GA1784@electric-eye.fr.zoreil.com> <D95C09DB1A7E493E89FE5A0B3879CEB0@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: booster@wolke7.net, "'Jonathan Nieder'" <jrnieder@gmail.com>,
	"'Eric Dumazet'" <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"'nic_swsd'" <nic_swsd@realtek.com>, linux-kernel@vger.kernel.org,
	"'Armin Kazmi'" <armin.kazmi@tu-dortmund.de>
To: hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <D95C09DB1A7E493E89FE5A0B3879CEB0@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hayeswang <hayeswang@realtek.com> :
[...]
> For the 8168c and the later chips, our hardware engineer says that don't enable
> the RxFIFOOver of IntrMask and don't clear the RxFIFOOver of IntrStatus. The
> hardware will automatically escape Rx fifo full situation. Although you try to
> clear the RxFIFOOver of IntrStatus, maybe the bit wouldn't be cleared. Just
> disregard it.

Should "later" be understood as gigabit PCI-E only or is there a similar
difference of behavior between older fast-ethernet PCI-E and more recent
ones ?

Gerd, can you try the patch below ? It should match Haye's description.

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6f06aa1..97b5593 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4885,8 +4885,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	RTL_W16(IntrMitigate, 0x5151);
 
 	/* Work around for RxFIFO overflow. */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_11 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_22) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
 		tp->intr_event |= RxFIFOOver | PCSTimeout;
 		tp->intr_event &= ~RxOverflow;
 	}
@@ -5804,6 +5803,10 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 	 */
 	status = RTL_R16(IntrStatus);
 	while (status && status != 0xffff) {
+		status &= ~tp->intr_event;
+		if (!status)
+			break;
+
 		handled = 1;
 
 		/* Handle all of the error cases first. These will reset
@@ -5818,7 +5821,6 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			switch (tp->mac_version) {
 			/* Work around for rx fifo overflow */
 			case RTL_GIGA_MAC_VER_11:
-			case RTL_GIGA_MAC_VER_22:
 			case RTL_GIGA_MAC_VER_26:
 				netif_stop_queue(dev);
 				rtl8169_tx_timeout(dev);
@@ -5828,6 +5830,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			case RTL_GIGA_MAC_VER_19:
 			case RTL_GIGA_MAC_VER_20:
 			case RTL_GIGA_MAC_VER_21:
+			case RTL_GIGA_MAC_VER_22:
 			case RTL_GIGA_MAC_VER_23:
 			case RTL_GIGA_MAC_VER_24:
 			case RTL_GIGA_MAC_VER_27:
