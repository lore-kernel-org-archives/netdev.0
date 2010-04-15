From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: [RFC][PATCH] xfrm6 refcnt problem in bundle creation
Date: Thu, 15 Apr 2010 18:32:55 +0200
Message-ID: <4BC73FB7.9090106@dev.6wind.com>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010804040007070907050607"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:59843 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753915Ab0DOQdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Apr 2010 12:33:06 -0400
Received: from smtp4-g21.free.fr (localhost [127.0.0.1])
	by smtp4-g21.free.fr (Postfix) with ESMTP id 295FF4C80D0
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 18:32:58 +0200 (CEST)
Received: from [192.168.1.1] (shm67-6-88-178-145-40.fbx.proxad.net [88.178.145.40])
	by smtp4-g21.free.fr (Postfix) with ESMTP id 2AEC64C8185
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 18:32:56 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010804040007070907050607
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi all,

I got a ref count problem in xfrm IPv6 part, but I don't really know what is the 
best way to fix it.

When xfrm6_fill_dst() is called, a dev is given as parameter:

static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
                           struct flowi *fl)
{
         struct rt6_info *rt = (struct rt6_info*)xdst->route;

         xdst->u.dst.dev = dev;
         dev_hold(dev);

         xdst->u.rt6.rt6i_idev = in6_dev_get(rt->u.dst.dev);
         if (!xdst->u.rt6.rt6i_idev)
                 return -ENODEV;
[snip]

In my case, dev points to an ethernet device and the route (rt->u.dst.dev) 
points to a tunnel interface (ip6 over ip6). This function will get a ref on the 
idev of the tunnel (xdst->u.rt6.rt6i_idev = in6_dev_get(rt->u.dst.dev)), but dev 
of the dst is set to the ethernet interface (xdst->u.dst.dev = dev).
After, when we try to remove the tunnel interface, the xfrm gc function will 
never check rt6i_idev, it will only check u.dst.dev, hence it will not remove 
the dst.
The consequence is that the interface cannot be removed.

IPv4 code takes the same dev to get idev, rather than using rt->u.dst.dev. Is it 
right to do the same in IPv6?
A proposal patch is attached.

Code, before the patch of the bundle creation merge, takes 'rt->u.dst.dev' to 
get idev and to set dst.dev.

Suggestions are welcome.


Regards,
Nicolas

--------------010804040007070907050607
Content-Type: text/x-diff;
 name="0001-xfrm6-ensure-to-use-the-same-dev-when-building-a-bu.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-xfrm6-ensure-to-use-the-same-dev-when-building-a-bu.pat";
 filename*1="ch"

>From 80432d47369925d4e9e38bcb1068ebf923de3a8f Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 15 Apr 2010 18:27:30 +0200
Subject: [PATCH] xfrm6: ensure to use the same dev when building a bundle

When building a bundle, we set dst.dev and rt6.rt6i_idev.
We must ensure to set the same device for both fields.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/xfrm6_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index ae18165..00bf7c9 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -124,7 +124,7 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
 
-	xdst->u.rt6.rt6i_idev = in6_dev_get(rt->u.dst.dev);
+	xdst->u.rt6.rt6i_idev = in6_dev_get(dev);
 	if (!xdst->u.rt6.rt6i_idev)
 		return -ENODEV;
 
-- 
1.5.4.5


--------------010804040007070907050607--
