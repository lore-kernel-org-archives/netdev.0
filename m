From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 2/7] ipv4: ipmr: Add the parent ID field to VIF
 struct
Date: Fri, 29 Sep 2017 12:50:55 +0300
Message-ID: <29b9104c-6ada-0c9a-ce84-df104fa0afba@cumulusnetworks.com>
References: <20170928173415.15551-1-jiri@resnulli.us>
 <20170928173415.15551-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, andrew@lunn.ch, dsa@cumulusnetworks.com,
        edumazet@google.com, willemb@google.com, johannes.berg@intel.com,
        dcaratti@redhat.com, pabeni@redhat.com, daniel@iogearbox.net,
        f.fainelli@gmail.com, fw@strlen.de, gfree.wind@vip.163.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:56556 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750926AbdI2Ju7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 05:50:59 -0400
Received: by mail-wm0-f50.google.com with SMTP id r74so2183421wme.5
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 02:50:58 -0700 (PDT)
In-Reply-To: <20170928173415.15551-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/09/17 20:34, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> In order to allow the ipmr module to do partial multicast forwarding
> according to the device parent ID, add the device parent ID field to the
> VIF struct. This way, the forwarding path can use the parent ID field
> without invoking switchdev calls, which requires the RTNL lock.
> 
> When a new VIF is added, set the device parent ID field in it by invoking
> the switchdev_port_attr_get call.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/linux/mroute.h | 2 ++
>  net/ipv4/ipmr.c        | 9 +++++++++
>  2 files changed, 11 insertions(+)
> 
> diff --git a/include/linux/mroute.h b/include/linux/mroute.h
> index b072a84..a46577f 100644
> --- a/include/linux/mroute.h
> +++ b/include/linux/mroute.h
> @@ -57,6 +57,8 @@ static inline bool ipmr_rule_default(const struct fib_rule *rule)
>  
>  struct vif_device {
>  	struct net_device 	*dev;			/* Device we are using */
> +	struct netdev_phys_item_id dev_parent_id;	/* Device parent ID    */
> +	bool		dev_parent_id_valid;
>  	unsigned long	bytes_in,bytes_out;
>  	unsigned long	pkt_in,pkt_out;		/* Statistics 			*/
>  	unsigned long	rate_limit;		/* Traffic shaping (NI) 	*/
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 292a8e8..4566c54 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -67,6 +67,7 @@
>  #include <net/fib_rules.h>
>  #include <linux/netconf.h>
>  #include <net/nexthop.h>
> +#include <net/switchdev.h>
>  
>  struct ipmr_rule {
>  	struct fib_rule		common;
> @@ -868,6 +869,9 @@ static int vif_add(struct net *net, struct mr_table *mrt,
>  		   struct vifctl *vifc, int mrtsock)
>  {
>  	int vifi = vifc->vifc_vifi;
> +	struct switchdev_attr attr = {
> +		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
> +	};
>  	struct vif_device *v = &mrt->vif_table[vifi];
>  	struct net_device *dev;
>  	struct in_device *in_dev;
> @@ -942,6 +946,11 @@ static int vif_add(struct net *net, struct mr_table *mrt,
>  
>  	/* Fill in the VIF structures */
>  
> +	attr.orig_dev = dev;
> +	if (!switchdev_port_attr_get(dev, &attr)) {
> +		v->dev_parent_id_valid = true;
> +		memcpy(v->dev_parent_id.id, attr.u.ppid.id, attr.u.ppid.id_len);
> +	}
>  	v->rate_limit = vifc->vifc_rate_limit;
>  	v->local = vifc->vifc_lcl_addr.s_addr;
>  	v->remote = vifc->vifc_rmt_addr.s_addr;
> 

One more thing - what happens on vif delete, then add with the same vif index of another
device that doesn't have a parent id ? I think the vif will be stuck with its parent_id
when it gets set.
