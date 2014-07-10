From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v8 2/4] net: set name assign type for renamed devices
Date: Thu, 10 Jul 2014 23:01:04 +0200
Message-ID: <1405026066-2547-3-git-send-email-teg@jklm.no>
References: <1405026066-2547-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:55473 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584AbaGJVBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 17:01:25 -0400
Received: by mail-wg0-f44.google.com with SMTP id m15so145022wgh.27
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 14:01:24 -0700 (PDT)
In-Reply-To: <1405026066-2547-1-git-send-email-teg@jklm.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on a patch from David Herrmann.

This is the only place devices can be renamed.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Reviewed-by: David Herrmann <dh.herrmann@gmail.com>
---
 net/core/dev.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 392c784..5d7b2a6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1083,6 +1083,7 @@ static int dev_get_valid_name(struct net *net,
 int dev_change_name(struct net_device *dev, const char *newname)
 {
 	char oldname[IFNAMSIZ];
+	unsigned char old_assign_type;
 	int err = 0;
 	int ret;
 	struct net *net;
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
