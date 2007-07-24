From: Thomas Graf <tgraf@suug.ch>
Subject: [REPOST][GENETLINK]: Fix race in genl_unregister_mc_groups()
Date: Tue, 24 Jul 2007 23:52:57 +0200
Message-ID: <20070724215257.GG9285@postel.suug.ch>
References: <20070724094557.GE9285@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:32820 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760530AbXGXVwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 17:52:36 -0400
Content-Disposition: inline
In-Reply-To: <20070724094557.GE9285@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

family->mcast_groups is protected by genl_lock so it must
be held while accessing the list in genl_unregister_mc_groups().
Requires adding a non-locking variant of genl_unregister_mc_group().

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/netlink/genetlink.c
===================================================================
--- net-2.6.orig/net/netlink/genetlink.c	2007-07-23 22:08:04.000000000 +0200
+++ net-2.6/net/netlink/genetlink.c	2007-07-24 23:51:11.000000000 +0200
@@ -200,6 +200,18 @@ int genl_register_mc_group(struct genl_f
 }
 EXPORT_SYMBOL(genl_register_mc_group);
 
+static void __genl_unregister_mc_group(struct genl_family *family,
+				       struct genl_multicast_group *grp)
+{
+	BUG_ON(grp->family != family);
+	netlink_clear_multicast_users(genl_sock, grp->id);
+	clear_bit(grp->id, mc_groups);
+	list_del(&grp->list);
+	genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, grp);
+	grp->id = 0;
+	grp->family = NULL;
+}
+
 /**
  * genl_unregister_mc_group - unregister a multicast group
  *
@@ -217,14 +229,8 @@ EXPORT_SYMBOL(genl_register_mc_group);
 void genl_unregister_mc_group(struct genl_family *family,
 			      struct genl_multicast_group *grp)
 {
-	BUG_ON(grp->family != family);
 	genl_lock();
-	netlink_clear_multicast_users(genl_sock, grp->id);
-	clear_bit(grp->id, mc_groups);
-	list_del(&grp->list);
-	genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, grp);
-	grp->id = 0;
-	grp->family = NULL;
+	__genl_unregister_mc_group(family, grp);
 	genl_unlock();
 }
 
@@ -232,8 +238,10 @@ static void genl_unregister_mc_groups(st
 {
 	struct genl_multicast_group *grp, *tmp;
 
+	genl_lock();
 	list_for_each_entry_safe(grp, tmp, &family->mcast_groups, list)
-		genl_unregister_mc_group(family, grp);
+		__genl_unregister_mc_group(family, grp);
+	genl_unlock();
 }
 
 /**
