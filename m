From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] Fix the upper MTU limit in ipv6 GRE tunnel
Date: Sat, 5 Oct 2013 16:06:36 +0200
Message-ID: <20131005140636.GA25076@order.stressinduktion.org>
References: <1380880333-3546-1-git-send-email-ou.ghorbel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oussama Ghorbel <ou.ghorbel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42272 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492Ab3JEOGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Oct 2013 10:06:38 -0400
Content-Disposition: inline
In-Reply-To: <1380880333-3546-1-git-send-email-ou.ghorbel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 04, 2013 at 10:52:13AM +0100, Oussama Ghorbel wrote:
> Unlike ipv4, the struct member hlen holds the length of the GRE and ipv6
> headers. This length is also counted in dev->hard_header_len.
> Perhaps, it's more clean to modify the hlen to count only the GRE header
> without ipv6 header as the variable name suggest, but the simple way to fix
> this without regression risk is simply modify the calculation of the limit
> in ip6gre_tunnel_change_mtu function.
> Verified in kernel version v3.11.
> 
> Signed-off-by: Oussama Ghorbel <ou.ghorbel@gmail.com>
> ---
>  net/ipv6/ip6_gre.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> index 90747f1..41487ab 100644
> --- a/net/ipv6/ip6_gre.c
> +++ b/net/ipv6/ip6_gre.c
> @@ -1175,9 +1175,8 @@ done:
>  
>  static int ip6gre_tunnel_change_mtu(struct net_device *dev, int new_mtu)
>  {
> -	struct ip6_tnl *tunnel = netdev_priv(dev);
>  	if (new_mtu < 68 ||
> -	    new_mtu > 0xFFF8 - dev->hard_header_len - tunnel->hlen)
> +	    new_mtu > 0xFFF8 - dev->hard_header_len)
>  		return -EINVAL;
>  	dev->mtu = new_mtu;
>  	return 0;

Hmmm...

dev->hard_header_len is initialized to LL_MAX_HEADER + sizeof(struct ipv6hdr)
+ 4 but won't include the additional head space needed for GRE_SEQ, GRE_KEY
etc. if at time of tunnel creation the routing table did not had a good guess
for the outgoing device.

To make this correct we would have to refactor the usage of the variables a
bit as is done in ipv4/ip_tunnel.c. The safest thing would be to leave this
check as-is currently although we exclude some allowed mtus.

Perhaps you want to take a look how to achieve that? ;)

Greetings,

  Hannes
