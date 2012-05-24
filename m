From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 11/21] datapath,
	vport: Provide tunnel realdev and tundev classes and vports
Date: Thu, 24 May 2012 18:09:04 +0900
Message-ID: <1337850554-10339-12-git-send-email-horms@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1337850554-10339-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On the user-space side of things, the existing tunnel classes become tunnel
realdev classes and new classes are added to provide tunnel tundevs.

On the datpath side of things, the existing tunnel vports are used as
tundev vports. A new vport is added for tunnel realdevs.

It should be possible to remove realdevs entirely from the datapath,
however that requries teaching the user-space netdev to exclude them from
kernel-related opperations. I have avoided that at this time in order to
allow review of other aspects of the approach taken in my flow-bassed
tunneling prototype.

Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

--

v4
* Tunnel tundevs should have a NULL set_config callback as their
  parse_config call back is NULL. Otherwise, reconfiguration will fail and
  ovs-vwitchd will exit if started with tundevs already configured.
* Remove unparse_tunnel_config, it is not used

v3
* Initial Post

remove unparse_tunnel_config
---
 datapath/Modules.mk             |   3 +-
 datapath/tunnel.c               | 158 +------------------
 datapath/vport-capwap.c         |   2 -
 datapath/vport-gre.c            |   2 -
 datapath/vport-tunnel-realdev.c | 260 +++++++++++++++++++++++++++++++
 datapath/vport.c                |   1 +
 datapath/vport.h                |   1 +
 include/linux/openvswitch.h     |   1 +
 include/openvswitch/tunnel.h    |   2 +
 lib/netdev-vport.c              | 333 +++++++++-------------------------------
 10 files changed, 343 insertions(+), 420 deletions(-)
 create mode 100644 datapath/vport-tunnel-realdev.c

diff --git a/datapath/Modules.mk b/datapath/Modules.mk
index 24c1075..9aed4c3 100644
--- a/datapath/Modules.mk
+++ b/datapath/Modules.mk
@@ -26,7 +26,8 @@ openvswitch_sources = \
 	vport-gre.c \
 	vport-internal_dev.c \
 	vport-netdev.c \
-	vport-patch.c
+	vport-patch.c \
+	vport-tunnel-realdev.c
 
 openvswitch_headers = \
 	checksum.h \
diff --git a/datapath/tunnel.c b/datapath/tunnel.c
index 61add96..f07ec69 100644
--- a/datapath/tunnel.c
+++ b/datapath/tunnel.c
@@ -250,21 +250,6 @@ static void port_table_add_port(struct vport *vport)
 	(*find_port_pool(rtnl_dereference(tnl_vport->mutable)))++;
 }
 
-static void port_table_move_port(struct vport *vport,
-		      struct tnl_mutable_config *new_mutable)
-{
-	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
-	u32 hash;
-
-	hash = port_hash(&new_mutable->key);
-	hlist_del_init_rcu(&tnl_vport->hash_node);
-	hlist_add_head_rcu(&tnl_vport->hash_node, find_bucket(hash));
-
-	(*find_port_pool(rtnl_dereference(tnl_vport->mutable)))--;
-	assign_config_rcu(vport, new_mutable);
-	(*find_port_pool(rtnl_dereference(tnl_vport->mutable)))++;
-}
-
 static void port_table_remove_port(struct vport *vport)
 {
 	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
@@ -1381,71 +1366,20 @@ out:
 	return sent_len;
 }
 
-static const struct nla_policy tnl_policy[OVS_TUNNEL_ATTR_MAX + 1] = {
-	[OVS_TUNNEL_ATTR_FLAGS]    = { .type = NLA_U32 },
-	[OVS_TUNNEL_ATTR_DST_IPV4] = { .type = NLA_U32 },
-	[OVS_TUNNEL_ATTR_SRC_IPV4] = { .type = NLA_U32 },
-	[OVS_TUNNEL_ATTR_OUT_KEY]  = { .type = NLA_U64 },
-	[OVS_TUNNEL_ATTR_IN_KEY]   = { .type = NLA_U64 },
-	[OVS_TUNNEL_ATTR_TOS]      = { .type = NLA_U8 },
-	[OVS_TUNNEL_ATTR_TTL]      = { .type = NLA_U8 },
-};
-
 /* Sets OVS_TUNNEL_ATTR_* fields in 'mutable', which must initially be
  * zeroed. */
-static int tnl_set_config(struct net *net, struct nlattr *options,
+static int tnl_set_config(struct net *net,
 			  const struct tnl_ops *tnl_ops,
 			  const struct vport *cur_vport,
 			  struct tnl_mutable_config *mutable)
 {
 	const struct vport *old_vport;
 	const struct tnl_mutable_config *old_mutable;
-	struct nlattr *a[OVS_TUNNEL_ATTR_MAX + 1];
-	int err;
-
-	if (!options)
-		return -EINVAL;
-
-	err = nla_parse_nested(a, OVS_TUNNEL_ATTR_MAX, options, tnl_policy);
-	if (err)
-		return err;
-
-	if (!a[OVS_TUNNEL_ATTR_FLAGS] || !a[OVS_TUNNEL_ATTR_DST_IPV4])
-		return -EINVAL;
-
-	mutable->flags = nla_get_u32(a[OVS_TUNNEL_ATTR_FLAGS]) & TNL_F_PUBLIC;
 
+	mutable->flags = 0;
 	port_key_set_net(&mutable->key, net);
-	mutable->key.daddr = nla_get_be32(a[OVS_TUNNEL_ATTR_DST_IPV4]);
-	if (a[OVS_TUNNEL_ATTR_SRC_IPV4]) {
-		if (ipv4_is_multicast(mutable->key.daddr))
-			return -EINVAL;
-		mutable->key.saddr = nla_get_be32(a[OVS_TUNNEL_ATTR_SRC_IPV4]);
-	}
-
-	if (a[OVS_TUNNEL_ATTR_TOS]) {
-		mutable->tos = nla_get_u8(a[OVS_TUNNEL_ATTR_TOS]);
-		/* Reject ToS config with ECN bits set. */
-		if (mutable->tos & INET_ECN_MASK)
-			return -EINVAL;
-	}
-
-	if (a[OVS_TUNNEL_ATTR_TTL])
-		mutable->ttl = nla_get_u8(a[OVS_TUNNEL_ATTR_TTL]);
-
+	mutable->key.daddr = htonl(0);
 	mutable->key.tunnel_type = tnl_ops->tunnel_type;
-	if (!a[OVS_TUNNEL_ATTR_IN_KEY]) {
-		mutable->key.tunnel_type |= TNL_T_KEY_MATCH;
-		mutable->flags |= TNL_F_IN_KEY_MATCH;
-	} else {
-		mutable->key.tunnel_type |= TNL_T_KEY_EXACT;
-		mutable->key.in_key = nla_get_be64(a[OVS_TUNNEL_ATTR_IN_KEY]);
-	}
-
-	if (!a[OVS_TUNNEL_ATTR_OUT_KEY])
-		mutable->flags |= TNL_F_OUT_KEY_ACTION;
-	else
-		mutable->out_key = nla_get_be64(a[OVS_TUNNEL_ATTR_OUT_KEY]);
 
 	mutable->tunnel_hlen = tnl_ops->hdr_len(mutable);
 	if (mutable->tunnel_hlen < 0)
@@ -1458,21 +1392,6 @@ static int tnl_set_config(struct net *net, struct nlattr *options,
 		return -EEXIST;
 
 	mutable->mlink = 0;
-	if (ipv4_is_multicast(mutable->key.daddr)) {
-		struct net_device *dev;
-		struct rtable *rt;
-
-		rt = __find_route(mutable, tnl_ops->ipproto, mutable->tos,
-				  mutable->key.daddr, mutable->key.saddr);
-		if (IS_ERR(rt))
-			return -EADDRNOTAVAIL;
-		dev = rt_dst(rt).dev;
-		ip_rt_put(rt);
-		if (__in_dev_get_rtnl(dev) == NULL)
-			return -EADDRNOTAVAIL;
-		mutable->mlink = dev->ifindex;
-		ip_mc_inc_group(__in_dev_get_rtnl(dev), mutable->key.daddr);
-	}
 
 	return 0;
 }
@@ -1509,8 +1428,7 @@ struct vport *ovs_tnl_create(const struct vport_parms *parms,
 	get_random_bytes(&initial_frag_id, sizeof(int));
 	atomic_set(&tnl_vport->frag_id, initial_frag_id);
 
-	err = tnl_set_config(ovs_dp_get_net(parms->dp), parms->options, tnl_ops,
-			     NULL, mutable);
+	err = tnl_set_config(ovs_dp_get_net(parms->dp), tnl_ops, NULL, mutable);
 	if (err)
 		goto error_free_mutable;
 
@@ -1535,74 +1453,6 @@ error:
 	return ERR_PTR(err);
 }
 
-int ovs_tnl_set_options(struct vport *vport, struct nlattr *options)
-{
-	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
-	const struct tnl_mutable_config *old_mutable;
-	struct tnl_mutable_config *mutable;
-	int err;
-
-	mutable = kzalloc(sizeof(struct tnl_mutable_config), GFP_KERNEL);
-	if (!mutable) {
-		err = -ENOMEM;
-		goto error;
-	}
-
-	/* Copy fields whose values should be retained. */
-	old_mutable = rtnl_dereference(tnl_vport->mutable);
-	mutable->seq = old_mutable->seq + 1;
-	memcpy(mutable->eth_addr, old_mutable->eth_addr, ETH_ALEN);
-
-	/* Parse the others configured by userspace. */
-	err = tnl_set_config(ovs_dp_get_net(vport->dp), options, tnl_vport->tnl_ops,
-			     vport, mutable);
-	if (err)
-		goto error_free;
-
-	if (port_hash(&mutable->key) != port_hash(&old_mutable->key))
-		port_table_move_port(vport, mutable);
-	else
-		assign_config_rcu(vport, mutable);
-
-	return 0;
-
-error_free:
-	free_mutable_rtnl(mutable);
-	kfree(mutable);
-error:
-	return err;
-}
-
-int ovs_tnl_get_options(const struct vport *vport, struct sk_buff *skb)
-{
-	const struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
-	const struct tnl_mutable_config *mutable = rcu_dereference_rtnl(tnl_vport->mutable);
-
-	if (nla_put_u32(skb, OVS_TUNNEL_ATTR_FLAGS,
-		      mutable->flags & TNL_F_PUBLIC) ||
-	    nla_put_be32(skb, OVS_TUNNEL_ATTR_DST_IPV4, mutable->key.daddr))
-		goto nla_put_failure;
-
-	if (!(mutable->flags & TNL_F_IN_KEY_MATCH) &&
-	    nla_put_be64(skb, OVS_TUNNEL_ATTR_IN_KEY, mutable->key.in_key))
-		goto nla_put_failure;
-	if (!(mutable->flags & TNL_F_OUT_KEY_ACTION) &&
-	    nla_put_be64(skb, OVS_TUNNEL_ATTR_OUT_KEY, mutable->out_key))
-		goto nla_put_failure;
-	if (mutable->key.saddr &&
-	    nla_put_be32(skb, OVS_TUNNEL_ATTR_SRC_IPV4, mutable->key.saddr))
-		goto nla_put_failure;
-	if (mutable->tos && nla_put_u8(skb, OVS_TUNNEL_ATTR_TOS, mutable->tos))
-		goto nla_put_failure;
-	if (mutable->ttl && nla_put_u8(skb, OVS_TUNNEL_ATTR_TTL, mutable->ttl))
-		goto nla_put_failure;
-
-	return 0;
-
-nla_put_failure:
-	return -EMSGSIZE;
-}
-
 static void free_port_rcu(struct rcu_head *rcu)
 {
 	struct tnl_vport *tnl_vport = container_of(rcu,
diff --git a/datapath/vport-capwap.c b/datapath/vport-capwap.c
index 1e08d5a..f26a7d2 100644
--- a/datapath/vport-capwap.c
+++ b/datapath/vport-capwap.c
@@ -835,8 +835,6 @@ const struct vport_ops ovs_capwap_vport_ops = {
 	.set_addr	= ovs_tnl_set_addr,
 	.get_name	= ovs_tnl_get_name,
 	.get_addr	= ovs_tnl_get_addr,
-	.get_options	= ovs_tnl_get_options,
-	.set_options	= ovs_tnl_set_options,
 	.get_dev_flags	= ovs_vport_gen_get_dev_flags,
 	.is_running	= ovs_vport_gen_is_running,
 	.get_operstate	= ovs_vport_gen_get_operstate,
diff --git a/datapath/vport-gre.c b/datapath/vport-gre.c
index fd2b038..f610097 100644
--- a/datapath/vport-gre.c
+++ b/datapath/vport-gre.c
@@ -415,8 +415,6 @@ const struct vport_ops ovs_gre_vport_ops = {
 	.set_addr	= ovs_tnl_set_addr,
 	.get_name	= ovs_tnl_get_name,
 	.get_addr	= ovs_tnl_get_addr,
-	.get_options	= ovs_tnl_get_options,
-	.set_options	= ovs_tnl_set_options,
 	.get_dev_flags	= ovs_vport_gen_get_dev_flags,
 	.is_running	= ovs_vport_gen_is_running,
 	.get_operstate	= ovs_vport_gen_get_operstate,
diff --git a/datapath/vport-tunnel-realdev.c b/datapath/vport-tunnel-realdev.c
new file mode 100644
index 0000000..6225f70
--- /dev/null
+++ b/datapath/vport-tunnel-realdev.c
@@ -0,0 +1,260 @@
+/*
+ * Copyright (c) 2012 Horms Solution Ltd.
+ *
+ * Based on vport-patch.c
+ *
+ * Copyright (c) 2007-2012 Nicira, Inc.
+ *
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/jhash.h>
+#include <linux/list.h>
+#include <linux/rtnetlink.h>
+#include <net/net_namespace.h>
+
+#include "compat.h"
+#include "datapath.h"
+#include "vport.h"
+#include "vport-generic.h"
+
+struct realdev_config {
+	struct rcu_head rcu;
+
+	unsigned char eth_addr[ETH_ALEN];
+	__be32 daddr;
+	u32 flags;
+};
+
+struct realdev_vport {
+	struct rcu_head rcu;
+
+	char name[IFNAMSIZ];
+
+	struct realdev_config __rcu *realdevconf;
+};
+
+static struct realdev_vport *realdev_vport_priv(const struct vport *vport)
+{
+	return vport_priv(vport);
+}
+
+/* RCU callback. */
+static void free_config(struct rcu_head *rcu)
+{
+	struct realdev_config *c = container_of(rcu, struct realdev_config, rcu);
+	kfree(c);
+}
+
+static void assign_config_rcu(struct vport *vport,
+			      struct realdev_config *new_config)
+{
+	struct realdev_vport *realdev_vport = realdev_vport_priv(vport);
+	struct realdev_config *old_config;
+
+	old_config = rtnl_dereference(realdev_vport->realdevconf);
+	rcu_assign_pointer(realdev_vport->realdevconf, new_config);
+	call_rcu(&old_config->rcu, free_config);
+}
+
+static int realdev_init(void)
+{
+	return 0;
+}
+
+static void realdev_exit(void)
+{
+}
+
+static const struct nla_policy realdev_policy[OVS_TUNNEL_ATTR_MAX + 1] = {
+	[OVS_TUNNEL_ATTR_FLAGS]    = { .type = NLA_U32 },
+	[OVS_TUNNEL_ATTR_DST_IPV4] = { .type = NLA_U32 },
+};
+
+static int realdev_set_config(struct vport *vport, const struct nlattr *options,
+			    struct realdev_config *realdevconf)
+{
+	struct nlattr *a[OVS_TUNNEL_ATTR_MAX + 1];
+	int err;
+
+	if (!options)
+		return -EINVAL;
+
+	err = nla_parse_nested(a, OVS_TUNNEL_ATTR_MAX, options, realdev_policy);
+	if (err)
+		return err;
+
+	if (!a[OVS_TUNNEL_ATTR_FLAGS] || !a[OVS_TUNNEL_ATTR_DST_IPV4])
+		return -EINVAL;
+
+	realdevconf->flags = nla_get_u32(a[OVS_TUNNEL_ATTR_FLAGS]);
+	realdevconf->daddr = nla_get_u32(a[OVS_TUNNEL_ATTR_DST_IPV4]);
+
+	return 0;
+}
+
+
+static struct vport *realdev_create(const struct vport_parms *parms)
+{
+	struct vport *vport;
+	struct realdev_vport *realdev_vport;
+	struct realdev_config *realdevconf;
+	int err;
+
+	vport = ovs_vport_alloc(sizeof(struct realdev_vport),
+				&ovs_tunnel_realdev_vport_ops, parms);
+	if (IS_ERR(vport)) {
+		err = PTR_ERR(vport);
+		goto error;
+	}
+
+	realdev_vport = realdev_vport_priv(vport);
+
+	strcpy(realdev_vport->name, parms->name);
+
+	realdevconf = kmalloc(sizeof(struct realdev_config), GFP_KERNEL);
+	if (!realdevconf) {
+		err = -ENOMEM;
+		goto error_free_vport;
+	}
+
+	err = realdev_set_config(vport, parms->options, realdevconf);
+	if (err)
+		goto error_free_realdevconf;
+
+	random_ether_addr(realdevconf->eth_addr);
+
+	rcu_assign_pointer(realdev_vport->realdevconf, realdevconf);
+
+	return vport;
+
+error_free_realdevconf:
+	kfree(realdevconf);
+error_free_vport:
+	ovs_vport_free(vport);
+error:
+	return ERR_PTR(err);
+}
+
+static void free_port_rcu(struct rcu_head *rcu)
+{
+	struct realdev_vport *realdev_vport = container_of(rcu,
+					  struct realdev_vport, rcu);
+
+	kfree((struct realdev_config __force *)realdev_vport->realdevconf);
+	ovs_vport_free(vport_from_priv(realdev_vport));
+}
+
+static void realdev_destroy(struct vport *vport)
+{
+	struct realdev_vport *realdev_vport = realdev_vport_priv(vport);
+	call_rcu(&realdev_vport->rcu, free_port_rcu);
+}
+
+static int realdev_set_addr(struct vport *vport, const unsigned char *addr)
+{
+	struct realdev_vport *realdev_vport = realdev_vport_priv(vport);
+	struct realdev_config *realdevconf;
+
+	realdevconf = kmemdup(rtnl_dereference(realdev_vport->realdevconf),
+			  sizeof(struct realdev_config), GFP_KERNEL);
+	if (!realdevconf)
+		return -ENOMEM;
+
+	memcpy(realdevconf->eth_addr, addr, ETH_ALEN);
+	assign_config_rcu(vport, realdevconf);
+
+	return 0;
+}
+
+static int realdev_set_options(struct vport *vport, struct nlattr *options)
+{
+	struct realdev_vport *realdev_vport = realdev_vport_priv(vport);
+	struct realdev_config *realdevconf;
+	int err;
+
+	realdevconf = kmemdup(rtnl_dereference(realdev_vport->realdevconf),
+			  sizeof(struct realdev_config), GFP_KERNEL);
+	if (!realdevconf) {
+		err = -ENOMEM;
+		goto error;
+	}
+
+	err = realdev_set_config(vport, options, realdevconf);
+	if (err)
+		goto error_free;
+
+	assign_config_rcu(vport, realdevconf);
+
+	return 0;
+error_free:
+	kfree(realdevconf);
+error:
+	return err;
+}
+
+static const char *realdev_get_name(const struct vport *vport)
+{
+	const struct realdev_vport *realdev_vport = realdev_vport_priv(vport);
+	return realdev_vport->name;
+}
+
+static const unsigned char *realdev_get_addr(const struct vport *vport)
+{
+	const struct realdev_vport *realdev_vport = realdev_vport_priv(vport);
+	return rcu_dereference_rtnl(realdev_vport->realdevconf)->eth_addr;
+}
+
+static int realdev_get_options(const struct vport *vport, struct sk_buff *skb)
+{
+	struct realdev_vport *realdev_vport = realdev_vport_priv(vport);
+	struct realdev_config *realdevconf =
+		rcu_dereference_rtnl(realdev_vport->realdevconf);
+	int err;
+
+	err = nla_put_u32(skb, OVS_TUNNEL_ATTR_FLAGS, realdevconf->flags);
+	if (err)
+		goto error;
+
+	err = nla_put_u32(skb, OVS_TUNNEL_ATTR_DST_IPV4, realdevconf->daddr);
+error:
+	return err;
+}
+
+static int realdev_send(struct vport *vport, struct sk_buff *skb)
+{
+	kfree_skb(skb);
+	ovs_vport_record_error(vport, VPORT_E_TX_DROPPED);
+	return 0;
+}
+
+const struct vport_ops ovs_tunnel_realdev_vport_ops = {
+	.type		= OVS_VPORT_TYPE_TUNNEL_REALDEV,
+	.init		= realdev_init,
+	.exit		= realdev_exit,
+	.create		= realdev_create,
+	.destroy	= realdev_destroy,
+	.set_addr	= realdev_set_addr,
+	.get_name	= realdev_get_name,
+	.get_addr	= realdev_get_addr,
+	.get_options	= realdev_get_options,
+	.set_options	= realdev_set_options,
+	.get_dev_flags	= ovs_vport_gen_get_dev_flags,
+	.is_running	= ovs_vport_gen_is_running,
+	.get_operstate	= ovs_vport_gen_get_operstate,
+	.send		= realdev_send,
+};
diff --git a/datapath/vport.c b/datapath/vport.c
index 0c77a1b..7759e07 100644
--- a/datapath/vport.c
+++ b/datapath/vport.c
@@ -44,6 +44,7 @@ static const struct vport_ops *base_vport_ops_list[] = {
 #if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,26)
 	&ovs_capwap_vport_ops,
 #endif
+	&ovs_tunnel_realdev_vport_ops,
 };
 
 static const struct vport_ops **vport_ops_list;
diff --git a/datapath/vport.h b/datapath/vport.h
index b0cdeae..893daaf 100644
--- a/datapath/vport.h
+++ b/datapath/vport.h
@@ -257,5 +257,6 @@ extern const struct vport_ops ovs_internal_vport_ops;
 extern const struct vport_ops ovs_patch_vport_ops;
 extern const struct vport_ops ovs_gre_vport_ops;
 extern const struct vport_ops ovs_capwap_vport_ops;
+extern const struct vport_ops ovs_tunnel_realdev_vport_ops;
 
 #endif /* vport.h */
diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index c32bb58..87a3e22 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -185,6 +185,7 @@ enum ovs_vport_type {
 	OVS_VPORT_TYPE_PATCH = 100, /* virtual tunnel connecting two vports */
 	OVS_VPORT_TYPE_GRE,      /* GRE tunnel */
 	OVS_VPORT_TYPE_CAPWAP,   /* CAPWAP tunnel */
+	OVS_VPORT_TYPE_TUNNEL_REALDEV,  /* real tunnel device */
 	__OVS_VPORT_TYPE_MAX
 };
 
diff --git a/include/openvswitch/tunnel.h b/include/openvswitch/tunnel.h
index 5f55ecc..078a940 100644
--- a/include/openvswitch/tunnel.h
+++ b/include/openvswitch/tunnel.h
@@ -74,4 +74,6 @@ enum {
 #define TNL_F_IN_KEY	(1 << 8) /* Tunnel port has input key. */
 #define TNL_F_OUT_KEY	(1 << 9) /* Tunnel port has output key. */
 
+#define TNL_F_CAPWAP    (1 << 10)
+
 #endif /* openvswitch/tunnel.h */
diff --git a/lib/netdev-vport.c b/lib/netdev-vport.c
index a9eb3eb..7a9803b 100644
--- a/lib/netdev-vport.c
+++ b/lib/netdev-vport.c
@@ -155,15 +155,24 @@ netdev_vport_get_netdev_type(const struct dpif_linux_vport *vport)
         return "patch";
 
     case OVS_VPORT_TYPE_GRE:
-        if (tnl_port_config_from_nlattr(vport->options, vport->options_len,
-                                        a)) {
-            break;
-        }
-        return (nl_attr_get_u32(a[OVS_TUNNEL_ATTR_FLAGS]) & TNL_F_IPSEC
-                ? "ipsec_gre" : "gre");
+        return "gre-tundev";
 
     case OVS_VPORT_TYPE_CAPWAP:
-        return "capwap";
+        return "capwap-tundev";
+
+    case OVS_VPORT_TYPE_TUNNEL_REALDEV:
+        if (tnl_port_config_from_nlattr(vport->options,
+                                        vport->options_len, a)) {
+                return "no-config";
+        }
+
+        if (nl_attr_get_u32(a[OVS_TUNNEL_ATTR_FLAGS]) & TNL_F_CAPWAP) {
+            return "capwap";
+        } else if (nl_attr_get_u32(a[OVS_TUNNEL_ATTR_FLAGS]) & TNL_F_IPSEC) {
+            return "ipsec_gre";
+        } else {
+            return "gre";
+        }
 
     case __OVS_VPORT_TYPE_MAX:
         break;
@@ -248,6 +257,10 @@ netdev_vport_get_config(struct netdev_dev *dev_, struct shash *args)
         ofpbuf_delete(buf);
     }
 
+    if (!vport_class->unparse_config) {
+        return 0;
+    }
+
     error = vport_class->unparse_config(name, netdev_class->type,
                                         dev->options->data,
                                         dev->options->size,
@@ -267,11 +280,13 @@ netdev_vport_set_config(struct netdev_dev *dev_, const struct shash *args)
     struct netdev_dev_vport *dev = netdev_dev_vport_cast(dev_);
     const char *name = netdev_dev_get_name(dev_);
     struct ofpbuf *options;
-    int error;
+    int error = 0;
 
     options = ofpbuf_new(64);
-    error = vport_class->parse_config(name, netdev_dev_get_type(dev_),
-                                      args, options);
+    if (vport_class->parse_config) {
+        error = vport_class->parse_config(name, netdev_dev_get_type(dev_),
+                                          args, options);
+    }
     if (!error
         && (!dev->options
             || options->size != dev->options->size
@@ -550,47 +565,18 @@ netdev_vport_poll_notify(const struct netdev *netdev)
 
 /* Code specific to individual vport types. */
 
-static void
-set_key(const struct shash *args, const char *name, uint16_t type,
-        struct ofpbuf *options)
-{
-    const char *s;
-
-    s = shash_find_data(args, name);
-    if (!s) {
-        s = shash_find_data(args, "key");
-        if (!s) {
-            s = "0";
-        }
-    }
-
-    if (!strcmp(s, "flow")) {
-        /* This is the default if no attribute is present. */
-    } else {
-        nl_msg_put_be64(options, type, htonll(strtoull(s, NULL, 0)));
-    }
-}
-
 static int
 parse_tunnel_config(const char *name, const char *type,
                     const struct shash *args, struct ofpbuf *options)
 {
-    bool is_gre = false;
-    bool is_ipsec = false;
-    struct shash_node *node;
-    bool ipsec_mech_set = false;
     ovs_be32 daddr = htonl(0);
-    ovs_be32 saddr = htonl(0);
-    uint32_t flags;
-
-    flags = TNL_F_DF_DEFAULT | TNL_F_PMTUD | TNL_F_HDR_CACHE;
-    if (!strcmp(type, "gre")) {
-        is_gre = true;
-    } else if (!strcmp(type, "ipsec_gre")) {
-        is_gre = true;
-        is_ipsec = true;
+    struct shash_node *node;
+    uint32_t flags = 0;
+
+    if (!strcmp(type, "ipsec_gre")) {
         flags |= TNL_F_IPSEC;
-        flags &= ~TNL_F_HDR_CACHE;
+    } else if (!strcmp(type, "capwap")) {
+        flags |= TNL_F_CAPWAP;
     }
 
     SHASH_FOR_EACH (node, args) {
@@ -601,112 +587,9 @@ parse_tunnel_config(const char *name, const char *type,
             } else {
                 daddr = in_addr.s_addr;
             }
-        } else if (!strcmp(node->name, "local_ip")) {
-            struct in_addr in_addr;
-            if (lookup_ip(node->data, &in_addr)) {
-                VLOG_WARN("%s: bad %s 'local_ip'", name, type);
-            } else {
-                saddr = in_addr.s_addr;
-            }
-        } else if (!strcmp(node->name, "tos")) {
-            if (!strcmp(node->data, "inherit")) {
-                flags |= TNL_F_TOS_INHERIT;
-            } else {
-                char *endptr;
-                int tos;
-                tos = strtol(node->data, &endptr, 0);
-                if (*endptr == '\0') {
-                    nl_msg_put_u8(options, OVS_TUNNEL_ATTR_TOS, tos);
-                }
-            }
-        } else if (!strcmp(node->name, "ttl")) {
-            if (!strcmp(node->data, "inherit")) {
-                flags |= TNL_F_TTL_INHERIT;
-            } else {
-                nl_msg_put_u8(options, OVS_TUNNEL_ATTR_TTL, atoi(node->data));
-            }
-        } else if (!strcmp(node->name, "csum") && is_gre) {
-            if (!strcmp(node->data, "true")) {
-                flags |= TNL_F_CSUM;
-            }
-        } else if (!strcmp(node->name, "df_inherit")) {
-            if (!strcmp(node->data, "true")) {
-                flags |= TNL_F_DF_INHERIT;
-            }
-        } else if (!strcmp(node->name, "df_default")) {
-            if (!strcmp(node->data, "false")) {
-                flags &= ~TNL_F_DF_DEFAULT;
-            }
-        } else if (!strcmp(node->name, "pmtud")) {
-            if (!strcmp(node->data, "false")) {
-                flags &= ~TNL_F_PMTUD;
-            }
-        } else if (!strcmp(node->name, "header_cache")) {
-            if (!strcmp(node->data, "false")) {
-                flags &= ~TNL_F_HDR_CACHE;
-            }
-        } else if (!strcmp(node->name, "peer_cert") && is_ipsec) {
-            if (shash_find(args, "certificate")) {
-                ipsec_mech_set = true;
-            } else {
-                const char *use_ssl_cert;
-
-                /* If the "use_ssl_cert" is true, then "certificate" and
-                 * "private_key" will be pulled from the SSL table.  The
-                 * use of this option is strongly discouraged, since it
-                 * will like be removed when multiple SSL configurations
-                 * are supported by OVS.
-                 */
-                use_ssl_cert = shash_find_data(args, "use_ssl_cert");
-                if (!use_ssl_cert || strcmp(use_ssl_cert, "true")) {
-                    VLOG_ERR("%s: 'peer_cert' requires 'certificate' argument",
-                             name);
-                    return EINVAL;
-                }
-                ipsec_mech_set = true;
-            }
-        } else if (!strcmp(node->name, "psk") && is_ipsec) {
-            ipsec_mech_set = true;
-        } else if (is_ipsec
-                && (!strcmp(node->name, "certificate")
-                    || !strcmp(node->name, "private_key")
-                    || !strcmp(node->name, "use_ssl_cert"))) {
-            /* Ignore options not used by the netdev. */
-        } else if (!strcmp(node->name, "key") ||
-                   !strcmp(node->name, "in_key") ||
-                   !strcmp(node->name, "out_key")) {
-            /* Handled separately below. */
-        } else {
-            VLOG_WARN("%s: unknown %s argument '%s'", name, type, node->name);
         }
     }
 
-    if (is_ipsec) {
-        char *file_name = xasprintf("%s/%s", ovs_rundir(),
-                "ovs-monitor-ipsec.pid");
-        pid_t pid = read_pidfile(file_name);
-        free(file_name);
-        if (pid < 0) {
-            VLOG_ERR("%s: IPsec requires the ovs-monitor-ipsec daemon",
-                     name);
-            return EINVAL;
-        }
-
-        if (shash_find(args, "peer_cert") && shash_find(args, "psk")) {
-            VLOG_ERR("%s: cannot define both 'peer_cert' and 'psk'", name);
-            return EINVAL;
-        }
-
-        if (!ipsec_mech_set) {
-            VLOG_ERR("%s: IPsec requires an 'peer_cert' or psk' argument",
-                     name);
-            return EINVAL;
-        }
-    }
-
-    set_key(args, "in_key", OVS_TUNNEL_ATTR_IN_KEY, options);
-    set_key(args, "out_key", OVS_TUNNEL_ATTR_OUT_KEY, options);
-
     if (!daddr) {
         VLOG_ERR("%s: %s type requires valid 'remote_ip' argument",
                  name, type);
@@ -714,14 +597,6 @@ parse_tunnel_config(const char *name, const char *type,
     }
     nl_msg_put_be32(options, OVS_TUNNEL_ATTR_DST_IPV4, daddr);
 
-    if (saddr) {
-        if (ip_is_multicast(daddr)) {
-            VLOG_WARN("%s: remote_ip is multicast, ignoring local_ip", name);
-        } else {
-            nl_msg_put_be32(options, OVS_TUNNEL_ATTR_SRC_IPV4, saddr);
-        }
-    }
-
     nl_msg_put_u32(options, OVS_TUNNEL_ATTR_FLAGS, flags);
 
     return 0;
@@ -749,95 +624,6 @@ tnl_port_config_from_nlattr(const struct nlattr *options, size_t options_len,
     }
     return 0;
 }
-
-static uint64_t
-get_be64_or_zero(const struct nlattr *a)
-{
-    return a ? ntohll(nl_attr_get_be64(a)) : 0;
-}
-
-static int
-unparse_tunnel_config(const char *name OVS_UNUSED, const char *type OVS_UNUSED,
-                      const struct nlattr *options, size_t options_len,
-                      struct shash *args)
-{
-    struct nlattr *a[OVS_TUNNEL_ATTR_MAX + 1];
-    ovs_be32 daddr;
-    uint32_t flags;
-    int error;
-
-    error = tnl_port_config_from_nlattr(options, options_len, a);
-    if (error) {
-        return error;
-    }
-
-    flags = nl_attr_get_u32(a[OVS_TUNNEL_ATTR_FLAGS]);
-    if (!(flags & TNL_F_HDR_CACHE) == !(flags & TNL_F_IPSEC)) {
-        smap_add(args, "header_cache",
-                 flags & TNL_F_HDR_CACHE ? "true" : "false");
-    }
-
-    daddr = nl_attr_get_be32(a[OVS_TUNNEL_ATTR_DST_IPV4]);
-    shash_add(args, "remote_ip", xasprintf(IP_FMT, IP_ARGS(&daddr)));
-
-    if (a[OVS_TUNNEL_ATTR_SRC_IPV4]) {
-        ovs_be32 saddr = nl_attr_get_be32(a[OVS_TUNNEL_ATTR_SRC_IPV4]);
-        shash_add(args, "local_ip", xasprintf(IP_FMT, IP_ARGS(&saddr)));
-    }
-
-    if (!a[OVS_TUNNEL_ATTR_IN_KEY] && !a[OVS_TUNNEL_ATTR_OUT_KEY]) {
-        smap_add(args, "key", "flow");
-    } else {
-        uint64_t in_key = get_be64_or_zero(a[OVS_TUNNEL_ATTR_IN_KEY]);
-        uint64_t out_key = get_be64_or_zero(a[OVS_TUNNEL_ATTR_OUT_KEY]);
-
-        if (in_key && in_key == out_key) {
-            shash_add(args, "key", xasprintf("%"PRIu64, in_key));
-        } else {
-            if (!a[OVS_TUNNEL_ATTR_IN_KEY]) {
-                smap_add(args, "in_key", "flow");
-            } else if (in_key) {
-                shash_add(args, "in_key", xasprintf("%"PRIu64, in_key));
-            }
-
-            if (!a[OVS_TUNNEL_ATTR_OUT_KEY]) {
-                smap_add(args, "out_key", "flow");
-            } else if (out_key) {
-                shash_add(args, "out_key", xasprintf("%"PRIu64, out_key));
-            }
-        }
-    }
-
-    if (flags & TNL_F_TTL_INHERIT) {
-        smap_add(args, "tos", "inherit");
-    } else if (a[OVS_TUNNEL_ATTR_TTL]) {
-        int ttl = nl_attr_get_u8(a[OVS_TUNNEL_ATTR_TTL]);
-        shash_add(args, "tos", xasprintf("%d", ttl));
-    }
-
-    if (flags & TNL_F_TOS_INHERIT) {
-        smap_add(args, "tos", "inherit");
-    } else if (a[OVS_TUNNEL_ATTR_TOS]) {
-        int tos = nl_attr_get_u8(a[OVS_TUNNEL_ATTR_TOS]);
-        shash_add(args, "tos", xasprintf("0x%x", tos));
-    }
-
-    if (flags & TNL_F_CSUM) {
-        smap_add(args, "csum", "true");
-    }
-    if (flags & TNL_F_DF_INHERIT) {
-        smap_add(args, "df_inherit", "true");
-    }
-    if (!(flags & TNL_F_DF_DEFAULT)) {
-        smap_add(args, "df_default", "false");
-    }
-    if (!(flags & TNL_F_PMTUD)) {
-        smap_add(args, "pmtud", "false");
-    }
-
-    return 0;
-}
-
 static int
 parse_patch_config(const char *name, const char *type OVS_UNUSED,
                    const struct shash *args, struct ofpbuf *options)
@@ -894,15 +680,17 @@ unparse_patch_config(const char *name OVS_UNUSED, const char *type OVS_UNUSED,
     return 0;
 }
 
-#define VPORT_FUNCTIONS(GET_STATUS)                         \
+#define __VPORT_FUNCTIONS(RUN, WAIT, GET_CONFIG,            \
+                          SET_CONFIG, SEND, GET_STATS,      \
+                          SET_STATS, GET_STATUS)            \
     NULL,                                                   \
-    netdev_vport_run,                                       \
-    netdev_vport_wait,                                      \
+    RUN,                                                    \
+    WAIT,                                                   \
                                                             \
     netdev_vport_create,                                    \
     netdev_vport_destroy,                                   \
-    netdev_vport_get_config,                                \
-    netdev_vport_set_config,                                \
+    GET_CONFIG,                                             \
+    SET_CONFIG,                                             \
                                                             \
     netdev_vport_open,                                      \
     netdev_vport_close,                                     \
@@ -912,7 +700,7 @@ unparse_patch_config(const char *name OVS_UNUSED, const char *type OVS_UNUSED,
     NULL,                       /* recv_wait */             \
     NULL,                       /* drain */                 \
                                                             \
-    netdev_vport_send,          /* send */                  \
+    SEND,                       /* send */                  \
     NULL,                       /* send_wait */             \
                                                             \
     netdev_vport_set_etheraddr,                             \
@@ -923,8 +711,8 @@ unparse_patch_config(const char *name OVS_UNUSED, const char *type OVS_UNUSED,
     NULL,                       /* get_carrier */           \
     NULL,                       /* get_carrier_resets */    \
     NULL,                       /* get_miimon */            \
-    netdev_vport_get_stats,                                 \
-    netdev_vport_set_stats,                                 \
+    GET_STATS,                                              \
+    SET_STATS,                                              \
                                                             \
     NULL,                       /* get_features */          \
     NULL,                       /* set_advertisements */    \
@@ -953,24 +741,47 @@ unparse_patch_config(const char *name OVS_UNUSED, const char *type OVS_UNUSED,
                                                             \
     netdev_vport_change_seq
 
+#define VPORT_FUNCTIONS(SET_CONFIG, GET_STATUS)             \
+        __VPORT_FUNCTIONS(netdev_vport_run,                 \
+                          netdev_vport_wait,                \
+                          netdev_vport_get_config,          \
+                          SET_CONFIG,                       \
+                          netdev_vport_send,                \
+                          netdev_vport_get_stats,           \
+                          netdev_vport_set_stats,           \
+                          GET_STATUS)
+
+#define VPORT_TUNNEL_REALDEV_FUNCTIONS                      \
+        __VPORT_FUNCTIONS(NULL, NULL, NULL,                 \
+                          netdev_vport_set_config,          \
+                          NULL, NULL, NULL, NULL)
+
 void
 netdev_vport_register(void)
 {
     static const struct vport_class vport_classes[] = {
-        { OVS_VPORT_TYPE_GRE,
-          { "gre", VPORT_FUNCTIONS(netdev_vport_get_drv_info) },
-          parse_tunnel_config, unparse_tunnel_config },
+        { OVS_VPORT_TYPE_TUNNEL_REALDEV,
+          { "gre", VPORT_TUNNEL_REALDEV_FUNCTIONS },
+          parse_tunnel_config, NULL },
+
+        { OVS_VPORT_TYPE_TUNNEL_REALDEV,
+          { "ipsec_gre", VPORT_TUNNEL_REALDEV_FUNCTIONS },
+          parse_tunnel_config, NULL },
 
         { OVS_VPORT_TYPE_GRE,
-          { "ipsec_gre", VPORT_FUNCTIONS(netdev_vport_get_drv_info) },
-          parse_tunnel_config, unparse_tunnel_config },
+          { "gre-tundev", VPORT_FUNCTIONS(NULL, netdev_vport_get_drv_info) },
+          NULL, NULL },
+
+        { OVS_VPORT_TYPE_TUNNEL_REALDEV,
+          { "capwap", VPORT_TUNNEL_REALDEV_FUNCTIONS },
+          parse_tunnel_config, NULL },
 
         { OVS_VPORT_TYPE_CAPWAP,
-          { "capwap", VPORT_FUNCTIONS(netdev_vport_get_drv_info) },
-          parse_tunnel_config, unparse_tunnel_config },
+          { "capwap-tundev", VPORT_FUNCTIONS(NULL, netdev_vport_get_drv_info) },
+          NULL, NULL },
 
         { OVS_VPORT_TYPE_PATCH,
-          { "patch", VPORT_FUNCTIONS(NULL) },
+          { "patch", VPORT_FUNCTIONS(netdev_vport_set_config, NULL) },
           parse_patch_config, unparse_patch_config }
     };
 
-- 
1.7.10.2.484.gcd07cc5
