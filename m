From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] bcm43xx-d80211: proper implementation of virtual
 interface support
Date: Tue, 2 May 2006 13:20:37 +0200
Message-ID: <20060502132037.059a7cb2@griffin.suse.cz>
References: <200605012135.00895.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:10959 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964775AbWEBLUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 07:20:39 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200605012135.00895.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 1 May 2006 21:35:00 +0200, Michael Buesch wrote:
> --- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-04-28 16:13:40.000000000 +0200
> +++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-05-01 20:25:31.000000000 +0200
> @@ -626,10 +626,34 @@
>  	u8 algorithm;
>  };
>  
> +struct bcm43xx_interface {
> +	struct list_head list;
> +	/* Interface type (IEEE80211_IF_TYPE_XXX). */
> +	int type;
> +	/* Opaque ID from the ieee80211 subsystem. Do not modify. */
> +	int if_id;
> +	/* MAC address for this interface. */
> +	u8 *mac_addr;
> +	/* BSSID (if any). */
> +	u8 *bssid;
> +};
> +
> +struct bcm43xx_interface_list {
> +	/* Linked list of active interfaces. */
> +	struct list_head list;
> +	/* Shortcut pointer to the AP interface (if any). */
> +	struct bcm43xx_interface *ap_if;
> +
> +	/* Usage counters of the internal operation modes. */
> +	u16 opmode_ap;
> +	u16 opmode_adhoc;
> +	u16 opmode_monitor;
> +	u16 opmode_promisc;
> +};
> +

This is unnecessary. AFAIK bcm43xx hardware doesn't support more than one
interface at a time (not counting monitor interfaces as those are somewhat
special). There is no need for the linked list.

Instead of those structures above, use something like this:

struct bcm43xx_interface {
	/* Interface type (IEEE80211_IF_TYPE_XXX). */
	int type;
	/* MAC address for this interface. */
	u8 *mac_addr;
	/* BSSID (if any). */
	u8 *bssid;
	/* Number of monitor interfaces. */
	int monitors;
	/* STA, IBSS, AP or WDS running? */
	int oper;
}

You need this structure just once per hw card.

In add_interface callback:
- If conf->type is MNTR:
	- If bcm43xx_interface->oper is FALSE and
	  bcm43xx_interface->monitors is 0, initialize the card.
	- If bcm43xx_interface->monitors is 0, switch the card to monitor
	  mode (enable promisc mode, enable receiving of control frames,
	  etc.)
	- Increase bcm43xx_interface->monitors.
- If conf->type != MNTR:
	- If bcm43xx_interface->oper is TRUE, return error.
	- Set bcm43xx_interface->oper to TRUE.
	- Set bcm43xx_interface->type to conf->type.
	- Set hw MAC address according to conf->mac_addr.
	- If bcm43xx_interface->monitors is 0, initialize the card.

In remove_interface callback:
- If conf->type is MNTR:
	- Decrease bcm43xx_interface->monitors.
	- If bcm43xx_interface->monitors is 0, switch the card from monitor
	  mode (disable promisc mode if not forced by set_multicast_list,
	  disable receiving of control frames, etc.)
	- If bcm43xx_interface->oper is FALSE and
	  bcm43xx_interface->monitors is 0, deinitialize the card.
- If conf->type != MNTR:
	- Set bcm43xx_interface->oper to FALSE.
	- If bcm43xx_interface->monitors is 0, deinitialize the card.

In config_interface callback:
- If conf->type is MNTR, please report a bug :-)
- Assume you are configuring the only interface you have running.

> [...]
> +	iface = kzalloc(sizeof(*iface), GFP_KERNEL);
> +	if (!iface)
> +		return -ENOMEM;
> +	INIT_LIST_HEAD(&iface->list);
> +	iface->type = conf->type;
> +	iface->if_id = conf->if_id;
> +	iface->mac_addr = conf->mac_addr;
> +
> +	bcm43xx_lock_mmio(bcm, flags);
> +	switch (conf->type) {
> +	case IEEE80211_IF_TYPE_AP:
> +		/* Cannot run more than one AP or concurrently
> +		 * with IBSS mode.
> +		 */
> +		if (bcm->interfaces.opmode_ap)
> +			break;
> +		if (bcm->interfaces.opmode_adhoc)
> +			break;
> +		bcm->interfaces.opmode_ap++;
> +		bcm->interfaces.ap_if = iface;
> +		err = 0;
> +		break;
> +	case IEEE80211_IF_TYPE_STA:
> +		/* Cannot run STA and AP or IBSS mode concurrently. */
> +		if (bcm->interfaces.opmode_ap)
> +			break;
> +		if (bcm->interfaces.opmode_adhoc)
> +			break;
> +		err = 0;
> +		break;

"ifconfig ap up ; ifconfig sta up" will succeed, while
"ifconfig sta up ; ifconfig ap up" won't.

Also, you cannot allow multiple STA interfaces, unless you can configure the
card to ack frames destined to several MAC addresses.

Nevertheless, this is all addressed by the solution suggested above.

> +	case IEEE80211_IF_TYPE_IBSS:
> +		/* Cannot run more than one IBSS or concurrently
> +		 * with AP mode.
> +		 */
> +		if (bcm->interfaces.opmode_ap)
> +			break;
> +		if (bcm->interfaces.opmode_adhoc)
> +			break;
> +		bcm->interfaces.opmode_adhoc++;
> +		err = 0;
> +		break;
> +	case IEEE80211_IF_TYPE_MNTR:
> +		bcm->interfaces.opmode_monitor++;
> +		err = 0;
> +		break;
> +	case IEEE80211_IF_TYPE_WDS:
> +		//TODO: Uhm..., well.
> +		break;

Please return more appropriate error code (-EINVAL perhaps?).

> +	default:
> +		assert(0);
>  	}

Thanks,

-- 
Jiri Benc
SUSE Labs
