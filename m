From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vlan:make mtu of vlan equal to physical dev
Date: Mon, 10 Oct 2011 00:00:09 -0400 (EDT)
Message-ID: <20111010.000009.1901557507648118650.davem@davemloft.net>
References: <bc33a6142ce48b71b9c232a9154ed76f6048f0cb.1318068629.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au
To: panweiping3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715Ab1JJEAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 00:00:19 -0400
In-Reply-To: <bc33a6142ce48b71b9c232a9154ed76f6048f0cb.1318068629.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <panweiping3@gmail.com>
Date: Sat,  8 Oct 2011 18:12:15 +0800

[ Herbert, Weiping is suggesting to remove the "vlandev->mtu <= dev->mtu"
  test in your patch below. ]

> Default mtu of vlan device is the same with mtu of physical device,
> for example 1500, but when change physics mtu to 1600,
> VLAN device's mtu is still 1500.
> Certainly, you can change vlan device's mtu to 1600 manually,
> but I think when you change physics device's mtu, VLAN's mtu should be changed
> automatically instead of by manually.
> 
> Steps to Reproduce:
> 1.vconfig add eth4 3
> 2.ifconfig eth4 mtu 1600
> 3.check mtu on eth4.3
> 
> And what's worse is that if you decrease mtu of pyhsical device,
> and when you want to increase it, the mtu of vlan device won't be changed.
> 
> Steps to Reproduce:
> 1.vconfig add eth4 3
> 2.ifconfig eth4 mtu 100
> 3.ifconfig eth4 mtu 1500
> 4.the mtu of eth4.3 is still 100
> 
> This bug is reported by Liang Zheng(lzheng@redhat.com).
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>

But now this setting is unconditional, and thus value user made
settings will be ignored.

The code that is there now is just a safety measure, and the
test appears to very much be intentional:

--------------------
commit 2e477c9bd2bb6a1606e498adb53ba913378ecdf2
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Mon Jul 20 07:35:37 2009 -0700

    vlan: Propagate physical MTU changes
    
    When the physical MTU changes we want to ensure that all existing
    VLAN device MTUs do not exceed the new underlying MTU.  This patch
    adds that propagation.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index fe64908..6d37b7e 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -468,6 +468,19 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		}
 		break;
 
+	case NETDEV_CHANGEMTU:
+		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+			vlandev = vlan_group_get_device(grp, i);
+			if (!vlandev)
+				continue;
+
+			if (vlandev->mtu <= dev->mtu)
+				continue;
+
+			dev_set_mtu(vlandev, dev->mtu);
+		}
+		break;
+
 	case NETDEV_FEAT_CHANGE:
 		/* Propagate device features to underlying device */
 		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
