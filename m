From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v3 [PATCH net-next 5/7] ipv4: Check return of dev_set_allmulti
Date: Wed, 02 Jul 2008 16:24:18 +0800
Message-ID: <486B3B32.3090702@cn.fujitsu.com>
References: <4869A251.108@cn.fujitsu.com> <4869A42A.2010009@cn.fujitsu.com> <4869FB80.8050107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62600 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752672AbYGBI3A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 04:29:00 -0400
In-Reply-To: <4869FB80.8050107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2->v3
  Do some unwind work when error happen.

allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check the positive increment for allmulti to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 11700a4..b1916d2 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -244,6 +244,13 @@ failure:
 	unregister_netdevice(dev);
 	return NULL;
 }
+
+static void ipmr_unreg_vif(struct net_device *dev)
+{
+	dev_close(dev);
+	unregister_netdevice(dev);
+	free_netdev(dev);
+}
 #endif
 
 /*
@@ -398,6 +405,7 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 	struct vif_device *v = &vif_table[vifi];
 	struct net_device *dev;
 	struct in_device *in_dev;
+	int err;
 
 	/* Is vif busy ? */
 	if (VIF_EXISTS(vifi))
@@ -415,18 +423,31 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 		dev = ipmr_reg_vif();
 		if (!dev)
 			return -ENOBUFS;
+		err = dev_set_allmulti(dev, 1);
+		if (err) {
+			ipmr_unreg_vif(dev);
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
@@ -435,7 +456,6 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 	if ((in_dev = __in_dev_get_rtnl(dev)) == NULL)
 		return -EADDRNOTAVAIL;
 	IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)++;
-	dev_set_allmulti(dev, +1);
 	ip_rt_multicast_event(in_dev);
 
 	/*

