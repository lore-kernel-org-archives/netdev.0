From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 1/5] tipc: Enhance enabling and disabling of
 Ethernet bearers
Date: Wed, 13 Oct 2010 09:42:21 -0400
Message-ID: <20101013134221.GB31379@hmsreliant.think-freely.org>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57279 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754129Ab0JMNmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 09:42:31 -0400
Content-Disposition: inline
In-Reply-To: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 12, 2010 at 08:25:54PM -0400, Paul Gortmaker wrote:
> From: Allan Stephens <allan.stephens@windriver.com>
> 
> Use work queue to eliminate release of TIPC's configuration lock when
> registering for device notifications while activating Ethernet media
> support. Optimize code that locates an unused bearer entry when enabling
> an Ethernet bearer. Use work queue to break the association between a
> newly disabled Ethernet bearer and its device driver, thereby allowing
> quicker reuse of the bearer entry.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

> ---
>  net/tipc/config.c    |   13 +------
>  net/tipc/eth_media.c |   93 ++++++++++++++++++++++++++++++-------------------
>  2 files changed, 58 insertions(+), 48 deletions(-)
> 
> diff --git a/net/tipc/config.c b/net/tipc/config.c
> index 961d1b0..a43450c 100644
> --- a/net/tipc/config.c
> +++ b/net/tipc/config.c
> @@ -332,19 +332,8 @@ static struct sk_buff *cfg_set_own_addr(void)
>  		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
>  						   " (cannot change node address once assigned)");
>  
> -	/*
> -	 * Must release all spinlocks before calling start_net() because
> -	 * Linux version of TIPC calls eth_media_start() which calls
> -	 * register_netdevice_notifier() which may block!
> -	 *
> -	 * Temporarily releasing the lock should be harmless for non-Linux TIPC,
> -	 * but Linux version of eth_media_start() should really be reworked
> -	 * so that it can be called with spinlocks held.
> -	 */
> -
> -	spin_unlock_bh(&config_lock);
>  	tipc_core_start_net(addr);
> -	spin_lock_bh(&config_lock);
> +
>  	return tipc_cfg_reply_none();
>  }
>  
Why is the work queue needed at all?  Looking at this path, the only entry to it
is from:
genl_rcv_msg
 handle_cmd
  tipc_cfg_do_cmd
   cfg_set_own_addr

That path looks to only be callable from a user space context, so sleeping on
the rtnl lock in when you call register_netdevice_notifier in eth_media_start
should be perfectly fine.  So you should just be able to remove the lock without
any additional work.  Does doing so cause other problems?

> diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
> index 6e988ba..479dbc0 100644
> --- a/net/tipc/eth_media.c
> +++ b/net/tipc/eth_media.c
> @@ -51,17 +51,20 @@
>   * @bearer: ptr to associated "generic" bearer structure
>   * @dev: ptr to associated Ethernet network device
>   * @tipc_packet_type: used in binding TIPC to Ethernet driver
> + * @cleanup: work item used when disabling bearer
>   */
>  
>  struct eth_bearer {
>  	struct tipc_bearer *bearer;
>  	struct net_device *dev;
>  	struct packet_type tipc_packet_type;
> +	struct work_struct cleanup;
>  };
>  
>  static struct eth_bearer eth_bearers[MAX_ETH_BEARERS];
>  static int eth_started = 0;
>  static struct notifier_block notifier;
> +static struct work_struct reg_notifier;
>  
>  /**
>   * send_msg - send a TIPC message out over an Ethernet interface
> @@ -157,22 +160,22 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
>  	if (!dev)
>  		return -ENODEV;
>  
> -	/* Find Ethernet bearer for device (or create one) */
> -
> -	for (;(eb_ptr != stop) && eb_ptr->dev && (eb_ptr->dev != dev); eb_ptr++);
> -	if (eb_ptr == stop)
> -		return -EDQUOT;
> -	if (!eb_ptr->dev) {
> -		eb_ptr->dev = dev;
> -		eb_ptr->tipc_packet_type.type = htons(ETH_P_TIPC);
> -		eb_ptr->tipc_packet_type.dev = dev;
> -		eb_ptr->tipc_packet_type.func = recv_msg;
> -		eb_ptr->tipc_packet_type.af_packet_priv = eb_ptr;
> -		INIT_LIST_HEAD(&(eb_ptr->tipc_packet_type.list));
> -		dev_hold(dev);
> -		dev_add_pack(&eb_ptr->tipc_packet_type);
> +	/* Create Ethernet bearer for device */
> +
> +	while (eb_ptr->dev != NULL) {
> +		if (++eb_ptr == stop)
> +			return -EDQUOT;
>  	}
>  
> +	eb_ptr->dev = dev;
> +	eb_ptr->tipc_packet_type.type = __constant_htons(ETH_P_TIPC);
> +	eb_ptr->tipc_packet_type.dev = dev;
> +	eb_ptr->tipc_packet_type.func = recv_msg;
> +	eb_ptr->tipc_packet_type.af_packet_priv = eb_ptr;
> +	INIT_LIST_HEAD(&eb_ptr->tipc_packet_type.list);
> +	dev_hold(dev);
> +	dev_add_pack(&eb_ptr->tipc_packet_type);
> +
>  	/* Associate TIPC bearer with Ethernet bearer */
>  
>  	eb_ptr->bearer = tb_ptr;
> @@ -185,16 +188,36 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
>  }
>  
>  /**
> + * cleanup_bearer - break association between Ethernet bearer and interface
> + *
> + * This routine must be invoked from a work queue because it can sleep.
> + */
> +
> +static void cleanup_bearer(struct work_struct *work)
> +{
> +	struct eth_bearer *eb_ptr =
> +		container_of(work, struct eth_bearer, cleanup);
> +
> +	dev_remove_pack(&eb_ptr->tipc_packet_type);
> +	dev_put(eb_ptr->dev);
> +	eb_ptr->dev = NULL;
> +}
> +
> +/**
>   * disable_bearer - detach TIPC bearer from an Ethernet interface
>   *
> - * We really should do dev_remove_pack() here, but this function can not be
> - * called at tasklet level. => Use eth_bearer->bearer as a flag to throw away
> - * incoming buffers, & postpone dev_remove_pack() to eth_media_stop() on exit.
> + * Mark Ethernet bearer as inactive so that incoming buffers are thrown away,
> + * then get worker thread to complete bearer cleanup.  (Can't do cleanup
> + * here because cleanup code needs to sleep and caller holds spinlocks.)
>   */
>  
>  static void disable_bearer(struct tipc_bearer *tb_ptr)
>  {
> -	((struct eth_bearer *)tb_ptr->usr_handle)->bearer = NULL;
> +	struct eth_bearer *eb_ptr = (struct eth_bearer *)tb_ptr->usr_handle;
> +
> +	eb_ptr->bearer = NULL;
> +	INIT_WORK(&eb_ptr->cleanup, cleanup_bearer);
If you do really need a workqueue for this, you should move this to someplace
like tipc_enable_bearers, in the restart loop, so you only initalize it once.
That also reduces the chance of a race if multiple processes attempt to disable
this barrier in rapid succession.

> +	schedule_work(&eb_ptr->cleanup);
>  }
>  
>  /**
> @@ -265,6 +288,19 @@ static char *eth_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size
>  }
>  
>  /**
> + * do_registration - register TIPC to receive device notifications
> + *
> + * This routine must be invoked from a work queue because it can sleep.
> + */
> +
> +static void do_registration(struct work_struct *dummy)
> +{
> +	notifier.notifier_call = &recv_notification;
> +	notifier.priority = 0;
> +	register_netdevice_notifier(&notifier);
> +}
> +
> +/**
>   * tipc_eth_media_start - activate Ethernet bearer support
>   *
>   * Register Ethernet media type with TIPC bearer code.  Also register
> @@ -291,11 +327,9 @@ int tipc_eth_media_start(void)
>  	if (res)
>  		return res;
>  
> -	notifier.notifier_call = &recv_notification;
> -	notifier.priority = 0;
> -	res = register_netdevice_notifier(&notifier);
> -	if (!res)
> -		eth_started = 1;
> +	INIT_WORK(&reg_notifier, do_registration);
> +	schedule_work(&reg_notifier);
> +	eth_started = 1;
This is racy.  Even though tipc_cfg_do_cmd holds the config_lock, so only one
context can execute this at a time. two requests that execute this code in rapid
succession can re-initalize the reg_notifier work_struct while its sitting on a
work queue, causing an oops if the workqueue task tries to dequeue this entry
while its getting re-initalized.  You need to move this to someplace like the
module_init routine.

>  	return res;
>  }
>  
> @@ -305,22 +339,9 @@ int tipc_eth_media_start(void)
>  
>  void tipc_eth_media_stop(void)
>  {
> -	int i;
> -
>  	if (!eth_started)
>  		return;
>  
>  	unregister_netdevice_notifier(&notifier);
> -	for (i = 0; i < MAX_ETH_BEARERS ; i++) {
> -		if (eth_bearers[i].bearer) {
> -			eth_bearers[i].bearer->blocked = 1;
Where does this now get set when executing a tipc_eth_media_stop?  Don't you
want to block access to all bearers immediately when you call this?

> -			eth_bearers[i].bearer = NULL;
> -		}
> -		if (eth_bearers[i].dev) {
> -			dev_remove_pack(&eth_bearers[i].tipc_packet_type);
> -			dev_put(eth_bearers[i].dev);
> -		}
> -	}
> -	memset(&eth_bearers, 0, sizeof(eth_bearers));
>  	eth_started = 0;
>  }
> -- 
> 1.7.0.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
