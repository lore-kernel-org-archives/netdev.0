From: "Harris, Jeff" <Jeff_Harris@kentrox.com>
Subject: RE: [PATCH] net: Prefer non link-local source addresses
Date: Tue, 6 Sep 2011 15:12:37 +0000
Message-ID: <A0C485B929C0994A889B2580ECDF807648D4D928@EXCHANGE.corp.kentrox.com>
References: <1314908454-14359-1-git-send-email-jeff_harris@kentrox.com>
 <alpine.LFD.2.00.1109020041140.1799@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1109020041140.1799@ja.ssi.bg>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In this case, the address scope values are being set properly.  The link-local address has link scope and the routable address has global scope.  When the inet_select_addr function is called, the dst address is 0 and the scope is 253 (link scope).  So, in this case, both address could match.  It just happens that the link local address is first in the list for the device.

This condition looks to be arising from the use of interface routes on our device (e.g. ip route add default dev eth0).  The routes are being installed with link scope.  Forcing a scope of global causes a scope of 0 in inet_select_addr which then selects the routable address always.  I have not found any definite documentation on whether local or global should be used for the route, but the default behavior of the 'ip' command is to use link scope on these routes and global on routes with a gateway address. 

Also, I have only been able to test against 2.6.33 which we use on our embedded device.  It is not easy to update to a more recent version.  The patch, though, applied cleanly to the latest stable version.

Jeff

-----Original Message-----
From: Julian Anastasov [mailto:ja@ssi.bg] 
Sent: Thursday, September 01, 2011 6:15 PM
To: Harris, Jeff
Cc: David S. Miller; Alexey Kuznetsov; James Morris; Hideaki YOSHIFUJI; Patrick McHardy; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: [PATCH] net: Prefer non link-local source addresses


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
