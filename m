From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] ipip: potential race in ip_tunnel_init_net()
Date: Fri, 23 Aug 2013 11:15:37 +0300
Message-ID: <20130823081537.GB31293@elgon.mountain>
References: <20130820.233301.985050199020241179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130820.233301.985050199020241179.davem@davemloft.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet says that my previous fix for an ERR_PTR dereference
(ea857f28ab 'ipip: dereferencing an ERR_PTR in ip_tunnel_init_net()')
could be racy and suggests the following fix instead.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 24549b4..830de3f 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -854,16 +854,14 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 
 	rtnl_lock();
 	itn->fb_tunnel_dev = __ip_tunnel_create(net, ops, &parms);
-	rtnl_unlock();
-
-	if (IS_ERR(itn->fb_tunnel_dev))
-		return PTR_ERR(itn->fb_tunnel_dev);
 	/* FB netdevice is special: we have one, and only one per netns.
 	 * Allowing to move it to another netns is clearly unsafe.
 	 */
-	itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
+	if (!IS_ERR(itn->fb_tunnel_dev))
+		itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
+	rtnl_unlock();
 
-	return 0;
+	return PTR_RET(itn->fb_tunnel_dev);
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_init_net);
 
