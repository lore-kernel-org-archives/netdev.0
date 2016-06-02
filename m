From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: vrf: Add l3mdev rules on first
 device create
Date: Thu, 02 Jun 2016 18:13:38 -0400 (EDT)
Message-ID: <20160602.181338.386706524198750313.davem@davemloft.net>
References: <1464840894-12697-1-git-send-email-dsa@cumulusnetworks.com>
	<1464840894-12697-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932511AbcFBWN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 18:13:56 -0400
In-Reply-To: <1464840894-12697-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  1 Jun 2016 21:14:54 -0700

> Add l3mdev rule per address family when the first VRF device is
> created. Remove them when the last is deleted.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  drivers/net/vrf.c | 114 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 113 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> index dff08842f26d..b3cb80e84ea7 100644
> --- a/drivers/net/vrf.c
> +++ b/drivers/net/vrf.c
> @@ -35,6 +35,7 @@
>  #include <net/route.h>
>  #include <net/addrconf.h>
>  #include <net/l3mdev.h>
> +#include <net/fib_rules.h>
>  
>  #define RT_FL_TOS(oldflp4) \
>  	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
> @@ -42,6 +43,11 @@
>  #define DRV_NAME	"vrf"
>  #define DRV_VERSION	"1.0"
>  
> +static atomic_t num_vrfs;
> +
> +static u32 rule_pref = 1000;
> +module_param(rule_pref, uint,  S_IRUGO);
> +
>  struct net_vrf {
>  	struct rtable __rcu	*rth;
>  	struct rt6_info	__rcu	*rt6;
> @@ -723,6 +729,93 @@ static const struct ethtool_ops vrf_ethtool_ops = {
>  	.get_drvinfo	= vrf_get_drvinfo,
>  };
>  
> +static inline size_t vrf_fib_rule_nl_size(void)
> +{
> +	size_t sz;
> +
> +	sz  = NLMSG_ALIGN(sizeof(struct fib_rule_hdr));
> +	sz += nla_total_size(sizeof(u8));	/* FRA_L3MDEV */
> +	sz += nla_total_size(sizeof(u32));	/* FRA_PRIORITY */
> +
> +	return sz;
> +}
> +
> +static int vrf_fib_rule(const struct net_device *dev, __u8 family, bool add_it)
 ...
> +static void vrf_del_fib_rules(const struct net_device *dev)
> +{
> +	if (vrf_fib_rule(dev, AF_INET,  0) ||
> +	    vrf_fib_rule(dev, AF_INET6, 0)) {
 ...
> +static int vrf_add_fib_rules(const struct net_device *dev)
> +{
> +	int err;
> +
> +	err = vrf_fib_rule(dev, AF_INET,  1);
> +	if (err < 0)
> +		goto out_err;
> +
> +	err = vrf_fib_rule(dev, AF_INET6, 1);

Since the third arg to vrf_fib_rule() is a bool, pass true/false.
