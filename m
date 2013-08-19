From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next v2] ipip: dereferencing an ERR_PTR in
 ip_tunnel_init_net()
Date: Tue, 20 Aug 2013 01:23:07 +0300
Message-ID: <20130819222307.GA3622@elgon.mountain>
References: <1376917088.4226.50.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23391 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224Ab3HSWYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 18:24:01 -0400
Content-Disposition: inline
In-Reply-To: <1376917088.4226.50.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The __ip_tunnel_create() function returns an ERR_PTR on error so we need
to check for that before dereferencing.  This bug was added in commit
6c742e714d8c2 ("ipip: add x-netns support").

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: Eric Dumazet said v1 patch looked racy and suggested the v2 fix.

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index a4d9126..830de3f 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -857,13 +857,11 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 	/* FB netdevice is special: we have one, and only one per netns.
 	 * Allowing to move it to another netns is clearly unsafe.
 	 */
-	itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
+	if (!IS_ERR(itn->fb_tunnel_dev))
+		itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
 	rtnl_unlock();
 
-	if (IS_ERR(itn->fb_tunnel_dev))
-		return PTR_ERR(itn->fb_tunnel_dev);
-
-	return 0;
+	return PTR_RET(itn->fb_tunnel_dev);
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_init_net);
 
