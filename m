From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 25/26] switchdev: convert swdev_fib_ipv4_add/del
 over to swdev_port_obj_add/del
Date: Wed, 01 Apr 2015 08:05:49 -0700
Message-ID: <551C094D.7000707@cumulusnetworks.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com> <1427882882-2533-26-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33253 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791AbbDAPGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 11:06:01 -0400
Received: by pacgg7 with SMTP id gg7so54771835pac.0
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 08:06:00 -0700 (PDT)
In-Reply-To: <1427882882-2533-26-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/1/15, 3:08 AM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> The IPv4 FIB ops convert nicely to the swdev objs and we're left with only
> four swdev ops: port get/set and port add/del.  Other objs will follow, such
> as FDB.  So go ahead and convert IPv4 FIB over to swdev obj for consistency,
> anticipating more objs to come.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>   drivers/net/ethernet/rocker/rocker.c |   42 +++++++++++------------------
>   include/net/switchdev.h              |   21 +++++++--------
>   net/switchdev/switchdev.c            |   49 +++++++++++++++++++++-------------
>   3 files changed, 56 insertions(+), 56 deletions(-)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index b7e54c3..b34efd8 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -4244,12 +4244,19 @@ static int rocker_port_vlans_add(struct rocker_port *rocker_port,
>   static int rocker_port_obj_add(struct net_device *dev, struct swdev_obj *obj)
>   {
>   	struct rocker_port *rocker_port = netdev_priv(dev);
> +	struct swdev_obj_ipv4_fib *fib4;
>   	int err = 0;
>   
>   	switch (obj->id) {
>   	case SWDEV_OBJ_PORT_VLAN:
>   		err = rocker_port_vlans_add(rocker_port, &obj->vlan);
>   		break;
> +	case SWDEV_OBJ_IPV4_FIB:
> +		fib4 = &obj->ipv4_fib;
> +		err = rocker_port_fib_ipv4(rocker_port, fib4->dst,
> +					   fib4->dst_len, fib4->fi,
> +					   fib4->tb_id, 0);
> +		break;
>   	default:
>   		err = -EOPNOTSUPP;
>   		break;
> @@ -4289,12 +4296,20 @@ static int rocker_port_vlans_del(struct rocker_port *rocker_port,
>   static int rocker_port_obj_del(struct net_device *dev, struct swdev_obj *obj)
>   {
>   	struct rocker_port *rocker_port = netdev_priv(dev);
> +	struct swdev_obj_ipv4_fib *fib4;
>   	int err = 0;
>   
>   	switch (obj->id) {
>   	case SWDEV_OBJ_PORT_VLAN:
>   		err = rocker_port_vlans_del(rocker_port, &obj->vlan);
>   		break;
> +	case SWDEV_OBJ_IPV4_FIB:
> +		fib4 = &obj->ipv4_fib;
> +		err = rocker_port_fib_ipv4(rocker_port, fib4->dst,
> +					   fib4->dst_len, fib4->fi,
> +					   fib4->tb_id,
> +					   ROCKER_OP_FLAG_REMOVE);
> +		break;
>   	default:
>   		err = -EOPNOTSUPP;
>   		break;
> @@ -4303,38 +4318,11 @@ static int rocker_port_obj_del(struct net_device *dev, struct swdev_obj *obj)
>   	return err;
>   }
>   
> -static int rocker_port_swdev_fib_ipv4_add(struct net_device *dev,
> -					  __be32 dst, int dst_len,
> -					  struct fib_info *fi,
> -					  u8 tos, u8 type,
> -					  u32 nlflags, u32 tb_id)
> -{
> -	struct rocker_port *rocker_port = netdev_priv(dev);
> -	int flags = 0;
> -
> -	return rocker_port_fib_ipv4(rocker_port, dst, dst_len,
> -				    fi, tb_id, flags);
> -}
> -
> -static int rocker_port_swdev_fib_ipv4_del(struct net_device *dev,
> -					  __be32 dst, int dst_len,
> -					  struct fib_info *fi,
> -					  u8 tos, u8 type, u32 tb_id)
> -{
> -	struct rocker_port *rocker_port = netdev_priv(dev);
> -	int flags = ROCKER_OP_FLAG_REMOVE;
> -
> -	return rocker_port_fib_ipv4(rocker_port, dst, dst_len,
> -				    fi, tb_id, flags);
> -}
> -
>   static const struct swdev_ops rocker_port_swdev_ops = {
>   	.swdev_port_attr_get		= rocker_port_attr_get,
>   	.swdev_port_attr_set		= rocker_port_attr_set,
>   	.swdev_port_obj_add		= rocker_port_obj_add,
>   	.swdev_port_obj_del		= rocker_port_obj_del,
> -	.swdev_fib_ipv4_add		= rocker_port_swdev_fib_ipv4_add,
> -	.swdev_fib_ipv4_del		= rocker_port_swdev_fib_ipv4_del,
>   };
>   
>   /********************
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index 37a2607..efaac55 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -39,6 +39,7 @@ struct fib_info;
>   enum swdev_obj_id {
>   	SWDEV_OBJ_UNDEFINED,
>   	SWDEV_OBJ_PORT_VLAN,
> +	SWDEV_OBJ_IPV4_FIB,
>   };
>   
>   struct swdev_obj {
> @@ -50,6 +51,15 @@ struct swdev_obj {
>   			u16 vid_start;
>   			u16 vid_end;
>   		} vlan;
> +		struct swdev_obj_ipv4_fib {		/* IPV4_FIB */
> +			u32 dst;
> +			int dst_len;
> +			struct fib_info *fi;
> +			u8 tos;
> +			u8 type;
> +			u32 nlflags;
> +			u32 tb_id;
> +		} ipv4_fib;
>   	};
>   };
>   
> @@ -63,10 +73,6 @@ struct swdev_obj {
>    * @swdev_port_obj_add: Add an object to port (see swdev_obj).
>    *
>    * @swdev_port_obj_del: Delete an object from port (see swdev_obj).
> - *
> - * @swdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
> - *
> - * @swdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
>    */
>   struct swdev_ops {
>   	int	(*swdev_port_attr_get)(struct net_device *dev,
> @@ -77,13 +83,6 @@ struct swdev_ops {
>   				      struct swdev_obj *obj);
>   	int	(*swdev_port_obj_del)(struct net_device *dev,
>   				      struct swdev_obj *obj);
> -	int	(*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
> -				      int dst_len, struct fib_info *fi,
> -				      u8 tos, u8 type, u32 nlflags,
> -				      u32 tb_id);
> -	int	(*swdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
> -				      int dst_len, struct fib_info *fi,
> -				      u8 tos, u8 type, u32 tb_id);
>   };
>   
>   enum swdev_notifier_type {
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 98c631c..4dbd4c4 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -535,8 +535,19 @@ static struct net_device *swdev_get_dev_by_nhs(struct fib_info *fi)
>   int swdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
>   		       u8 tos, u8 type, u32 nlflags, u32 tb_id)
>   {
> +	struct swdev_obj fib_obj = {
> +		.id = SWDEV_OBJ_IPV4_FIB,
> +		.ipv4_fib = {
> +			.dst = htonl(dst),
> +			.dst_len = dst_len,
> +			.fi = fi,
> +			.tos = tos,
> +			.type = type,
> +			.nlflags = nlflags,
> +			.tb_id = tb_id,
> +		},
> +	};
>   	struct net_device *dev;
> -	const struct swdev_ops *ops;
>   	int err = 0;
>   
>   	/* Don't offload route if using custom ip rules or if
> @@ -554,15 +565,10 @@ int swdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
>   	dev = swdev_get_dev_by_nhs(fi);
>   	if (!dev)
>   		return 0;
> -	ops = dev->swdev_ops;
> -
> -	if (ops->swdev_fib_ipv4_add) {
> -		err = ops->swdev_fib_ipv4_add(dev, htonl(dst), dst_len,
> -					      fi, tos, type, nlflags,
> -					      tb_id);
> -		if (!err)
> -			fi->fib_flags |= RTNH_F_EXTERNAL;
> -	}
> +
> +	err = swdev_port_obj_add(dev, &fib_obj);
> +	if (!err)
> +		fi->fib_flags |= RTNH_F_EXTERNAL;
>   
>   	return err;
>   }
> @@ -583,8 +589,19 @@ EXPORT_SYMBOL_GPL(swdev_fib_ipv4_add);
>   int swdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
>   		       u8 tos, u8 type, u32 tb_id)
>   {
> +	struct swdev_obj fib_obj = {
> +		.id = SWDEV_OBJ_IPV4_FIB,
> +		.ipv4_fib = {
> +			.dst = htonl(dst),
> +			.dst_len = dst_len,
> +			.fi = fi,
> +			.tos = tos,
> +			.type = type,
> +			.nlflags = 0,
> +			.tb_id = tb_id,
> +		},
> +	};
>   
This looks nice. However, my only concern is we have now ended up adding 
a whole layer of abstraction to all objects. The api abstraction seemed 
fine.
But, carrying it to objects and duplicating every object in the swdev 
layer seems too much duplication. Maybe its just me.
we will end up adding this for bond attributes...vxlan...fdb and 
nftables etc.

The advantage of switchdev in the kernel was to have access the existing 
kernel api and objects directly from switchdev layer.
In which case, to me, it would be better to skip this extra layer of 
objects. And keep the way you had it originally.
