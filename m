From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] NF: IP tables idletimer target implementation
Date: Fri, 14 May 2010 18:03:25 +0200
Message-ID: <4BED744D.3040400@trash.net>
References: <1273841458-10443-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Timo Teras <timo.teras@iki.fi>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273841458-10443-1-git-send-email-luciano.coelho@nokia.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please CC netfilter-devel on future submissions.

Luciano Coelho wrote:
> It adds a file to the sysfs for each interface that is brought up.  The file
> contains the time remaining before the event is triggered.  This file can
> also be used to set the timer manually.

What is this used for? It doesn't seem to smart to poll manually
if you get an event anyways, and the timeout can already be set
per rule.

> diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
> index 1833bdb..91fba9a 100644
> --- a/net/ipv4/netfilter/Kconfig
> +++ b/net/ipv4/netfilter/Kconfig
> @@ -204,6 +204,23 @@ config IP_NF_TARGET_REDIRECT
>  
>  	  To compile it as a module, choose M here.  If unsure, say N.
>  
> +config IP_NF_TARGET_IDLETIMER

This should be a x_tables target, there's nothing IPv4-specific
about it.

> diff --git a/net/ipv4/netfilter/ipt_IDLETIMER.c b/net/ipv4/netfilter/ipt_IDLETIMER.c
> new file mode 100644
> index 0000000..2c5b465
> --- /dev/null
> +++ b/net/ipv4/netfilter/ipt_IDLETIMER.c

> +
> +#ifdef CONFIG_IP_NF_TARGET_IDLETIMER_DEBUG
> +#define DEBUGP(format, args...) printk(KERN_DEBUG \
> +				       "ipt_IDLETIMER:%s:" format "\n", \
> +				       __func__ , ## args)
> +#else
> +#define DEBUGP(format, args...)
> +#endif

Please use pr_debug and get rid of the config option.

> +
> +/*
> + * Internal timer management.
> + */
> +static ssize_t utimer_attr_show(struct device *dev,
> +				struct device_attribute *attr, char *buf);
> +static ssize_t utimer_attr_store(struct device *dev,
> +				 struct device_attribute *attr,
> +				 const char *buf, size_t count);
> +
> +struct utimer_t {
> +	char name[IFNAMSIZ];
> +	struct list_head entry;
> +	struct timer_list timer;
> +	struct work_struct work;
> +	struct net *net;
> +};
> +
> +static LIST_HEAD(active_utimer_head);
> +static DEFINE_SPINLOCK(list_lock);
> +static DEVICE_ATTR(idletimer, 0644, utimer_attr_show, utimer_attr_store);
> +
> +static void utimer_delete(struct utimer_t *timer)
> +{
> +	DEBUGP("Deleting timer '%s'\n", timer->name);
> +
> +	list_del(&timer->entry);
> +	del_timer_sync(&timer->timer);
> +	put_net(timer->net);
> +	kfree(timer);
> +}
> +
> +static void utimer_work(struct work_struct *work)
> +{
> +	struct utimer_t *timer = container_of(work, struct utimer_t, work);
> +	struct net_device *netdev = NULL;

Unnecessary initialization.

> +
> +	netdev = dev_get_by_name(timer->net, timer->name);
> +
> +	if (netdev != NULL) {
> +		sysfs_notify(&netdev->dev.kobj, NULL,
> +			     "idletimer");
> +		dev_put(netdev);
> +	}
> +}
> +
> +static void utimer_expired(unsigned long data)
> +{
> +	struct utimer_t *timer = (struct utimer_t *) data;
> +
> +	DEBUGP("Timer '%s' expired\n", timer->name);
> +
> +	spin_lock_bh(&list_lock);
> +	utimer_delete(timer);
> +	spin_unlock_bh(&list_lock);
> +
> +	schedule_work(&timer->work);

Use after free, utimer_delete() frees the timer.

> +}
> +
> +static struct utimer_t *utimer_create(const char *name,
> +				      struct net *net)
> +{
> +	struct utimer_t *timer;
> +
> +	timer = kmalloc(sizeof(struct utimer_t), GFP_ATOMIC);
> +	if (timer == NULL)
> +		return NULL;
> +
> +	list_add(&timer->entry, &active_utimer_head);
> +	strlcpy(timer->name, name, sizeof(timer->name));
> +	timer->net = get_net(net);

How does this handle namespace exit?

> +
> +	init_timer(&timer->timer);
> +	timer->timer.function = utimer_expired;
> +	timer->timer.data = (unsigned long) timer;

setup_timer()

> +
> +	INIT_WORK(&timer->work, utimer_work);
> +
> +	DEBUGP("Created timer '%s'\n", timer->name);
> +
> +	return timer;
> +}
> +
> +static struct utimer_t *__utimer_find(const char *name, const struct net *net)
> +{
> +	struct utimer_t *entry;
> +
> +	list_for_each_entry(entry, &active_utimer_head, entry) {
> +		if (!strcmp(name, entry->name) && net == entry->net)
> +			return entry;
> +	}
> +
> +	return NULL;
> +}
> +
> +static void utimer_modify(const char *name,
> +			  struct net *net,
> +			  unsigned long expires)
> +{
> +	struct utimer_t *timer;
> +
> +	DEBUGP("Modifying timer '%s'\n", name);
> +	spin_lock_bh(&list_lock);
> +	timer = __utimer_find(name, net);

So you're scanning the list up to twice per packet? That seems
highly suboptimal, why not create the timer when the rule is
created and only update the timeout? You could use the interfaces
specified in struct ipt_ip.

> +	if (timer == NULL)
> +		timer = utimer_create(name, net);
> +	mod_timer(&timer->timer, expires);
> +	spin_unlock_bh(&list_lock);
> +}
> +
> +static ssize_t utimer_attr_show(struct device *dev,
> +				struct device_attribute *attr, char *buf)
> +{
> +	struct utimer_t *timer;
> +	struct net_device *netdev = to_net_dev(dev);
> +	unsigned long expires = 0;
> +
> +	spin_lock_bh(&list_lock);
> +	timer = __utimer_find(netdev->name, dev_net(netdev));
> +	if (timer)
> +		expires = timer->timer.expires;
> +	spin_unlock_bh(&list_lock);
> +
> +	if (expires)
> +		return sprintf(buf, "%lu\n", (expires-jiffies) / HZ);
> +
> +	return sprintf(buf, "0\n");
> +}
> +
> +static ssize_t utimer_attr_store(struct device *dev,
> +				 struct device_attribute *attr,
> +				 const char *buf, size_t count)
> +{
> +	int expires;
> +	struct net_device *netdev = to_net_dev(dev);
> +
> +	if (sscanf(buf, "%d", &expires) == 1) {
> +		if (expires > 0)

Using %u seems better.

> +			utimer_modify(netdev->name,
> +				      dev_net(netdev),
> +				      jiffies+HZ*(unsigned long)expires);
> +	}
> +
> +	return count;
> +}
> +
> +static int utimer_notifier_call(struct notifier_block *this,
> +				unsigned long event, void *ptr)
> +{
> +	struct net_device *netdev = ptr;
> +	int ret;
> +
> +	switch (event) {
> +	case NETDEV_UP:
> +		DEBUGP("NETDEV_UP: %s\n", netdev->name);
> +		ret = device_create_file(&netdev->dev,
> +					 &dev_attr_idletimer);
> +		WARN_ON(ret);
> +
> +		break;
> +	case NETDEV_DOWN:
> +		DEBUGP("NETDEV_DOWN: %s\n", netdev->name);
> +		device_remove_file(&netdev->dev,
> +				   &dev_attr_idletimer);
> +		break;
> +	}
> +
> +	return NOTIFY_DONE;
> +}
> +
> +static struct notifier_block utimer_notifier_block = {
> +	.notifier_call	= utimer_notifier_call,
> +};
> +
> +
> +static int utimer_init(void)
> +{
> +	return register_netdevice_notifier(&utimer_notifier_block);
> +}
> +
> +static void utimer_fini(void)
> +{
> +	struct utimer_t *entry, *next;
> +	struct net_device *dev;
> +	struct net *net;
> +
> +	list_for_each_entry_safe(entry, next, &active_utimer_head, entry)
> +		utimer_delete(entry);
> +
> +	rtnl_lock();

deadlock? unregister_netdevice_notifier() already takes the RTNL.

> +	unregister_netdevice_notifier(&utimer_notifier_block);
> +	for_each_net(net) {
> +		for_each_netdev(net, dev) {
> +			utimer_notifier_call(&utimer_notifier_block,
> +					     NETDEV_DOWN, dev);
> +		}
> +	}
> +	rtnl_unlock();
> +}
> +
> +/*
> + * The actual iptables plugin.
> + */
> +static unsigned int ipt_idletimer_target(struct sk_buff *skb,
> +					 const struct xt_action_param *par)
> +{
> +	const struct ipt_idletimer_info *target = par->targinfo;
> +	unsigned long expires;
> +
> +	expires = jiffies + HZ*target->timeout;
> +
> +	if (par->in != NULL)
> +		utimer_modify(par->in->name,
> +			      dev_net(par->in),
> +			      expires);
> +
> +	if (par->out != NULL)
> +		utimer_modify(par->out->name,
> +			      dev_net(par->out),
> +			      expires);
> +
> +	return XT_CONTINUE;
> +}
> +
> +static int ipt_idletimer_checkentry(const struct xt_tgchk_param *par)
> +{
> +	const struct ipt_idletimer_info *info = par->targinfo;
> +
> +	if (info->timeout == 0) {
> +		DEBUGP("timeout value is zero\n");
> +		return false;
> +	}
> +
> +	return true;

The return convention in the current net-next tree is 0 for
no error or an errno code otherwise.

> +}
