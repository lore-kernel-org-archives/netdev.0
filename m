From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch net-next v2 04/19] net: switchdev: Change notifier chain
 to be atomic
Date: Thu, 8 Jun 2017 11:30:39 +0200
Message-ID: <6ca77a33-9c7c-6fbf-c6a0-3483cbc4f6e1@redhat.com>
References: <20170608064428.4785-1-jiri@resnulli.us>
 <20170608064428.4785-5-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38950 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751679AbdFHJam (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 05:30:42 -0400
In-Reply-To: <20170608064428.4785-5-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8.6.2017 08:44, Jiri Pirko wrote:
> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> In order to use the switchdev notifier chain for FDB sync with the
> device it has to be changed to atomic. The is done because the bridge
> can learn new FDBs in atomic context.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Reviewed-by: Ivan Vecera <ivecera@redhat.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  net/switchdev/switchdev.c | 30 ++++++------------------------
>  1 file changed, 6 insertions(+), 24 deletions(-)
> 
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 8d40a7d..25dc67e 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -571,24 +571,17 @@ int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
>  }
>  EXPORT_SYMBOL_GPL(switchdev_port_obj_dump);
>  
> -static RAW_NOTIFIER_HEAD(switchdev_notif_chain);
> +static ATOMIC_NOTIFIER_HEAD(switchdev_notif_chain);
>  
>  /**
>   *	register_switchdev_notifier - Register notifier
>   *	@nb: notifier_block
>   *
> - *	Register switch device notifier. This should be used by code
> - *	which needs to monitor events happening in particular device.
> - *	Return values are same as for atomic_notifier_chain_register().
> + *	Register switch device notifier.
>   */
>  int register_switchdev_notifier(struct notifier_block *nb)
>  {
> -	int err;
> -
> -	rtnl_lock();
> -	err = raw_notifier_chain_register(&switchdev_notif_chain, nb);
> -	rtnl_unlock();
> -	return err;
> +	return atomic_notifier_chain_register(&switchdev_notif_chain, nb);
>  }
>  EXPORT_SYMBOL_GPL(register_switchdev_notifier);
>  
> @@ -597,16 +590,10 @@ EXPORT_SYMBOL_GPL(register_switchdev_notifier);
>   *	@nb: notifier_block
>   *
>   *	Unregister switch device notifier.
> - *	Return values are same as for atomic_notifier_chain_unregister().
>   */
>  int unregister_switchdev_notifier(struct notifier_block *nb)
>  {
> -	int err;
> -
> -	rtnl_lock();
> -	err = raw_notifier_chain_unregister(&switchdev_notif_chain, nb);
> -	rtnl_unlock();
> -	return err;
> +	return atomic_notifier_chain_unregister(&switchdev_notif_chain, nb);
>  }
>  EXPORT_SYMBOL_GPL(unregister_switchdev_notifier);
>  
> @@ -616,18 +603,13 @@ EXPORT_SYMBOL_GPL(unregister_switchdev_notifier);
>   *	@dev: port device
>   *	@info: notifier information data
>   *
> - *	Call all network notifier blocks. This should be called by driver
> - *	when it needs to propagate hardware event.
> - *	Return values are same as for atomic_notifier_call_chain().
> - *	rtnl_lock must be held.
> + *	Call all network notifier blocks.
>   */
>  int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
>  			     struct switchdev_notifier_info *info)
>  {
> -	ASSERT_RTNL();
> -
>  	info->dev = dev;
> -	return raw_notifier_call_chain(&switchdev_notif_chain, val, info);
> +	return atomic_notifier_call_chain(&switchdev_notif_chain, val, info);
>  }
>  EXPORT_SYMBOL_GPL(call_switchdev_notifiers);
>  
> 

Reviewed-by: Ivan Vecera <ivecera@redhat.com>
