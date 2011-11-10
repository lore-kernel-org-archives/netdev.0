From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] bridge: add NTF_USE support
Date: Wed, 9 Nov 2011 20:30:08 -0800
Message-ID: <20111109203008.6bebce8d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46916 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965045Ab1KJEaL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 23:30:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More changes to the recent code to support control of forwarding
database via netlink.
   * Support NTF_USE like neighbour table
   * Validate state bits from application
   * Only send notifications (and change bits) if new entry is
     different.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_fdb.c	2011-11-02 11:14:06.009407558 -0700
+++ b/net/bridge/br_fdb.c	2011-11-07 08:30:00.882705168 -0800
@@ -556,7 +556,7 @@ skip:
 	return skb->len;
 }
 
-/* Create new static fdb entry */
+/* Update (create or replace) forwarding database entry */
 static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 			 __u16 state, __u16 flags)
 {
@@ -575,16 +575,21 @@ static int fdb_add_entry(struct net_brid
 	} else {
 		if (flags & NLM_F_EXCL)
 			return -EEXIST;
+	}
+
+	if (fdb_to_nud(fdb) != state) {
+		if (state & NUD_PERMANENT)
+			fdb->is_local = fdb->is_static = 1;
+		else if (state & NUD_NOARP) {
+			fdb->is_local = 0;
+			fdb->is_static = 1;
+		} else
+			fdb->is_local = fdb->is_static = 0;
 
-		if (flags & NLM_F_REPLACE)
-			fdb->updated = fdb->used = jiffies;
-		fdb->is_local = fdb->is_static = 0;
+		fdb->updated = fdb->used = jiffies;
+		fdb_notify(fdb, RTM_NEWNEIGH);
 	}
 
-	if (state & NUD_PERMANENT)
-		fdb->is_local = fdb->is_static = 1;
-	else if (state & NUD_NOARP)
-		fdb->is_static = 1;
 	return 0;
 }
 
@@ -627,6 +632,11 @@ int br_fdb_add(struct sk_buff *skb, stru
 		return -EINVAL;
 	}
 
+	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE))) {
+		pr_info("bridge: RTM_NEWNEIGH with invalid state %#x\n", ndm->ndm_state);
+		return -EINVAL;
+	}
+
 	p = br_port_get_rtnl(dev);
 	if (p == NULL) {
 		pr_info("bridge: RTM_NEWNEIGH %s not a bridge port\n",
@@ -634,9 +644,15 @@ int br_fdb_add(struct sk_buff *skb, stru
 		return -EINVAL;
 	}
 
-	spin_lock_bh(&p->br->hash_lock);
-	err = fdb_add_entry(p, addr, ndm->ndm_state, nlh->nlmsg_flags);
-	spin_unlock_bh(&p->br->hash_lock);
+	if (ndm->ndm_flags & NTF_USE) {
+		rcu_read_lock();
+		br_fdb_update(p->br, p, addr);
+		rcu_read_unlock();
+	} else {
+		spin_lock_bh(&p->br->hash_lock);
+		err = fdb_add_entry(p, addr, ndm->ndm_state, nlh->nlmsg_flags);
+		spin_unlock_bh(&p->br->hash_lock);
+	}
 
 	return err;
 }
