From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/7] bridge: add netlink notification on forward entry changes
Date: Mon, 04 Apr 2011 17:03:30 -0700
Message-ID: <20110405000537.279540732@vyatta.com>
References: <20110405000326.714524584@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42824 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750920Ab1DEAJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 20:09:50 -0400
Content-Disposition: inline; filename=br-fdb-notify.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows applications to query and monitor bridge forwarding
table in the same method used for neighbor table. The forward table
entries are returned in same structure format as used by the ioctl.
If more information is desired in future, the netlink method is
extensible.

Example (using bridge extensions to iproute2)
  # br monitor

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/bridge/br_fdb.c     |  125 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_netlink.c |    1 
 net/bridge/br_private.h |    1 
 3 files changed, 127 insertions(+)

--- a/net/bridge/br_fdb.c	2011-03-21 10:37:11.872443564 -0700
+++ b/net/bridge/br_fdb.c	2011-03-21 13:00:35.370484883 -0700
@@ -28,6 +28,7 @@
 static struct kmem_cache *br_fdb_cache __read_mostly;
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		      const unsigned char *addr);
+static void fdb_notify(const struct net_bridge_fdb_entry *, int);
 
 static u32 fdb_salt __read_mostly;
 
@@ -81,6 +82,7 @@ static void fdb_rcu_free(struct rcu_head
 
 static inline void fdb_delete(struct net_bridge_fdb_entry *f)
 {
+	fdb_notify(f, RTM_DELNEIGH);
 	hlist_del_rcu(&f->hlist);
 	call_rcu(&f->rcu, fdb_rcu_free);
 }
@@ -345,6 +347,7 @@ static struct net_bridge_fdb_entry *fdb_
 		fdb->is_static = 0;
 		fdb->updated = fdb->used = jiffies;
 		hlist_add_head_rcu(&fdb->hlist, head);
+		fdb_notify(fdb, RTM_NEWNEIGH);
 	}
 	return fdb;
 }
@@ -430,3 +433,125 @@ void br_fdb_update(struct net_bridge *br
 		spin_unlock(&br->hash_lock);
 	}
 }
+
+static int fdb_to_nud(const struct net_bridge_fdb_entry *fdb)
+{
+	if (fdb->is_local)
+		return NUD_PERMANENT;
+	else if (fdb->is_static)
+		return NUD_NOARP;
+	else if (has_expired(fdb->dst->br, fdb))
+		return NUD_STALE;
+	else
+		return NUD_REACHABLE;
+}
+
+static int fdb_fill_info(struct sk_buff *skb,
+			 const struct net_bridge_fdb_entry *fdb,
+			 u32 pid, u32 seq, int type, unsigned int flags)
+{
+	unsigned long now = jiffies;
+	struct nda_cacheinfo ci;
+	struct nlmsghdr *nlh;
+	struct ndmsg *ndm;
+
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ndm), flags);
+	if (nlh == NULL)
+		return -EMSGSIZE;
+
+
+	ndm = nlmsg_data(nlh);
+	ndm->ndm_family	 = AF_BRIDGE;
+	ndm->ndm_pad1    = 0;
+	ndm->ndm_pad2    = 0;
+	ndm->ndm_flags	 = 0;
+	ndm->ndm_type	 = 0;
+	ndm->ndm_ifindex = fdb->dst->dev->ifindex;
+	ndm->ndm_state   = fdb_to_nud(fdb);
+
+	NLA_PUT(skb, NDA_LLADDR, ETH_ALEN, &fdb->addr);
+
+	ci.ndm_used	 = jiffies_to_clock_t(now - fdb->used);
+	ci.ndm_confirmed = 0;
+	ci.ndm_updated	 = jiffies_to_clock_t(now - fdb->updated);
+	ci.ndm_refcnt	 = 0;
+	NLA_PUT(skb, NDA_CACHEINFO, sizeof(ci), &ci);
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static inline size_t fdb_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct ndmsg))
+		+ nla_total_size(ETH_ALEN) /* NDA_LLADDR */
+		+ nla_total_size(sizeof(struct nda_cacheinfo));
+}
+
+static void fdb_notify(const struct net_bridge_fdb_entry *fdb, int type)
+{
+	struct net *net = dev_net(fdb->dst->dev);
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(fdb_nlmsg_size(), GFP_ATOMIC);
+	if (skb == NULL)
+		goto errout;
+
+	err = fdb_fill_info(skb, fdb, 0, 0, type, 0);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in fdb_nlmsg_size() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
+	rtnl_notify(skb, net, 0, RTNLGRP_NEIGH, NULL, GFP_ATOMIC);
+	return;
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
+}
+
+/* Dump information about entries, in response to GETNEIGH */
+int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct net_device *dev;
+	int idx = 0;
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
+		struct net_bridge *br = netdev_priv(dev);
+		int i;
+
+		if (!(dev->priv_flags & IFF_EBRIDGE))
+			continue;
+
+		for (i = 0; i < BR_HASH_SIZE; i++) {
+			struct hlist_node *h;
+			struct net_bridge_fdb_entry *f;
+
+			hlist_for_each_entry_rcu(f, h, &br->hash[i], hlist) {
+				if (idx < cb->args[0])
+					goto skip;
+
+				if (fdb_fill_info(skb, f,
+						  NETLINK_CB(cb->skb).pid,
+						  cb->nlh->nlmsg_seq,
+						  RTM_NEWNEIGH,
+						  NLM_F_MULTI) < 0)
+					break;
+skip:
+				++idx;
+			}
+		}
+	}
+	rcu_read_unlock();
+
+	cb->args[0] = idx;
+
+	return skb->len;
+}
--- a/net/bridge/br_private.h	2011-03-21 10:36:16.608199014 -0700
+++ b/net/bridge/br_private.h	2011-03-21 13:00:19.106207704 -0700
@@ -354,6 +354,7 @@ extern int br_fdb_insert(struct net_brid
 extern void br_fdb_update(struct net_bridge *br,
 			  struct net_bridge_port *source,
 			  const unsigned char *addr);
+extern int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb);
 
 /* br_forward.c */
 extern void br_deliver(const struct net_bridge_port *to,
--- a/net/bridge/br_netlink.c	2011-03-21 10:33:38.838610211 -0700
+++ b/net/bridge/br_netlink.c	2011-03-21 13:00:19.090207432 -0700
@@ -196,6 +196,7 @@ int __init br_netlink_init(void)
 
 	/* Only the first call to __rtnl_register can fail */
 	__rtnl_register(PF_BRIDGE, RTM_SETLINK, br_rtm_setlink, NULL);
+	__rtnl_register(PF_BRIDGE, RTM_GETNEIGH, NULL, br_fdb_dump);
 
 	return 0;
 }


