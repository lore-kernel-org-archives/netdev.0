From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next 3/4] gtp: add support to select a GTP socket during PDP context creation
Date: Tue, 14 Mar 2017 12:25:47 +0100
Message-ID: <20170314112548.24027-4-aschultz@tpip.net>
References: <20170314112548.24027-1-aschultz@tpip.net>
Cc: osmocom-net-gprs@lists.osmocom.org,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
To: Harald Welte <laforge@gnumonks.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:43967 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750849AbdCNL1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 07:27:24 -0400
In-Reply-To: <20170314112548.24027-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For each new PDP a separate socket can be selected. The per netdevice
default sockets are no longer mandatory.

This means also that multiple gtp netdevices can share the same default
socket and that therefore the destruction of a gtp netdevice can no
longer automatically disable the gtp encapsulation on it's sockets.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 79 +++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 68 insertions(+), 11 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index c4cf1b9..afa043d 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -381,9 +381,6 @@ static int gtp_dev_init(struct net_device *dev)
 
 static void gtp_dev_uninit(struct net_device *dev)
 {
-	struct gtp_dev *gtp = netdev_priv(dev);
-
-	gtp_encap_disable(gtp);
 	free_percpu(dev->tstats);
 }
 
@@ -647,9 +644,6 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 	struct gtp_net *gn;
 	int hashsize, err;
 
-	if (!data[IFLA_GTP_FD0] && !data[IFLA_GTP_FD1])
-		return -EINVAL;
-
 	gtp = netdev_priv(dev);
 
 	if (!data[IFLA_GTP_PDP_HASHSIZE])
@@ -689,8 +683,11 @@ static void gtp_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct gtp_dev *gtp = netdev_priv(dev);
 
-	gtp_encap_disable(gtp);
 	gtp_hashtable_free(gtp);
+	if (gtp->sk0)
+		sock_put(gtp->sk0);
+	if (gtp->sk1u)
+		sock_put(gtp->sk1u);
 	list_del_rcu(&gtp->list);
 	unregister_netdevice_queue(dev, head);
 }
@@ -1008,9 +1005,10 @@ static void pdp_context_delete(struct pdp_ctx *pctx)
 
 static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 {
+	struct socket *sock = NULL;
+	struct sock *sk = NULL;
 	unsigned int version;
 	struct gtp_dev *gtp;
-	struct sock *sk;
 	int err;
 
 	if (!info->attrs[GTPA_VERSION] ||
@@ -1045,12 +1043,14 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 		goto out_unlock;
 	}
 
-	if (version == GTP_V0)
+	if (info->attrs[GTPA_FD]) {
+		sock = sockfd_lookup(nla_get_u32(info->attrs[GTPA_FD]), &err);
+		if (sock)
+			sk = sock->sk;
+	} else if (version == GTP_V0)
 		sk = gtp->sk0;
 	else if (version == GTP_V1)
 		sk = gtp->sk1u;
-	else
-		sk = NULL;
 
 	if (!sk) {
 		err = -ENODEV;
@@ -1059,6 +1059,9 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 
 	err = ipv4_pdp_add(gtp, sk, info);
 
+	if (sock)
+		sockfd_put(sock);
+
 out_unlock:
 	rcu_read_unlock();
 	return err;
@@ -1079,12 +1082,66 @@ static struct pdp_ctx *gtp_find_pdp_by_link(struct net *net,
 	return ipv4_pdp_find(gtp, nla_get_be32(nla[GTPA_MS_ADDRESS]));
 }
 
+static struct pdp_ctx *gtp_genl_find_pdp_by_socket(struct net *net,
+						   struct nlattr *nla[])
+{
+	struct socket *sock;
+	struct gtp_sock *gsk;
+	struct pdp_ctx *pctx;
+	int fd, err = 0;
+
+	if (!nla[GTPA_FD])
+		return ERR_PTR(-EINVAL);
+
+	fd = nla_get_u32(nla[GTPA_FD]);
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
+	switch (nla_get_u32(nla[GTPA_VERSION])) {
+	case GTP_V0:
+		if (!nla[GTPA_TID]) {
+			pctx = ERR_PTR(-EINVAL);
+			break;
+		}
+		pctx = gtp0_pdp_find(gsk, nla_get_u64(nla[GTPA_TID]));
+		break;
+
+	case GTP_V1:
+		if (!nla[GTPA_I_TEI]) {
+			pctx = ERR_PTR(-EINVAL);
+			break;
+		}
+		pctx = gtp1_pdp_find(gsk, nla_get_u64(nla[GTPA_I_TEI]));
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
 static struct pdp_ctx *gtp_find_pdp(struct net *net, struct nlattr *nla[])
 {
 	struct pdp_ctx *pctx;
 
 	if (nla[GTPA_LINK])
 		pctx = gtp_find_pdp_by_link(net, nla);
+	else if (nla[GTPA_FD])
+		pctx = gtp_genl_find_pdp_by_socket(net, nla);
+
 	else
 		pctx = ERR_PTR(-EINVAL);
 
-- 
2.10.2
