From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [patch net-next] bridge: try switchdev op first in
 __vlan_vid_add/del
Date: Fri, 9 Oct 2015 18:44:06 -0400
Message-ID: <20151009224405.GA25393@ketchup.mtl.sfl>
References: <1444391651-13775-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, andrew@lunn.ch, john.fastabend@gmail.com,
	David.Laight@ACULAB.COM
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36884 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102AbbJIWoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 18:44:11 -0400
Content-Disposition: inline
In-Reply-To: <1444391651-13775-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Oct. Friday 09 (41) 01:54 PM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Some drivers need to implement both switchdev vlan ops and
> vid_add/kill ndos. For that to work in bridge code, we need to try
> switchdev op first when adding/deleting vlan id.

Just curious, when would a driver need to have both operations?

I kinda have the same question regarding ndo_fdb_{add,del} and the
bridge_{get,set}link equivalent, which is a bit confusing to me.

> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> ---
>  net/bridge/br_vlan.c | 58 ++++++++++++++++++++--------------------------------
>  1 file changed, 22 insertions(+), 36 deletions(-)
> 
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index eae07ee..975deb9 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -72,28 +72,20 @@ static void __vlan_add_flags(struct net_bridge_vlan *v, u16 flags)
>  static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
>  			  u16 vid, u16 flags)
>  {
> -	const struct net_device_ops *ops = dev->netdev_ops;
> +	struct switchdev_obj_port_vlan v = {
> +		.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
> +		.flags = flags,
> +		.vid_begin = vid,
> +		.vid_end = vid,
> +	};
>  	int err;
>  
> -	/* If driver uses VLAN ndo ops, use 8021q to install vid
> -	 * on device, otherwise try switchdev ops to install vid.
> +	/* Try switchdev op first. In case it is not supported, fallback to
> +	 * 8021q add.
>  	 */
> -
> -	if (ops->ndo_vlan_rx_add_vid) {
> -		err = vlan_vid_add(dev, br->vlan_proto, vid);
> -	} else {
> -		struct switchdev_obj_port_vlan v = {
> -			.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
> -			.flags = flags,
> -			.vid_begin = vid,
> -			.vid_end = vid,
> -		};
> -
> -		err = switchdev_port_obj_add(dev, &v.obj);
> -		if (err == -EOPNOTSUPP)
> -			err = 0;
> -	}
> -
> +	err = switchdev_port_obj_add(dev, &v.obj);
> +	if (err == -EOPNOTSUPP)
> +		return vlan_vid_add(dev, br->vlan_proto, vid);

                err = vlan_vid_add(dev, br->vlan_proto, vid);

Just being picky: the above line would have been preferred to keep a
single return path, but this does not justify a v2 though.

>  	return err;
>  }

Thanks,
-v
