From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/3] sky2: beter ram buffer partitioning
Date: Mon, 4 Dec 2006 15:53:45 -0800
Message-ID: <20061204155345.0c276a90@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:36486 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937152AbWLDXxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 18:53:52 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Different chips have different sizes of ram buffers, and some versions have
no ram buffer at all!.  Be more careful about sizing the ram usage because
it maybe a problem if vendor keeps changing sizes.

There is the (unlikely) possibility that some of the errors on some of the
chips have been caused by partitioning not on a 1K boundary.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |   41 +++++++++++++++++++++++++----------------
 1 file changed, 25 insertions(+), 16 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2006-12-04 12:47:19.000000000 -0800
+++ sky2/drivers/net/sky2.c	2006-12-04 13:19:49.000000000 -0800
@@ -696,10 +696,15 @@
 
 }
 
-/* Assign Ram Buffer allocation in units of 64bit (8 bytes) */
-static void sky2_ramset(struct sky2_hw *hw, u16 q, u32 start, u32 end)
+/* Assign Ram Buffer allocation to queue */
+static void sky2_ramset(struct sky2_hw *hw, u16 q, u32 start, u32 space)
 {
-	pr_debug(PFX "q %d %#x %#x\n", q, start, end);
+	u32 end;
+
+	/* convert from K bytes to qwords used for hw register */
+	start *= 1024/8;
+	space *= 1024/8;
+	end = start + space - 1;
 
 	sky2_write8(hw, RB_ADDR(q, RB_CTRL), RB_RST_CLR);
 	sky2_write32(hw, RB_ADDR(q, RB_START), start);
@@ -708,7 +713,6 @@
 	sky2_write32(hw, RB_ADDR(q, RB_RP), start);
 
 	if (q == Q_R1 || q == Q_R2) {
-		u32 space = end - start + 1;
 		u32 tp = space - space/4;
 
 		/* On receive queue's set the thresholds
@@ -1138,7 +1142,7 @@
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	u32 ramsize, rxspace, imask;
+	u32 ramsize, imask;
 	int cap, err = -ENOMEM;
 	struct net_device *otherdev = hw->dev[sky2->port^1];
 
@@ -1191,20 +1195,25 @@
 
 	sky2_mac_init(hw, port);
 
-	/* Determine available ram buffer space in qwords.  */
-	ramsize = sky2_read8(hw, B2_E_0) * 4096/8;
+	/* Register is number of 4K blocks on internal RAM buffer. */
+	ramsize = sky2_read8(hw, B2_E_0) * 4;
+	printk(KERN_INFO PFX "%s: ram buffer %dK\n", dev->name, ramsize);
 
-	if (ramsize > 6*1024/8)
-		rxspace = ramsize - (ramsize + 2) / 3;
-	else
-		rxspace = ramsize / 2;
+	if (ramsize > 0) {
+		u32 rxspace;
 
-	sky2_ramset(hw, rxqaddr[port], 0, rxspace-1);
-	sky2_ramset(hw, txqaddr[port], rxspace, ramsize-1);
+		if (ramsize < 16)
+			rxspace = ramsize / 2;
+		else
+			rxspace = 8 + (2*(ramsize - 16))/3;
 
-	/* Make sure SyncQ is disabled */
-	sky2_write8(hw, RB_ADDR(port == 0 ? Q_XS1 : Q_XS2, RB_CTRL),
-		    RB_RST_SET);
+		sky2_ramset(hw, rxqaddr[port], 0, rxspace);
+		sky2_ramset(hw, txqaddr[port], rxspace, ramsize - rxspace);
+
+		/* Make sure SyncQ is disabled */
+		sky2_write8(hw, RB_ADDR(port == 0 ? Q_XS1 : Q_XS2, RB_CTRL),
+			    RB_RST_SET);
+	}
 
 	sky2_qset(hw, txqaddr[port]);
 


-- 
Stephen Hemminger <shemminger@osdl.org>
