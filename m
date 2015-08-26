From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v4 net-next 4/8] geneve: Make dst-port configurable.
Date: Wed, 26 Aug 2015 14:54:35 -0700
Message-ID: <1440626079-11689-5-git-send-email-pshelar@nicira.com>
References: <1440626079-11689-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35058 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172AbbHZVyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 17:54:49 -0400
Received: by pacdd16 with SMTP id dd16so831195pac.2
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 14:54:48 -0700 (PDT)
In-Reply-To: <1440626079-11689-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netlink interface to configure Geneve UDP port number.
So that user can configure it for a Gevene device.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Reviewed-by: Jesse Gross <jesse@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
Acked-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/geneve.c         |   25 +++++++++++++++++++++----
 include/uapi/linux/if_link.h |    1 +
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 3c5b2b1..0a6d974 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -49,6 +49,7 @@ struct geneve_dev {
 	u8                 tos;		/* TOS override */
 	struct sockaddr_in remote;	/* IPv4 address for link partner */
 	struct list_head   next;	/* geneve's per namespace list */
+	__be16		   dst_port;
 };
 
 static int geneve_net_id;
@@ -64,6 +65,7 @@ static inline __u32 geneve_net_vni_hash(u8 vni[3])
 /* geneve receive/decap routine */
 static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 {
+	struct inet_sock *sk = inet_sk(gs->sock->sk);
 	struct genevehdr *gnvh = geneve_hdr(skb);
 	struct geneve_dev *dummy, *geneve = NULL;
 	struct geneve_net *gn;
@@ -82,7 +84,8 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 	vni_list_head = &gn->vni_list[hash];
 	hlist_for_each_entry_rcu(dummy, vni_list_head, hlist) {
 		if (!memcmp(gnvh->vni, dummy->vni, sizeof(dummy->vni)) &&
-		    iph->saddr == dummy->remote.sin_addr.s_addr) {
+		    iph->saddr == dummy->remote.sin_addr.s_addr &&
+		    sk->inet_sport == dummy->dst_port) {
 			geneve = dummy;
 			break;
 		}
@@ -157,7 +160,7 @@ static int geneve_open(struct net_device *dev)
 	struct geneve_net *gn = net_generic(geneve->net, geneve_net_id);
 	struct geneve_sock *gs;
 
-	gs = geneve_sock_add(net, htons(GENEVE_UDP_PORT), geneve_rx, gn,
+	gs = geneve_sock_add(net, geneve->dst_port, geneve_rx, gn,
 	                     false, false);
 	if (IS_ERR(gs))
 		return PTR_ERR(gs);
@@ -228,7 +231,7 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* no need to handle local destination and encap bypass...yet... */
 
 	err = geneve_xmit_skb(gs, rt, skb, fl4.saddr, fl4.daddr,
-	                      tos, ttl, 0, sport, htons(GENEVE_UDP_PORT), 0,
+			      tos, ttl, 0, sport, geneve->dst_port, 0,
 	                      geneve->vni, 0, NULL, false,
 	                      !net_eq(geneve->net, dev_net(geneve->dev)));
 	if (err < 0)
@@ -308,6 +311,7 @@ static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
 	[IFLA_GENEVE_REMOTE]		= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
 	[IFLA_GENEVE_TTL]		= { .type = NLA_U8 },
 	[IFLA_GENEVE_TOS]		= { .type = NLA_U8 },
+	[IFLA_GENEVE_PORT]		= { .type = NLA_U16 },
 };
 
 static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -341,6 +345,7 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 	struct hlist_head *vni_list_head;
 	struct sockaddr_in remote;	/* IPv4 address for link partner */
 	__u32 vni, hash;
+	__be16 dst_port;
 	int err;
 
 	if (!data[IFLA_GENEVE_ID] || !data[IFLA_GENEVE_REMOTE])
@@ -359,13 +364,20 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 	if (IN_MULTICAST(ntohl(geneve->remote.sin_addr.s_addr)))
 		return -EINVAL;
 
+	if (data[IFLA_GENEVE_PORT])
+		dst_port = htons(nla_get_u16(data[IFLA_GENEVE_PORT]));
+	else
+		dst_port = htons(GENEVE_UDP_PORT);
+
 	remote = geneve->remote;
 	hash = geneve_net_vni_hash(geneve->vni);
 	vni_list_head = &gn->vni_list[hash];
 	hlist_for_each_entry_rcu(dummy, vni_list_head, hlist) {
 		if (!memcmp(geneve->vni, dummy->vni, sizeof(dummy->vni)) &&
-		    !memcmp(&remote, &dummy->remote, sizeof(dummy->remote)))
+		    !memcmp(&remote, &dummy->remote, sizeof(dummy->remote)) &&
+		    dst_port == dummy->dst_port) {
 			return -EBUSY;
+		}
 	}
 
 	err = register_netdevice(dev);
@@ -378,6 +390,7 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 	if (data[IFLA_GENEVE_TOS])
 		geneve->tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
 
+	geneve->dst_port = dst_port;
 	list_add(&geneve->next, &gn->geneve_list);
 
 	hlist_add_head_rcu(&geneve->hlist, &gn->vni_list[hash]);
@@ -402,6 +415,7 @@ static size_t geneve_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(struct in_addr)) + /* IFLA_GENEVE_REMOTE */
 		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TTL */
 		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TOS */
+		nla_total_size(sizeof(__u16)) +  /* IFLA_GENEVE_PORT */
 		0;
 }
 
@@ -422,6 +436,9 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_GENEVE_TOS, geneve->tos))
 		goto nla_put_failure;
 
+	if (nla_put_u16(skb, IFLA_GENEVE_PORT, ntohs(geneve->dst_port)))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 313c305..aa0d0f1 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -409,6 +409,7 @@ enum {
 	IFLA_GENEVE_REMOTE,
 	IFLA_GENEVE_TTL,
 	IFLA_GENEVE_TOS,
+	IFLA_GENEVE_PORT,	/* destination port */
 	__IFLA_GENEVE_MAX
 };
 #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
-- 
1.7.1
