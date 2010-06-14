From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v4] netfilter: Xtables: idletimer target implementation
Date: Mon, 14 Jun 2010 16:48:50 +0200
Message-ID: <4C164152.8080103@trash.net>
References: <1276264913-429-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter@vger.kernel.org, netdev@vger.kernel.org,
	Jan Engelhardt <jengelh@medozas.de>,
	Timo Teras <timo.teras@iki.fi>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51825 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754483Ab0FNOtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 10:49:15 -0400
In-Reply-To: <1276264913-429-1-git-send-email-luciano.coelho@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Luciano Coelho wrote:
> +static int idletimer_tg_create(struct idletimer_tg_info *info)
> +{
> +	int ret;
> +
> +	info->timer = kmalloc(sizeof(*info->timer), GFP_ATOMIC);
> +	if (!info->timer) {
> +		pr_debug("couldn't alloc timer\n");
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	info->timer->attr.attr.name = kstrdup(info->label, GFP_ATOMIC);
>   

These two allocations don't need GFP_ATOMIC AFAICT.

> +	if (!info->timer->attr.attr.name) {
> +		pr_debug("couldn't alloc attribute name\n");
> +		ret = -ENOMEM;
> +		goto out_free_timer;
> +	}
> +	info->timer->attr.attr.mode = S_IRUGO;
> +	info->timer->attr.show = idletimer_tg_show;
> +
> +	ret = sysfs_create_file(idletimer_tg_kobj, &info->timer->attr.attr);
> +	if (ret < 0) {
> +		pr_debug("couldn't add file to sysfs");
> +		goto out_free_attr;
> +	}
> +
> +	list_add(&info->timer->entry, &idletimer_tg_list);
> +
> +	setup_timer(&info->timer->timer, idletimer_tg_expired,
> +		    (unsigned long) info->timer);
> +	info->timer->refcnt = 1;
> +
> +	mod_timer(&info->timer->timer,
> +		  msecs_to_jiffies(info->timeout * 1000) + jiffies);
> +
> +	INIT_WORK(&info->timer->work, idletimer_tg_work);
> +
> +	return 0;
> +
> +out_free_attr:
> +	kfree(info->timer->attr.attr.name);
> +out_free_timer:
> +	kfree(info->timer);
> +out:
> +	return ret;
> +}
> +
> +/*
> + * The actual xt_tables plugin.
> + */
> +static unsigned int idletimer_tg_target(struct sk_buff *skb,
> +					 const struct xt_action_param *par)
> +{
> +	const struct idletimer_tg_info *info = par->targinfo;
> +
> +	pr_debug("resetting timer %s, timeout period %u\n",
> +		 info->label, info->timeout);
> +
> +	mutex_lock(&list_mutex);
>   

You can't take the mutex in the target function. What is it supposed to
protect again?

> +
> +	BUG_ON(!info->timer);
> +
> +	mod_timer(&info->timer->timer,
> +		  msecs_to_jiffies(info->timeout * 1000) + jiffies);
> +
> +	mutex_unlock(&list_mutex);
> +
> +	return XT_CONTINUE;
> +}
> +

