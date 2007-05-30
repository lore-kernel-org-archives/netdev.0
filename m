From: Patrick McHardy <kaber@trash.net>
Subject: [8139CP]: Fix VLAN unregistration
Date: Wed, 30 May 2007 09:52:55 +0200
Message-ID: <465D2D57.2080900@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030508060601050705020802"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64244 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667AbXE3Hxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 03:53:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030508060601050705020802
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Fix 8139cp disabling VLAN completely once the first vid is unregistered.
Compile-tested only since I don't own one of these cards.


--------------030508060601050705020802
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[8139CP]: Fix VLAN unregistration

8139cp disables VLAN completely when the first VID is unregistered. It
should instead disable VLAN when the group is unregistered by calling
cp_vlan_rx_register with grp = NULL.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b91a2ac4f5a148bfa9778f2bf0e9a46ed3a4aca9
tree bdf13171526857e7a15fdb31db8b58706a10b34f
parent 62d7f463e185a0b65915110d25d8c4c732e67c0a
author Patrick McHardy <kaber@trash.net> Wed, 30 May 2007 09:49:20 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 30 May 2007 09:49:20 +0200

 drivers/net/8139cp.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index e8c9f27..5cc961e 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -435,21 +435,17 @@ static void cp_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 
 	spin_lock_irqsave(&cp->lock, flags);
 	cp->vlgrp = grp;
-	cp->cpcmd |= RxVlanOn;
+	if (grp)
+		cp->cpcmd |= RxVlanOn;
+	else
+		cp->cpcmd &= ~RxVlanOn;
 	cpw16(CpCmd, cp->cpcmd);
 	spin_unlock_irqrestore(&cp->lock, flags);
 }
 
 static void cp_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
-	struct cp_private *cp = netdev_priv(dev);
-	unsigned long flags;
-
-	spin_lock_irqsave(&cp->lock, flags);
-	cp->cpcmd &= ~RxVlanOn;
-	cpw16(CpCmd, cp->cpcmd);
-	vlan_group_set_device(cp->vlgrp, vid, NULL);
-	spin_unlock_irqrestore(&cp->lock, flags);
+	return;
 }
 #endif /* CP_VLAN_TAG_USED */
 

--------------030508060601050705020802--
