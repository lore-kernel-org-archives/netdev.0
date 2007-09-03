From: Al Viro <viro@ftp.linux.org.uk>
Subject: [PATCH] fix net_device leak in vlan
Date: Mon, 3 Sep 2007 14:35:20 +0100
Message-ID: <20070903133520.GV21089@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:41809 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792AbXICNfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 09:35:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In "[VLAN]: Move device registation to seperate function" (commit
e89fe42cd03c8fd3686df82d8390a235717a66de), a pile of code got moved
to register_vlan_dev(), including grabbing a reference to underlying
device.  However, original dev_hold() had been left behind, so we
leak a reference to net_device now...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 1583c5e..2a54691 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -562,8 +562,6 @@ static int register_vlan_device(struct net_device *real_dev,
 	if (err < 0)
 		goto out_free_newdev;
 
-	/* Account for reference in struct vlan_dev_info */
-	dev_hold(real_dev);
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "Allocated new device successfully, returning.\n");
 #endif
