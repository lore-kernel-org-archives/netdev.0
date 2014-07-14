From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v9 2/4] net: set name assign type for renamed devices
Date: Mon, 14 Jul 2014 16:37:23 +0200
Message-ID: <1405348645-1995-2-git-send-email-teg@jklm.no>
References: <1405348645-1995-1-git-send-email-teg@jklm.no>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:46000 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157AbaGNOhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 10:37:45 -0400
Received: by mail-wg0-f42.google.com with SMTP id l18so4153252wgh.1
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 07:37:44 -0700 (PDT)
In-Reply-To: <1405348645-1995-1-git-send-email-teg@jklm.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on a patch from David Herrmann.

This is the only place devices can be renamed.

v9: restore revers-christmas-tree order of local variables

Signed-off-by: Tom Gundersen <teg@jklm.no>
Reviewed-by: David Herrmann <dh.herrmann@gmail.com>
---
 net/core/dev.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 30eedf6..80ae059 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1082,6 +1082,7 @@ static int dev_get_valid_name(struct net *net,
  */
 int dev_change_name(struct net_device *dev, const char *newname)
 {
+	unsigned char old_assign_type;
 	char oldname[IFNAMSIZ];
 	int err = 0;
 	int ret;
@@ -1109,10 +1110,14 @@ int dev_change_name(struct net_device *dev, const char *newname)
 		return err;
 	}
 
+	old_assign_type = dev->name_assign_type;
+	dev->name_assign_type = NET_NAME_RENAMED;
+
 rollback:
 	ret = device_rename(&dev->dev, dev->name);
 	if (ret) {
 		memcpy(dev->name, oldname, IFNAMSIZ);
+		dev->name_assign_type = old_assign_type;
 		write_seqcount_end(&devnet_rename_seq);
 		return ret;
 	}
@@ -1141,6 +1146,8 @@ rollback:
 			write_seqcount_begin(&devnet_rename_seq);
 			memcpy(dev->name, oldname, IFNAMSIZ);
 			memcpy(oldname, newname, IFNAMSIZ);
+			dev->name_assign_type = old_assign_type;
+			old_assign_type = NET_NAME_RENAMED;
 			goto rollback;
 		} else {
 			pr_err("%s: name change rollback failed: %d\n",
-- 
1.9.3
