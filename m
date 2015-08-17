From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 9/9] geneve: Implement rtnl changelink
Date: Mon, 17 Aug 2015 14:11:45 -0700
Message-ID: <1439845905-31666-10-git-send-email-pshelar@nicira.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36703 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbbHQVMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:12:08 -0400
Received: by pdbmi9 with SMTP id mi9so19180855pdb.3
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:12:08 -0700 (PDT)
In-Reply-To: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow run time changes to Geneve device configuration.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/geneve.c | 159 +++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 115 insertions(+), 44 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index e47cdd9..0d7fbef 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -70,12 +70,18 @@ struct geneve_sock {
 	struct hlist_head	vni_list[VNI_HASH_SIZE];
 };
 
-static inline __u32 geneve_net_vni_hash(u8 vni[3])
+/* Convert 64 bit tunnel ID to 24 bit VNI. */
+static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
 {
-	__u32 vnid;
-
-	vnid = (vni[0] << 16) | (vni[1] << 8) | vni[2];
-	return hash_32(vnid, VNI_HASH_BITS);
+#ifdef __BIG_ENDIAN
+	vni[0] = (__force __u8)(tun_id >> 16);
+	vni[1] = (__force __u8)(tun_id >> 8);
+	vni[2] = (__force __u8)tun_id;
+#else
+	vni[0] = (__force __u8)((__force u64)tun_id >> 40);
+	vni[1] = (__force __u8)((__force u64)tun_id >> 48);
+	vni[2] = (__force __u8)((__force u64)tun_id >> 56);
+#endif
 }
 
 static __be64 vni_to_tunnel_id(const __u8 *vni)
@@ -89,8 +95,28 @@ static __be64 vni_to_tunnel_id(const __u8 *vni)
 #endif
 }
 
+static u32 vni_to_u32(const u8 vni[])
+{
+	return (vni[0] << 16) | (vni[1] << 8) | vni[2];
+}
+
+static void u32_to_vni(u32 id, u8 vni[])
+{
+	vni[0] = (id & 0x00ff0000) >> 16;
+	vni[1] = (id & 0x0000ff00) >> 8;
+	vni[2] =  id & 0x000000ff;
+}
+
+static inline __u32 geneve_net_vni_hash(const u8 vni[])
+{
+	__u32 vnid;
+
+	vnid = vni_to_u32(vni);
+	return hash_32(vnid, VNI_HASH_BITS);
+}
+
 static struct geneve_dev *geneve_lookup(struct geneve_sock *gs,
-					__be32 addr, u8 vni[])
+					__be32 addr, const u8 vni[])
 {
 	struct hlist_head *vni_list_head;
 	struct geneve_dev *geneve;
@@ -120,7 +146,7 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 	struct geneve_dev *geneve = NULL;
 	struct pcpu_sw_netstats *stats;
 	struct iphdr *iph;
-	u8 *vni;
+	const u8 *vni;
 	__be32 addr;
 	bool xnet;
 	int err;
@@ -519,6 +545,7 @@ static int geneve_stop(struct net_device *dev)
 	if (!hlist_unhashed(&geneve->hlist))
 		hlist_del_rcu(&geneve->hlist);
 	geneve_sock_release(gs);
+	geneve->sock = NULL;
 	return 0;
 }
 
@@ -613,20 +640,6 @@ static struct rtable *geneve_get_rt(struct sk_buff *skb,
 	return rt;
 }
 
-/* Convert 64 bit tunnel ID to 24 bit VNI. */
-static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
-{
-#ifdef __BIG_ENDIAN
-	vni[0] = (__force __u8)(tun_id >> 16);
-	vni[1] = (__force __u8)(tun_id >> 8);
-	vni[2] = (__force __u8)tun_id;
-#else
-	vni[0] = (__force __u8)((__force u64)tun_id >> 40);
-	vni[1] = (__force __u8)((__force u64)tun_id >> 48);
-	vni[2] = (__force __u8)((__force u64)tun_id >> 56);
-#endif
-}
-
 static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
@@ -800,26 +813,22 @@ static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
-static int geneve_configure(struct net *net, struct net_device *dev,
-			    __be32 rem_addr, __u32 vni, __u8 ttl, __u8 tos,
-			    __u16 dst_port, bool metadata)
+static int __geneve_configure(struct net *net, struct net_device *dev,
+			      __be32 rem_addr, __u32 vni, __u8 ttl, __u8 tos,
+			      __u16 dst_port, bool metadata)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct geneve_dev *t;
-	int err;
 
 	geneve->net = net;
 	geneve->dev = dev;
 
-	geneve->vni[0] = (vni & 0x00ff0000) >> 16;
-	geneve->vni[1] = (vni & 0x0000ff00) >> 8;
-	geneve->vni[2] =  vni & 0x000000ff;
-
 	geneve->remote.sin_addr.s_addr = rem_addr;
 	if (IN_MULTICAST(ntohl(geneve->remote.sin_addr.s_addr)))
 		return -EINVAL;
 
+	u32_to_vni(vni, geneve->vni);
 	list_for_each_entry(t, &gn->geneve_list, next) {
 		if (!memcmp(geneve->vni, t->vni, sizeof(t->vni)) &&
 		    rem_addr == t->remote.sin_addr.s_addr &&
@@ -832,6 +841,22 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 	geneve->dst_port = htons(dst_port);
 	geneve->collect_md = metadata;
 
+	return 0;
+}
+
+static int geneve_configure(struct net *net, struct net_device *dev,
+			    __be32 rem_addr, __u32 vni, __u8 ttl, __u8 tos,
+			    __u32 dst_port, bool metadata)
+{
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
+	struct geneve_dev *geneve = netdev_priv(dev);
+	int err;
+
+	err = __geneve_configure(net, dev, rem_addr, vni, ttl, tos,
+				 dst_port, metadata);
+	if (err)
+		return err;
+
 	err = register_netdevice(dev);
 	if (err)
 		return err;
@@ -840,35 +865,80 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 	return 0;
 }
 
+static void geneve_parse_conf(struct nlattr *data[], __be32 *rem_addr,
+			      __u32 *vni, __u8 *ttl, __u8 *tos,
+			      __u16 *dst_port, bool *metadata)
+{
+	if (data[IFLA_GENEVE_ID])
+		*vni = nla_get_u32(data[IFLA_GENEVE_ID]);
+
+	if (data[IFLA_GENEVE_REMOTE])
+		*rem_addr = nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
+
+	if (data[IFLA_GENEVE_TTL])
+		*ttl = nla_get_u8(data[IFLA_GENEVE_TTL]);
+
+	if (data[IFLA_GENEVE_TOS])
+		*tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
+
+	if (data[IFLA_GENEVE_PORT])
+		*dst_port = nla_get_u16(data[IFLA_GENEVE_PORT]);
+
+	if (data[IFLA_GENEVE_COLLECT_METADATA])
+		*metadata = true;
+}
+
 static int geneve_newlink(struct net *net, struct net_device *dev,
 			  struct nlattr *tb[], struct nlattr *data[])
 {
 	__u16 dst_port = GENEVE_UDP_PORT;
 	__u8 ttl = 0, tos = 0;
 	bool metadata = false;
-	__be32 rem_addr;
-	__u32 vni;
+	__be32 rem_addr = 0;
+	__u32 vni = 0;
 
 	if (!data[IFLA_GENEVE_ID] || !data[IFLA_GENEVE_REMOTE])
 		return -EINVAL;
 
-	vni = nla_get_u32(data[IFLA_GENEVE_ID]);
-	rem_addr = nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
+	geneve_parse_conf(data, &rem_addr, &vni, &ttl, &tos, &dst_port,
+			  &metadata);
+	return geneve_configure(net, dev, rem_addr, vni,
+				ttl, tos, dst_port, metadata);
+}
 
-	if (data[IFLA_GENEVE_TTL])
-		ttl = nla_get_u8(data[IFLA_GENEVE_TTL]);
+static int geneve_changelink(struct net_device *dev,
+			     struct nlattr *tb[], struct nlattr *data[])
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+	__be32 rem_addr = geneve->remote.sin_addr.s_addr;
+	__u16 dst_port = ntohs(geneve->dst_port);
+	bool metadata = geneve->collect_md;
+	u32 vni = vni_to_u32(geneve->vni);
+	__u8 ttl = geneve->ttl;
+	__u8 tos = geneve->tos;
+	bool start_dev = false;
+	int err;
 
-	if (data[IFLA_GENEVE_TOS])
-		tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
+	geneve_parse_conf(data, &rem_addr, &vni, &ttl, &tos, &dst_port,
+			  &metadata);
 
-	if (data[IFLA_GENEVE_PORT])
-		dst_port = nla_get_u16(data[IFLA_GENEVE_PORT]);
+	if (geneve->sock && (dst_port != ntohs(geneve->dst_port) ||
+			     metadata != geneve->collect_md)) {
+		/* Recreate socket due to socket related changes. */
+		err = geneve_stop(dev);
+		if (err)
+			return err;
+		start_dev = true;
+	}
+	err = __geneve_configure(geneve->net, dev, rem_addr, vni, ttl, tos,
+				 dst_port, metadata);
+	if (err)
+		return err;
 
-	if (data[IFLA_GENEVE_COLLECT_METADATA])
-		metadata = true;
+	if (start_dev)
+		err = geneve_open(dev);
 
-	return geneve_configure(net, dev, rem_addr, vni,
-				ttl, tos, dst_port, metadata);
+	return err;
 }
 
 static void geneve_dellink(struct net_device *dev, struct list_head *head)
@@ -895,7 +965,7 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct geneve_dev *geneve = netdev_priv(dev);
 	__u32 vni;
 
-	vni = (geneve->vni[0] << 16) | (geneve->vni[1] << 8) | geneve->vni[2];
+	vni = vni_to_u32(geneve->vni);
 	if (nla_put_u32(skb, IFLA_GENEVE_ID, vni))
 		goto nla_put_failure;
 
@@ -929,6 +999,7 @@ static struct rtnl_link_ops geneve_link_ops __read_mostly = {
 	.setup		= geneve_setup,
 	.validate	= geneve_validate,
 	.newlink	= geneve_newlink,
+	.changelink	= geneve_changelink,
 	.dellink	= geneve_dellink,
 	.get_size	= geneve_get_size,
 	.fill_info	= geneve_fill_info,
-- 
1.8.3.1
