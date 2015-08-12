From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/6] geneve: Make dst-port configurable.
Date: Tue, 11 Aug 2015 22:17:40 -0700
Message-ID: <1439356660-21754-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34714 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933418AbbHLFSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 01:18:47 -0400
Received: by pdbfa8 with SMTP id fa8so3269607pdb.1
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 22:18:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netlink interface to configure Geneve UDP port number.
So that user can configure it for a Gevene device.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/geneve.c         | 14 ++++++++++++--
 include/uapi/linux/if_link.h |  1 +
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 78d49d1..5e9bab8 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -49,6 +49,7 @@ struct geneve_dev {
 	u8                 tos;		/* TOS override */
 	struct sockaddr_in remote;	/* IPv4 address for link partner */
 	struct list_head   next;	/* geneve's per namespace list */
+	__be16		   dst_port;
 };
 
 static int geneve_net_id;
@@ -157,7 +158,7 @@ static int geneve_open(struct net_device *dev)
 	struct geneve_net *gn = net_generic(geneve->net, geneve_net_id);
 	struct geneve_sock *gs;
 
-	gs = geneve_sock_add(net, htons(GENEVE_UDP_PORT), geneve_rx, gn,
+	gs = geneve_sock_add(net, geneve->dst_port, geneve_rx, gn,
 	                     false, false);
 	if (IS_ERR(gs))
 		return PTR_ERR(gs);
@@ -225,7 +226,7 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* no need to handle local destination and encap bypass...yet... */
 
 	err = geneve_xmit_skb(gs, rt, skb, fl4.saddr, fl4.daddr,
-	                      tos, ttl, 0, sport, htons(GENEVE_UDP_PORT), 0,
+			      tos, ttl, 0, sport, geneve->dst_port, 0,
 	                      geneve->vni, 0, NULL, false,
 	                      !net_eq(geneve->net, dev_net(geneve->dev)));
 	if (err < 0)
@@ -378,6 +379,11 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 	if (data[IFLA_GENEVE_TOS])
 		geneve->tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
 
+	if (data[IFLA_GENEVE_PORT])
+		geneve->dst_port = htons(nla_get_u16(data[IFLA_GENEVE_PORT]));
+	else
+		geneve->dst_port = htons(GENEVE_UDP_PORT);
+
 	list_add(&geneve->next, &gn->geneve_list);
 
 	hlist_add_head_rcu(&geneve->hlist, &gn->vni_list[hash]);
@@ -402,6 +408,7 @@ static size_t geneve_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(struct in_addr)) + /* IFLA_GENEVE_REMOTE */
 		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TTL */
 		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TOS */
+		nla_total_size(sizeof(__u16)) +  /* IFLA_GENEVE_PORT */
 		0;
 }
 
@@ -422,6 +429,9 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_GENEVE_TOS, geneve->tos))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, IFLA_GENEVE_PORT, ntohs(geneve->dst_port)))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index d450be3..26d4412 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -400,6 +400,7 @@ enum {
 	IFLA_GENEVE_REMOTE,
 	IFLA_GENEVE_TTL,
 	IFLA_GENEVE_TOS,
+	IFLA_GENEVE_PORT,	/* destination port */
 	__IFLA_GENEVE_MAX
 };
 #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
-- 
1.8.3.1
