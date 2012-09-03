From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 6/7] stmmac: add mitigation and sysfs info in the doc
Date: Mon,  3 Sep 2012 09:47:01 +0200
Message-ID: <1346658422-1925-7-git-send-email-peppe.cavallaro@st.com>
References: <1346658422-1925-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:37219 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755537Ab2ICHrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 03:47:32 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id DB8831D5
	for <netdev@vger.kernel.org>; Mon,  3 Sep 2012 07:47:28 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 787A02BA1
	for <netdev@vger.kernel.org>; Mon,  3 Sep 2012 07:47:28 +0000 (GMT)
In-Reply-To: <1346658422-1925-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the stmmac.txt addinf some information
about the new rx/tx mitigation schema and the sysFs support.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt |   34 +++++++++++++++++++++-------------
 1 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index ef9ee71..67eaa35 100644
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
@@ -60,17 +58,21 @@ Then the poll method will be scheduled at some future point.
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
+User can tune (also via sysfs) a parameter that is the RI Watchdog
+Timer count. It indicates the number of system clock cycles.
+
+On Tx-side, the mitigation schema is based on a SW timer that calls the
+tx function (stmmac_tx) to reclaim the resource after transmitting the
+frames.
+Also there is another parameter (like a threshold) used to program
+the descriptors avoiding to set the interrupt on completion bit in
+when the frame is sent (xmit).
+These parameters can be tuned by sysfs entries.
 
 4.4) WOL
 Wake up on Lan feature through Magic and Unicast frames are supported for the
@@ -324,6 +326,12 @@ To enter in Tx LPI mode the driver needs to have a software timer
 that enable and disable the LPI mode when there is nothing to be
 transmitted.
 
+7) sys FS interface
+Some internal driver parameters can be tuned by using some
+entries exposed via sysFS. There parameter currently are,
+for example, for internal timers used to mitigate the rx/tx
+interrupts or for EEE.
+
 7) TODO:
  o XGMAC is not supported.
  o Add the PTP - precision time protocol
-- 
1.7.4.4
