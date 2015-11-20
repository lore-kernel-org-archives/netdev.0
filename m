From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net 1/2] net: ipmr: fix static mfc/dev leaks on table destruction
Date: Fri, 20 Nov 2015 13:54:19 +0100
Message-ID: <1448024060-20466-2-git-send-email-razor@blackwall.org>
References: <1448024060-20466-1-git-send-email-razor@blackwall.org>
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34157 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760140AbbKTM4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 07:56:04 -0500
Received: by wmvv187 with SMTP id v187so70711899wmv.1
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 04:56:03 -0800 (PST)
In-Reply-To: <1448024060-20466-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

When destroying an mrt table the static mfc entries and the static
devices are kept, which leads to devices that can never be destroyed
(because of refcnt taken) and leaked memory, for example:
unreferenced object 0xffff880034c144c0 (size 192):
  comm "mfc-broken", pid 4777, jiffies 4320349055 (age 46001.964s)
  hex dump (first 32 bytes):
    98 53 f0 34 00 88 ff ff 98 53 f0 34 00 88 ff ff  .S.4.....S.4....
    ef 0a 0a 14 01 02 03 04 00 00 00 00 01 00 00 00  ................
  backtrace:
    [<ffffffff815c1b9e>] kmemleak_alloc+0x4e/0xb0
    [<ffffffff811ea6e0>] kmem_cache_alloc+0x190/0x300
    [<ffffffff815931cb>] ip_mroute_setsockopt+0x5cb/0x910
    [<ffffffff8153d575>] do_ip_setsockopt.isra.11+0x105/0xff0
    [<ffffffff8153e490>] ip_setsockopt+0x30/0xa0
    [<ffffffff81564e13>] raw_setsockopt+0x33/0x90
    [<ffffffff814d1e14>] sock_common_setsockopt+0x14/0x20
    [<ffffffff814d0b51>] SyS_setsockopt+0x71/0xc0
    [<ffffffff815cdbf6>] entry_SYSCALL_64_fastpath+0x16/0x7a
    [<ffffffffffffffff>] 0xffffffffffffffff

Make sure that everything is cleaned on netns destruction.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
This doesn't fix a specific commit as the behaviour seems to have been like
that since beginning of use of mroute_clean_tables to cleanup on netns
exit, but the fix can be sent back up to
acbb219d5f53 ("net: ipv4: ipmr_expire_timer causes crash when removing net
namespace")
which started cleaning up on netns destruction.

 net/ipv4/ipmr.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 92dd4b74d513..292123bc30fa 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -134,7 +134,7 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 			      struct mfc_cache *c, struct rtmsg *rtm);
 static void mroute_netlink_event(struct mr_table *mrt, struct mfc_cache *mfc,
 				 int cmd);
-static void mroute_clean_tables(struct mr_table *mrt);
+static void mroute_clean_tables(struct mr_table *mrt, bool all);
 static void ipmr_expire_process(unsigned long arg);
 
 #ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES
@@ -350,7 +350,7 @@ static struct mr_table *ipmr_new_table(struct net *net, u32 id)
 static void ipmr_free_table(struct mr_table *mrt)
 {
 	del_timer_sync(&mrt->ipmr_expire_timer);
-	mroute_clean_tables(mrt);
+	mroute_clean_tables(mrt, true);
 	kfree(mrt);
 }
 
@@ -1208,7 +1208,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
  *	Close the multicast socket, and clear the vif tables etc
  */
 
-static void mroute_clean_tables(struct mr_table *mrt)
+static void mroute_clean_tables(struct mr_table *mrt, bool all)
 {
 	int i;
 	LIST_HEAD(list);
@@ -1217,8 +1217,9 @@ static void mroute_clean_tables(struct mr_table *mrt)
 	/* Shut down all active vif entries */
 
 	for (i = 0; i < mrt->maxvif; i++) {
-		if (!(mrt->vif_table[i].flags & VIFF_STATIC))
-			vif_delete(mrt, i, 0, &list);
+		if (!all && (mrt->vif_table[i].flags & VIFF_STATIC))
+			continue;
+		vif_delete(mrt, i, 0, &list);
 	}
 	unregister_netdevice_many(&list);
 
@@ -1226,7 +1227,7 @@ static void mroute_clean_tables(struct mr_table *mrt)
 
 	for (i = 0; i < MFC_LINES; i++) {
 		list_for_each_entry_safe(c, next, &mrt->mfc_cache_array[i], list) {
-			if (c->mfc_flags & MFC_STATIC)
+			if (!all && (c->mfc_flags & MFC_STATIC))
 				continue;
 			list_del_rcu(&c->list);
 			mroute_netlink_event(mrt, c, RTM_DELROUTE);
@@ -1261,7 +1262,7 @@ static void mrtsock_destruct(struct sock *sk)
 						    NETCONFA_IFINDEX_ALL,
 						    net->ipv4.devconf_all);
 			RCU_INIT_POINTER(mrt->mroute_sk, NULL);
-			mroute_clean_tables(mrt);
+			mroute_clean_tables(mrt, false);
 		}
 	}
 	rtnl_unlock();
-- 
2.4.3
