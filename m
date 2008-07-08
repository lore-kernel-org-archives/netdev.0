From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: v3 [PATCH net-next 5/7] ipv4: Check return of dev_set_allmulti
Date: Tue, 08 Jul 2008 17:41:35 +0800
Message-ID: <4873364F.1030709@cn.fujitsu.com>
References: <48718014.4030009@cn.fujitsu.com> <48718172.8070404@cn.fujitsu.com> <4871FC5C.9030106@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63999 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753441AbYGHJqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 05:46:16 -0400
In-Reply-To: <4871FC5C.9030106@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy said the following on 2008-7-7 19:22:
>>      case 0:
>>          dev = ip_dev_find(&init_net, vifc->vifc_lcl_addr.s_addr);
>>          if (!dev)
>>              return -EADDRNOTAVAIL;
>>          dev_put(dev);
>> +        err = dev_set_allmulti(dev, 1);
>> +        if (err)
>> +            return err;
> 
> Also looks like a use after free, but again, one that is
> already present without your patch.
> 

Here is the patch for fixing use after free.
It fixes both ipv4 and ipv6 side and on top of my patches.
This patch will be the 6/8 of the series.

I will wait for Patrick's ack and resend the whole series again.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a55a23a..23fa3f3 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -441,8 +441,10 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 		dev = ipmr_reg_vif();
 		if (!dev)
 			return -ENOBUFS;
+		dev_hold(dev);
 		err = dev_set_allmulti(dev, 1);
 		if (err) {
+			dev_put(dev);
 			unregister_netdevice(dev);
 			return err;
 		}
@@ -452,8 +454,10 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 		dev = ipmr_new_tunnel(vifc);
 		if (!dev)
 			return -ENOBUFS;
+		dev_hold(dev);
 		err = dev_set_allmulti(dev, 1);
 		if (err) {
+			dev_put(dev);
 			ipmr_del_tunnel(dev, vifc);
 			return err;
 		}
@@ -462,10 +466,11 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 		dev = ip_dev_find(&init_net, vifc->vifc_lcl_addr.s_addr);
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
@@ -496,7 +501,6 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 
 	/* And finish update writing critical data */
 	write_lock_bh(&mrt_lock);
-	dev_hold(dev);
 	v->dev=dev;
 #ifdef CONFIG_IP_PIMSM
 	if (v->flags&VIFF_REGISTER)
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 6cd286d..a9bd74d 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -621,8 +621,10 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 		dev = ip6mr_reg_vif();
 		if (!dev)
 			return -ENOBUFS;
+		dev_hold(dev);
 		err = dev_set_allmulti(dev, 1);
 		if (err) {
+			dev_put(dev);
 			unregister_netdevice(dev);
 			return err;
 		}
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

