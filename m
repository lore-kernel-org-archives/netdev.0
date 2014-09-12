From: Alexander Fomichev <git.user@gmail.com>
Subject: [PATCH net] net: fix sysfs symlinks of adjacent devices
Date: Fri, 12 Sep 2014 14:13:46 +0400
Message-ID: <1410516826-6926-1-git-send-email-git.user@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Andres Freund <andres@anarazel.de>,
	"Alexander Y. Fomichev" <git.user@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:42197 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600AbaILKOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 06:14:30 -0400
Received: by mail-la0-f46.google.com with SMTP id el20so618830lab.5
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 03:14:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alexander Y. Fomichev" <git.user@gmail.com>

__netdev_adjacent_dev_insert may add adjacent device from another
namespace. Without proper check it leads to emergence of broken
symlink from/to device not existing in current namespace.
Fix: check net_ns is the same before netdev_adjacent_sysfs_add/del
related to: 4c75431ac3520631f1d9e74aa88407e6374dbbc4

Signed-off-by: Alexander Y. Fomichev <git.user@gmail.com>
---
 net/core/dev.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ab9a16530c36..887784b2dcde 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4841,7 +4841,8 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	pr_debug("dev_hold for %s, because of link added from %s to %s\n",
 		 adj_dev->name, dev->name, adj_dev->name);
 
-	if (netdev_adjacent_is_neigh_list(dev, dev_list)) {
+	if (netdev_adjacent_is_neigh_list(dev, dev_list) &&
+	    net_eq(dev_net(dev), dev_net(adj_dev))) {
 		ret = netdev_adjacent_sysfs_add(dev, adj_dev, dev_list);
 		if (ret)
 			goto free_adj;
@@ -4862,7 +4863,8 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 	return 0;
 
 remove_symlinks:
-	if (netdev_adjacent_is_neigh_list(dev, dev_list))
+	if (netdev_adjacent_is_neigh_list(dev, dev_list) &&
+	    net_eq(dev_net(dev), dev_net(adj_dev)))
 		netdev_adjacent_sysfs_del(dev, adj_dev->name, dev_list);
 free_adj:
 	kfree(adj);
-- 
2.1.0
