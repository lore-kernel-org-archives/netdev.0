From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH v2 main-v4.9-rc7] net/ipv6: allow sysctl to change link-local
 address generation mode
Date: Sun, 04 Dec 2016 18:08:17 -0800
Message-ID: <5844CC11.7090300@cumulusnetworks.com>
References: <20161204223136.12119-1-felix.jia@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Carl Smith <carl.smith@alliedtelesis.co.nz>
To: Felix Jia <felix.jia@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:32970 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751168AbcLECIT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 21:08:19 -0500
Received: by mail-pg0-f41.google.com with SMTP id 3so130763867pgd.0
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 18:08:19 -0800 (PST)
In-Reply-To: <20161204223136.12119-1-felix.jia@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/4/16, 2:31 PM, Felix Jia wrote:
> Removed the rtnl lock and switch to use RCU lock to iterate through
> the netdev list.
>
> The address generation mode for IPv6 link-local can only be configured
> by netlink messages. This patch adds the ability to change the address
> generation mode via sysctl.
>
> An possible improvement is to remove the addrgenmode variable from the
> idev structure and use the systcl storage for the flag.
>
> The patch is based from v4.9-rc7 in mainline.
>
> Signed-off-by: Felix Jia <felix.jia@alliedtelesis.co.nz>
> Cc: Carl Smith <carl.smith@alliedtelesis.co.nz>
> ---
>  include/linux/ipv6.h      |  1 +
>  include/uapi/linux/ipv6.h |  1 +
>  net/ipv6/addrconf.c       | 73 ++++++++++++++++++++++++++++++++++++++++++++++-
>  3 files changed, 74 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index a064997..0d9e5d4 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -64,6 +64,7 @@ struct ipv6_devconf {
>  	} stable_secret;
>  	__s32		use_oif_addrs_only;
>  	__s32		keep_addr_on_down;
> +	__s32		addrgenmode;
>  
>  	struct ctl_table_header *sysctl_header;
>  };
> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
> index 8c27723..0524e2c 100644
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -178,6 +178,7 @@ enum {
>  	DEVCONF_DROP_UNSOLICITED_NA,
>  	DEVCONF_KEEP_ADDR_ON_DOWN,
>  	DEVCONF_RTR_SOLICIT_MAX_INTERVAL,
> +	DEVCONF_ADDRGENMODE,
>  	DEVCONF_MAX
>  };
>  
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 4bc5ba3..2b83cc7 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -238,6 +238,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
>  	.use_oif_addrs_only	= 0,
>  	.ignore_routes_with_linkdown = 0,
>  	.keep_addr_on_down	= 0,
> +	.addrgenmode = IN6_ADDR_GEN_MODE_EUI64,
>  };
>  
>  static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
> @@ -284,6 +285,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
>  	.use_oif_addrs_only	= 0,
>  	.ignore_routes_with_linkdown = 0,
>  	.keep_addr_on_down	= 0,
> +	.addrgenmode = IN6_ADDR_GEN_MODE_EUI64,
>  };
>  
>  /* Check if a valid qdisc is available */
> @@ -378,7 +380,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
>  	if (ndev->cnf.stable_secret.initialized)
>  		ndev->addr_gen_mode = IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
>  	else
> -		ndev->addr_gen_mode = IN6_ADDR_GEN_MODE_EUI64;
> +		ndev->addr_gen_mode = ipv6_devconf_dflt.addrgenmode;
>  
>  	ndev->cnf.mtu6 = dev->mtu;
>  	ndev->nd_parms = neigh_parms_alloc(dev, &nd_tbl);
> @@ -4950,6 +4952,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
>  	array[DEVCONF_DROP_UNICAST_IN_L2_MULTICAST] = cnf->drop_unicast_in_l2_multicast;
>  	array[DEVCONF_DROP_UNSOLICITED_NA] = cnf->drop_unsolicited_na;
>  	array[DEVCONF_KEEP_ADDR_ON_DOWN] = cnf->keep_addr_on_down;
> +	array[DEVCONF_ADDRGENMODE] = cnf->addrgenmode;
>  }
>  
>  static inline size_t inet6_ifla6_size(void)
> @@ -5496,6 +5499,67 @@ int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
>  	return proc_dointvec_minmax(&lctl, write, buffer, lenp, ppos);
>  }
>  
> +static void addrconf_addrgenmode_change(struct net *net)
> +{
> +	struct net_device *dev;
> +	struct inet6_dev *idev;
> +
> +	rcu_read_lock();
> +	for_each_netdev_rcu(net, dev) {
> +		idev = __in6_dev_get(dev);
> +		if (idev) {
> +			idev->cnf.addrgenmode = ipv6_devconf_dflt.addrgenmode;
> +			idev->addr_gen_mode = ipv6_devconf_dflt.addrgenmode;
> +			addrconf_dev_config(idev->dev);
> +		}
> +	}
> +	rcu_read_unlock();
> +}
> +
> +static int addrconf_sysctl_addrgenmode(struct ctl_table *ctl, int write,
> +								void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	int ret;
> +	int new_val;
> +	struct inet6_dev *idev = (struct inet6_dev *)ctl->extra1;
> +	struct net *net = (struct net *)ctl->extra2;
> +
> +	if (write) { /* sysctl write request */
> +		ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
> +		new_val = *((int *)ctl->data);
> +
>
unless I missed it, I don't see a check for valid values for new_val.
The netlink attribute  is checked  for valid values in the existing equivalent netlink code.
