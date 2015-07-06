From: Bob Liu <bob.liu@oracle.com>
Subject: Re: [Xen-devel] [PATCH] net/bridge: Add missing in6_dev_put in br_validate_ipv6
Date: Mon, 06 Jul 2015 17:58:26 +0800
Message-ID: <559A5142.5000109@oracle.com>
References: <1435946491-11148-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, davem@davemloft.net,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	wei.liu2@citrix.com, ian.campbell@citrix.com, fw@strlen.de,
	linux-kernel@vger.kernel.org,
	Bernhard Thaler <bernhard.thaler@wvnet.at>,
	xen-devel@lists.xenproject.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435946491-11148-1-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 07/04/2015 02:01 AM, Julien Grall wrote:
> The commit efb6de9b4ba0092b2c55f6a52d16294a8a698edd "netfilter: bridge:
> forward IPv6 fragmented packets" introduced a new function
> br_validate_ipv6 which take a reference on the inet6 device. Although,
> the reference is not released at the end.
> 
> This will result to the impossibility to destroy any netdevice using
> ipv6 and bridge.
> 
> Spotted while trying to destroy a Xen guest on the upstream Linux:
> "unregister_netdevice: waiting for vif1.0 to become free. Usage count = 1"
> 
> Signed-off-by: Julien Grall <julien.grall@citrix.com>

Also hit the same issue, thank you for the fix.

Tested-by: Bob Liu <bob.liu@oracle.com>

> Cc: Bernhard Thaler <bernhard.thaler@wvnet.at>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: fw@strlen.de
> Cc: ian.campbell@citrix.com
> Cc: wei.liu2@citrix.com
> 
> ---
>     Note that it's impossible to create new guest after this message.
>     I'm not sure if it's normal.
> ---
>  net/bridge/br_netfilter_ipv6.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/net/bridge/br_netfilter_ipv6.c b/net/bridge/br_netfilter_ipv6.c
> index 6d12d26..7046e19 100644
> --- a/net/bridge/br_netfilter_ipv6.c
> +++ b/net/bridge/br_netfilter_ipv6.c
> @@ -140,11 +140,16 @@ int br_validate_ipv6(struct sk_buff *skb)
>  	/* No IP options in IPv6 header; however it should be
>  	 * checked if some next headers need special treatment
>  	 */
> +
> +	in6_dev_put(idev);
> +
>  	return 0;
>  
>  inhdr_error:
>  	IP6_INC_STATS_BH(dev_net(dev), idev, IPSTATS_MIB_INHDRERRORS);
>  drop:
> +	in6_dev_put(idev);
> +
>  	return -1;
>  }
>  
> 
