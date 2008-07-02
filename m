From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v3 [PATCH net-next 4/7] ipv6: Check return of dev_set_allmulti
Date: Wed, 02 Jul 2008 16:17:26 +0800
Message-ID: <486B3996.8000201@cn.fujitsu.com>
References: <4869A251.108@cn.fujitsu.com> <4869A3EF.60403@cn.fujitsu.com> <4869FB47.6080502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64388 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752457AbYGBIWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 04:22:00 -0400
In-Reply-To: <4869FB47.6080502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2->v3:
  Do unwind job when error happen.

allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check the positive increment for allmulti to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 1479618..ba763b8 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -461,6 +461,13 @@ failure:
 	unregister_netdevice(dev);
 	return NULL;
 }
+
+static void ip6mr_unreg_vif(struct net_device *dev)
+{
+	dev_close(dev);
+	unregister_netdevice(dev);
+	free_netdev(dev);
+}
 #endif
 
 /*
@@ -603,6 +610,7 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 	int vifi = vifc->mif6c_mifi;
 	struct mif_device *v = &vif6_table[vifi];
 	struct net_device *dev;
+	int err;
 
 	/* Is vif busy ? */
 	if (MIF_EXISTS(vifi))
@@ -620,6 +628,11 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 		dev = ip6mr_reg_vif();
 		if (!dev)
 			return -ENOBUFS;
+		err = dev_set_allmulti(dev, 1);
+		if (err) {
+			ip6mr_unreg_vif(dev);
+			return err;
+		}
 		break;
 #endif
 	case 0:
@@ -627,13 +640,14 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 		if (!dev)
 			return -EADDRNOTAVAIL;
 		dev_put(dev);
+		err = dev_set_allmulti(dev, 1);
+		if (err)
+			return err;
 		break;
 	default:
 		return -EINVAL;
 	}
 
-	dev_set_allmulti(dev, 1);
-
 	/*
 	 *	Fill in the VIF structures
 	 */

