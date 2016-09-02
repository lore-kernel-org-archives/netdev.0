From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 2/2] vxlan: fix duplicated and wrong error messages
Date: Fri,  2 Sep 2016 13:37:12 +0200
Message-ID: <d511676fb743ac869cebedc1bd0fba3b1298fe81.1472815982.git.jbenc@redhat.com>
References: <cover.1472815982.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56494 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752073AbcIBLh2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 07:37:28 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 03290C04D2AF
        for <netdev@vger.kernel.org>; Fri,  2 Sep 2016 11:37:25 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-85.brq.redhat.com [10.40.204.85])
        by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u82BbMAl001359
        for <netdev@vger.kernel.org>; Fri, 2 Sep 2016 07:37:24 -0400
In-Reply-To: <cover.1472815982.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan_dev_configure outputs error messages before returning, no need to
print again the same mesages in vxlan_newlink. Also, vxlan_dev_configure may
return a particular error code for a different reason than vxlan_newlink
thinks.

Move the remaining error messages into vxlan_dev_configure and let
vxlan_newlink just pass on the error code.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 35 +++++++++--------------------------
 1 file changed, 9 insertions(+), 26 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6358e35d74b7..6e65832051d6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2782,14 +2782,15 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	struct net_device *lowerdev = NULL;
 
 	if (conf->flags & VXLAN_F_GPE) {
-		if (conf->flags & ~VXLAN_F_ALLOWED_GPE)
-			return -EINVAL;
 		/* For now, allow GPE only together with COLLECT_METADATA.
 		 * This can be relaxed later; in such case, the other side
 		 * of the PtP link will have to be provided.
 		 */
-		if (!(conf->flags & VXLAN_F_COLLECT_METADATA))
+		if ((conf->flags & ~VXLAN_F_ALLOWED_GPE) ||
+		    !(conf->flags & VXLAN_F_COLLECT_METADATA)) {
+			pr_info("unsupported combination of extensions\n");
 			return -EINVAL;
+		}
 
 		vxlan_raw_setup(dev);
 	} else {
@@ -2877,8 +2878,10 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		     tmp->cfg.saddr.sa.sa_family == AF_INET6) == use_ipv6 &&
 		    tmp->cfg.dst_port == vxlan->cfg.dst_port &&
 		    (tmp->flags & VXLAN_F_RCV_FLAGS) ==
-		    (vxlan->flags & VXLAN_F_RCV_FLAGS))
-		return -EEXIST;
+		    (vxlan->flags & VXLAN_F_RCV_FLAGS)) {
+			pr_info("duplicate VNI %u\n", be32_to_cpu(conf->vni));
+			return -EEXIST;
+		}
 	}
 
 	dev->ethtool_ops = &vxlan_ethtool_ops;
@@ -2912,7 +2915,6 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
 	struct vxlan_config conf;
-	int err;
 
 	memset(&conf, 0, sizeof(conf));
 
@@ -3021,26 +3023,7 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	if (tb[IFLA_MTU])
 		conf.mtu = nla_get_u32(tb[IFLA_MTU]);
 
-	err = vxlan_dev_configure(src_net, dev, &conf);
-	switch (err) {
-	case -ENODEV:
-		pr_info("ifindex %d does not exist\n", conf.remote_ifindex);
-		break;
-
-	case -EPERM:
-		pr_info("IPv6 is disabled via sysctl\n");
-		break;
-
-	case -EEXIST:
-		pr_info("duplicate VNI %u\n", be32_to_cpu(conf.vni));
-		break;
-
-	case -EINVAL:
-		pr_info("unsupported combination of extensions\n");
-		break;
-	}
-
-	return err;
+	return vxlan_dev_configure(src_net, dev, &conf);
 }
 
 static void vxlan_dellink(struct net_device *dev, struct list_head *head)
-- 
1.8.3.1
