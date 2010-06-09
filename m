From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH v3] netfilter: Xtables: idletimer target implementation
Date: Wed, 09 Jun 2010 18:11:15 +0300
Message-ID: <1276096275.31892.117.camel@chilepepper>
References: <1275592445-15555-1-git-send-email-luciano.coelho@nokia.com>
	 <4C0F9B17.10504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	Timo Teras <timo.teras@iki.fi>
To: ext Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:57821 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049Ab0FIPMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 11:12:36 -0400
In-Reply-To: <4C0F9B17.10504@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-09 at 15:45 +0200, ext Patrick McHardy wrote:
> luciano.coelho@nokia.com wrote:
> > From: Luciano Coelho <luciano.coelho@nokia.com>
> >
> > This patch implements an idletimer Xtables target that can be used to
> > identify when interfaces have been idle for a certain period of time.
> >
> > Timers are identified by labels and are created when a rule is set with a new
> > label.  The rules also take a timeout value (in seconds) as an option.  If
> > more than one rule uses the same timer label, the timer will be restarted
> > whenever any of the rules get a hit.
> >
> > One entry for each timer is created in sysfs.  This attribute contains the
> > timer remaining for the timer to expire.  The attributes are located under
> > the xt_idletimer class:
> >
> > /sys/class/xt_idletimer/timers/<label>
> >
> > When the timer expires, the target module sends a sysfs notification to the
> > userspace, which can then decide what to do (eg. disconnect to save power).
> >   
> 
> Basically this seems fine to me, some minor comments below.

Thanks a lot for reviewing this again.  My replies below.


> > +++ b/include/linux/netfilter/xt_IDLETIMER.h
> > @@ -0,0 +1,40 @@
> > +#ifndef _XT_IDLETIMER_H
> > +#define _XT_IDLETIMER_H
> > +
> > +#define MAX_LABEL_SIZE 32
> >   
> 
> This seems a bit generic, maybe better use MAX_IDLETIMER_LABER_SIZE.

True, I'll change it.


> > +struct idletimer_tg {
> > +	struct list_head entry;
> > +	struct timer_list timer;
> > +	struct work_struct work;
> > +
> > +	struct kobject *kobj;
> > +	struct idletimer_tg_attr *attr;
> > +
> > +	unsigned int refcnt;
> > +};
> > +
> > +struct idletimer_tg_attr {
> > +	struct attribute attr;
> > +	ssize_t	(*show)(struct kobject *kobj,
> > +			struct attribute *attr, char *buf);
> > +};
> > +
> > +static LIST_HEAD(idletimer_tg_list);
> >   
> 
> How does this work with multiple namespaces? It seems every namespace
> can bind to any timer.

I was implementing this solution for multiple namespaces (see the
previous versions of my patch), but the code started getting really
complicated.  Then I found out that sysfs and multiple namespaces are
not working very well together yet and decided to drop it for the time
being.  Of course this doesn't matter anymore, since the timers belong
to an independent class in sysfs, so I can easily add multiple namespace
support by adding struct net *net as part of the list key together with
the label.

Do you think it's okay to leave it like this for now and extend it for
multiple namespace support with a future patch?


> > +static ssize_t idletimer_tg_show(struct kobject *kobj, struct attribute *attr,
> > +				 char *buf)
> > +{
> > +	struct idletimer_tg *timer;
> > +	unsigned long expires = 0;
> > +
> > +	spin_lock_bh(&list_lock);
> > +	timer =	__idletimer_tg_find_by_label(attr->name);
> > +	if (timer)
> > +		expires = timer->timer.expires;
> > +	spin_unlock_bh(&list_lock);
> > +
> > +	if (expires > jiffies)
> >   
> 
> time_after()?

Of course!


> > +		return sprintf(buf, "%u\n",
> > +			       jiffies_to_msecs(expires - jiffies) / 1000);
> > +
> > +	return sprintf(buf, "0\n");
> > +}
> > +
> > +static void idletimer_tg_delete(const struct idletimer_tg_info *info)
> > +{
> >   
> 
> The only caller is the target cleanup function, why don't you just move
> everything there?

Good point.  It probably remained as a separate function as vestigial
code.


> > +static
> > +struct idletimer_tg *idletimer_tg_create(const struct idletimer_tg_info *info)
> > +{
> > +	struct idletimer_tg *timer;
> > +	struct idletimer_tg_attr *attr;
> > +
> > +	attr = kzalloc(sizeof(attr), GFP_KERNEL);
> >   
> 
> sizeof(*attr)

Ugh! Nice catch, I'll fix it.


> > +	if (!attr) {
> > +		pr_debug("couldn't alloc attribute\n");
> > +		return NULL;
> > +	}
> > +
> > +	attr->attr.name = kstrdup(info->label, GFP_KERNEL);
> > +	if (!attr->attr.name) {
> > +		pr_debug("couldn't alloc attribute name\n");
> > +		goto out_free_attr;
> > +	}
> > +	attr->attr.mode = S_IRUGO;
> > +	attr->show = idletimer_tg_show;
> > +
> > +	if (sysfs_create_file(idletimer_tg_kobj, &attr->attr)) {
> > +		pr_debug("couldn't add attr to sysfs\n");
> > +		goto out_free_name;
> > +	}
> > +
> > +	timer = kmalloc(sizeof(struct idletimer_tg), GFP_KERNEL);

I will also change this to kmalloc(sizeof(*timer), GFP_KERNEL) for
consistency.


> > +	if (!timer) {
> > +		pr_debug("couldn't alloc timer\n");
> > +		goto out_free_file;
> > +	}
> > +
> > +	spin_lock_bh(&list_lock);
> > +	list_add(&timer->entry, &idletimer_tg_list);
> > +
> > +	init_timer(&timer->timer);
> > +	setup_timer(&timer->timer, idletimer_tg_expired, (unsigned long) timer);
> > +	mod_timer(&timer->timer,
> > +		  msecs_to_jiffies(info->timeout * 1000) + jiffies);
> > +
> > +	timer->attr = attr;
> > +	timer->refcnt = 0;
> >   
> 
> Better fully set up the timer before activating it.

Ok.  Also, I don't need init_timer() here, since setup_timer() already
calls it.


> > +
> > +	INIT_WORK(&timer->work, idletimer_tg_work);
> > +	spin_unlock_bh(&list_lock);
> > +
> > +	return timer;
> > +
> > +out_free_file:
> > +	sysfs_remove_file(idletimer_tg_kobj, &attr->attr);
> > +out_free_name:
> > +	kfree(attr->attr.name);
> > +out_free_attr:
> > +	kfree(attr);
> > +	return NULL;
> > +}
> > +
> > +static void idletimer_tg_cleanup(void)
> > +{
> > +	struct idletimer_tg *timer;
> > +
> > +	spin_lock(&list_lock);
> > +	list_for_each_entry(timer, &idletimer_tg_list, entry) {
> >   
> 
> list_for_each_entry_safe(). This function seems unnecessary though, the
> module
> can't be unloaded while its still in use and cleanup will already happen
> when the
> rules are removed.

Right.  I'll remove the cleanup function, since it's unnecessary.


> > +static unsigned int idletimer_tg_target(struct sk_buff *skb,
> > +					 const struct xt_action_param *par)
> > +{
> > +	const struct idletimer_tg_info *info = par->targinfo;
> > +	struct idletimer_tg *timer;
> > +
> > +	pr_debug("resetting timer %s, timeout period %u\n",
> > +		 info->label, info->timeout);
> > +
> > +	spin_lock(&list_lock);
> >   
> 
> You need BH protection here as well for the output path.

True.  I'll add it.


> > +static int idletimer_tg_checkentry(const struct xt_tgchk_param *par)
> > +{
> > +	const struct idletimer_tg_info *info = par->targinfo;
> > +	struct idletimer_tg *timer;
> > +
> > +	pr_debug("checkentry targinfo %s\n", info->label);
> > +
> > +	if (info->timeout == 0) {
> > +		pr_debug("timeout value is zero\n");
> > +		return -EINVAL;
> > +	}
> > +
> > +	if (!info->label || strlen(info->label) == 0) {
> >   
> 
> !info->label is impossible. You should check for \0 termination instead.

Ooops! <blush> I'll fix it.


> 
> > +		pr_debug("label is missing\n");
> > +		return -EINVAL;
> > +	}
> > +
> > +	spin_lock(&list_lock);
> >   
> spin_lock_bh()

Yes, I'll add BH here too.


> > +	timer = __idletimer_tg_find_by_label(info->label);
> > +	if (!timer) {
> > +		spin_unlock(&list_lock);
> > +		timer = idletimer_tg_create(info);
> >   
> 
> How does this prevent creating the same timer twice?

The timer will only be created if __idletimer_tg_find_by_label() returns
NULL, which means that no timer with that label has been found.  "info"
won't be the same if info->label is different, right? Or can it change
on the fly?

I'll submit v4 with these changes later this evening.


-- 
Cheers,
Luca.

