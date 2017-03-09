From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v5 3/7] gtp: merge gtp_get_net and gtp_genl_find_dev
Date: Thu,  9 Mar 2017 17:42:58 +0100
Message-ID: <20170309164302.13550-4-aschultz@tpip.net>
References: <20170309164302.13550-1-aschultz@tpip.net>
Cc: osmocom-net-gprs@lists.osmocom.org, netdev <netdev@vger.kernel.org>
To: Harald Welte <laforge@gnumonks.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:51672 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932722AbdCIQna (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 11:43:30 -0500
In-Reply-To: <20170309164302.13550-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both function are always used together with the final goal to
get the gtp_dev. This simplifies the code by merging them together.

The netdevice lookup is changed to use the regular dev_get_by_index.
The gtp netdevice list is now only used to find the PDP contexts for
imcomming packets. It can be completely eliminated Once the TEID
hash is moved into the GTP socket.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 146 ++++++++++++++++++++++++++----------------------------
 1 file changed, 69 insertions(+), 77 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 9aa2b35..74018eb 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -744,21 +744,6 @@ static struct rtnl_link_ops gtp_link_ops __read_mostly = {
 	.fill_info	= gtp_fill_info,
 };
 
-static struct net *gtp_genl_get_net(struct net *src_net, struct nlattr *tb[])
-{
-	struct net *net;
-
-	/* Examine the link attributes and figure out which network namespace
-	 * we are talking about.
-	 */
-	if (tb[GTPA_NET_NS_FD])
-		net = get_net_ns_by_fd(nla_get_u32(tb[GTPA_NET_NS_FD]));
-	else
-		net = get_net(src_net);
-
-	return net;
-}
-
 static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize)
 {
 	int i;
@@ -872,16 +857,30 @@ static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[])
 	return 0;
 }
 
-static struct net_device *gtp_find_dev(struct net *net, int ifindex)
+static struct gtp_dev *gtp_find_dev(struct net *src_net, struct nlattr *nla[])
 {
-	struct gtp_net *gn = net_generic(net, gtp_net_id);
-	struct gtp_dev *gtp;
-
-	list_for_each_entry_rcu(gtp, &gn->gtp_dev_list, list) {
-		if (ifindex == gtp->dev->ifindex)
-			return gtp->dev;
-	}
-	return NULL;
+	struct gtp_dev *gtp = NULL;
+	struct net_device *dev;
+	struct net *net;
+
+	/* Examine the link attributes and figure out which network namespace
+	 * we are talking about.
+	 */
+	if (nla[GTPA_NET_NS_FD])
+		net = get_net_ns_by_fd(nla_get_u32(nla[GTPA_NET_NS_FD]));
+	else
+		net = get_net(src_net);
+
+	if (IS_ERR(net))
+		return NULL;
+
+	/* Check if there's an existing gtpX device to configure */
+	dev = dev_get_by_index_rcu(net, nla_get_u32(nla[GTPA_LINK]));
+	if (dev->netdev_ops == &gtp_netdev_ops)
+		gtp = netdev_priv(dev);
+
+	put_net(net);
+	return gtp;
 }
 
 static void ipv4_pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
@@ -911,9 +910,9 @@ static void ipv4_pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
 	}
 }
 
-static int ipv4_pdp_add(struct net_device *dev, struct genl_info *info)
+static int ipv4_pdp_add(struct gtp_dev *gtp, struct genl_info *info)
 {
-	struct gtp_dev *gtp = netdev_priv(dev);
+	struct net_device *dev = gtp->dev;
 	u32 hash_ms, hash_tid = 0;
 	struct pdp_ctx *pctx;
 	bool found = false;
@@ -990,8 +989,8 @@ static int ipv4_pdp_add(struct net_device *dev, struct genl_info *info)
 
 static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 {
-	struct net_device *dev;
-	struct net *net;
+	struct gtp_dev *gtp;
+	int err;
 
 	if (!info->attrs[GTPA_VERSION] ||
 	    !info->attrs[GTPA_LINK] ||
@@ -1015,77 +1014,79 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 	}
 
-	net = gtp_genl_get_net(sock_net(skb->sk), info->attrs);
-	if (IS_ERR(net))
-		return PTR_ERR(net);
+	rcu_read_lock();
 
-	/* Check if there's an existing gtpX device to configure */
-	dev = gtp_find_dev(net, nla_get_u32(info->attrs[GTPA_LINK]));
-	if (dev == NULL) {
-		put_net(net);
-		return -ENODEV;
+	gtp = gtp_find_dev(sock_net(skb->sk), info->attrs);
+	if (!gtp) {
+		err = -ENODEV;
+		goto out_unlock;
 	}
-	put_net(net);
 
-	return ipv4_pdp_add(dev, info);
+	err = ipv4_pdp_add(gtp, info);
+
+out_unlock:
+	rcu_read_unlock();
+	return err;
 }
 
 static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
 {
-	struct net_device *dev;
 	struct pdp_ctx *pctx;
 	struct gtp_dev *gtp;
-	struct net *net;
+	int err = 0;
 
 	if (!info->attrs[GTPA_VERSION] ||
 	    !info->attrs[GTPA_LINK])
 		return -EINVAL;
 
-	net = gtp_genl_get_net(sock_net(skb->sk), info->attrs);
-	if (IS_ERR(net))
-		return PTR_ERR(net);
+	rcu_read_lock();
 
-	/* Check if there's an existing gtpX device to configure */
-	dev = gtp_find_dev(net, nla_get_u32(info->attrs[GTPA_LINK]));
-	if (dev == NULL) {
-		put_net(net);
-		return -ENODEV;
+	gtp = gtp_find_dev(sock_net(skb->sk), info->attrs);
+	if (!gtp) {
+		err = -ENODEV;
+		goto out_unlock;
 	}
-	put_net(net);
-
-	gtp = netdev_priv(dev);
 
 	switch (nla_get_u32(info->attrs[GTPA_VERSION])) {
 	case GTP_V0:
-		if (!info->attrs[GTPA_TID])
-			return -EINVAL;
+		if (!info->attrs[GTPA_TID]) {
+			err = -EINVAL;
+			goto out_unlock;
+		}
 		pctx = gtp0_pdp_find(gtp, nla_get_u64(info->attrs[GTPA_TID]));
 		break;
 	case GTP_V1:
-		if (!info->attrs[GTPA_I_TEI])
-			return -EINVAL;
+		if (!info->attrs[GTPA_I_TEI]) {
+			err = -EINVAL;
+			goto out_unlock;
+		}
 		pctx = gtp1_pdp_find(gtp, nla_get_u64(info->attrs[GTPA_I_TEI]));
 		break;
 
 	default:
-		return -EINVAL;
+		err = -EINVAL;
+		goto out_unlock;
 	}
 
-	if (pctx == NULL)
-		return -ENOENT;
+	if (!pctx) {
+		err = -ENOENT;
+		goto out_unlock;
+	}
 
 	if (pctx->gtp_version == GTP_V0)
-		netdev_dbg(dev, "GTPv0-U: deleting tunnel id = %llx (pdp %p)\n",
+		netdev_dbg(gtp->dev, "GTPv0-U: deleting tunnel id = %llx (pdp %p)\n",
 			   pctx->u.v0.tid, pctx);
 	else if (pctx->gtp_version == GTP_V1)
-		netdev_dbg(dev, "GTPv1-U: deleting tunnel id = %x/%x (pdp %p)\n",
+		netdev_dbg(gtp->dev, "GTPv1-U: deleting tunnel id = %x/%x (pdp %p)\n",
 			   pctx->u.v1.i_tei, pctx->u.v1.o_tei, pctx);
 
 	hlist_del_rcu(&pctx->hlist_tid);
 	hlist_del_rcu(&pctx->hlist_addr);
 	kfree_rcu(pctx, rcu_head);
 
-	return 0;
+out_unlock:
+	rcu_read_unlock();
+	return err;
 }
 
 static struct genl_family gtp_genl_family;
@@ -1129,11 +1130,9 @@ static int gtp_genl_fill_info(struct sk_buff *skb, u32 snd_portid, u32 snd_seq,
 static int gtp_genl_get_pdp(struct sk_buff *skb, struct genl_info *info)
 {
 	struct pdp_ctx *pctx = NULL;
-	struct net_device *dev;
 	struct sk_buff *skb2;
 	struct gtp_dev *gtp;
 	u32 gtp_version;
-	struct net *net;
 	int err;
 
 	if (!info->attrs[GTPA_VERSION] ||
@@ -1149,21 +1148,14 @@ static int gtp_genl_get_pdp(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 	}
 
-	net = gtp_genl_get_net(sock_net(skb->sk), info->attrs);
-	if (IS_ERR(net))
-		return PTR_ERR(net);
-
-	/* Check if there's an existing gtpX device to configure */
-	dev = gtp_find_dev(net, nla_get_u32(info->attrs[GTPA_LINK]));
-	if (dev == NULL) {
-		put_net(net);
-		return -ENODEV;
-	}
-	put_net(net);
-
-	gtp = netdev_priv(dev);
-
 	rcu_read_lock();
+
+	gtp = gtp_find_dev(sock_net(skb->sk), info->attrs);
+	if (!gtp) {
+		err = -ENODEV;
+		goto err_unlock;
+	}
+
 	if (gtp_version == GTP_V0 &&
 	    info->attrs[GTPA_TID]) {
 		u64 tid = nla_get_u64(info->attrs[GTPA_TID]);
-- 
2.10.2
