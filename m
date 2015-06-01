From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 1/2] geneve: allow user to specify TTL for tunnel frames
Date: Mon,  1 Jun 2015 15:51:34 -0400
Message-ID: <1433188295-19043-1-git-send-email-linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59571 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987AbbFATwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 15:52:55 -0400
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
index b7eafa4c1a67..1675dfdbfa70 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -44,7 +44,8 @@ struct geneve_dev {
 	struct net	   *net;	/* netns for packet i/o */
 	struct net_device  *dev;	/* netdev for geneve tunnel */
 	struct geneve_sock *sock;	/* socket used for geneve tunnel */
-	u8 vni[3];			/* virtual network ID for tunnel */
+	u8                 vni[3];	/* virtual network ID for tunnel */
+	u8                 ttl;		/* TTL override */
 	struct sockaddr_in remote;	/* IPv4 address for link partner */
 	struct list_head   next;	/* geneve's per namespace list */
 };
@@ -184,7 +185,7 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct flowi4 fl4;
 	int err;
 	__be16 sport;
-	__u8 tos, ttl = 0;
+	__u8 tos, ttl;
 
 	iip = ip_hdr(skb);
 
@@ -207,11 +208,12 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto rt_tx_error;
 	}
 
-	/* TODO: tos and ttl should be configurable */
+	/* TODO: tos should be configurable */
 
 	tos = ip_tunnel_ecn_encap(0, iip, skb);
 
-	if (IN_MULTICAST(ntohl(fl4.daddr)))
+	ttl = geneve->ttl;
+	if (!ttl && IN_MULTICAST(ntohl(fl4.daddr)))
 		ttl = 1;
 
 	ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
@@ -297,6 +299,7 @@ static void geneve_setup(struct net_device *dev)
 static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
 	[IFLA_GENEVE_ID]		= { .type = NLA_U32 },
 	[IFLA_GENEVE_REMOTE]		= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
+	[IFLA_GENEVE_TTL]		= { .type = NLA_U8 },
 };
 
 static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -364,6 +367,9 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 	if (err)
 		return err;
 
+	if (data[IFLA_GENEVE_TTL])
+		geneve->ttl = nla_get_u8(data[IFLA_GENEVE_TTL]);
+
 	list_add(&geneve->next, &gn->geneve_list);
 
 	hlist_add_head_rcu(&geneve->hlist, &gn->vni_list[hash]);
@@ -386,6 +392,7 @@ static size_t geneve_get_size(const struct net_device *dev)
 {
 	return nla_total_size(sizeof(__u32)) +	/* IFLA_GENEVE_ID */
 		nla_total_size(sizeof(struct in_addr)) + /* IFLA_GENEVE_REMOTE */
+		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TTL */
 		0;
 }
 
@@ -402,6 +409,9 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			    geneve->remote.sin_addr.s_addr))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, IFLA_GENEVE_TTL, geneve->ttl))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 2ca17d1cff3f..6edb8d268d58 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -395,6 +395,7 @@ enum {
 	IFLA_GENEVE_UNSPEC,
 	IFLA_GENEVE_ID,
 	IFLA_GENEVE_REMOTE,
+	IFLA_GENEVE_TTL,
 	__IFLA_GENEVE_MAX
 };
 #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
-- 
2.1.0
