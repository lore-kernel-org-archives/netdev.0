From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3 03/22] netconsole: Introduce 'enabled' state-machine
Date: Fri, 17 Dec 2010 15:52:38 -0500
Message-ID: <20101217205238.GA8642@hmsreliant.think-freely.org>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
 <20101214212909.17022.96801.stgit@mike.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon.kagstrom@netinsight.net, davem@davemloft.net,
	Matt Mackall <mpm@selenic.com>, adurbin@google.com,
	linux-kernel@vger.kernel.org, chavey@google.com,
	Greg KH <greg@kroah.com>, netdev@vger.kernel.org,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	akpm@linux-foundation.org, linux-api@vger.kernel.org
To: Mike Waychison <mikew@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101214212909.17022.96801.stgit@mike.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 14, 2010 at 01:29:10PM -0800, Mike Waychison wrote:
> Representing the internal state within netconsole isn't really a boolean
> value, but rather a state machine with transitions.
> 
> This patch introduces 4 states that the netconsole multi-target can
> handle.  These states are:
> - NETPOLL_DISABLED:
>     The netpoll structure hasn't been setup.
> - NETPOLL_SETTINGUP:
>     The netpoll structure is being setup, and only whoever set this
>     state can transition out of it.  Must come from the NETPOLL_DISABLED
>     state.
> - NETPOLL_ENABLED:
>     The netpoll structure has been setup and we are good to emit
>     packets.
> - NETPOLL_CLEANING:
>     Somebody is queued to call netpoll_clean.  Whoever does so must
>     transition out of this state.  Must come from the NETPOLL_CLEANING
>     state.
> 
> The SETTINGUP state specifically targets the window where
> netpoll_setup() can take a while (for example, waiting on RTNL).
> During this window, we want to exclude console messages from being
> emitted to this netpoll target.  We also want to exclude any subsequent
> user thread that tries to simultaneously enable or disable the target.
> 
> The CLEANING state will be used in a subsequent patch to safely defer
> netpoll_cleanup to scheduled work in process context (to fix the
> deadlock that will occur whenever NETDEV_UNREGISTER is seen).
> 
> When introducing these new transition states, it no longer makes sense
> to 'disable' the target if the interface is going down, only when it is
> being removed completely (or deslaved).  In fact, prior to this change,
> we would leak a reference to the network device if an interface was
> brought down, the target removed, and netconsole unloaded.
> 
> Signed-off-by: Mike Waychison <mikew@google.com>
> Acked-by: Matt Mackall <mpm@selenic.com>
> ---
>  drivers/net/netconsole.c |   62 +++++++++++++++++++++++++++++-----------------
>  1 files changed, 39 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> index 6e16888..288a025 100644
> --- a/drivers/net/netconsole.c
> +++ b/drivers/net/netconsole.c
> @@ -71,16 +71,24 @@ static LIST_HEAD(target_list);
>  /* This needs to be a spinlock because write_msg() cannot sleep */
>  static DEFINE_SPINLOCK(target_list_lock);
>  
> +#define NETPOLL_DISABLED	0
> +#define NETPOLL_SETTINGUP	1
> +#define NETPOLL_ENABLED		2
> +#define NETPOLL_CLEANING	3
> +
>  /**
>   * struct netconsole_target - Represents a configured netconsole target.
>   * @list:	Links this target into the target_list.
>   * @item:	Links us into the configfs subsystem hierarchy.
> - * @enabled:	On / off knob to enable / disable target.
> - *		Visible from userspace (read-write).
> - *		We maintain a strict 1:1 correspondence between this and
> - *		whether the corresponding netpoll is active or inactive.
> + * @np_state:	Enabled / Disabled / SettingUp / Cleaning
> + *		Visible from userspace (read-write) as "enabled".
> + *		We maintain a state machine here of the valid states.  Either a
> + *		target is enabled or disabled, but it may also be in a
> + *		transitional state whereby nobody is allowed to act on the
> + *		target other than whoever owns the transition.
> + *
>   *		Also, other parameters of a target may be modified at
> - *		runtime only when it is disabled (enabled == 0).
> + *		runtime only when it is disabled (np_state == NETPOLL_ENABLED).
>   * @np:		The netpoll structure for this target.
>   *		Contains the other userspace visible parameters:
>   *		dev_name	(read-write)
> @@ -96,7 +104,7 @@ struct netconsole_target {
>  #ifdef	CONFIG_NETCONSOLE_DYNAMIC
>  	struct config_item	item;
>  #endif
> -	int			enabled;
> +	int			np_state;
>  	struct netpoll		np;
>  };
>  
> @@ -189,7 +197,7 @@ static struct netconsole_target *alloc_param_target(char *target_config)
>  	if (err)
>  		goto fail;
>  
> -	nt->enabled = 1;
> +	nt->np_state = NETPOLL_ENABLED;
>  
>  	return nt;
>  
> @@ -275,7 +283,8 @@ static long strtol10_check_range(const char *cp, long min, long max)
>  
>  static ssize_t show_enabled(struct netconsole_target *nt, char *buf)
>  {
> -	return snprintf(buf, PAGE_SIZE, "%d\n", nt->enabled);
> +	return snprintf(buf, PAGE_SIZE, "%d\n",
> +			nt->np_state == NETPOLL_ENABLED);
>  }
>  
>  static ssize_t show_dev_name(struct netconsole_target *nt, char *buf)
> @@ -337,9 +346,12 @@ static ssize_t store_enabled(struct netconsole_target *nt,
>  
>  	if (enabled) {	/* 1 */
>  		spin_lock_irqsave(&target_list_lock, flags);
> -		if (nt->enabled)
> +		if (nt->np_state != NETPOLL_DISABLED)
>  			goto busy;
> -		spin_unlock_irqrestore(&target_list_lock, flags);
> +		else {
> +			nt->np_state = NETPOLL_SETTINGUP;
> +			spin_unlock_irqrestore(&target_list_lock, flags);
> +		}
>  
>  		/*
>  		 * Skip netpoll_parse_options() -- all the attributes are
> @@ -350,9 +362,9 @@ static ssize_t store_enabled(struct netconsole_target *nt,
>  		err = netpoll_setup(&nt->np);
>  		spin_lock_irqsave(&target_list_lock, flags);
>  		if (err)
> -			nt->enabled = 0;
> +			nt->np_state = NETPOLL_DISABLED;
>  		else
> -			nt->enabled = 1;
> +			nt->np_state = NETPOLL_ENABLED;
>  		spin_unlock_irqrestore(&target_list_lock, flags);
>  		if (err)
>  			return err;
> @@ -360,10 +372,17 @@ static ssize_t store_enabled(struct netconsole_target *nt,
>  		printk(KERN_INFO "netconsole: network logging started\n");
>  	} else {	/* 0 */
>  		spin_lock_irqsave(&target_list_lock, flags);
> -		nt->enabled = 0;
> +		if (nt->np_state == NETPOLL_ENABLED)
> +			nt->np_state = NETPOLL_CLEANING;
> +		else if (nt->np_state != NETPOLL_DISABLED)
> +			goto busy;
>  		spin_unlock_irqrestore(&target_list_lock, flags);
>  
>  		netpoll_cleanup(&nt->np);
> +
> +		spin_lock_irqsave(&target_list_lock, flags);
> +		nt->np_state = NETPOLL_DISABLED;
> +		spin_unlock_irqrestore(&target_list_lock, flags);
>  	}
>  
>  	return strnlen(buf, count);
> @@ -486,7 +505,7 @@ static ssize_t store_locked_##_name(struct netconsole_target *nt,	\
>  	unsigned long flags;						\
>  	ssize_t ret;							\
>  	spin_lock_irqsave(&target_list_lock, flags);			\
> -	if (nt->enabled) {						\
> +	if (nt->np_state != NETPOLL_DISABLED) {				\
>  		printk(KERN_ERR "netconsole: target (%s) is enabled, "	\
>  				"disable to update parameters\n",	\
>  				config_item_name(&nt->item));		\
> @@ -642,7 +661,7 @@ static void drop_netconsole_target(struct config_group *group,
>  	 * The target may have never been enabled, or was manually disabled
>  	 * before being removed so netpoll may have already been cleaned up.
>  	 */
> -	if (nt->enabled)
> +	if (nt->np_state == NETPOLL_ENABLED)
>  		netpoll_cleanup(&nt->np);
>  
>  	config_item_put(&nt->item);
> @@ -680,16 +699,17 @@ static int netconsole_netdev_event(struct notifier_block *this,
>  	struct net_device *dev = ptr;
>  
>  	if (!(event == NETDEV_CHANGENAME || event == NETDEV_UNREGISTER ||
> -	      event == NETDEV_BONDING_DESLAVE || event == NETDEV_GOING_DOWN))
> +	      event == NETDEV_BONDING_DESLAVE))
>  		goto done;
>  
>  	spin_lock_irqsave(&target_list_lock, flags);
>  	list_for_each_entry(nt, &target_list, list) {
> -		if (nt->np.dev == dev) {
> +		if (nt->np_state == NETPOLL_ENABLED && nt->np.dev == dev) {
>  			switch (event) {
>  			case NETDEV_CHANGENAME:
>  				strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
>  				break;
> +			case NETDEV_BONDING_DESLAVE:
>  			case NETDEV_UNREGISTER:
I don't follow what you're doing here.  Previously NETDEV_BONDING_DESLAVE events
simply caused the netconsole interface to get deactivated, and now we're doing a
dev_put on the bonded interface bacause of the above move.  Given that
NETDEV_BONDING_DESLAVE events are generated when a slave leaves the bond, this
doesn't seem right, or am I missing something

Regards
Neil
