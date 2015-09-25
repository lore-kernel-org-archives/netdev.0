From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [patch net-next v3 02/10] switchdev: introduce transaction item
 queue for attr_set and obj_add
Date: Fri, 25 Sep 2015 00:36:40 -0400
Message-ID: <20150925043640.GB18915@ketchup.lan>
References: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
 <1443081769-11193-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:55626
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750850AbbIYEgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 00:36:44 -0400
Content-Disposition: inline
In-Reply-To: <1443081769-11193-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Sep. Thursday 24 (39) 10:02 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Now, the memory allocation in prepare/commit state is done separatelly
> in each driver (rocker). Introduce the similar mechanism in generic
> switchdev code, in form of queue. That can be used not only for memory
> allocations, but also for different items. Abort item destruction
> is handled as well.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

[...]

>  /**
>   * struct switchdev_ops - switchdev operations
>   *
> @@ -94,9 +110,11 @@ struct switchdev_ops {
>  	int	(*switchdev_port_attr_get)(struct net_device *dev,
>  					   struct switchdev_attr *attr);
>  	int	(*switchdev_port_attr_set)(struct net_device *dev,
> -					   struct switchdev_attr *attr);
> +					   struct switchdev_attr *attr,
> +					   struct switchdev_trans *trans);
>  	int	(*switchdev_port_obj_add)(struct net_device *dev,
> -					  struct switchdev_obj *obj);
> +					  struct switchdev_obj *obj,
> +					  struct switchdev_trans *trans);
>  	int	(*switchdev_port_obj_del)(struct net_device *dev,
>  					  struct switchdev_obj *obj);
>  	int	(*switchdev_port_obj_dump)(struct net_device *dev,

This version is better than the current state, but it's too bad we
didn't get feedback yet on the real purpose of this 2-phase model...

Anyway, if we do need that, my wish would be to at least make it
optional. What do you think about having an optional prepare op?

    int (*switchdev_port_obj_prepare)(struct net_device *dev,
                                      struct switchdev_obj *obj,
                                      struct switchdev_prepare *prep);

So that the switchdev_port_obj_add function may look like this:

    int switchdev_port_obj_add(struct net_device *dev,
                               struct switchdev_obj *obj)
    {
        struct switchdev_prepare prep;
        int err;

        ASSERT_RTNL();

        switchdev_trans_init(&prep);

        err = __switchdev_port_obj_prepare(dev, obj, &prep);
        if (!err)
            err = __switchdev_port_obj_add(dev, obj, &prep);

        switchdev_prepare_items_destroy(dev, &prep);

        return err;
    }

So drivers can implement the prepare operation if they want to setup a
transaction. You won't have to carry a boolean around, no need for extra
switchdev_trans_ph_{prepare,commit} helpers, and drivers add operation
become simpler.

Same goes for attr_set for sure. Note that I suggest "switchdev_prepare"
instead of "switchdev_trans" to avoid renaming commits and being more
explicit, but it doesn't really matter.

Thanks,
-v
