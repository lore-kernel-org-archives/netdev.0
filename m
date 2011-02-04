From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] bridge: Don't put partly initialized fdb into hash
Date: Fri, 04 Feb 2011 18:58:08 +0300
Message-ID: <4D4C2210.8010705@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:46903 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104Ab1BDP6Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Feb 2011 10:58:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fdb_create() puts a new fdb into hash with only addr set. This is
not good, since there are callers, that search the hash w/o the lock
and access all the other its fields.

Applies to current netdev tree.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 2872393..88485cc 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -328,12 +328,12 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 	fdb = kmem_cache_alloc(br_fdb_cache, GFP_ATOMIC);
 	if (fdb) {
 		memcpy(fdb->addr.addr, addr, ETH_ALEN);
-		hlist_add_head_rcu(&fdb->hlist, head);
-
 		fdb->dst = source;
 		fdb->is_local = is_local;
 		fdb->is_static = is_local;
 		fdb->ageing_timer = jiffies;
+
+		hlist_add_head_rcu(&fdb->hlist, head);
 	}
 	return fdb;
 }
