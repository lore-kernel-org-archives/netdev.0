From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v3 [PATCH net-next 5/7] ipv4: Check return of dev_set_allmulti
Date: Mon, 07 Jul 2008 10:37:38 +0800
Message-ID: <48718172.8070404@cn.fujitsu.com>
References: <48718014.4030009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57177 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752249AbYGGCmP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jul 2008 22:42:15 -0400
In-Reply-To: <48718014.4030009@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check the positive increment for allmulti to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 11700a4..05a2ab8 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -398,6 +398,7 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 	struct vif_device *v = &vif_table[vifi];
 	struct net_device *dev;
 	struct in_device *in_dev;
+	int err;
 
 	/* Is vif busy ? */
 	if (VIF_EXISTS(vifi))
@@ -415,18 +416,31 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 		dev = ipmr_reg_vif();
 		if (!dev)
 			return -ENOBUFS;
+		err = dev_set_allmulti(dev, 1);
+		if (err) {
+			unregister_netdevice(dev);
+			return err;
+		}
 		break;
 #endif
 	case VIFF_TUNNEL:
 		dev = ipmr_new_tunnel(vifc);
 		if (!dev)
 			return -ENOBUFS;
+		err = dev_set_allmulti(dev, 1);
+		if (err) {
+			dev_close(dev);
+			return err;
+		}
 		break;
 	case 0:
 		dev = ip_dev_find(&init_net, vifc->vifc_lcl_addr.s_addr);
 		if (!dev)
 			return -EADDRNOTAVAIL;
 		dev_put(dev);
+		err = dev_set_allmulti(dev, 1);
+		if (err)
+			return err;
 		break;
 	default:
 		return -EINVAL;
@@ -435,7 +449,6 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 	if ((in_dev = __in_dev_get_rtnl(dev)) == NULL)
 		return -EADDRNOTAVAIL;
 	IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)++;
-	dev_set_allmulti(dev, +1);
 	ip_rt_multicast_event(in_dev);
 
 	/*


