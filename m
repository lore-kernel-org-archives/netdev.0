From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] vxlan: advertise link netns in fdb messages
Date: Mon, 26 Jan 2015 14:10:53 +0100
Message-ID: <1422277853-5722-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40817 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755817AbbAZO36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 09:29:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previous commit is based on a wrong assumption, fdb messages are always sent
into the netns where the interface stands (see vxlan_fdb_notify()).

These fdb messages doesn't embed the rtnl attribute IFLA_LINK_NETNSID, thus we
need to add it (useful to interpret NDA_IFINDEX or NDA_DST for example).

Note also that vxlan_nlmsg_size() was not updated.

Fixes: 193523bf9373 ("vxlan: advertise netns of vxlan dev in fdb msg")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

Note that NDA_NDM_IFINDEX_NETNSID exists only in net-next, thus it's still
possible to remove it.

 drivers/net/vxlan.c            | 5 +++--
 include/uapi/linux/neighbour.h | 2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 19d3664ab9dd..c20a71fdcfa3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -340,8 +340,8 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	ndm->ndm_type = RTN_UNICAST;
 
 	if (!net_eq(dev_net(vxlan->dev), vxlan->net) &&
-	    nla_put_s32(skb, NDA_NDM_IFINDEX_NETNSID,
-			peernet2id(vxlan->net, dev_net(vxlan->dev))))
+	    nla_put_s32(skb, NDA_LINK_NETNSID,
+			peernet2id(dev_net(vxlan->dev), vxlan->net)))
 		goto nla_put_failure;
 
 	if (send_eth && nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
@@ -384,6 +384,7 @@ static inline size_t vxlan_nlmsg_size(void)
 		+ nla_total_size(sizeof(__be16)) /* NDA_PORT */
 		+ nla_total_size(sizeof(__be32)) /* NDA_VNI */
 		+ nla_total_size(sizeof(__u32)) /* NDA_IFINDEX */
+		+ nla_total_size(sizeof(__s32)) /* NDA_LINK_NETNSID */
 		+ nla_total_size(sizeof(struct nda_cacheinfo));
 }
 
diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index 38f236853cc0..3873a35509aa 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -25,7 +25,7 @@ enum {
 	NDA_VNI,
 	NDA_IFINDEX,
 	NDA_MASTER,
-	NDA_NDM_IFINDEX_NETNSID,
+	NDA_LINK_NETNSID,
 	__NDA_MAX
 };
 
-- 
2.2.2
