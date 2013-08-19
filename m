From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch -next] ipip: dereferencing an ERR_PTR in
 ip_tunnel_init_net()
Date: Mon, 19 Aug 2013 05:58:08 -0700
Message-ID: <1376917088.4226.50.camel@edumazet-glaptop>
References: <20130819070510.GE28591@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130819070510.GE28591@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-08-19 at 10:05 +0300, Dan Carpenter wrote:
> We need to move the derefernce after the IS_ERR() check.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index a4d9126..24549b4 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -854,14 +854,14 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
>  
>  	rtnl_lock();
>  	itn->fb_tunnel_dev = __ip_tunnel_create(net, ops, &parms);
> -	/* FB netdevice is special: we have one, and only one per netns.
> -	 * Allowing to move it to another netns is clearly unsafe.
> -	 */
> -	itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
>  	rtnl_unlock();
>  
>  	if (IS_ERR(itn->fb_tunnel_dev))
>  		return PTR_ERR(itn->fb_tunnel_dev);
> +	/* FB netdevice is special: we have one, and only one per netns.
> +	 * Allowing to move it to another netns is clearly unsafe.
> +	 */
> +	itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
>  
>  	return 0;
>  }
> --

Please add to the changelog :

Bug was added in commit 6c742e714d8c2 ("ipip: add x-netns support")

I do not think this fix is safe.

"dev->features |= some_flag;" should be protected by rtnl

So I suggest using instead :

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
 


