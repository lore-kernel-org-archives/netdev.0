From: Asaf Vertz <asaf.vertz@tandemg.com>
Subject: [PATCH] cirrus: cs89x0: fix time comparison
Date: Sun, 14 Dec 2014 10:34:18 +0200
Message-ID: <20141214083418.GA25910@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, julia.lawall@lip6.fr, himangi774@gmail.com,
	asaf.vertz@tandemg.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To be future-proof and for better readability the time comparisons are
modified to use time_before, time_after, and time_after_eq instead of
plain, error-prone math.

Signed-off-by: Asaf Vertz <asaf.vertz@tandemg.com>
---
 drivers/net/ethernet/cirrus/cs89x0.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 9823a0e..965331f 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -60,6 +60,7 @@
 #include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/in.h>
+#include <linux/jiffies.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
@@ -238,13 +239,13 @@ writereg(struct net_device *dev, u16 regno, u16 value)
 static int __init
 wait_eeprom_ready(struct net_device *dev)
 {
-	int timeout = jiffies;
+	unsigned long timeout = jiffies;
 	/* check to see if the EEPROM is ready,
 	 * a timeout is used just in case EEPROM is ready when
 	 * SI_BUSY in the PP_SelfST is clear
 	 */
 	while (readreg(dev, PP_SelfST) & SI_BUSY)
-		if (jiffies - timeout >= 40)
+		if (time_after_eq(jiffies, timeout + 40))
 			return -1;
 	return 0;
 }
@@ -485,7 +486,7 @@ control_dc_dc(struct net_device *dev, int on_not_off)
 {
 	struct net_local *lp = netdev_priv(dev);
 	unsigned int selfcontrol;
-	int timenow = jiffies;
+	unsigned long timenow = jiffies;
 	/* control the DC to DC convertor in the SelfControl register.
 	 * Note: This is hooked up to a general purpose pin, might not
 	 * always be a DC to DC convertor.
@@ -499,7 +500,7 @@ control_dc_dc(struct net_device *dev, int on_not_off)
 	writereg(dev, PP_SelfCTL, selfcontrol);
 
 	/* Wait for the DC/DC converter to power up - 500ms */
-	while (jiffies - timenow < HZ)
+	while (time_before(jiffies, timenow + HZ))
 		;
 }
 
@@ -514,7 +515,7 @@ send_test_pkt(struct net_device *dev)
 		0, 0,		/* DSAP=0 & SSAP=0 fields */
 		0xf3, 0		/* Control (Test Req + P bit set) */
 	};
-	long timenow = jiffies;
+	unsigned long timenow = jiffies;
 
 	writereg(dev, PP_LineCTL, readreg(dev, PP_LineCTL) | SERIAL_TX_ON);
 
@@ -525,10 +526,10 @@ send_test_pkt(struct net_device *dev)
 	iowrite16(ETH_ZLEN, lp->virt_addr + TX_LEN_PORT);
 
 	/* Test to see if the chip has allocated memory for the packet */
-	while (jiffies - timenow < 5)
+	while (time_before(jiffies, timenow + 5))
 		if (readreg(dev, PP_BusST) & READY_FOR_TX_NOW)
 			break;
-	if (jiffies - timenow >= 5)
+	if (time_after_eq(jiffies, timenow + 5))
 		return 0;	/* this shouldn't happen */
 
 	/* Write the contents of the packet */
@@ -536,7 +537,7 @@ send_test_pkt(struct net_device *dev)
 
 	cs89_dbg(1, debug, "Sending test packet ");
 	/* wait a couple of jiffies for packet to be received */
-	for (timenow = jiffies; jiffies - timenow < 3;)
+	for (timenow = jiffies; time_before(jiffies, timenow + 3);)
 		;
 	if ((readreg(dev, PP_TxEvent) & TX_SEND_OK_BITS) == TX_OK) {
 		cs89_dbg(1, cont, "succeeded\n");
@@ -556,7 +557,7 @@ static int
 detect_tp(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
-	int timenow = jiffies;
+	unsigned long timenow = jiffies;
 	int fdx;
 
 	cs89_dbg(1, debug, "%s: Attempting TP\n", dev->name);
@@ -574,7 +575,7 @@ detect_tp(struct net_device *dev)
 	/* Delay for the hardware to work out if the TP cable is present
 	 * - 150ms
 	 */
-	for (timenow = jiffies; jiffies - timenow < 15;)
+	for (timenow = jiffies; time_before(jiffies, timenow + 15);)
 		;
 	if ((readreg(dev, PP_LineST) & LINK_OK) == 0)
 		return DETECTED_NONE;
@@ -618,7 +619,7 @@ detect_tp(struct net_device *dev)
 		if ((lp->auto_neg_cnf & AUTO_NEG_BITS) == AUTO_NEG_ENABLE) {
 			pr_info("%s: negotiating duplex...\n", dev->name);
 			while (readreg(dev, PP_AutoNegST) & AUTO_NEG_BUSY) {
-				if (jiffies - timenow > 4000) {
+				if (time_after(jiffies, timenow + 4000)) {
 					pr_err("**** Full / half duplex auto-negotiation timed out ****\n");
 					break;
 				}
@@ -1271,7 +1272,7 @@ static void __init reset_chip(struct net_device *dev)
 {
 #if !defined(CONFIG_MACH_MX31ADS)
 	struct net_local *lp = netdev_priv(dev);
-	int reset_start_time;
+	unsigned long reset_start_time;
 
 	writereg(dev, PP_SelfCTL, readreg(dev, PP_SelfCTL) | POWER_ON_RESET);
 
@@ -1294,7 +1295,7 @@ static void __init reset_chip(struct net_device *dev)
 	/* Wait until the chip is reset */
 	reset_start_time = jiffies;
 	while ((readreg(dev, PP_SelfST) & INIT_DONE) == 0 &&
-	       jiffies - reset_start_time < 2)
+	       time_before(jiffies, reset_start_time + 2))
 		;
 #endif /* !CONFIG_MACH_MX31ADS */
 }
-- 
1.7.0.4
