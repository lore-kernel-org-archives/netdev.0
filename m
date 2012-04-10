From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v1 7/7] macvlan: add FDB bridge ops and new
 macvlan mode
Date: Tue, 10 Apr 2012 11:09:18 +0300
Message-ID: <20120410080916.GB26540@redhat.com>
References: <20120409215419.3288.50790.stgit@jf-dev1-dcblab>
 <20120409220053.3288.40867.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roprabhu@cisco.com, stephen.hemminger@vyatta.com,
	davem@davemloft.net, hadi@cyberus.ca, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gregory.v.rose@intel.com, krkumar2@in.ibm.com, sri@us.ibm.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12712 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755601Ab2DJIJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 04:09:18 -0400
Content-Disposition: inline
In-Reply-To: <20120409220053.3288.40867.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 09, 2012 at 03:00:54PM -0700, John Fastabend wrote:
> This adds a new macvlan mode MACVLAN_PASSTHRU_NOPROMISC
> this mode acts the same as the original passthru mode _except_
> it does not set promiscuous mode on the lowerdev. Because the
> lowerdev is not put in promiscuous mode any unicast or multicast
> addresses the device should receive must be explicitely added
> with the FDB bridge ops. In many use cases the management stack
> will know the mac addresses needed (maybe negotiated via EVB/VDP)
> or may require only receiving known "good" mac addresses. This
> mode with the FDB ops supports this usage model.


Looks good to me. Some questions below:

> This patch is a result of Roopa Prabhu's work. Follow up
> patches are needed for VEPA and VEB macvlan modes.

And bridge too?

Also, my understanding is that other modes won't need a flag
like this since they don't put the device in promisc mode initially,
so no assumptions are broken if we require all addresses
to be declared, right?

A final question: I think we'll later add a macvlan mode
that does not flood all multicasts. This would change behaviour
in an incompatible way so we'll probably need yet another
flag. Would it make sense to combine this functionality
with nopromisc so we have less modes to support?

> CC: Roopa Prabhu <roprabhu@cisco.com>
> CC: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  drivers/net/macvlan.c   |   60 ++++++++++++++++++++++++++++++++++++++++++-----
>  include/linux/if_link.h |    1 +
>  2 files changed, 55 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index b17fc90..9892d8d 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -181,6 +181,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
>  					  MACVLAN_MODE_PRIVATE |
>  					  MACVLAN_MODE_VEPA    |
>  					  MACVLAN_MODE_PASSTHRU|
> +					  MACVLAN_MODE_PASSTHRU_NOPROMISC |
>  					  MACVLAN_MODE_BRIDGE);
>  		else if (src->mode == MACVLAN_MODE_VEPA)
>  			/* flood to everyone except source */
> @@ -312,7 +313,8 @@ static int macvlan_open(struct net_device *dev)
>  	int err;
>  
>  	if (vlan->port->passthru) {
> -		dev_set_promiscuity(lowerdev, 1);
> +		if (vlan->mode == MACVLAN_MODE_PASSTHRU)
> +			dev_set_promiscuity(lowerdev, 1);
>  		goto hash_add;
>  	}
>  
> @@ -344,12 +346,15 @@ static int macvlan_stop(struct net_device *dev)
>  	struct macvlan_dev *vlan = netdev_priv(dev);
>  	struct net_device *lowerdev = vlan->lowerdev;
>  
> +	dev_uc_unsync(lowerdev, dev);
> +	dev_mc_unsync(lowerdev, dev);
> +
>  	if (vlan->port->passthru) {
> -		dev_set_promiscuity(lowerdev, -1);
> +		if (vlan->mode == MACVLAN_MODE_PASSTHRU)
> +			dev_set_promiscuity(lowerdev, 1);
>  		goto hash_del;
>  	}
>  
> -	dev_mc_unsync(lowerdev, dev);
>  	if (dev->flags & IFF_ALLMULTI)
>  		dev_set_allmulti(lowerdev, -1);
>  
> @@ -399,10 +404,11 @@ static void macvlan_change_rx_flags(struct net_device *dev, int change)
>  		dev_set_allmulti(lowerdev, dev->flags & IFF_ALLMULTI ? 1 : -1);
>  }
>  
> -static void macvlan_set_multicast_list(struct net_device *dev)
> +static void macvlan_set_mac_lists(struct net_device *dev)
>  {
>  	struct macvlan_dev *vlan = netdev_priv(dev);
>  
> +	dev_uc_sync(vlan->lowerdev, dev);
>  	dev_mc_sync(vlan->lowerdev, dev);
>  }
>  
> @@ -542,6 +548,43 @@ static int macvlan_vlan_rx_kill_vid(struct net_device *dev,
>  	return 0;
>  }
>  
> +static int macvlan_fdb_add(struct ndmsg *ndm,
> +			   struct net_device *dev,
> +			   unsigned char *addr,
> +			   u16 flags)
> +{
> +	struct macvlan_dev *vlan = netdev_priv(dev);
> +	int err = -EINVAL;
> +
> +	if (!vlan->port->passthru)
> +		return -EOPNOTSUPP;
> +
> +	if (is_unicast_ether_addr(addr))
> +		err = dev_uc_add_excl(dev, addr);
> +	else if (is_multicast_ether_addr(addr))
> +		err = dev_mc_add_excl(dev, addr);
> +
> +	return err;
> +}
> +
> +static int macvlan_fdb_del(struct ndmsg *ndm,
> +			   struct net_device *dev,
> +			   unsigned char *addr)
> +{
> +	struct macvlan_dev *vlan = netdev_priv(dev);
> +	int err = -EINVAL;
> +
> +	if (!vlan->port->passthru)
> +		return -EOPNOTSUPP;
> +
> +	if (is_unicast_ether_addr(addr))
> +		err = dev_uc_del(dev, addr);
> +	else if (is_multicast_ether_addr(addr))
> +		err = dev_mc_del(dev, addr);
> +
> +	return err;
> +}
> +
>  static void macvlan_ethtool_get_drvinfo(struct net_device *dev,
>  					struct ethtool_drvinfo *drvinfo)
>  {
> @@ -572,11 +615,14 @@ static const struct net_device_ops macvlan_netdev_ops = {
>  	.ndo_change_mtu		= macvlan_change_mtu,
>  	.ndo_change_rx_flags	= macvlan_change_rx_flags,
>  	.ndo_set_mac_address	= macvlan_set_mac_address,
> -	.ndo_set_rx_mode	= macvlan_set_multicast_list,
> +	.ndo_set_rx_mode	= macvlan_set_mac_lists,
>  	.ndo_get_stats64	= macvlan_dev_get_stats64,
>  	.ndo_validate_addr	= eth_validate_addr,
>  	.ndo_vlan_rx_add_vid	= macvlan_vlan_rx_add_vid,
>  	.ndo_vlan_rx_kill_vid	= macvlan_vlan_rx_kill_vid,
> +	.ndo_fdb_add		= macvlan_fdb_add,
> +	.ndo_fdb_del		= macvlan_fdb_del,
> +	.ndo_fdb_dump		= ndo_dflt_fdb_dump,
>  };
>  
>  void macvlan_common_setup(struct net_device *dev)
> @@ -648,6 +694,7 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
>  		case MACVLAN_MODE_VEPA:
>  		case MACVLAN_MODE_BRIDGE:
>  		case MACVLAN_MODE_PASSTHRU:
> +		case MACVLAN_MODE_PASSTHRU_NOPROMISC:
>  			break;
>  		default:
>  			return -EINVAL;
> @@ -711,7 +758,8 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
>  	if (data && data[IFLA_MACVLAN_MODE])
>  		vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
>  
> -	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
> +	if ((vlan->mode == MACVLAN_MODE_PASSTHRU) ||
> +	    (vlan->mode == MACVLAN_MODE_PASSTHRU_NOPROMISC)) {
>  		if (port->count)
>  			return -EINVAL;
>  		port->passthru = true;
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index 2f4fa93..db67b9d 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -265,6 +265,7 @@ enum macvlan_mode {
>  	MACVLAN_MODE_VEPA    = 2, /* talk to other ports through ext bridge */
>  	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
>  	MACVLAN_MODE_PASSTHRU = 8,/* take over the underlying device */
> +	MACVLAN_MODE_PASSTHRU_NOPROMISC = 16, /* passthru without promisc */
>  };
>  
>  /* SR-IOV virtual function management section */
