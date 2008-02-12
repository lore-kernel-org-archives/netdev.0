From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][GENETLINK]: Relax dances with genl_lock.
Date: Tue, 12 Feb 2008 20:16:13 +0300
Message-ID: <47B1D45D.3020409@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39409 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758939AbYBLRQL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 12:16:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The genl_unregister_family() calls the genl_unregister_mc_groups(), 
which takes and releases the genl_lock and then locks and releases
this lock itself.

Relax this behavior, all the more so the genl_unregister_mc_groups() 
is called from genl_unregister_family() only.

I'm not sure, whether this is 2.6.25 material, but the patch looks
pretty simple. Should I hold it till 2.6.26?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 150579a..d16929c 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -230,10 +230,8 @@ static void genl_unregister_mc_groups(struct genl_family *family)
 {
 	struct genl_multicast_group *grp, *tmp;
 
-	genl_lock();
 	list_for_each_entry_safe(grp, tmp, &family->mcast_groups, list)
 		__genl_unregister_mc_group(family, grp);
-	genl_unlock();
 }
 
 /**
@@ -396,10 +394,10 @@ int genl_unregister_family(struct genl_family *family)
 {
 	struct genl_family *rc;
 
-	genl_unregister_mc_groups(family);
-
 	genl_lock();
 
+	genl_unregister_mc_groups(family);
+
 	list_for_each_entry(rc, genl_family_chain(family->id), family_list) {
 		if (family->id != rc->id || strcmp(rc->name, family->name))
 			continue;
