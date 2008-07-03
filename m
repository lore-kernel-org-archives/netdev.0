From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v4 [PATCH net-next 4/7] ipv6: Check return of dev_set_allmulti
Date: Thu, 03 Jul 2008 11:23:44 +0800
Message-ID: <486C4640.8060009@cn.fujitsu.com>
References: <4869A251.108@cn.fujitsu.com> <4869A3EF.60403@cn.fujitsu.com> <4869FB47.6080502@trash.net> <486B3996.8000201@cn.fujitsu.com> <486B7A7D.2020700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49520 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754635AbYGCD2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 23:28:18 -0400
In-Reply-To: <486B7A7D.2020700@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy said the following on 2008-7-2 20:54:
>> +    dev_close(dev);
>> +    unregister_netdevice(dev);
> 
> dev_close is already performed by unregister_netdevice.
> 
>> +    free_netdev(dev);
> 
> This is a double free, the device uses free_netdev as destructor.
> 

Patrick, thanks for your time.
I am so shame for being unware such idiot mistake.

v3->v4
As Patrick said, unregister_netdevice() can do all unwind job
for ip6mr_reg_vif().

allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check the positive increment for allmulti to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 1479618..6cd286d 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -603,6 +603,7 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 	int vifi = vifc->mif6c_mifi;
 	struct mif_device *v = &vif6_table[vifi];
 	struct net_device *dev;
+	int err;
 
 	/* Is vif busy ? */
 	if (MIF_EXISTS(vifi))
@@ -620,6 +621,11 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 		dev = ip6mr_reg_vif();
 		if (!dev)
 			return -ENOBUFS;
+		err = dev_set_allmulti(dev, 1);
+		if (err) {
+			unregister_netdevice(dev);
+			return err;
+		}
 		break;
 #endif
 	case 0:
@@ -627,13 +633,14 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
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

