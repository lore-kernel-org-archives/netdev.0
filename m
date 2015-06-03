From: Tom Herbert <tom@herbertland.com>
Subject: [RFC net-next 2/6] net: Identfier Locator Addressing module
Date: Wed, 3 Jun 2015 12:58:18 -0700
Message-ID: <1433361502-3478761-3-git-send-email-tom@herbertland.com>
References: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <agartrell@fb.com>, <maheshb@google.com>,
	<tgraf@suug.ch>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:19511 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754182AbbFCT6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 15:58:48 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t53Jvqsi008190
	for <netdev@vger.kernel.org>; Wed, 3 Jun 2015 12:58:46 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1ut7h4r4gv-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 12:58:46 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 efe990c00a2a11e583200002c991e86a-216da280 for <netdev@vger.kernel.org>;	Wed,
 03 Jun 2015 12:58:43 -0700
In-Reply-To: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding new module name ila. This implements ILA tanslation. A netlink
interface is used to configure identifier to lacator mappings. Two
functions are exported to attempt to perform a translation on input
or output path.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/ila.h |   7 +
 net/ipv6/Kconfig  |   8 +
 net/ipv6/Makefile |   1 +
 net/ipv6/ila.c    | 496 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 512 insertions(+)
 create mode 100644 include/net/ila.h
 create mode 100644 net/ipv6/ila.c

diff --git a/include/net/ila.h b/include/net/ila.h
new file mode 100644
index 0000000..25660c6
--- /dev/null
+++ b/include/net/ila.h
@@ -0,0 +1,7 @@
+#ifndef __NET_ILA_H
+#define __NET_ILA_H
+
+int ila_xlat_incoming(struct sk_buff *skb);
+int ila_xlat_outgoing(struct sk_buff *skb);
+
+#endif
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 438a73a..609ca1a 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -93,6 +93,14 @@ config IPV6_MIP6
 
 	  If unsure, say N.
 
+config IPV6_ILA
+	tristate "IPv6: Identifier Locator Addressing (ILA)"
+	---help---
+	  Support for IPv6 Identifier Locator Addressing described in
+	  https://tools.ietf.org/html/draft-herbert-nvo3-ila-00.
+
+	  If unsure, say N.
+
 config INET6_XFRM_TUNNEL
 	tristate
 	select INET6_TUNNEL
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 0f3f199..2c900c7 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_INET6_XFRM_MODE_TUNNEL) += xfrm6_mode_tunnel.o
 obj-$(CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION) += xfrm6_mode_ro.o
 obj-$(CONFIG_INET6_XFRM_MODE_BEET) += xfrm6_mode_beet.o
 obj-$(CONFIG_IPV6_MIP6) += mip6.o
+obj-$(CONFIG_IPV6_ILA) += ila.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 
 obj-$(CONFIG_IPV6_VTI) += ip6_vti.o
diff --git a/net/ipv6/ila.c b/net/ipv6/ila.c
new file mode 100644
index 0000000..54a215d
--- /dev/null
+++ b/net/ipv6/ila.c
@@ -0,0 +1,496 @@
+#include <linux/errno.h>
+#include <linux/ip.h>
+#include <linux/jhash.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/socket.h>
+#include <linux/skbuff.h>
+#include <linux/rcupdate.h>
+#include <linux/types.h>
+#include <net/checksum.h>
+#include <net/genetlink.h>
+#include <net/ila.h>
+#include <net/ip.h>
+#include <net/netns/generic.h>
+#include <net/protocol.h>
+#include <uapi/linux/genetlink.h>
+#include <uapi/linux/ila.h>
+
+struct ila_map {
+	u64	identifier;
+	u64	locator;
+	struct hlist_node hlnode;
+	struct rcu_head rcu;
+};
+
+struct ila_map_bucket {
+	struct hlist_head chain;
+	spinlock_t lock;
+};
+
+#define ILA_HASH_TABLE_SIZE 1024
+
+struct ila_maps_info {
+	struct ila_map_bucket buckets[ILA_HASH_TABLE_SIZE];
+	unsigned int mask;
+	size_t size;
+};
+
+struct ila_cfg {
+	u64 identifier;
+	u64 locator;
+};
+
+static unsigned int ila_net_id;
+
+struct ila_net {
+	struct ila_maps_info info;
+};
+
+static struct genl_family ila_nl_family = {
+	.id		= GENL_ID_GENERATE,
+	.hdrsize	= 0,
+	.name		= ILA_GENL_NAME,
+	.version	= ILA_GENL_VERSION,
+	.maxattr	= ILA_ATTR_MAX,
+	.netnsok	= true,
+};
+
+static struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
+	[ILA_ATTR_IDENTIFIER] = { .type = NLA_U64, },
+	[ILA_ATTR_LOCATOR] = { .type = NLA_U64, },
+};
+
+static u32 hashrnd __read_mostly;
+static __always_inline void ila_init_secret(void)
+{
+	net_get_random_once(&hashrnd, sizeof(hashrnd));
+}
+
+static inline unsigned int ila_hash(u64 id)
+{
+	u32 *words = (u32 *)&id;
+
+	return jhash_2words(words[0], words[1], hashrnd);
+}
+
+static int parse_nl_config(struct genl_info *info,
+			   struct ila_cfg *cfg)
+{
+	memset(cfg, 0, sizeof(*cfg));
+
+	if (info->attrs[ILA_ATTR_IDENTIFIER]) {
+		u64 identifier = nla_get_u64(info->attrs[ILA_ATTR_IDENTIFIER]);
+
+		cfg->identifier = identifier;
+	}
+
+	if (info->attrs[ILA_ATTR_LOCATOR]) {
+		u64 locator = nla_get_u64(info->attrs[ILA_ATTR_LOCATOR]);
+
+		cfg->locator = locator;
+	}
+
+	return 0;
+}
+
+/* Must be called with rcu readlock */
+struct ila_map *ila_lookup(u64 id, struct ila_maps_info *info)
+{
+	unsigned int hash = ila_hash(id);
+	unsigned int slot = hash & info->mask;
+	struct ila_map_bucket *head = &info->buckets[slot];
+	struct ila_map *ila;
+
+	hlist_for_each_entry_rcu(ila, &head->chain, hlnode) {
+		if (ila->identifier == id)
+			return ila;
+	}
+
+	return NULL;
+}
+
+/* Called with lock held for hlist */
+static inline void ila_release(struct ila_map *ila)
+{
+	hlist_del_init_rcu(&ila->hlnode);
+	kfree_rcu(ila, rcu);
+}
+
+static int ila_del_mapping(struct net *net, struct ila_cfg *cfg)
+{
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+	unsigned int hash = ila_hash(cfg->identifier);
+	struct ila_maps_info *info = &ilan->info;
+	struct ila_map_bucket *ilab = &info->buckets[hash & info->mask];
+	struct ila_map *ila;
+
+	spin_lock(&ilab->lock);
+
+	ila = ila_lookup(cfg->identifier, info);
+	if (ila)
+		ila_release(ila);
+
+	spin_unlock(&ilab->lock);
+
+	return 0;
+}
+
+static int ila_add_mapping(struct net *net, struct ila_cfg *cfg)
+{
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+	unsigned int hash = ila_hash(cfg->identifier);
+	struct ila_maps_info *info = &ilan->info;
+	struct ila_map_bucket *ilab = &info->buckets[hash & info->mask];
+	struct ila_map *ila, *ila_tmp;
+
+	ila = kzalloc(sizeof(*ila), GFP_KERNEL);
+	if (!ila)
+		return -ENOMEM;
+
+	ila->identifier = cfg->identifier;
+	ila->locator = cfg->locator;
+
+	spin_lock(&ilab->lock);
+
+	hlist_for_each_entry_rcu(ila_tmp, &ilab->chain, hlnode) {
+		if (ila_tmp->identifier == cfg->identifier) {
+			/* There's already a mapping for this locator,
+			 * delete for for now. Later just modify it in place?
+			 */
+			ila_release(ila_tmp);
+		}
+	}
+
+	if (hlist_unhashed(&ila->hlnode))
+		hlist_add_head_rcu(&ila->hlnode, &ilab->chain);
+
+	spin_unlock(&ilab->lock);
+
+	return 0;
+}
+
+static int ila_nl_cmd_add_mapping(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct ila_cfg cfg;
+	int err;
+
+	err = parse_nl_config(info, &cfg);
+	if (err)
+		return err;
+
+	return ila_add_mapping(net, &cfg);
+}
+
+static int ila_nl_cmd_del_mapping(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct ila_cfg cfg;
+	int err;
+
+	err = parse_nl_config(info, &cfg);
+	if (err)
+		return err;
+
+	return ila_del_mapping(net, &cfg);
+}
+
+static int ila_fill_info(struct ila_map *ila, struct sk_buff *msg)
+{
+	if (nla_put_u64(msg, ILA_ATTR_IDENTIFIER, ila->identifier) ||
+	    nla_put_u64(msg, ILA_ATTR_LOCATOR, ila->locator))
+		return -1;
+
+	return 0;
+}
+
+static int ila_dump_info(struct ila_map *ila, u32 portid, u32 seq,
+			 u32 flags, struct sk_buff *skb, u8 cmd)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(skb, portid, seq, &ila_nl_family, flags, cmd);
+	if (!hdr)
+		return -ENOMEM;
+
+	if (ila_fill_info(ila, skb) < 0)
+		goto nla_put_failure;
+
+	genlmsg_end(skb, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
+}
+
+static int ila_nl_cmd_get_mapping(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+	struct sk_buff *msg;
+	struct ila_cfg cfg;
+	struct ila_map *ila;
+	int ret;
+
+	ret = parse_nl_config(info, &cfg);
+	if (ret)
+		return ret;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	rcu_read_lock();
+
+	ila = ila_lookup(cfg.identifier, &ilan->info);
+	if (ila) {
+		ret = ila_dump_info(ila, info->snd_portid,
+				    info->snd_seq, 0, msg,
+				    info->genlhdr->cmd);
+	}
+
+	rcu_read_unlock();
+
+	if (ret < 0)
+		goto out_free;
+
+	return genlmsg_reply(msg, info);
+
+out_free:
+	nlmsg_free(msg);
+	return ret;
+}
+
+static int ila_nl_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+	struct ila_maps_info *info = &ilan->info;
+	struct ila_map *ila;
+	int idx = 0;
+	int i;
+
+	for (i = 0; i < info->size; i++) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(ila, &info->buckets[i].chain, hlnode) {
+			if (idx < cb->args[0])
+				goto skip;
+			if (ila_dump_info(ila, NETLINK_CB(cb->skb).portid,
+					  cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					  skb, ILA_CMD_GET) < 0)
+				break;
+skip:
+			idx++;
+		}
+		rcu_read_unlock();
+	}
+
+	cb->args[0] = idx;
+	return skb->len;
+}
+
+static const struct genl_ops ila_nl_ops[] = {
+	{
+		.cmd = ILA_CMD_ADD,
+		.doit = ila_nl_cmd_add_mapping,
+		.policy = ila_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = ILA_CMD_DEL,
+		.doit = ila_nl_cmd_del_mapping,
+		.policy = ila_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = ILA_CMD_GET,
+		.doit = ila_nl_cmd_get_mapping,
+		.dumpit = ila_nl_dump,
+		.policy = ila_nl_policy,
+	},
+};
+
+#define ILA_HASH_TABLE_SIZE 1024
+
+void ila_hashinfo_init(struct ila_maps_info *info)
+{
+	int i;
+
+	memset(info, 0, sizeof(*info));
+
+	info->size = ILA_HASH_TABLE_SIZE;
+	info->mask = ILA_HASH_TABLE_SIZE - 1;
+
+	for (i = 0; i < ILA_HASH_TABLE_SIZE; i++) {
+		struct ila_map_bucket *ilab = &info->buckets[i];
+
+		spin_lock_init(&ilab->lock);
+		INIT_HLIST_HEAD(&ilab->chain);
+	}
+}
+
+static __net_init int ila_init_net(struct net *net)
+{
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+
+	ila_hashinfo_init(&ilan->info);
+
+	return 0;
+}
+
+static __net_exit void ila_exit_net(struct net *net)
+{
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+	struct ila_maps_info *info = &ilan->info;
+	struct ila_map *ila;
+	struct hlist_node *tmp;
+	int i;
+
+	for (i = 0; i < info->size; i++) {
+		struct ila_map_bucket *ilab = &info->buckets[i];
+
+		spin_lock(&ilab->lock);
+
+		hlist_for_each_entry_safe(ila, tmp, &ilab->chain, hlnode) {
+			ila_release(ila);
+		}
+
+		spin_unlock(&ilab->lock);
+	}
+
+	info->size = 0;
+}
+
+static struct pernet_operations ila_net_ops = {
+	.init = ila_init_net,
+	.exit = ila_exit_net,
+	.id   = &ila_net_id,
+	.size = sizeof(struct ila_net),
+};
+
+static int __init ila_init(void)
+{
+	int ret;
+
+	ila_init_secret();
+
+	ret = register_pernet_device(&ila_net_ops);
+	if (ret)
+		goto exit;
+
+	ret = genl_register_family_with_ops(&ila_nl_family,
+					    ila_nl_ops);
+	if (ret < 0)
+		goto unregister;
+
+	return 0;
+
+unregister:
+	unregister_pernet_device(&ila_net_ops);
+exit:
+	return ret;
+}
+
+static void update_ipv6_checksum(struct sk_buff *skb, u8 l4_proto,
+				 __be32 loc[2], const __be32 new_loc[2])
+{
+	int nhoff = sizeof(struct ipv6hdr);
+
+	switch (l4_proto) {
+	case NEXTHDR_TCP:
+		if (likely(pskb_may_pull(skb, nhoff + sizeof(struct tcphdr)))) {
+			struct tcphdr *th = (struct tcphdr *)
+					(skb_network_header(skb) + nhoff);
+
+			inet_proto_csum_replace8(&th->check, skb,
+						 loc, new_loc, 1);
+		}
+		break;
+	case NEXTHDR_UDP:
+		if (likely(pskb_may_pull(skb, nhoff + sizeof(struct udphdr)))) {
+			struct udphdr *uh = (struct udphdr *)
+					(skb_network_header(skb) + nhoff);
+
+			if (uh->check || skb->ip_summed == CHECKSUM_PARTIAL) {
+				inet_proto_csum_replace8(&uh->check, skb,
+							 loc, new_loc, 1);
+				if (!uh->check)
+					uh->check = CSUM_MANGLED_0;
+			}
+		}
+		break;
+	case NEXTHDR_ICMP:
+		if (likely(pskb_may_pull(skb,
+					 nhoff + sizeof(struct icmp6hdr)))) {
+			struct icmp6hdr *ih = (struct icmp6hdr *)
+					(skb_network_header(skb) + nhoff);
+
+			inet_proto_csum_replace8(&ih->icmp6_cksum,
+						 skb, loc, new_loc, 1);
+		}
+		break;
+	}
+}
+
+static void nat_locator(struct sk_buff *skb, struct ipv6hdr *ip6h, u64 locator)
+{
+	__be32 *words = (__be32 *)&locator;
+
+	update_ipv6_checksum(skb, ip6h->nexthdr, (__be32 *)&ip6h->daddr, words);
+	memcpy(&ip6h->daddr, words, sizeof(locator));
+}
+
+static void __exit ila_fini(void)
+{
+	genl_unregister_family(&ila_nl_family);
+	unregister_pernet_device(&ila_net_ops);
+}
+
+static int __ila_xlat(struct sk_buff *skb, struct net *net)
+{
+	struct ila_map *ila;
+	struct ipv6hdr *ip6h;
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+	struct ila_maps_info *info = &ilan->info;
+	u64 identifier;
+
+	if (skb->protocol != htons(ETH_P_IPV6))
+		return 0;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(*ip6h))))
+		return 0;
+
+	ip6h = ipv6_hdr(skb);
+	if (ip6h->version != 6)
+		return 0;
+
+	identifier = *(u64 *)&ip6h->daddr.in6_u.u6_addr8[8];
+	ila = ila_lookup(identifier, info);
+	if (ila)
+		nat_locator(skb, ip6h, ila->locator);
+
+	return 0;
+}
+
+int ila_xlat_outgoing(struct sk_buff *skb)
+{
+	struct net *net = dev_net(skb_dst(skb)->dev);
+
+	return __ila_xlat(skb, net);
+}
+EXPORT_SYMBOL(ila_xlat_outgoing);
+
+int ila_xlat_incoming(struct sk_buff *skb)
+{
+	struct net *net = dev_net(skb->dev);
+
+	return __ila_xlat(skb, net);
+}
+EXPORT_SYMBOL(ila_xlat_incoming);
+
+module_init(ila_init);
+module_exit(ila_fini);
+MODULE_AUTHOR("Tom Herbert <tom@herbertland.com>");
+MODULE_LICENSE("GPL");
-- 
1.8.1
