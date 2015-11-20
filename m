From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net 2/2] net: ip6mr: fix static mfc/dev leaks on table destruction
Date: Fri, 20 Nov 2015 13:54:20 +0100
Message-ID: <1448024060-20466-3-git-send-email-razor@blackwall.org>
References: <1448024060-20466-1-git-send-email-razor@blackwall.org>
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34174 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760169AbbKTM4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 07:56:05 -0500
Received: by wmvv187 with SMTP id v187so70712441wmv.1
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 04:56:04 -0800 (PST)
In-Reply-To: <1448024060-20466-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Similar to ipv4, when destroying an mrt table the static mfc entries and
the static devices are kept, which leads to devices that can never be
destroyed (because of refcnt taken) and leaked memory. Make sure that
everything is cleaned up on netns destruction.

Fixes: 8229efdaef1e ("netns: ip6mr: enable namespace support in ipv6 multicast forwarding code")
CC: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/ipv6/ip6mr.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index ad19136086dd..7a4a1b81dbb6 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -118,7 +118,7 @@ static void mr6_netlink_event(struct mr6_table *mrt, struct mfc6_cache *mfc,
 			      int cmd);
 static int ip6mr_rtm_dumproute(struct sk_buff *skb,
 			       struct netlink_callback *cb);
-static void mroute_clean_tables(struct mr6_table *mrt);
+static void mroute_clean_tables(struct mr6_table *mrt, bool all);
 static void ipmr_expire_process(unsigned long arg);
 
 #ifdef CONFIG_IPV6_MROUTE_MULTIPLE_TABLES
@@ -334,7 +334,7 @@ static struct mr6_table *ip6mr_new_table(struct net *net, u32 id)
 static void ip6mr_free_table(struct mr6_table *mrt)
 {
 	del_timer_sync(&mrt->ipmr_expire_timer);
-	mroute_clean_tables(mrt);
+	mroute_clean_tables(mrt, true);
 	kfree(mrt);
 }
 
@@ -1542,7 +1542,7 @@ static int ip6mr_mfc_add(struct net *net, struct mr6_table *mrt,
  *	Close the multicast socket, and clear the vif tables etc
  */
 
-static void mroute_clean_tables(struct mr6_table *mrt)
+static void mroute_clean_tables(struct mr6_table *mrt, bool all)
 {
 	int i;
 	LIST_HEAD(list);
@@ -1552,8 +1552,9 @@ static void mroute_clean_tables(struct mr6_table *mrt)
 	 *	Shut down all active vif entries
 	 */
 	for (i = 0; i < mrt->maxvif; i++) {
-		if (!(mrt->vif6_table[i].flags & VIFF_STATIC))
-			mif6_delete(mrt, i, &list);
+		if (!all && (mrt->vif6_table[i].flags & VIFF_STATIC))
+			continue;
+		mif6_delete(mrt, i, &list);
 	}
 	unregister_netdevice_many(&list);
 
@@ -1562,7 +1563,7 @@ static void mroute_clean_tables(struct mr6_table *mrt)
 	 */
 	for (i = 0; i < MFC6_LINES; i++) {
 		list_for_each_entry_safe(c, next, &mrt->mfc6_cache_array[i], list) {
-			if (c->mfc_flags & MFC_STATIC)
+			if (!all && (c->mfc_flags & MFC_STATIC))
 				continue;
 			write_lock_bh(&mrt_lock);
 			list_del(&c->list);
@@ -1625,7 +1626,7 @@ int ip6mr_sk_done(struct sock *sk)
 						     net->ipv6.devconf_all);
 			write_unlock_bh(&mrt_lock);
 
-			mroute_clean_tables(mrt);
+			mroute_clean_tables(mrt, false);
 			err = 0;
 			break;
 		}
-- 
2.4.3
