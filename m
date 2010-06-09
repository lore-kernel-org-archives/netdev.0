From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v3] netfilter: Xtables: idletimer target implementation
Date: Wed, 09 Jun 2010 15:45:59 +0200
Message-ID: <4C0F9B17.10504@trash.net>
References: <1275592445-15555-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	jengelh@medozas.de, Timo Teras <timo.teras@iki.fi>
To: luciano.coelho@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34621 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756961Ab0FINp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 09:45:57 -0400
In-Reply-To: <1275592445-15555-1-git-send-email-luciano.coelho@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

luciano.coelho@nokia.com wrote:
> From: Luciano Coelho <luciano.coelho@nokia.com>
>
> This patch implements an idletimer Xtables target that can be used to
> identify when interfaces have been idle for a certain period of time.
>
> Timers are identified by labels and are created when a rule is set with a new
> label.  The rules also take a timeout value (in seconds) as an option.  If
> more than one rule uses the same timer label, the timer will be restarted
> whenever any of the rules get a hit.
>
> One entry for each timer is created in sysfs.  This attribute contains the
> timer remaining for the timer to expire.  The attributes are located under
> the xt_idletimer class:
>
> /sys/class/xt_idletimer/timers/<label>
>
> When the timer expires, the target module sends a sysfs notification to the
> userspace, which can then decide what to do (eg. disconnect to save power).
>   

Basically this seems fine to me, some minor comments below.

> +++ b/include/linux/netfilter/xt_IDLETIMER.h
> @@ -0,0 +1,40 @@
> +#ifndef _XT_IDLETIMER_H
> +#define _XT_IDLETIMER_H
> +
> +#define MAX_LABEL_SIZE 32
>   

This seems a bit generic, maybe better use MAX_IDLETIMER_LABER_SIZE.

> +
> +struct idletimer_tg_info {
> +	__u32 timeout;
> +
> +	char label[MAX_LABEL_SIZE];
> +};
> +
> +#endif
> new file mode 100644
> index 0000000..65c195e
> --- /dev/null
> +++ b/net/netfilter/xt_IDLETIMER.c
> @@ -0,0 +1,356 @@
> +/*
> + * linux/net/netfilter/xt_IDLETIMER.c
> + *
> + * Netfilter module to trigger a timer when packet matches.
> + * After timer expires a kevent will be sent.
> + *
> + * Copyright (C) 2004, 2010 Nokia Corporation
> + * Written by Timo Teras <ext-timo.teras@nokia.com>
> + *
> + * Converted to x_tables and reworked for upstream inclusion
> + * by Luciano Coelho <luciano.coelho@nokia.com>
> + *
> + * Contact: Luciano Coelho <luciano.coelho@nokia.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
> + * 02110-1301 USA
> + */
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/module.h>
> +#include <linux/timer.h>
> +#include <linux/list.h>
> +#include <linux/spinlock.h>
> +#include <linux/netfilter.h>
> +#include <linux/netfilter/x_tables.h>
> +#include <linux/netfilter/xt_IDLETIMER.h>
> +#include <linux/kobject.h>
> +#include <linux/workqueue.h>
> +#include <linux/sysfs.h>
> +
> +struct idletimer_tg {
> +	struct list_head entry;
> +	struct timer_list timer;
> +	struct work_struct work;
> +
> +	struct kobject *kobj;
> +	struct idletimer_tg_attr *attr;
> +
> +	unsigned int refcnt;
> +};
> +
> +struct idletimer_tg_attr {
> +	struct attribute attr;
> +	ssize_t	(*show)(struct kobject *kobj,
> +			struct attribute *attr, char *buf);
> +};
> +
> +static LIST_HEAD(idletimer_tg_list);
>   

How does this work with multiple namespaces? It seems every namespace
can bind to any timer.

> +static DEFINE_SPINLOCK(list_lock);
> +
> +static struct kobject *idletimer_tg_kobj;
> +
> +static
> +struct idletimer_tg *__idletimer_tg_find_by_label(const char *label)
> +{
> +	struct idletimer_tg *entry;
> +
> +	BUG_ON(!label);
> +
> +	list_for_each_entry(entry, &idletimer_tg_list, entry) {
> +		if (!strcmp(label, entry->attr->attr.name))
> +			return entry;
> +	}
> +
> +	return NULL;
> +}
> +
> +static ssize_t idletimer_tg_show(struct kobject *kobj, struct attribute *attr,
> +				 char *buf)
> +{
> +	struct idletimer_tg *timer;
> +	unsigned long expires = 0;
> +
> +	spin_lock_bh(&list_lock);
> +	timer =	__idletimer_tg_find_by_label(attr->name);
> +	if (timer)
> +		expires = timer->timer.expires;
> +	spin_unlock_bh(&list_lock);
> +
> +	if (expires > jiffies)
>   

time_after()?

> +		return sprintf(buf, "%u\n",
> +			       jiffies_to_msecs(expires - jiffies) / 1000);
> +
> +	return sprintf(buf, "0\n");
> +}
> +
> +static void idletimer_tg_delete(const struct idletimer_tg_info *info)
> +{
>   

The only caller is the target cleanup function, why don't you just move
everything there?

> +	struct idletimer_tg *timer;
> +
> +	spin_lock_bh(&list_lock);
> +	timer = __idletimer_tg_find_by_label(info->label);
> +	if (!timer) {
> +		spin_unlock_bh(&list_lock);
> +		return;
> +	}
> +
> +	if (--timer->refcnt == 0) {
> +		pr_debug("deleting timer %s\n", info->label);
> +
> +		list_del(&timer->entry);
> +		del_timer_sync(&timer->timer);
> +		spin_unlock_bh(&list_lock);
> +
> +		sysfs_remove_file(idletimer_tg_kobj, &timer->attr->attr);
> +		kfree(timer->attr->attr.name);
> +		kfree(timer->attr);
> +		kfree(timer);
> +	} else {
> +		spin_unlock_bh(&list_lock);
> +		pr_debug("decreased refcnt of timer %s to %u\n",
> +			 info->label, timer->refcnt);
> +	}
> +}
> +
> +static void idletimer_tg_work(struct work_struct *work)
> +{
> +	struct idletimer_tg *timer = container_of(work, struct idletimer_tg,
> +						  work);
> +
> +	sysfs_notify(idletimer_tg_kobj, NULL,
> +		     timer->attr->attr.name);
> +}
> +
> +static void idletimer_tg_expired(unsigned long data)
> +{
> +	struct idletimer_tg *timer = (struct idletimer_tg *) data;
> +
> +	pr_debug("timer %s expired\n",
> +		 timer->attr->attr.name);
> +
> +	schedule_work(&timer->work);
> +}
> +
> +static
> +struct idletimer_tg *idletimer_tg_create(const struct idletimer_tg_info *info)
> +{
> +	struct idletimer_tg *timer;
> +	struct idletimer_tg_attr *attr;
> +
> +	attr = kzalloc(sizeof(attr), GFP_KERNEL);
>   

sizeof(*attr)

> +	if (!attr) {
> +		pr_debug("couldn't alloc attribute\n");
> +		return NULL;
> +	}
> +
> +	attr->attr.name = kstrdup(info->label, GFP_KERNEL);
> +	if (!attr->attr.name) {
> +		pr_debug("couldn't alloc attribute name\n");
> +		goto out_free_attr;
> +	}
> +	attr->attr.mode = S_IRUGO;
> +	attr->show = idletimer_tg_show;
> +
> +	if (sysfs_create_file(idletimer_tg_kobj, &attr->attr)) {
> +		pr_debug("couldn't add attr to sysfs\n");
> +		goto out_free_name;
> +	}
> +
> +	timer = kmalloc(sizeof(struct idletimer_tg), GFP_KERNEL);
> +	if (!timer) {
> +		pr_debug("couldn't alloc timer\n");
> +		goto out_free_file;
> +	}
> +
> +	spin_lock_bh(&list_lock);
> +	list_add(&timer->entry, &idletimer_tg_list);
> +
> +	init_timer(&timer->timer);
> +	setup_timer(&timer->timer, idletimer_tg_expired, (unsigned long) timer);
> +	mod_timer(&timer->timer,
> +		  msecs_to_jiffies(info->timeout * 1000) + jiffies);
> +
> +	timer->attr = attr;
> +	timer->refcnt = 0;
>   

Better fully set up the timer before activating it.

> +
> +	INIT_WORK(&timer->work, idletimer_tg_work);
> +	spin_unlock_bh(&list_lock);
> +
> +	return timer;
> +
> +out_free_file:
> +	sysfs_remove_file(idletimer_tg_kobj, &attr->attr);
> +out_free_name:
> +	kfree(attr->attr.name);
> +out_free_attr:
> +	kfree(attr);
> +	return NULL;
> +}
> +
> +static void idletimer_tg_cleanup(void)
> +{
> +	struct idletimer_tg *timer;
> +
> +	spin_lock(&list_lock);
> +	list_for_each_entry(timer, &idletimer_tg_list, entry) {
>   

list_for_each_entry_safe(). This function seems unnecessary though, the
module
can't be unloaded while its still in use and cleanup will already happen
when the
rules are removed.

> +		pr_debug("deleting timer %s\n", timer->attr->attr.name);
> +
> +		list_del(&timer->entry);
> +		del_timer_sync(&timer->timer);
> +		kfree(timer->attr->attr.name);
> +		kfree(timer->attr);
> +		kfree(timer);
> +	}
> +	spin_unlock(&list_lock);
> +}
> +
> +/*
> + * The actual xt_tables plugin.
> + */
> +static unsigned int idletimer_tg_target(struct sk_buff *skb,
> +					 const struct xt_action_param *par)
> +{
> +	const struct idletimer_tg_info *info = par->targinfo;
> +	struct idletimer_tg *timer;
> +
> +	pr_debug("resetting timer %s, timeout period %u\n",
> +		 info->label, info->timeout);
> +
> +	spin_lock(&list_lock);
>   

You need BH protection here as well for the output path.

> +	timer = __idletimer_tg_find_by_label(info->label);
> +
> +	BUG_ON(!timer);
> +
> +	mod_timer(&timer->timer,
> +		  msecs_to_jiffies(info->timeout * 1000) + jiffies);
> +	spin_unlock(&list_lock);
> +
> +	return XT_CONTINUE;
> +}
> +
> +static int idletimer_tg_checkentry(const struct xt_tgchk_param *par)
> +{
> +	const struct idletimer_tg_info *info = par->targinfo;
> +	struct idletimer_tg *timer;
> +
> +	pr_debug("checkentry targinfo %s\n", info->label);
> +
> +	if (info->timeout == 0) {
> +		pr_debug("timeout value is zero\n");
> +		return -EINVAL;
> +	}
> +
> +	if (!info->label || strlen(info->label) == 0) {
>   

!info->label is impossible. You should check for \0 termination instead.

> +		pr_debug("label is missing\n");
> +		return -EINVAL;
> +	}
> +
> +	spin_lock(&list_lock);
>   
spin_lock_bh()

> +	timer = __idletimer_tg_find_by_label(info->label);
> +	if (!timer) {
> +		spin_unlock(&list_lock);
> +		timer = idletimer_tg_create(info);
>   

How does this prevent creating the same timer twice?

> +		if (!timer) {
> +			pr_debug("failed to create timer\n");
> +			return -ENOMEM;
> +		}
> +		spin_lock(&list_lock);
> +	}
> +
> +	timer->refcnt++;
> +	mod_timer(&timer->timer,
> +		  msecs_to_jiffies(info->timeout * 1000) + jiffies);
> +	spin_unlock(&list_lock);
> +
> +	return 0;
> +}
> +
> +static void idletimer_tg_destroy(const struct xt_tgdtor_param *par)
> +{
> +	const struct idletimer_tg_info *info = par->targinfo;
> +
> +	pr_debug("destroy targinfo %s\n", info->label);
> +
> +	idletimer_tg_delete(info);
> +}
> +
> +static struct xt_target idletimer_tg __read_mostly = {
> +	.name		= "IDLETIMER",
> +	.family		= NFPROTO_UNSPEC,
> +	.target		= idletimer_tg_target,
> +	.targetsize     = sizeof(struct idletimer_tg_info),
> +	.checkentry	= idletimer_tg_checkentry,
> +	.destroy        = idletimer_tg_destroy,
> +	.me		= THIS_MODULE,
> +};
> +
> +static struct class *idletimer_tg_class;
> +
> +static struct device *idletimer_tg_device;
> +
> +static int __init idletimer_tg_init(void)
> +{
> +	int err;
> +
> +	idletimer_tg_class = class_create(THIS_MODULE, "xt_idletimer");
> +	err = PTR_ERR(idletimer_tg_class);
> +	if (IS_ERR(idletimer_tg_class)) {
> +		pr_debug("couldn't register device class\n");
> +		goto out;
> +	}
> +
> +	idletimer_tg_device = device_create(idletimer_tg_class, NULL,
> +					    MKDEV(0, 0), NULL, "timers");
> +	err = PTR_ERR(idletimer_tg_device);
> +	if (IS_ERR(idletimer_tg_device)) {
> +		pr_debug("couldn't register system device\n");
> +		goto out_class;
> +	}
> +
> +	idletimer_tg_kobj = &idletimer_tg_device->kobj;
> +
> +	err =  xt_register_target(&idletimer_tg);
> +	if (err < 0) {
> +		pr_debug("couldn't register xt target\n");
> +		goto out_dev;
> +	}
> +
> +	return 0;
> +out_dev:
> +	device_destroy(idletimer_tg_class, MKDEV(0, 0));
> +out_class:
> +	class_destroy(idletimer_tg_class);
> +out:
> +	return err;
> +}
> +
> +static void __exit idletimer_tg_exit(void)
> +{
> +	xt_unregister_target(&idletimer_tg);
> +
> +	device_destroy(idletimer_tg_class, MKDEV(0, 0));
> +	class_destroy(idletimer_tg_class);
> +
> +	idletimer_tg_cleanup();
> +}
> +
> +module_init(idletimer_tg_init);
> +module_exit(idletimer_tg_exit);
> +
> +MODULE_AUTHOR("Timo Teras <ext-timo.teras@nokia.com>");
> +MODULE_AUTHOR("Luciano Coelho <luciano.coelho@nokia.com>");
> +MODULE_DESCRIPTION("Xtables: idle time monitor");
> +MODULE_LICENSE("GPL v2");
>   

