From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch net-next] openvswitch: introduce rtnl ops stub
Date: Wed, 25 Jun 2014 01:34:27 -0700
Message-ID: <87k385xu98.fsf@x220.int.ebiederm.org>
References: <1403684861-9185-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, pshelar@nicira.com,
	cwang@twopensource.com, nicolas.dichtel@6wind.com,
	david@gibson.dropbear.id.au, sfeldma@cumulusnetworks.com,
	sucheta.chakraborty@qlogic.com, stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:38139 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755312AbaFYIhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 04:37:45 -0400
In-Reply-To: <1403684861-9185-1-git-send-email-jiri@resnulli.us> (Jiri Pirko's
	message of "Wed, 25 Jun 2014 10:27:41 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:

> This stub now allows userspace to see IFLA_INFO_KIND for ovs master and
> IFLA_INFO_SLAVE_KIND for slave.
>
> Note that I added ops->setup check into newlink and dellink in order to
> prevent creating and deleting openvswitch instances using rtnl for
> now.

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Don't add hacks to the core code to only satisfy your openvswitch
device.

If the change is justified make it a separate patch and describe why
it is ok for everyone.  As this sits I think you have broken some
other users of rtnl_link_ops.

Eric


> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/core/rtnetlink.c                 |  5 ++++-
>  net/openvswitch/datapath.c           |  9 ++++++++-
>  net/openvswitch/vport-internal_dev.c | 16 ++++++++++++++++
>  net/openvswitch/vport-internal_dev.h |  2 ++
>  4 files changed, 30 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 1063996..84affd7 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1777,7 +1777,7 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
>  		return -ENODEV;
>  
>  	ops = dev->rtnl_link_ops;
> -	if (!ops)
> +	if (!ops || !ops->setup)
>  		return -EOPNOTSUPP;
>  
>  	ops->dellink(dev, &list_kill);
> @@ -2038,6 +2038,9 @@ replay:
>  			return -EOPNOTSUPP;
>  		}
>  
> +		if (!ops->setup)
> +			return -EOPNOTSUPP;
> +
>  		if (!ifname[0])
>  			snprintf(ifname, IFNAMSIZ, "%s%%d", ops->kind);
>  
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 0d407bc..fe95b6c 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -2054,10 +2054,14 @@ static int __init dp_init(void)
>  
>  	pr_info("Open vSwitch switching datapath\n");
>  
> -	err = ovs_flow_init();
> +	err = ovs_internal_dev_rtnl_link_register();
>  	if (err)
>  		goto error;
>  
> +	err = ovs_flow_init();
> +	if (err)
> +		goto error_unreg_rtnl_link;
> +
>  	err = ovs_vport_init();
>  	if (err)
>  		goto error_flow_exit;
> @@ -2084,6 +2088,8 @@ error_vport_exit:
>  	ovs_vport_exit();
>  error_flow_exit:
>  	ovs_flow_exit();
> +error_unreg_rtnl_link:
> +	ovs_internal_dev_rtnl_link_unregister();
>  error:
>  	return err;
>  }
> @@ -2096,6 +2102,7 @@ static void dp_cleanup(void)
>  	rcu_barrier();
>  	ovs_vport_exit();
>  	ovs_flow_exit();
> +	ovs_internal_dev_rtnl_link_unregister();
>  }
>  
>  module_init(dp_init);
> diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
> index 789af92..295471a 100644
> --- a/net/openvswitch/vport-internal_dev.c
> +++ b/net/openvswitch/vport-internal_dev.c
> @@ -26,6 +26,7 @@
>  
>  #include <net/dst.h>
>  #include <net/xfrm.h>
> +#include <net/rtnetlink.h>
>  
>  #include "datapath.h"
>  #include "vport-internal_dev.h"
> @@ -121,6 +122,10 @@ static const struct net_device_ops internal_dev_netdev_ops = {
>  	.ndo_get_stats64 = internal_dev_get_stats,
>  };
>  
> +static struct rtnl_link_ops internal_dev_link_ops __read_mostly = {
> +	.kind = "openvswitch",
> +};
> +
>  static void do_setup(struct net_device *netdev)
>  {
>  	ether_setup(netdev);
> @@ -131,6 +136,7 @@ static void do_setup(struct net_device *netdev)
>  	netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
>  	netdev->destructor = internal_dev_destructor;
>  	netdev->ethtool_ops = &internal_dev_ethtool_ops;
> +	netdev->rtnl_link_ops = &internal_dev_link_ops;
>  	netdev->tx_queue_len = 0;
>  
>  	netdev->features = NETIF_F_LLTX | NETIF_F_SG | NETIF_F_FRAGLIST |
> @@ -248,3 +254,13 @@ struct vport *ovs_internal_dev_get_vport(struct net_device *netdev)
>  
>  	return internal_dev_priv(netdev)->vport;
>  }
> +
> +int ovs_internal_dev_rtnl_link_register(void)
> +{
> +	return rtnl_link_register(&internal_dev_link_ops);
> +}
> +
> +void ovs_internal_dev_rtnl_link_unregister(void)
> +{
> +	rtnl_link_unregister(&internal_dev_link_ops);
> +}
> diff --git a/net/openvswitch/vport-internal_dev.h b/net/openvswitch/vport-internal_dev.h
> index 9a7d30e..1b179a1 100644
> --- a/net/openvswitch/vport-internal_dev.h
> +++ b/net/openvswitch/vport-internal_dev.h
> @@ -24,5 +24,7 @@
>  
>  int ovs_is_internal_dev(const struct net_device *);
>  struct vport *ovs_internal_dev_get_vport(struct net_device *);
> +int ovs_internal_dev_rtnl_link_register(void);
> +void ovs_internal_dev_rtnl_link_unregister(void);
>  
>  #endif /* vport-internal_dev.h */
