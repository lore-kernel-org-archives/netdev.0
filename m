From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] cfg80211: new wireless config infrastructure
Date: Wed, 25 Apr 2007 18:06:45 +0200
Message-ID: <200704251806.46270.netdev@axxeo.de>
References: <20070423183334.GC5883@tuxdriver.com> <20070423183443.GD5883@tuxdriver.com> <20070423183634.GE5883@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, johannes@sipsolutions.net
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:48911 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992795AbXDYQHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 12:07:24 -0400
In-Reply-To: <20070423183634.GE5883@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

John W. Linville schrieb:
> From: Johannes Berg <johannes@sipsolutions.net>
> --- /dev/null
> +++ b/net/wireless/core.c
> @@ -0,0 +1,209 @@
> +/*
> + * This is the linux wireless configuration interface.
> + *
> + * Copyright 2006, 2007		Johannes Berg <johannes@sipsolutions.net>
> + */
> +
> +#include <linux/if.h>
> +#include <linux/module.h>
> +#include <linux/err.h>
> +#include <linux/mutex.h>
> +#include <linux/list.h>
> +#include <linux/nl80211.h>
> +#include <linux/debugfs.h>
> +#include <linux/notifier.h>
> +#include <linux/device.h>
> +#include <net/genetlink.h>
> +#include <net/cfg80211.h>
> +#include <net/wireless.h>
> +#include "core.h"
> +#include "sysfs.h"
> +
> +/* name for sysfs, %d is appended */
> +#define PHY_NAME "phy"
> +
> +MODULE_AUTHOR("Johannes Berg");
> +MODULE_LICENSE("GPL");
> +MODULE_DESCRIPTION("wireless configuration support");
> +
> +/* RCU might be appropriate here since we usually
> + * only read the list, and that can happen quite
> + * often because we need to do it for each command */
> +LIST_HEAD(cfg80211_drv_list);
> +DEFINE_MUTEX(cfg80211_drv_mutex);
> +static int wiphy_counter;
> +
> +/* for debugfs */
> +static struct dentry *ieee80211_debugfs_dir;
> +
> +/* exported functions */
> +
> +struct wiphy *wiphy_new(struct cfg80211_ops *ops, int sizeof_priv)
> +{
> +	struct cfg80211_registered_device *drv;
> +	int alloc_size;
> +
> +	alloc_size = sizeof(*drv) + sizeof_priv;
> +
> +	drv = kzalloc(alloc_size, GFP_KERNEL);
> +	if (!drv)
> +		return NULL;
> +
> +	drv->ops = ops;
> +
> +	mutex_lock(&cfg80211_drv_mutex);
> +
> +	if (unlikely(wiphy_counter<0)) {

		mutex_unlock(&cfg80211_drv_mutex);

> +		/* ugh, wrapped! */
> +		kfree(drv);
> +		return NULL;
> +	}
> +	drv->idx = wiphy_counter;
> +
> +	/* give it a proper name */
> +	snprintf(drv->wiphy.dev.bus_id, BUS_ID_SIZE,
> +		 PHY_NAME "%d", drv->idx);
> +
> +	/* now increase counter for the next time */
> +	wiphy_counter++;
> +	mutex_unlock(&cfg80211_drv_mutex);

Since drv and its contents are not visible to anyone yet, 
I suggest the following code flow for that:

mutex_lock(&cfg80211_drv_mutex);

drv->idx = wiphy_counter;

/* increase counter for the next time, if id didn't wrap */
if (drv->idx >= 0)
	wiphy_counter++;

mutex_unlock(&cfg80211_drv_mutex);

if (drv->idx < 0) {
	kfree(drv);
	return NULL;
}

/* give it a proper name */
snprintf(drv->wiphy.dev.bus_id, BUS_ID_SIZE,
	 PHY_NAME "%d", drv->idx);

[enqueue to all lists here]


Rest looks good so far.

Regards

Ingo Oeser
