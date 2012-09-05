From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 6/7] stmmac: update the doc with new IRQ mitigation
Date: Wed,  5 Sep 2012 17:03:51 +0200
Message-ID: <1346857432-24657-7-git-send-email-peppe.cavallaro@st.com>
References: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:45663 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752249Ab2IEPE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 11:04:27 -0400
In-Reply-To: <1346857432-24657-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the stmmac.txt adding some information
about the new rx/tx mitigation schema adopted in the driver.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt |   28 +++++++++++++++-------------
 1 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index ef9ee71..f9fa6db 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -29,11 +29,9 @@ The kernel configuration option is STMMAC_ETH:
 	dma_txsize: DMA tx ring size;
 	buf_sz: DMA buffer size;
 	tc: control the HW FIFO threshold;
-	tx_coe: Enable/Disable Tx Checksum Offload engine;
 	watchdog: transmit timeout (in milliseconds);
 	flow_ctrl: Flow control ability [on/off];
 	pause: Flow Control Pause Time;
-	tmrate: timer period (only if timer optimisation is configured).
 
 3) Command line options
 Driver parameters can be also passed in command line by using:
@@ -60,17 +58,19 @@ Then the poll method will be scheduled at some future point.
 The incoming packets are stored, by the DMA, in a list of pre-allocated socket
 buffers in order to avoid the memcpy (Zero-copy).
 
-4.3) Timer-Driver Interrupt
-Instead of having the device that asynchronously notifies the frame receptions,
-the driver configures a timer to generate an interrupt at regular intervals.
-Based on the granularity of the timer, the frames that are received by the
-device will experience different levels of latency. Some NICs have dedicated
-timer device to perform this task. STMMAC can use either the RTC device or the
-TMU channel 2  on STLinux platforms.
-The timers frequency can be passed to the driver as parameter; when change it,
-take care of both hardware capability and network stability/performance impact.
-Several performance tests on STM platforms showed this optimisation allows to
-spare the CPU while having the maximum throughput.
+4.3) Interrupt Mitigation
+The driver is able to mitigate the number of its DMA interrupts
+using NAPI for the reception on chips older than the 3.50.
+New chips have an HW RX-Watchdog used for this mitigation.
+
+On Tx-side, the mitigation schema is based on a SW timer that calls the
+tx function (stmmac_tx) to reclaim the resource after transmitting the
+frames.
+Also there is another parameter (like a threshold) used to program
+the descriptors avoiding to set the interrupt on completion bit in
+when the frame is sent (xmit).
+
+Mitigation parameters can be tuned by ethtool.
 
 4.4) WOL
 Wake up on Lan feature through Magic and Unicast frames are supported for the
@@ -121,6 +121,7 @@ struct plat_stmmacenet_data {
 	int bugged_jumbo;
 	int pmt;
 	int force_sf_dma_mode;
+	int riwt_off;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
 	int (*init)(struct platform_device *pdev);
@@ -156,6 +157,7 @@ Where:
  o pmt: core has the embedded power module (optional).
  o force_sf_dma_mode: force DMA to use the Store and Forward mode
 		     instead of the Threshold.
+ o riwt_off: force to disable the RX watchdog feature and switch to NAPI mode.
  o fix_mac_speed: this callback is used for modifying some syscfg registers
 		 (on ST SoCs) according to the link speed negotiated by the
 		 physical layer .
-- 
1.7.4.4
