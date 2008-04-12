From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NETFILTER]: Fix race between clusterip_config_find_get and
 _entry_put.
Date: Sat, 12 Apr 2008 14:44:18 +0400
Message-ID: <48009282.9040808@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39656 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757524AbYDLKpY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 06:45:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consider we are putting a clusterip_config entry with the "entries"
count == 1, and on the other CPU there's a clusterip_config_find_get
in progress:

CPU1:							CPU2:
clusterip_config_entry_put:				clusterip_config_find_get:
if (atomic_dec_and_test(&c->entries)) { 
	/* true */
							read_lock_bh(&clusterip_lock);
							c = __clusterip_config_find(clusterip);
							/* found - it's still in list */
							...
							atomic_inc(&c->entries);
							read_unlock_bh(&clusterip_lock);

	write_lock_bh(&clusterip_lock);
	list_del(&c->list);
	write_unlock_bh(&clusterip_lock);
	...
	dev_put(c->dev);

Oops! We have an entry returned by the clusterip_config_find_get,
which is a) not in list b) has a stale dev pointer.

The problems will happen when the CPU2 will release the entry - it
will remove it from the list for the 2nd time, thus spoiling it, and
will put a stale dev pointer.

The fix is to make atomic_dec_and_test under the clusterip_lock.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 52926c8..a12dd32 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -82,8 +82,8 @@ clusterip_config_put(struct clusterip_config *c)
 static inline void
 clusterip_config_entry_put(struct clusterip_config *c)
 {
+	write_lock_bh(&clusterip_lock);
 	if (atomic_dec_and_test(&c->entries)) {
-		write_lock_bh(&clusterip_lock);
 		list_del(&c->list);
 		write_unlock_bh(&clusterip_lock);
 
@@ -96,7 +96,9 @@ clusterip_config_entry_put(struct clusterip_config *c)
 #ifdef CONFIG_PROC_FS
 		remove_proc_entry(c->pde->name, c->pde->parent);
 #endif
+		return;
 	}
+	write_unlock_bh(&clusterip_lock);
 }
 
 static struct clusterip_config *
