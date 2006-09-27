From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Wed, 27 Sep 2006 11:18:14 -0500
Message-ID: <451AA446.7060009@lwfinger.net>
References: <200609271726.34305.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Christian <email@christianhoffmann.info>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:24472 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751201AbWI0QSa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 12:18:30 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609271726.34305.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> This fixes some race conditions in the WirelessExtension
> handling and association handling code.
> 
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> 
> ---

This patch doesn't apply.

> Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_wx.c
> ===================================================================
> --- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-09-17 15:21:53.000000000 +0200
> +++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-09-27 16:49:25.000000000 +0200
> @@ -73,13 +73,14 @@ ieee80211softmac_wx_set_essid(struct net
>  	struct ieee80211softmac_network *n;
>  	struct ieee80211softmac_auth_queue_item *authptr;
>  	int length = 0;
> -	unsigned long flags;
> +
> +	mutex_lock(&sm->associnfo.mutex);
>  
>  	/* Check if we're already associating to this or another network
>  	 * If it's another network, cancel and start over with our new network
>  	 * If it's our network, ignore the change, we're already doing it!
>  	 */
> -	if((sm->associnfo.associating || sm->associated) &&
> +	if((sm->associnfo.associating || sm->associnfo.associated) &&
>  	   (data->essid.flags && data->essid.length && extra)) {
                                                    ^^^^^^^^^

The marked stuff is not in my copy of wireless-2.6. Is mine hosed?

Larry

>  		/* Get the associating network */
>  		n = ieee80211softmac_get_network_by_bssid(sm, sm->associnfo.bssid);
> @@ -87,10 +88,9 @@ ieee80211softmac_wx_set_essid(struct net
>  		   !memcmp(n->essid.data, extra, n->essid.len)) {
>  			dprintk(KERN_INFO PFX "Already associating or associated to "MAC_FMT"\n",
>  				MAC_ARG(sm->associnfo.bssid));
> -			return 0;
> +			goto out;
>  		} else {
>  			dprintk(KERN_INFO PFX "Canceling existing associate request!\n");
> -			spin_lock_irqsave(&sm->lock,flags);
>  			/* Cancel assoc work */
>  			cancel_delayed_work(&sm->associnfo.work);
>  			/* We don't have to do this, but it's a little cleaner */
> @@ -98,14 +98,13 @@ ieee80211softmac_wx_set_essid(struct net
>  				cancel_delayed_work(&authptr->work);
>  			sm->associnfo.bssvalid = 0;
>  			sm->associnfo.bssfixed = 0;
> -			spin_unlock_irqrestore(&sm->lock,flags);
>  			flush_scheduled_work();
> +			sm->associnfo.associating = 0;
> +			sm->associnfo.associated = 0;
>  		}
>  	}
>  
>  
> -	spin_lock_irqsave(&sm->lock, flags);
> -
>  	sm->associnfo.static_essid = 0;
>  	sm->associnfo.assoc_wait = 0;
>  
> @@ -121,10 +120,12 @@ ieee80211softmac_wx_set_essid(struct net
>  	 * If applicable, we have already copied the data in */
>  	sm->associnfo.req_essid.len = length;
>  
> +	sm->associnfo.associating = 1;
>  	/* queue lower level code to do work (if necessary) */
>  	schedule_work(&sm->associnfo.work);
> +out:
> +	mutex_unlock(&sm->associnfo.mutex);
>  
> -	spin_unlock_irqrestore(&sm->lock, flags);
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(ieee80211softmac_wx_set_essid);
> @@ -136,10 +137,8 @@ ieee80211softmac_wx_get_essid(struct net
>  			      char *extra)
>  {
>  	struct ieee80211softmac_device *sm = ieee80211_priv(net_dev);
> -	unsigned long flags;
>  
> -	/* avoid getting inconsistent information */
> -	spin_lock_irqsave(&sm->lock, flags);
> +	mutex_lock(&sm->associnfo.mutex);
>  	/* If all fails, return ANY (empty) */
>  	data->essid.length = 0;
>  	data->essid.flags = 0;  /* active */
> @@ -152,12 +151,13 @@ ieee80211softmac_wx_get_essid(struct net
>  	}
>  	
>  	/* If we're associating/associated, return that */
> -	if (sm->associated || sm->associnfo.associating) {
> +	if (sm->associnfo.associated || sm->associnfo.associating) {
>  		data->essid.length = sm->associnfo.associate_essid.len;
>  		data->essid.flags = 1;  /* active */
>  		memcpy(extra, sm->associnfo.associate_essid.data, sm->associnfo.associate_essid.len);
>  	}
> -	spin_unlock_irqrestore(&sm->lock, flags);
> +	mutex_unlock(&sm->associnfo.mutex);
> +
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(ieee80211softmac_wx_get_essid);
> @@ -322,15 +322,15 @@ ieee80211softmac_wx_get_wap(struct net_d
>  {
>  	struct ieee80211softmac_device *mac = ieee80211_priv(net_dev);
>  	int err = 0;
> -	unsigned long flags;
>  
> -	spin_lock_irqsave(&mac->lock, flags);
> +	mutex_lock(&mac->associnfo.mutex);
>  	if (mac->associnfo.bssvalid)
>  		memcpy(data->ap_addr.sa_data, mac->associnfo.bssid, ETH_ALEN);
>  	else
>  		memset(data->ap_addr.sa_data, 0xff, ETH_ALEN);
>  	data->ap_addr.sa_family = ARPHRD_ETHER;
> -	spin_unlock_irqrestore(&mac->lock, flags);
> +	mutex_unlock(&mac->associnfo.mutex);
> +
>  	return err;
>  }
>  EXPORT_SYMBOL_GPL(ieee80211softmac_wx_get_wap);
> @@ -342,28 +342,27 @@ ieee80211softmac_wx_set_wap(struct net_d
>  			    char *extra)
>  {
>  	struct ieee80211softmac_device *mac = ieee80211_priv(net_dev);
> -	unsigned long flags;
>  
>  	/* sanity check */
>  	if (data->ap_addr.sa_family != ARPHRD_ETHER) {
>  		return -EINVAL;
>  	}
>  
> -	spin_lock_irqsave(&mac->lock, flags);
> +	mutex_lock(&mac->associnfo.mutex);
>  	if (is_broadcast_ether_addr(data->ap_addr.sa_data)) {
>  		/* the bssid we have is not to be fixed any longer,
>  		 * and we should reassociate to the best AP. */
>  		mac->associnfo.bssfixed = 0;
>  		/* force reassociation */
>  		mac->associnfo.bssvalid = 0;
> -		if (mac->associated)
> +		if (mac->associnfo.associated)
>  			schedule_work(&mac->associnfo.work);
>  	} else if (is_zero_ether_addr(data->ap_addr.sa_data)) {
>  		/* the bssid we have is no longer fixed */
>  		mac->associnfo.bssfixed = 0;
>          } else {
>  		if (!memcmp(mac->associnfo.bssid, data->ap_addr.sa_data, ETH_ALEN)) {
> -			if (mac->associnfo.associating || mac->associated) {
> +			if (mac->associnfo.associating || mac->associnfo.associated) {
>  			/* bssid unchanged and associated or associating - just return */
>  				goto out;
>  			}
> @@ -378,7 +377,8 @@ ieee80211softmac_wx_set_wap(struct net_d
>          }
>  
>   out:
> -	spin_unlock_irqrestore(&mac->lock, flags);
> +	mutex_unlock(&mac->associnfo.mutex);
> +
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(ieee80211softmac_wx_set_wap);
> @@ -394,7 +394,8 @@ ieee80211softmac_wx_set_genie(struct net
>  	int err = 0;
>  	char *buf;
>  	int i;
> -	
> +
> +	mutex_lock(&mac->associnfo.mutex);
>  	spin_lock_irqsave(&mac->lock, flags);
>  	/* bleh. shouldn't be locked for that kmalloc... */
>  
> @@ -432,6 +433,8 @@ ieee80211softmac_wx_set_genie(struct net
>  
>   out:	
>  	spin_unlock_irqrestore(&mac->lock, flags);
> +	mutex_unlock(&mac->associnfo.mutex);
> +
>  	return err;
>  }
>  EXPORT_SYMBOL_GPL(ieee80211softmac_wx_set_genie);
> @@ -446,7 +449,8 @@ ieee80211softmac_wx_get_genie(struct net
>  	unsigned long flags;
>  	int err = 0;
>  	int space = wrqu->data.length;
> -	
> +
> +	mutex_lock(&mac->associnfo.mutex);
>  	spin_lock_irqsave(&mac->lock, flags);
>  	
>  	wrqu->data.length = 0;
> @@ -459,6 +463,8 @@ ieee80211softmac_wx_get_genie(struct net
>  			err = -E2BIG;
>  	}
>  	spin_unlock_irqrestore(&mac->lock, flags);
> +	mutex_lock(&mac->associnfo.mutex);
> +
>  	return err;
>  }
>  EXPORT_SYMBOL_GPL(ieee80211softmac_wx_get_genie);
> @@ -473,10 +479,13 @@ ieee80211softmac_wx_set_mlme(struct net_
>  	struct iw_mlme *mlme = (struct iw_mlme *)extra;
>  	u16 reason = cpu_to_le16(mlme->reason_code);
>  	struct ieee80211softmac_network *net;
> +	int err = -EINVAL;
> +
> +	mutex_lock(&mac->associnfo.mutex);
>  
>  	if (memcmp(mac->associnfo.bssid, mlme->addr.sa_data, ETH_ALEN)) {
>  		printk(KERN_DEBUG PFX "wx_set_mlme: requested operation on net we don't use\n");
> -		return -EINVAL;
> +		goto out;
>  	}
>  
>  	switch (mlme->cmd) {
> @@ -484,14 +493,22 @@ ieee80211softmac_wx_set_mlme(struct net_
>  		net = ieee80211softmac_get_network_by_bssid_locked(mac, mlme->addr.sa_data);
>  		if (!net) {
>  			printk(KERN_DEBUG PFX "wx_set_mlme: we should know the net here...\n");
> -			return -EINVAL;
> +			goto out;
>  		}
>  		return ieee80211softmac_deauth_req(mac, net, reason);
>  	case IW_MLME_DISASSOC:
>  		ieee80211softmac_send_disassoc_req(mac, reason);
> -		return 0;
> +		mac->associnfo.associated = 0;
> +		mac->associnfo.associating = 0;
> +		err = 0;
> +		goto out;
>  	default:
> -		return -EOPNOTSUPP;
> +		err = -EOPNOTSUPP;
>  	}
> +
> +out:
> +	mutex_unlock(&mac->associnfo.mutex);
> +
> +	return err;
>  }
>  EXPORT_SYMBOL_GPL(ieee80211softmac_wx_set_mlme);
> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_leds.c	2006-09-17 15:24:29.000000000 +0200
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_leds.c	2006-09-27 15:29:01.000000000 +0200
> @@ -242,7 +242,7 @@ void bcm43xx_leds_update(struct bcm43xx_
>  			//TODO
>  			break;
>  		case BCM43xx_LED_ASSOC:
> -			if (bcm->softmac->associated)
> +			if (bcm->softmac->associnfo.associated)
>  				turn_on = 1;
>  			break;
>  #ifdef CONFIG_BCM43XX_DEBUG
> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-09-24 18:34:58.000000000 +0200
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-09-27 15:28:36.000000000 +0200
> @@ -847,7 +847,7 @@ static struct iw_statistics *bcm43xx_get
>  	unsigned long flags;
>  
>  	wstats = &bcm->stats.wstats;
> -	if (!mac->associated) {
> +	if (!mac->associnfo.associated) {
>  		wstats->miss.beacon = 0;
>  //		bcm->ieee->ieee_stats.tx_retry_limit_exceeded = 0; // FIXME: should this be cleared here?
>  		wstats->discard.retries = 0;
> Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_io.c
> ===================================================================
> --- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_io.c	2006-09-17 15:21:53.000000000 +0200
> +++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_io.c	2006-09-27 16:33:18.000000000 +0200
> @@ -475,8 +475,13 @@ int ieee80211softmac_handle_beacon(struc
>  {
>  	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
>  
> -	if (mac->associated && memcmp(network->bssid, mac->associnfo.bssid, ETH_ALEN) == 0)
> -		ieee80211softmac_process_erp(mac, network->erp_value);
> +	/* This might race, but we don't really care and it's not worth
> +	 * adding heavyweight locking in this fastpath.
> +	 */
> +	if (mac->associnfo.associated) {
> +		if (memcmp(network->bssid, mac->associnfo.bssid, ETH_ALEN) == 0)
> +			ieee80211softmac_process_erp(mac, network->erp_value);
> +	}
>  
>  	return 0;
>  }
> 
> 

