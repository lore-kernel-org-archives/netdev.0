From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH v4] netfilter: Xtables: idletimer target implementation
Date: Mon, 14 Jun 2010 17:59:24 +0300
Message-ID: <1276527564.2092.42.camel@chilepepper>
References: <1276264913-429-1-git-send-email-luciano.coelho@nokia.com>
	 <4C164152.8080103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netfilter@vger.kernel.org" <netfilter@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>,
	Timo Teras <timo.teras@iki.fi>
To: ext Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4C164152.8080103@trash.net>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-06-14 at 16:48 +0200, ext Patrick McHardy wrote:
> Luciano Coelho wrote:
> > +static int idletimer_tg_create(struct idletimer_tg_info *info)
> > +{
> > +	int ret;
> > +
> > +	info->timer = kmalloc(sizeof(*info->timer), GFP_ATOMIC);
> > +	if (!info->timer) {
> > +		pr_debug("couldn't alloc timer\n");
> > +		ret = -ENOMEM;
> > +		goto out;
> > +	}
> > +
> > +	info->timer->attr.attr.name = kstrdup(info->label, GFP_ATOMIC);
> >   
> 
> These two allocations don't need GFP_ATOMIC AFAICT.

You're right, I'll fix it in v5.


> 
> > +	if (!info->timer->attr.attr.name) {
> > +		pr_debug("couldn't alloc attribute name\n");
> > +		ret = -ENOMEM;
> > +		goto out_free_timer;
> > +	}
> > +	info->timer->attr.attr.mode = S_IRUGO;
> > +	info->timer->attr.show = idletimer_tg_show;
> > +
> > +	ret = sysfs_create_file(idletimer_tg_kobj, &info->timer->attr.attr);
> > +	if (ret < 0) {
> > +		pr_debug("couldn't add file to sysfs");
> > +		goto out_free_attr;
> > +	}
> > +
> > +	list_add(&info->timer->entry, &idletimer_tg_list);
> > +
> > +	setup_timer(&info->timer->timer, idletimer_tg_expired,
> > +		    (unsigned long) info->timer);
> > +	info->timer->refcnt = 1;
> > +
> > +	mod_timer(&info->timer->timer,
> > +		  msecs_to_jiffies(info->timeout * 1000) + jiffies);
> > +
> > +	INIT_WORK(&info->timer->work, idletimer_tg_work);
> > +
> > +	return 0;
> > +
> > +out_free_attr:
> > +	kfree(info->timer->attr.attr.name);
> > +out_free_timer:
> > +	kfree(info->timer);
> > +out:
> > +	return ret;
> > +}
> > +
> > +/*
> > + * The actual xt_tables plugin.
> > + */
> > +static unsigned int idletimer_tg_target(struct sk_buff *skb,
> > +					 const struct xt_action_param *par)
> > +{
> > +	const struct idletimer_tg_info *info = par->targinfo;
> > +
> > +	pr_debug("resetting timer %s, timeout period %u\n",
> > +		 info->label, info->timeout);
> > +
> > +	mutex_lock(&list_mutex);
> >   
> 
> You can't take the mutex in the target function. What is it supposed to
> protect again?

Hmmmm... I was thinking that info->timer could be freed while this
function is executing.  But I guess the call to this function is already
protected against that, right?

I'll remove the mutex from here.


> > +
> > +	BUG_ON(!info->timer);
> > +
> > +	mod_timer(&info->timer->timer,
> > +		  msecs_to_jiffies(info->timeout * 1000) + jiffies);
> > +
> > +	mutex_unlock(&list_mutex);
> > +
> > +	return XT_CONTINUE;
> > +}
> > +
> 


-- 
Cheers,
Luca.

