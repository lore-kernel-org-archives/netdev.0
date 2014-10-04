From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/1] net: fix rcu access on phonet_routes
Date: Sat, 04 Oct 2014 08:30:42 -0700
Message-ID: <1412436642.17245.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412416676-21698-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Josh Triplett <josh@joshtriplett.org>,
	Remi Denis-Courmont <courmisch@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:54459 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbaJDPao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 11:30:44 -0400
In-Reply-To: <1412416676-21698-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-10-04 at 11:57 +0200, Fabian Frederick wrote:
> -Add __rcu annotation on table to fix sparse warnings:
> net/phonet/pn_dev.c:279:25: warning: incorrect type in assignment (different address spaces)
> net/phonet/pn_dev.c:279:25:    expected struct net_device *<noident>
> net/phonet/pn_dev.c:279:25:    got void [noderef] <asn:4>*<noident>
> net/phonet/pn_dev.c:376:17: warning: incorrect type in assignment (different address spaces)
> net/phonet/pn_dev.c:376:17:    expected struct net_device *volatile <noident>
> net/phonet/pn_dev.c:376:17:    got struct net_device [noderef] <asn:4>*<noident>
> net/phonet/pn_dev.c:392:17: warning: incorrect type in assignment (different address spaces)
> net/phonet/pn_dev.c:392:17:    expected struct net_device *<noident>
> net/phonet/pn_dev.c:392:17:    got void [noderef] <asn:4>*<noident>
> 
> -Access table with rcu_dereference (fixes the following sparse errors):
> net/phonet/pn_dev.c:278:25: error: incompatible types in comparison expression (different address spaces)
> net/phonet/pn_dev.c:391:17: error: incompatible types in comparison expression (different address spaces)
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
>  net/phonet/pn_dev.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
> index 56a6146..5c9c0b2f1 100644
> --- a/net/phonet/pn_dev.c
> +++ b/net/phonet/pn_dev.c
> @@ -36,7 +36,7 @@
>  
>  struct phonet_routes {
>  	struct mutex		lock;
> -	struct net_device	*table[64];
> +	struct net_device __rcu	*table[64];
>  };
>  
>  struct phonet_net {
> @@ -275,7 +275,7 @@ static void phonet_route_autodel(struct net_device *dev)
>  	bitmap_zero(deleted, 64);
>  	mutex_lock(&pnn->routes.lock);
>  	for (i = 0; i < 64; i++)
> -		if (dev == pnn->routes.table[i]) {
> +		if (rcu_dereference(pnn->routes.table[i]) == dev) {
>  			RCU_INIT_POINTER(pnn->routes.table[i], NULL);
>  			set_bit(i, deleted);
>  		}
> @@ -388,7 +388,7 @@ int phonet_route_del(struct net_device *dev, u8 daddr)
>  
>  	daddr = daddr >> 2;
>  	mutex_lock(&routes->lock);
> -	if (dev == routes->table[daddr])
> +	if (rcu_dereference(routes->table[daddr]) == dev)
>  		RCU_INIT_POINTER(routes->table[daddr], NULL);
>  	else
>  		dev = NULL;

Hi Fabian

Have you tested this running the kernel with following config options :

CONFIG_LOCKDEP=y
CONFIG_PROVE_RCU=y

LOCKDEP should complain loudly, if not, we should file a bug !

Hint : Use rcu_access_pointer(), and check that LOCKDEP is happy with
that.

Thanks !
