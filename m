From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v4 [PATCH 5/9] ipv6: Fix using after dev_put()
Date: Tue, 15 Jul 2008 10:59:29 +0800
Message-ID: <487C1291.6050107@cn.fujitsu.com>
References: <487C0ABA.1070506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57094 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753029AbYGODEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 23:04:32 -0400
In-Reply-To: <487C0ABA.1070506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy pointed out it.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 6cd286d..faf6650 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -451,6 +451,7 @@ static struct net_device *ip6mr_reg_vif(void)
 	if (dev_open(dev))
 		goto failure;
 
+	dev_hold(dev);
 	return dev;
 
 failure:
@@ -624,6 +625,7 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 		err = dev_set_allmulti(dev, 1);
 		if (err) {
 			unregister_netdevice(dev);
+			dev_put(dev);
 			return err;
 		}
 		break;
@@ -632,10 +634,11 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 		dev = dev_get_by_index(&init_net, vifc->mif6c_pifi);
 		if (!dev)
 			return -EADDRNOTAVAIL;
-		dev_put(dev);
 		err = dev_set_allmulti(dev, 1);
-		if (err)
+		if (err) {
+			dev_put(dev);
 			return err;
+		}
 		break;
 	default:
 		return -EINVAL;
@@ -659,7 +662,6 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 
 	/* And finish update writing critical data */
 	write_lock_bh(&mrt_lock);
-	dev_hold(dev);
 	v->dev = dev;
 #ifdef CONFIG_IPV6_PIMSM_V2
 	if (v->flags & MIFF_REGISTER)



