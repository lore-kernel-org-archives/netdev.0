From: Jon Mason <jdmason@kudzu.us>
Subject: Re: [net-next-2.6 RFC PATCH v3] ethtool: allow custom interval for
 physical identification
Date: Thu, 14 Apr 2011 13:55:35 -0500
Message-ID: <20110414185533.GA3128@kudzu.us>
References: <20110413230910.16317.11372.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Divy Le Ray <divy@chelsio.com>,
	Don Fry <pcnet32@frontier.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Matt Carlson <mcarlson@broadcom.com>
To: Bruce Allan <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:54073 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864Ab1DNSzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 14:55:41 -0400
Received: by yxs7 with SMTP id 7so857339yxs.19
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 11:55:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110413230910.16317.11372.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2011 at 04:09:10PM -0700, Bruce Allan wrote:
> When physical identification of an adapter is done by toggling the
> mechanism on and off through software utilizing the set_phys_id operation,
> it is done with a fixed duration for both on and off states.  Some drivers
> may want to set a custom duration for the on/off intervals.  This patch
> changes the API so the return code from the driver's entry point when it
> is called with ETHTOOL_ID_ACTIVE can specify the frequency at which to
> cycle the on/off states, and updates the drivers that have already been
> converted to use the new set_phys_id and use the synchronous method for
> identifying an adapter.
> 
> The physical identification frequency set in the updated drivers is based
> on how it was done prior to the introduction of set_phys_id.
> 
> Compile tested only.  Also fixes a compiler warning in sfc.
> 
> v2: drivers do not return -EINVAL for ETHOOL_ID_ACTIVE
> v3: fold patchset into single patch and cleanup per Ben's feedback
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Acked-by: Jon Mason <jdmason@kudzu.us>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Cc: Sathya Perla <sathya.perla@emulex.com>
> Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Cc: Michael Chan <mchan@broadcom.com>
> Cc: Eilon Greenstein <eilong@broadcom.com>
> Cc: Divy Le Ray <divy@chelsio.com>
> Cc: Don Fry <pcnet32@frontier.com>
> Cc: Jon Mason <jdmason@kudzu.us>
> Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
> Cc: Steve Hodgson <shodgson@solarflare.com>
> Cc: Stephen Hemminger <shemminger@linux-foundation.org>
> Cc: Matt Carlson <mcarlson@broadcom.com>
> ---
> 
>  drivers/net/benet/be_ethtool.c    |    2 +-
>  drivers/net/bnx2.c                |    2 +-
>  drivers/net/bnx2x/bnx2x_ethtool.c |    2 +-
>  drivers/net/cxgb3/cxgb3_main.c    |    2 +-
>  drivers/net/ewrk3.c               |    2 +-
>  drivers/net/niu.c                 |    2 +-
>  drivers/net/pcnet32.c             |    2 +-
>  drivers/net/s2io.c                |    2 +-
>  drivers/net/sfc/ethtool.c         |    6 +++---
>  drivers/net/skge.c                |    2 +-
>  drivers/net/sky2.c                |    2 +-
>  drivers/net/tg3.c                 |    2 +-
>  include/linux/ethtool.h           |    6 ++++--
>  net/core/ethtool.c                |   31 ++++++++++++++++---------------
>  14 files changed, 34 insertions(+), 31 deletions(-)
> 
> diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
> index 96f5502..80226e4 100644
> --- a/drivers/net/benet/be_ethtool.c
> +++ b/drivers/net/benet/be_ethtool.c
> @@ -516,7 +516,7 @@ be_set_phys_id(struct net_device *netdev,
>  	case ETHTOOL_ID_ACTIVE:
>  		be_cmd_get_beacon_state(adapter, adapter->hba_port_num,
>  					&adapter->beacon_state);
> -		return -EINVAL;
> +		return 1;	/* cycle on/off once per second */
>  
>  	case ETHTOOL_ID_ON:
>  		be_cmd_set_beacon_state(adapter, adapter->hba_port_num, 0, 0,
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 0a52079..bf729ee 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -7473,7 +7473,7 @@ bnx2_set_phys_id(struct net_device *dev, enum ethtool_phys_id_state state)
>  
>  		bp->leds_save = REG_RD(bp, BNX2_MISC_CFG);
>  		REG_WR(bp, BNX2_MISC_CFG, BNX2_MISC_CFG_LEDMODE_MAC);
> -		return -EINVAL;
> +		return 1;	/* cycle on/off once per second */
>  
>  	case ETHTOOL_ID_ON:
>  		REG_WR(bp, BNX2_EMAC_LED, BNX2_EMAC_LED_OVERRIDE |
> diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
> index ad7d91e..0a5e88d 100644
> --- a/drivers/net/bnx2x/bnx2x_ethtool.c
> +++ b/drivers/net/bnx2x/bnx2x_ethtool.c
> @@ -2025,7 +2025,7 @@ static int bnx2x_set_phys_id(struct net_device *dev,
>  
>  	switch (state) {
>  	case ETHTOOL_ID_ACTIVE:
> -		return -EINVAL;
> +		return 1;	/* cycle on/off once per second */
>  
>  	case ETHTOOL_ID_ON:
>  		bnx2x_set_led(&bp->link_params, &bp->link_vars,
> diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
> index 802c7a7..a087e06 100644
> --- a/drivers/net/cxgb3/cxgb3_main.c
> +++ b/drivers/net/cxgb3/cxgb3_main.c
> @@ -1757,7 +1757,7 @@ static int set_phys_id(struct net_device *dev,
>  
>  	switch (state) {
>  	case ETHTOOL_ID_ACTIVE:
> -		return -EINVAL;
> +		return 1;	/* cycle on/off once per second */
>  
>  	case ETHTOOL_ID_OFF:
>  		t3_set_reg_field(adapter, A_T3DBG_GPIO_EN, F_GPIO0_OUT_VAL, 0);
> diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
> index c7ce443..17b6027 100644
> --- a/drivers/net/ewrk3.c
> +++ b/drivers/net/ewrk3.c
> @@ -1618,7 +1618,7 @@ static int ewrk3_set_phys_id(struct net_device *dev,
>  		/* Prevent ISR from twiddling the LED */
>  		lp->led_mask = 0;
>  		spin_unlock_irq(&lp->hw_lock);
> -		return -EINVAL;
> +		return 2;	/* cycle on/off twice per second */
>  
>  	case ETHTOOL_ID_ON:
>  		cr = inb(EWRK3_CR);
> diff --git a/drivers/net/niu.c b/drivers/net/niu.c
> index 3fa1e9c..ea2272f 100644
> --- a/drivers/net/niu.c
> +++ b/drivers/net/niu.c
> @@ -7896,7 +7896,7 @@ static int niu_set_phys_id(struct net_device *dev,
>  	switch (state) {
>  	case ETHTOOL_ID_ACTIVE:
>  		np->orig_led_state = niu_led_state_save(np);
> -		return -EINVAL;
> +		return 1;	/* cycle on/off once per second */
>  
>  	case ETHTOOL_ID_ON:
>  		niu_force_led(np, 1);
> diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
> index e89afb9..0a1efba 100644
> --- a/drivers/net/pcnet32.c
> +++ b/drivers/net/pcnet32.c
> @@ -1038,7 +1038,7 @@ static int pcnet32_set_phys_id(struct net_device *dev,
>  		for (i = 4; i < 8; i++)
>  			lp->save_regs[i - 4] = a->read_bcr(ioaddr, i);
>  		spin_unlock_irqrestore(&lp->lock, flags);
> -		return -EINVAL;
> +		return 2;	/* cycle on/off twice per second */
>  
>  	case ETHTOOL_ID_ON:
>  	case ETHTOOL_ID_OFF:
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index 2d5cc61..2302d97 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -5541,7 +5541,7 @@ static int s2io_ethtool_set_led(struct net_device *dev,
>  	switch (state) {
>  	case ETHTOOL_ID_ACTIVE:
>  		sp->adapt_ctrl_org = readq(&bar0->gpio_control);
> -		return -EINVAL;
> +		return 1;	/* cycle on/off once per second */
>  
>  	case ETHTOOL_ID_ON:
>  		s2io_set_led(sp, true);
> diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
> index 644f7c1..5d8468f 100644
> --- a/drivers/net/sfc/ethtool.c
> +++ b/drivers/net/sfc/ethtool.c
> @@ -182,7 +182,7 @@ static int efx_ethtool_phys_id(struct net_device *net_dev,
>  			       enum ethtool_phys_id_state state)
>  {
>  	struct efx_nic *efx = netdev_priv(net_dev);
> -	enum efx_led_mode mode;
> +	enum efx_led_mode mode = EFX_LED_DEFAULT;
>  
>  	switch (state) {
>  	case ETHTOOL_ID_ON:
> @@ -194,8 +194,8 @@ static int efx_ethtool_phys_id(struct net_device *net_dev,
>  	case ETHTOOL_ID_INACTIVE:
>  		mode = EFX_LED_DEFAULT;
>  		break;
> -	default:
> -		return -EINVAL;
> +	case ETHTOOL_ID_ACTIVE:
> +		return 1;	/* cycle on/off once per second */
>  	}
>  
>  	efx->type->set_id_led(efx, mode);
> diff --git a/drivers/net/skge.c b/drivers/net/skge.c
> index 310dcbc..176d784 100644
> --- a/drivers/net/skge.c
> +++ b/drivers/net/skge.c
> @@ -753,7 +753,7 @@ static int skge_set_phys_id(struct net_device *dev,
>  
>  	switch (state) {
>  	case ETHTOOL_ID_ACTIVE:
> -		return -EINVAL;
> +		return 2;	/* cycle on/off twice per second */
>  
>  	case ETHTOOL_ID_ON:
>  		skge_led(skge, LED_MODE_TST);
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index a4b8fe5..c8d0451 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -3813,7 +3813,7 @@ static int sky2_set_phys_id(struct net_device *dev,
>  
>  	switch (state) {
>  	case ETHTOOL_ID_ACTIVE:
> -		return -EINVAL;
> +		return 1;	/* cycle on/off once per second */
>  	case ETHTOOL_ID_INACTIVE:
>  		sky2_led(sky2, MO_LED_NORM);
>  		break;
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 9d7defc..7c1a9dd 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -10292,7 +10292,7 @@ static int tg3_set_phys_id(struct net_device *dev,
>  
>  	switch (state) {
>  	case ETHTOOL_ID_ACTIVE:
> -		return -EINVAL;
> +		return 1;	/* cycle on/off once per second */
>  
>  	case ETHTOOL_ID_ON:
>  		tw32(MAC_LED_CTRL, LED_CTRL_LNKLED_OVERRIDE |
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index ad22a68..9de3127 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -798,8 +798,10 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
>   *	attached to it.  The implementation may update the indicator
>   *	asynchronously or synchronously, but in either case it must return
>   *	quickly.  It is initially called with the argument %ETHTOOL_ID_ACTIVE,
> - *	and must either activate asynchronous updates or return -%EINVAL.
> - *	If it returns -%EINVAL then it will be called again at intervals with
> + *	and must either activate asynchronous updates and return zero, return
> + *	a negative error or return a positive frequency for synchronous
> + *	indication (e.g. 1 for one on/off cycle per second).  If it returns
> + *	a frequency then it will be called again at intervals with the
>   *	argument %ETHTOOL_ID_ON or %ETHTOOL_ID_OFF and should set the state of
>   *	the indicator accordingly.  Finally, it is called with the argument
>   *	%ETHTOOL_ID_INACTIVE and must deactivate the indicator.  Returns a
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 41dee2d..13d79f5 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1669,7 +1669,7 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
>  		return dev->ethtool_ops->phys_id(dev, id.data);
>  
>  	rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_ACTIVE);
> -	if (rc && rc != -EINVAL)
> +	if (rc < 0)
>  		return rc;
>  
>  	/* Drop the RTNL lock while waiting, but prevent reentry or
> @@ -1684,21 +1684,22 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
>  		schedule_timeout_interruptible(
>  			id.data ? (id.data * HZ) : MAX_SCHEDULE_TIMEOUT);
>  	} else {
> -		/* Driver expects to be called periodically */
> +		/* Driver expects to be called at twice the frequency in rc */
> +		int n = rc * 2, i, interval = HZ / n;
> +
> +		/* Count down seconds */
>  		do {
> -			rtnl_lock();
> -			rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_ON);
> -			rtnl_unlock();
> -			if (rc)
> -				break;
> -			schedule_timeout_interruptible(HZ / 2);
> -
> -			rtnl_lock();
> -			rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_OFF);
> -			rtnl_unlock();
> -			if (rc)
> -				break;
> -			schedule_timeout_interruptible(HZ / 2);
> +			/* Count down iterations per second */
> +			i = n;
> +			do {
> +				rtnl_lock();
> +				rc = dev->ethtool_ops->set_phys_id(dev,
> +				    (i & 1) ? ETHTOOL_ID_OFF : ETHTOOL_ID_ON);
> +				rtnl_unlock();
> +				if (rc)
> +					break;
> +				schedule_timeout_interruptible(interval);
> +			} while (!signal_pending(current) && --i != 0);
>  		} while (!signal_pending(current) &&
>  			 (id.data == 0 || --id.data != 0));
>  	}
> 
