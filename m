From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v5 3/6] vxlan: introduce vxlan_fdb_parse
Date: Tue, 25 Jun 2013 16:01:53 +0300
Message-ID: <1372165316-17647-4-git-send-email-mike.rapoport@ravellosystems.com>
References: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog108.obsmtp.com ([74.125.245.84]:40292 "HELO
	na3sys010aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751177Ab3FYNCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 09:02:18 -0400
Received: by mail-wg0-f42.google.com with SMTP id z11so754882wgg.3
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 06:02:16 -0700 (PDT)
In-Reply-To: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

which will be reused by vxlan_fdb_delete

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c | 81 +++++++++++++++++++++++++++++++++--------------------
 1 file changed, 50 insertions(+), 31 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 306bd94..ee7cc71 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -518,58 +518,77 @@ static void vxlan_fdb_destroy(struct vxlan_dev *vxlan, struct vxlan_fdb *f)
 	call_rcu(&f->rcu, vxlan_fdb_free);
 }
 
-/* Add static entry (via netlink) */
-static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
-			 struct net_device *dev,
-			 const unsigned char *addr, u16 flags)
+static int vxlan_fdb_parse(struct nlattr *tb[], struct vxlan_dev *vxlan,
+			   __be32 *ip, __be16 *port, u32 *vni, u32 *ifindex)
 {
-	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct net *net = dev_net(vxlan->dev);
-	__be32 ip;
-	__be16 port;
-	u32 vni, ifindex;
-	int err;
-
-	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_REACHABLE))) {
-		pr_info("RTM_NEWNEIGH with invalid state %#x\n",
-			ndm->ndm_state);
-		return -EINVAL;
-	}
-
-	if (tb[NDA_DST] == NULL)
-		return -EINVAL;
 
-	if (nla_len(tb[NDA_DST]) != sizeof(__be32))
-		return -EAFNOSUPPORT;
+	if (tb[NDA_DST]) {
+		if (nla_len(tb[NDA_DST]) != sizeof(__be32))
+			return -EAFNOSUPPORT;
 
-	ip = nla_get_be32(tb[NDA_DST]);
+		*ip = nla_get_be32(tb[NDA_DST]);
+	} else {
+		*ip = htonl(INADDR_ANY);
+	}
 
 	if (tb[NDA_PORT]) {
 		if (nla_len(tb[NDA_PORT]) != sizeof(__be16))
 			return -EINVAL;
-		port = nla_get_be16(tb[NDA_PORT]);
-	} else
-		port = vxlan->dst_port;
+		*port = nla_get_be16(tb[NDA_PORT]);
+	} else {
+		*port = vxlan->dst_port;
+	}
 
 	if (tb[NDA_VNI]) {
 		if (nla_len(tb[NDA_VNI]) != sizeof(u32))
 			return -EINVAL;
-		vni = nla_get_u32(tb[NDA_VNI]);
-	} else
-		vni = vxlan->default_dst.remote_vni;
+		*vni = nla_get_u32(tb[NDA_VNI]);
+	} else {
+		*vni = vxlan->default_dst.remote_vni;
+	}
 
 	if (tb[NDA_IFINDEX]) {
 		struct net_device *tdev;
 
 		if (nla_len(tb[NDA_IFINDEX]) != sizeof(u32))
 			return -EINVAL;
-		ifindex = nla_get_u32(tb[NDA_IFINDEX]);
-		tdev = dev_get_by_index(net, ifindex);
+		*ifindex = nla_get_u32(tb[NDA_IFINDEX]);
+		tdev = dev_get_by_index(net, *ifindex);
 		if (!tdev)
 			return -EADDRNOTAVAIL;
 		dev_put(tdev);
-	} else
-		ifindex = 0;
+	} else {
+		*ifindex = 0;
+	}
+
+	return 0;
+}
+
+/* Add static entry (via netlink) */
+static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+			 struct net_device *dev,
+			 const unsigned char *addr, u16 flags)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	/* struct net *net = dev_net(vxlan->dev); */
+	__be32 ip;
+	__be16 port;
+	u32 vni, ifindex;
+	int err;
+
+	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_REACHABLE))) {
+		pr_info("RTM_NEWNEIGH with invalid state %#x\n",
+			ndm->ndm_state);
+		return -EINVAL;
+	}
+
+	if (tb[NDA_DST] == NULL)
+		return -EINVAL;
+
+	err = vxlan_fdb_parse(tb, vxlan, &ip, &port, &vni, &ifindex);
+	if (err)
+		return err;
 
 	spin_lock_bh(&vxlan->hash_lock);
 	err = vxlan_fdb_create(vxlan, addr, ip, ndm->ndm_state, flags,
-- 
1.8.1.5
