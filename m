From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 17/17] gtp: add support to select a GTP socket during PDP context creation
Date: Mon, 23 Jan 2017 12:57:06 +0100
Message-ID: <20170123115706.4354-18-aschultz@tpip.net>
References: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:39385 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751074AbdAWMG4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:56 -0500
In-Reply-To: <20170123115706.4354-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 65 insertions(+), 3 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 157cf40..53faaa4 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -1016,6 +1016,7 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 	struct net_device *dev;
 	struct net *net;
 	struct socket *sock;
+	int err;
 
 	if (!info->attrs[GTPA_VERSION] ||
 	    !info->attrs[GTPA_LINK] ||
@@ -1053,11 +1054,19 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 	}
 	put_net(net);
 
-	sock = gtp_genl_new_pdp_select_socket(version, dev);
-	if (!sock)
+	if (info->attrs[GTPA_FD])
+		sock = sockfd_lookup(nla_get_u32(info->attrs[GTPA_FD]), &err);
+	else
+		sock = gtp_genl_new_pdp_select_socket(version, dev);
+	if (!sock || !sock->sk)
 		return -ENODEV;
 
-	return ipv4_pdp_add(dev, sock->sk, info);
+	err = ipv4_pdp_add(dev, sock->sk, info);
+
+	if (info->attrs[GTPA_FD])
+		sockfd_put(sock);
+
+	return err;
 }
 
 static struct pdp_ctx *gtp_genl_find_pdp_by_link(struct sk_buff *skb,
@@ -1089,11 +1098,64 @@ static struct pdp_ctx *gtp_genl_find_pdp_by_link(struct sk_buff *skb,
 	return ipv4_pdp_find(gtp, ms_addr);
 }
 
+static struct pdp_ctx *gtp_genl_find_pdp_by_socket(struct sk_buff *skb,
+						   struct genl_info *info)
+{
+	struct socket *sock;
+	struct gtp_sock *gsk;
+	struct pdp_ctx *pctx;
+	int fd, err = 0;
+
+	if (!info->attrs[GTPA_FD])
+		return ERR_PTR(-EINVAL);
+
+	fd = nla_get_u32(info->attrs[GTPA_FD]);
+	sock = sockfd_lookup(fd, &err);
+	if (!sock) {
+		pr_debug("gtp socket fd=%d not found\n", fd);
+		return ERR_PTR(-EBADF);
+	}
+
+	gsk = rcu_dereference_sk_user_data(sock->sk);
+	if (!gsk) {
+		pctx = ERR_PTR(-EINVAL);
+		goto out_sock;
+	}
+
+	switch (nla_get_u32(info->attrs[GTPA_VERSION])) {
+	case GTP_V0:
+		if (!info->attrs[GTPA_TID]) {
+			pctx = ERR_PTR(-EINVAL);
+			break;
+		}
+		pctx = gtp0_pdp_find(gsk, nla_get_u64(info->attrs[GTPA_TID]));
+		break;
+
+	case GTP_V1:
+		if (!info->attrs[GTPA_I_TEI]) {
+			pctx = ERR_PTR(-EINVAL);
+			break;
+		}
+		pctx = gtp1_pdp_find(gsk, nla_get_u64(info->attrs[GTPA_I_TEI]));
+		break;
+
+	default:
+		pctx = ERR_PTR(-EINVAL);
+		break;
+	}
+
+out_sock:
+	sockfd_put(sock);
+	return pctx;
+}
+
 static struct pdp_ctx *gtp_genl_find_pdp(struct sk_buff *skb,
 					 struct genl_info *info)
 {
 	if (info->attrs[GTPA_LINK])
 		return gtp_genl_find_pdp_by_link(skb, info);
+	else if (info->attrs[GTPA_FD])
+		return gtp_genl_find_pdp_by_socket(skb, info);
 	else
 		return ERR_PTR(-EINVAL);
 }
-- 
2.10.2
