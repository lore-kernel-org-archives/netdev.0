From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 2/2] geneve: allow user to specify TOS info for tunnel frames
Date: Mon,  1 Jun 2015 15:51:35 -0400
Message-ID: <1433188295-19043-2-git-send-email-linville@tuxdriver.com>
References: <1433188295-19043-1-git-send-email-linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59572 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891AbbFATwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 15:52:55 -0400
In-Reply-To: <1433188295-19043-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
I have the corresponding iproute2 patch ready, but I am holding it
for now to avoid confusion on the list and such...

 drivers/net/geneve.c         | 18 ++++++++++++++----
 include/uapi/linux/if_link.h |  1 +
 2 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 1675dfdbfa70..78d49d186e05 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -46,6 +46,7 @@ struct geneve_dev {
 	struct geneve_sock *sock;	/* socket used for geneve tunnel */
 	u8                 vni[3];	/* virtual network ID for tunnel */
 	u8                 ttl;		/* TTL override */
+	u8                 tos;		/* TOS override */
 	struct sockaddr_in remote;	/* IPv4 address for link partner */
 	struct list_head   next;	/* geneve's per namespace list */
 };
@@ -194,7 +195,12 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* TODO: port min/max limits should be configurable */
 	sport = udp_flow_src_port(dev_net(dev), skb, 0, 0, true);
 
+	tos = geneve->tos;
+	if (tos == 1)
+		tos = ip_tunnel_get_dsfield(iip, skb);
+
 	memset(&fl4, 0, sizeof(fl4));
+	fl4.flowi4_tos = RT_TOS(tos);
 	fl4.daddr = geneve->remote.sin_addr.s_addr;
 	rt = ip_route_output_key(geneve->net, &fl4);
 	if (IS_ERR(rt)) {
@@ -208,9 +214,7 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto rt_tx_error;
 	}
 
-	/* TODO: tos should be configurable */
-
-	tos = ip_tunnel_ecn_encap(0, iip, skb);
+	tos = ip_tunnel_ecn_encap(tos, iip, skb);
 
 	ttl = geneve->ttl;
 	if (!ttl && IN_MULTICAST(ntohl(fl4.daddr)))
@@ -300,6 +304,7 @@ static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
 	[IFLA_GENEVE_ID]		= { .type = NLA_U32 },
 	[IFLA_GENEVE_REMOTE]		= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
 	[IFLA_GENEVE_TTL]		= { .type = NLA_U8 },
+	[IFLA_GENEVE_TOS]		= { .type = NLA_U8 },
 };
 
 static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -370,6 +375,9 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 	if (data[IFLA_GENEVE_TTL])
 		geneve->ttl = nla_get_u8(data[IFLA_GENEVE_TTL]);
 
+	if (data[IFLA_GENEVE_TOS])
+		geneve->tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
+
 	list_add(&geneve->next, &gn->geneve_list);
 
 	hlist_add_head_rcu(&geneve->hlist, &gn->vni_list[hash]);
@@ -393,6 +401,7 @@ static size_t geneve_get_size(const struct net_device *dev)
 	return nla_total_size(sizeof(__u32)) +	/* IFLA_GENEVE_ID */
 		nla_total_size(sizeof(struct in_addr)) + /* IFLA_GENEVE_REMOTE */
 		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TTL */
+		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TOS */
 		0;
 }
 
@@ -409,7 +418,8 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			    geneve->remote.sin_addr.s_addr))
 		goto nla_put_failure;
 
-	if (nla_put_u8(skb, IFLA_GENEVE_TTL, geneve->ttl))
+	if (nla_put_u8(skb, IFLA_GENEVE_TTL, geneve->ttl) ||
+	    nla_put_u8(skb, IFLA_GENEVE_TOS, geneve->tos))
 		goto nla_put_failure;
 
 	return 0;
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 6edb8d268d58..ab90c196dde0 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -396,6 +396,7 @@ enum {
 	IFLA_GENEVE_ID,
 	IFLA_GENEVE_REMOTE,
 	IFLA_GENEVE_TTL,
+	IFLA_GENEVE_TOS,
 	__IFLA_GENEVE_MAX
 };
 #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
-- 
2.1.0
