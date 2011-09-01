From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: Prefer non link-local source addresses
Date: Fri, 2 Sep 2011 01:14:59 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1109020041140.1799@ja.ssi.bg>
References: <1314908454-14359-1-git-send-email-jeff_harris@kentrox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Harris <jeff_harris@kentrox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47000 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932190Ab1IAWJp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Sep 2011 18:09:45 -0400
In-Reply-To: <1314908454-14359-1-git-send-email-jeff_harris@kentrox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 1 Sep 2011, Jeff Harris wrote:

> Section 2.6.1 of RFC 3927 specifies that if link-local and routable addresses
> are available on an interface, a routable address is preferred.  Update the
> IPv4 source address selection algorithm to use a 169.254.x.x address only if
> another matching address is not found.
> 
> Tested combinations of configured IP addresses with and without link-local to
> verify a link-local address was chosen only if no routable address was
> present.

	As David Lamparter already said, isn't the scope value
suitable for this purpose? Eg.
ip addr add 169.254.5.5/16 brd + dev eth0 scope link

	iproute2 already has function default_scope() in
ip/ipaddress.c that assigns scope if it is not specified
while adding address. May be we can add RT_SCOPE_LINK for
169.254 there?

	Another such place is inet_set_ifa() in
net/ipv4/devinet.c where we can assign scope, so that
ifconfig works too.

	I see also that net/ipv6/addrconf.c (sit_add_v4_addrs)
avoids link-local addresses. What I mean is that the scope
can be checked at many places and it is a mechanism that
already works.

	As result, we will not complicate inet_select_addr.

> Signed-off-by: Jeff Harris <jeff_harris@kentrox.com>
> ---
>  net/ipv4/devinet.c |   18 ++++++++++++++++--
>  1 files changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index bc19bd0..70ddf37 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -965,6 +965,8 @@ out:
>  __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
>  {
>  	__be32 addr = 0;
> +	__be32 lladdr = 0;
> +	__be32 firstaddr = 0;
>  	struct in_device *in_dev;
>  	struct net *net = dev_net(dev);
>  
> @@ -977,15 +979,27 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
>  		if (ifa->ifa_scope > scope)
>  			continue;
>  		if (!dst || inet_ifa_match(dst, ifa)) {
> +			if (ipv4_is_linklocal_169(ifa->ifa_address)) {
> +				lladdr = ifa->ifa_local;
> +				continue;
> +			}
>  			addr = ifa->ifa_local;
>  			break;
>  		}
> -		if (!addr)
> -			addr = ifa->ifa_local;
> +		if (!firstaddr)
> +			firstaddr = ifa->ifa_local;
>  	} endfor_ifa(in_dev);
>  
>  	if (addr)
>  		goto out_unlock;
> +	if (lladdr) {
> +		addr = lladdr;
> +		goto out_unlock;
> +	}
> +	if (firstaddr) {
> +		addr = firstaddr;
> +		goto out_unlock;
> +	}
>  no_in_dev:
>  
>  	/* Not loopback addresses on loopback should be preferred
> -- 
> 1.7.0.5

Regards

--
Julian Anastasov <ja@ssi.bg>
