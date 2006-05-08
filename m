From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 6/9] sky2: dont write status ring
Date: Mon, 08 May 2006 15:11:31 -0700
Message-ID: <20060508221229.198503000@localhost.localdomain>
References: <20060508221125.177816000@localhost.localdomain>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12221 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751308AbWEHWXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 18:23:53 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k48MNmtH003755
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:50 -0700
Received: from shell0.pdx.osdl.net (localhost [127.0.0.1])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k48MNm2d023562
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:48 -0700
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=sky2-status-ring.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is more efficient not to write the status ring from the
processor and just read the active portion.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c	2006-05-02 09:49:38.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-05-02 09:49:42.000000000 -0700
@@ -1865,35 +1865,28 @@
 static int sky2_status_intr(struct sky2_hw *hw, int to_do)
 {
 	int work_done = 0;
+	u16 hwidx = sky2_read16(hw, STAT_PUT_IDX);
 
 	rmb();
 
-	for(;;) {
+	while (hw->st_idx != hwidx) {
 		struct sky2_status_le *le  = hw->st_le + hw->st_idx;
 		struct net_device *dev;
 		struct sky2_port *sky2;
 		struct sk_buff *skb;
 		u32 status;
 		u16 length;
-		u8  link, opcode;
-
-		opcode = le->opcode;
-		if (!opcode)
-			break;
-		opcode &= ~HW_OWNER;
 
 		hw->st_idx = RING_NEXT(hw->st_idx, STATUS_RING_SIZE);
-		le->opcode = 0;
 
-		link = le->link;
-		BUG_ON(link >= 2);
-		dev = hw->dev[link];
+		BUG_ON(le->link >= 2);
+		dev = hw->dev[le->link];
 
 		sky2 = netdev_priv(dev);
 		length = le->length;
 		status = le->status;
 
-		switch (opcode) {
+		switch (le->opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
 			skb = sky2_receive(sky2, length, status);
 			if (!skb)
@@ -1944,8 +1937,8 @@
 		default:
 			if (net_ratelimit())
 				printk(KERN_WARNING PFX
-				       "unknown status opcode 0x%x\n", opcode);
-			break;
+				       "unknown status opcode 0x%x\n", le->opcode);
+			goto exit_loop;
 		}
 	}
 

--

