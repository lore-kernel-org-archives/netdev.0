From: "James R. Leu" <jleu@mindspring.com>
Subject: Re: [RFC] Per-process network namespaces
Date: Thu, 21 Oct 2004 11:51:38 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021165138.GD5216@mindspring.com>
References: <20041021164039.GA3632@IBM-BWN8ZTBWA01.austin.ibm.com>
Reply-To: jleu@mindspring.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20041021164039.GA3632@IBM-BWN8ZTBWA01.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Opps.  I forgot the link.

http://linux-vrf.sf.net/

On Thu, Oct 21, 2004 at 11:40:39AM -0500, Serge E. Hallyn wrote:
> Hi,
> 
> I've been looking at how (and whether :) to implement network
> namespaces.  The particular use I have for this is to provide
> a more general method of doing the network controls for bsdjail
> (sourceforge.net/projects/linuxjail).  I would greatly appreciate
> comments on the approach pursued in the attached patch.
> 
> The task_struct is augmented with a network namespace (network_ns).
> This is just an hlist of wrappers which point to struct net_devices.
> By default, all processes have the root network namespace, which
> contains all network devices.  On clone(2), specifying the CLONE_NETNS
> flag will cause you to receive a copy of this hlist.
> 
> Under /sys/class/net/<dev> there is a new file called hide. Doing 'echo
> 1 > /sys/class/net/eth1/hide' will cause eth1 to be taken out of the
> current network namespace.  sigconf and /proc/net/dev will no longer
> show this device within this namespace.  It still shows under
> /sys/class/net/, though.  The intent is not exactly to prevent the
> process from knowing the interface exists, but rather to prevent it
> using the interface, and give "useful" info, ie ifconfig -a should
> show only useful interfaces.
> 
> For actual network controls, I've given only a single example, which
> is the inet_bind().  This checks whether the address to be bound is
> on a device which is in the network namespace.  These checks would
> of course need to be done for ipv6/etc, and for connect, sock_rcv_skb,
> and send.
> 
> This becomes more invasive than I'd like, but I'm not sure of a
> cleaner way to do it.  Comments are greatly appreciated.
> 
> thanks,
> -serge
> 
> 
> diff -Nrup linux-2.6.9/include/linux/netdevice.h linux-2.6.9-netns/include/linux/netdevice.h
> --- linux-2.6.9/include/linux/netdevice.h	2004-10-18 16:55:27.000000000 -0500
> +++ linux-2.6.9-netns/include/linux/netdevice.h	2004-10-20 12:38:58.000000000 -0500
> @@ -488,6 +488,28 @@ struct net_device
>  	int padded;
>  };
>  
> +struct netdev_wrap {
> +	struct hlist_node next;
> +	struct hlist_node name_hlist;
> +	struct hlist_node index_hlist;
> +	struct net_device *dev;
> +};
> +
> +#define NETDEV_HASHBITS	8
> +struct network_ns {
> +	struct list_head namespaces;
> +	struct hlist_head dev_base;  /* list of netdev_wrap's */
> +	struct hlist_head dev_name_head[1<<NETDEV_HASHBITS];
> +	struct hlist_head dev_index_head[1<<NETDEV_HASHBITS];
> +
> +	struct kref kref;
> +};
> +
> +extern void release_task_network_ns(struct kref *kref);
> +extern int copy_netdev_namespace(int flags, struct task_struct *tsk);
> +extern int is_root_netns(struct task_struct *tsk);
> +extern int netns_contains_dev(struct task_struct *tsk, struct net_device *dev);
> +
>  #define	NETDEV_ALIGN		32
>  #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
>  
> diff -Nrup linux-2.6.9/include/linux/sched.h linux-2.6.9-netns/include/linux/sched.h
> --- linux-2.6.9/include/linux/sched.h	2004-10-18 16:53:13.000000000 -0500
> +++ linux-2.6.9-netns/include/linux/sched.h	2004-10-19 12:04:53.000000000 -0500
> @@ -53,6 +53,8 @@ struct exec_domain;
>  #define CLONE_UNTRACED		0x00800000	/* set if the tracing process can't force CLONE_PTRACE on this clone */
>  #define CLONE_CHILD_SETTID	0x01000000	/* set the TID in the child */
>  #define CLONE_STOPPED		0x02000000	/* Start in stopped state */
> +#define CLONE_NETNS             0x04000000      /* New network namespace group? */
> +
>  
>  /*
>   * List of flags we want to share for kernel threads,
> @@ -433,6 +435,7 @@ int set_current_groups(struct group_info
>  
>  struct audit_context;		/* See audit.c */
>  struct mempolicy;
> +struct network_ns;		/* See netdevice.h */
>  
>  struct task_struct {
>  	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
> @@ -584,6 +587,8 @@ struct task_struct {
>    	struct mempolicy *mempolicy;
>    	short il_next;		/* could be shared with used_math */
>  #endif
> +
> +	struct network_ns *network_ns;
>  };
>  
>  static inline pid_t process_group(struct task_struct *tsk)
> diff -Nrup linux-2.6.9/include/net/route.h linux-2.6.9-netns/include/net/route.h
> --- linux-2.6.9/include/net/route.h	2004-10-18 16:53:06.000000000 -0500
> +++ linux-2.6.9-netns/include/net/route.h	2004-10-20 11:42:03.000000000 -0500
> @@ -122,6 +122,7 @@ extern int		ip_route_input(struct sk_buf
>  extern unsigned short	ip_rt_frag_needed(struct iphdr *iph, unsigned short new_mtu);
>  extern void		ip_rt_send_redirect(struct sk_buff *skb);
>  
> +extern int		netns_contains_local_addr(struct task_struct *tsk, u32 s_addr);
>  extern unsigned		inet_addr_type(u32 addr);
>  extern void		ip_rt_multicast_event(struct in_device *);
>  extern int		ip_rt_ioctl(unsigned int cmd, void __user *arg);
> diff -Nrup linux-2.6.9/kernel/fork.c linux-2.6.9-netns/kernel/fork.c
> --- linux-2.6.9/kernel/fork.c	2004-10-18 16:53:13.000000000 -0500
> +++ linux-2.6.9-netns/kernel/fork.c	2004-10-19 12:10:13.000000000 -0500
> @@ -38,6 +38,7 @@
>  #include <linux/audit.h>
>  #include <linux/profile.h>
>  #include <linux/rmap.h>
> +#include <linux/netdevice.h>
>  
>  #include <asm/pgtable.h>
>  #include <asm/pgalloc.h>
> @@ -93,6 +94,7 @@ void __put_task_struct(struct task_struc
>  	if (unlikely(tsk->audit_context))
>  		audit_free(tsk);
>  	security_task_free(tsk);
> +	kref_put(&tsk->network_ns->kref, release_task_network_ns);
>  	free_uid(tsk->user);
>  	put_group_info(tsk->group_info);
>  
> @@ -275,6 +277,8 @@ static struct task_struct *dup_task_stru
>  	tsk->thread_info = ti;
>  	ti->task = tsk;
>  
> +	tsk->network_ns = orig->network_ns;
> +
>  	/* One for us, one for whoever does the "release_task()" (usually parent) */
>  	atomic_set(&tsk->usage,2);
>  	return tsk;
> @@ -1025,9 +1029,11 @@ static task_t *copy_process(unsigned lon
>  		goto bad_fork_cleanup_signal;
>  	if ((retval = copy_namespace(clone_flags, p)))
>  		goto bad_fork_cleanup_mm;
> +	if ((retval = copy_netdev_namespace(clone_flags, p)))
> +		goto bad_fork_cleanup_namespace;
>  	retval = copy_thread(0, clone_flags, stack_start, stack_size, p, regs);
>  	if (retval)
> -		goto bad_fork_cleanup_namespace;
> +		goto bad_fork_cleanup_netns;
>  
>  	p->set_child_tid = (clone_flags & CLONE_CHILD_SETTID) ? child_tidptr : NULL;
>  	/*
> @@ -1082,7 +1088,7 @@ static task_t *copy_process(unsigned lon
>  	if (sigismember(&current->pending.signal, SIGKILL)) {
>  		write_unlock_irq(&tasklist_lock);
>  		retval = -EINTR;
> -		goto bad_fork_cleanup_namespace;
> +		goto bad_fork_cleanup_netns;
>  	}
>  
>  	/* CLONE_PARENT re-uses the old parent */
> @@ -1103,7 +1109,7 @@ static task_t *copy_process(unsigned lon
>  			spin_unlock(&current->sighand->siglock);
>  			write_unlock_irq(&tasklist_lock);
>  			retval = -EAGAIN;
> -			goto bad_fork_cleanup_namespace;
> +			goto bad_fork_cleanup_netns;
>  		}
>  		p->tgid = current->tgid;
>  		p->group_leader = current->group_leader;
> @@ -1143,6 +1149,8 @@ fork_out:
>  		return ERR_PTR(retval);
>  	return p;
>  
> +bad_fork_cleanup_netns:
> +	kref_put(&p->network_ns->kref, release_task_network_ns);
>  bad_fork_cleanup_namespace:
>  	exit_namespace(p);
>  bad_fork_cleanup_mm:
> diff -Nrup linux-2.6.9/net/core/dev.c linux-2.6.9-netns/net/core/dev.c
> --- linux-2.6.9/net/core/dev.c	2004-10-18 16:54:08.000000000 -0500
> +++ linux-2.6.9-netns/net/core/dev.c	2004-10-20 12:44:16.000000000 -0500
> @@ -108,6 +108,7 @@
>  #include <linux/kallsyms.h>
>  #include <linux/netpoll.h>
>  #include <linux/rcupdate.h>
> +#include <linux/list.h>
>  #ifdef CONFIG_NET_RADIO
>  #include <linux/wireless.h>		/* Note : will define WIRELESS_EXT */
>  #include <net/iw_handler.h>
> @@ -163,6 +164,8 @@ static void sample_queue(unsigned long d
>  static struct timer_list samp_timer = TIMER_INITIALIZER(sample_queue, 0, 0);
>  #endif
>  
> +static struct list_head network_namespaces;
> +
>  /*
>   * The @dev_base list is protected by @dev_base_lock and the rtln
>   * semaphore.
> @@ -189,19 +192,28 @@ rwlock_t dev_base_lock = RW_LOCK_UNLOCKE
>  EXPORT_SYMBOL(dev_base);
>  EXPORT_SYMBOL(dev_base_lock);
>  
> -#define NETDEV_HASHBITS	8
> -static struct hlist_head dev_name_head[1<<NETDEV_HASHBITS];
> -static struct hlist_head dev_index_head[1<<NETDEV_HASHBITS];
> +#define root_ns (*init_task.network_ns)
> +
> +static inline struct hlist_head *curns_dev_name_hash(const char *name)
> +{
> +	unsigned hash = full_name_hash(name, strnlen(name, IFNAMSIZ));
> +	return &current->network_ns->dev_name_head[hash & ((1<<NETDEV_HASHBITS)-1)];
> +}
> +
> +static inline struct hlist_head *curns_dev_index_hash(int ifindex)
> +{
> +	return &current->network_ns->dev_index_head[ifindex & ((1<<NETDEV_HASHBITS)-1)];
> +}
>  
>  static inline struct hlist_head *dev_name_hash(const char *name)
>  {
>  	unsigned hash = full_name_hash(name, strnlen(name, IFNAMSIZ));
> -	return &dev_name_head[hash & ((1<<NETDEV_HASHBITS)-1)];
> +	return &root_ns.dev_name_head[hash & ((1<<NETDEV_HASHBITS)-1)];
>  }
>  
>  static inline struct hlist_head *dev_index_hash(int ifindex)
>  {
> -	return &dev_index_head[ifindex & ((1<<NETDEV_HASHBITS)-1)];
> +	return &root_ns.dev_index_head[ifindex & ((1<<NETDEV_HASHBITS)-1)];
>  }
>  
>  /*
> @@ -2033,10 +2045,19 @@ static int dev_ifconf(char __user *arg)
>   */
>  static __inline__ struct net_device *dev_get_idx(loff_t pos)
>  {
> -	struct net_device *dev;
> -	loff_t i;
> +	struct net_device *dev = NULL;
> +	struct netdev_wrap *devw;
> +	struct hlist_node *tmp;
> +	loff_t i = 0;
> +
> +	hlist_for_each(tmp, &current->network_ns->dev_base) {
> +		devw = hlist_entry(tmp, struct netdev_wrap, next);
> +		dev = devw->dev;
> +		if (i >= pos)
> +			break;
> +		i++;
> +	}
>  
> -	for (i = 0, dev = dev_base; dev && i < pos; ++i, dev = dev->next);
>  
>  	return i == pos ? dev : NULL;
>  }
> @@ -2049,8 +2070,27 @@ void *dev_seq_start(struct seq_file *seq
>  
>  void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  {
> +	struct netdev_wrap *devw;
> +	struct net_device *dev = NULL;
> +	struct hlist_node *tmp;
> +	int found = 0;
> +
>  	++*pos;
> -	return v == SEQ_START_TOKEN ? dev_base : ((struct net_device *)v)->next;
> +	if (v == SEQ_START_TOKEN) {
> +		tmp = current->network_ns->dev_base.first;
> +		devw = hlist_entry(tmp, struct netdev_wrap, next);
> +		return devw->dev;
> +	}
> +
> +	hlist_for_each(tmp, &current->network_ns->dev_base) {
> +		devw = hlist_entry(tmp, struct netdev_wrap, next);
> +		dev = devw->dev;
> +		if (found)
> +			return dev;
> +		if (dev == v)
> +			found = 1;
> +	}
> +	return dev;
>  }
>  
>  void dev_seq_stop(struct seq_file *seq, void *v)
> @@ -2810,6 +2850,7 @@ int register_netdevice(struct net_device
>  {
>  	struct hlist_head *head;
>  	struct hlist_node *p;
> +	struct netdev_wrap *devw;
>  	int ret;
>  
>  	BUG_ON(dev_boot_phase);
> @@ -2893,6 +2934,16 @@ int register_netdevice(struct net_device
>  	dev_tail = &dev->next;
>  	hlist_add_head(&dev->name_hlist, head);
>  	hlist_add_head(&dev->index_hlist, dev_index_hash(dev->ifindex));
> +	/* add to root ns */
> +	devw = kmalloc(sizeof(struct netdev_wrap), GFP_KERNEL);
> +	INIT_HLIST_NODE(&devw->next);
> +	INIT_HLIST_NODE(&devw->name_hlist);
> +	INIT_HLIST_NODE(&devw->index_hlist);
> +	devw->dev = dev;
> +	hlist_add_head(&devw->next, &root_ns.dev_base);
> +	hlist_add_head(&dev->name_hlist, dev_name_hash(dev->name));
> +	hlist_add_head(&dev->index_hlist, dev_index_hash(dev->ifindex));
> +
>  	dev_hold(dev);
>  	dev->reg_state = NETREG_REGISTERING;
>  	write_unlock_bh(&dev_base_lock);
> @@ -3087,6 +3138,56 @@ void synchronize_net(void) 
>  	synchronize_kernel();
>  }
>  
> +static struct net_device *delete_from_all_namespaces(struct net_device *dev)
> +{
> +	struct net_device *d, **dp, *found;
> +	struct list_head *tmp_ns;
> +	struct hlist_node *tmp;
> +
> +	/* 
> +	 * delete from dev_base
> +	 * this will go away once we move to fully using namespaces
> +	 */
> +	for (dp = &dev_base; (d = *dp) != NULL; dp = &d->next) {
> +		if (d == dev) {
> +			write_lock_bh(&dev_base_lock);
> +			hlist_del(&dev->name_hlist);
> +			hlist_del(&dev->index_hlist);
> +			if (dev_tail == &dev->next)
> +				dev_tail = dp;
> +			*dp = d->next;
> +			write_unlock_bh(&dev_base_lock);
> +			break;
> +		}
> +	}
> +
> +	if (d)
> +		found = d;
> +	else
> +		return NULL;
> +
> +	list_for_each(tmp_ns, &network_namespaces) {
> +		struct network_ns *ns = list_entry(tmp_ns, struct network_ns,
> +				namespaces);
> +
> +		hlist_for_each(tmp, &ns->dev_base) {
> +			struct netdev_wrap *devw =
> +				hlist_entry(tmp, struct netdev_wrap, next);
> +			if (devw->dev == dev) {
> +				write_lock_bh(&dev_base_lock);
> +				hlist_del(&devw->name_hlist);
> +				hlist_del(&devw->index_hlist);
> +				hlist_del(&devw->next);
> +				kfree(devw);
> +				write_unlock_bh(&dev_base_lock);
> +				break;
> +			}
> +		}
> +	}
> +
> +	return found;
> +}
> +
>  /**
>   *	unregister_netdevice - remove device from the kernel
>   *	@dev: device
> @@ -3102,7 +3203,7 @@ void synchronize_net(void) 
>  
>  int unregister_netdevice(struct net_device *dev)
>  {
> -	struct net_device *d, **dp;
> +	struct net_device *d;
>  
>  	BUG_ON(dev_boot_phase);
>  	ASSERT_RTNL();
> @@ -3121,18 +3222,7 @@ int unregister_netdevice(struct net_devi
>  		dev_close(dev);
>  
>  	/* And unlink it from device chain. */
> -	for (dp = &dev_base; (d = *dp) != NULL; dp = &d->next) {
> -		if (d == dev) {
> -			write_lock_bh(&dev_base_lock);
> -			hlist_del(&dev->name_hlist);
> -			hlist_del(&dev->index_hlist);
> -			if (dev_tail == &dev->next)
> -				dev_tail = dp;
> -			*dp = d->next;
> -			write_unlock_bh(&dev_base_lock);
> -			break;
> -		}
> -	}
> +	d = delete_from_all_namespaces(dev);
>  	if (!d) {
>  		printk(KERN_ERR "unregister net_device: '%s' not found\n",
>  		       dev->name);
> @@ -3250,12 +3340,6 @@ static int __init net_dev_init(void)
>  	for (i = 0; i < 16; i++) 
>  		INIT_LIST_HEAD(&ptype_base[i]);
>  
> -	for (i = 0; i < ARRAY_SIZE(dev_name_head); i++)
> -		INIT_HLIST_HEAD(&dev_name_head[i]);
> -
> -	for (i = 0; i < ARRAY_SIZE(dev_index_head); i++)
> -		INIT_HLIST_HEAD(&dev_index_head[i]);
> -
>  	/*
>  	 *	Initialise the packet receive queues.
>  	 */
> @@ -3294,6 +3378,179 @@ out:
>  	return rc;
>  }
>  
> +void release_task_network_ns(struct kref *kref)
> +{
> +	struct network_ns *ns;
> +
> +	if (!kref) {
> +		printk(KERN_ERR "%s: called with NULL\n", __FUNCTION__);
> +		return;
> +	}
> +
> +	ns = container_of(kref, struct network_ns, kref);
> +	if (!ns)
> +		BUG();  /* can't be! */
> +
> +	while (!hlist_empty(&ns->dev_base)) {
> +		struct hlist_node *tmp = ns->dev_base.first;
> +		struct netdev_wrap *devw = 
> +				hlist_entry(tmp, struct netdev_wrap, next);
> +		hlist_del(&devw->next);
> +		hlist_del(&devw->name_hlist);
> +		hlist_del(&devw->index_hlist);
> +		kfree(devw);
> +	}
> +
> +	list_del(&ns->namespaces);
> +	kfree(ns);
> +}
> +
> +/* XXX NO NO NO - we're only setting the wrappers and hashes now! */
> +/* don't copy the whole dev_base/dev_tail crap. */
> +int copy_netdev_namespace(int flags, struct task_struct *tsk)
> +{
> +	struct network_ns *ns = tsk->network_ns;
> +	struct network_ns *new_ns;
> +	struct hlist_node *tmp;
> +	int i;
> +
> +
> +	if (!ns) {
> +		INIT_LIST_HEAD(&network_namespaces);
> +		ns = kmalloc(sizeof(struct network_ns), GFP_KERNEL);
> +		INIT_LIST_HEAD(&ns->namespaces);
> +		list_add(&ns->namespaces, &network_namespaces);
> +		tsk->network_ns = ns;
> +		init_task.network_ns = ns;
> +		if (!ns)
> +			BUG();
> +		INIT_HLIST_HEAD(&ns->dev_base);
> +		kref_init(&ns->kref);
> +		kref_get(&ns->kref);  /* this one's for init_task's instance */
> +
> +		for (i = 0; i < ARRAY_SIZE(ns->dev_name_head); i++)
> +			INIT_HLIST_HEAD(&ns->dev_name_head[i]);
> +
> +		for (i = 0; i < ARRAY_SIZE(ns->dev_index_head); i++)
> +			INIT_HLIST_HEAD(&ns->dev_index_head[i]);
> +		
> +		/* If devices already existed in dev_base, we would have to copy them
> +		   into ns->dev_base */
> +	}
> +	kref_get(&ns->kref);
> +
> +	if (!(flags & CLONE_NETNS))
> +		return 0;
> +
> +	if (!capable(CAP_SYS_ADMIN)) {
> +		kref_put(&ns->kref, release_task_network_ns);
> +		return -EPERM;
> +	}
> +
> +	new_ns = kmalloc(sizeof(struct network_ns), GFP_KERNEL);
> +	if (!new_ns)
> +		goto out;
> +
> +	INIT_LIST_HEAD(&new_ns->namespaces);
> +	list_add(&new_ns->namespaces, &network_namespaces);
> +
> +	write_lock(&dev_base_lock);
> +
> +	kref_init(&new_ns->kref);
> +	INIT_HLIST_HEAD(&new_ns->dev_base);
> +	for (i = 0; i < ARRAY_SIZE(new_ns->dev_name_head); i++)
> +		INIT_HLIST_HEAD(&new_ns->dev_name_head[i]);
> +	for (i = 0; i < ARRAY_SIZE(new_ns->dev_index_head); i++)
> +		INIT_HLIST_HEAD(&new_ns->dev_index_head[i]);
> +
> +	/* Copy in the network devices */
> +	hlist_for_each(tmp, &ns->dev_base) {
> +		struct netdev_wrap *devw, *neww;
> +		struct net_device *dev;
> +		unsigned hash;
> +
> +		devw = hlist_entry(tmp, struct netdev_wrap, next);
> +		dev = devw->dev;
> +		neww = kmalloc(sizeof(struct netdev_wrap), GFP_KERNEL);
> +		INIT_HLIST_NODE(&neww->next);
> +		INIT_HLIST_NODE(&neww->name_hlist);
> +		INIT_HLIST_NODE(&neww->index_hlist);
> +		neww->dev = dev;
> +		hlist_add_head(&neww->next, &new_ns->dev_base);
> +		hash = full_name_hash(dev->name, strnlen(dev->name, IFNAMSIZ));
> +		hlist_add_head(&neww->name_hlist,
> +			&new_ns->dev_name_head[hash & ((1<<NETDEV_HASHBITS)-1)]);
> +		hlist_add_head(&neww->index_hlist,
> +			&new_ns->dev_index_head[dev->ifindex]);
> +	}
> +
> +	write_unlock(&dev_base_lock);
> +	tsk->network_ns = new_ns;
> +	kref_put(&ns->kref, release_task_network_ns);
> +	return 0;
> +
> +out:
> +	kref_put(&ns->kref, release_task_network_ns);
> +	return -ENOMEM;
> +}
> +
> +/* XXX fix for new layout */
> +void ns_remove_dev(struct network_ns *ns, struct net_device *dev)
> +{
> +	struct hlist_node *tmp;
> +
> +	printk(KERN_NOTICE "%s: called\n", __FUNCTION__);
> +
> +	hlist_for_each(tmp, &ns->dev_base) {
> +		struct netdev_wrap *devw =
> +				hlist_entry(tmp, struct netdev_wrap, next);
> +		if (devw->dev == dev) {
> +			printk(KERN_NOTICE "%s: found device\n", __FUNCTION__);
> +			write_lock_bh(&dev_base_lock);
> +
> +			hlist_del(&devw->name_hlist);
> +			hlist_del(&devw->index_hlist);
> +			hlist_del(&devw->next);
> +			kfree(devw);
> +
> +			write_unlock_bh(&dev_base_lock);
> +			return;
> +		}
> +	}
> +	printk(KERN_NOTICE "%s: did not find device\n", __FUNCTION__);
> +}
> +
> +int is_root_netns(struct task_struct *tsk)
> +{
> +	if (tsk->network_ns == init_task.network_ns)
> +		return 1;
> +	return 0;
> +}
> +
> +int netns_contains_dev(struct task_struct *tsk, struct net_device *dev)
> +{
> +	struct hlist_node *tmp;
> +	
> +	/*
> +	 * suppose a simple check for tsk->network_ns->dev_index_hash[dev]
> +	 * should work?
> +	 */
> +	hlist_for_each(tmp, &tsk->network_ns->dev_base) {
> +		struct netdev_wrap *devw =
> +			hlist_entry(tmp, struct netdev_wrap, next);
> +		if (devw->dev == dev)
> +			return 1;
> +	}
> +
> +	return 0;
> +}
> +
> +EXPORT_SYMBOL(release_task_network_ns);
> +EXPORT_SYMBOL(copy_netdev_namespace);
> +EXPORT_SYMBOL(ns_remove_dev);
> +EXPORT_SYMBOL(is_root_netns);
> +EXPORT_SYMBOL(netns_contains_dev);
> +
>  subsys_initcall(net_dev_init);
>  
>  EXPORT_SYMBOL(__dev_get);
> diff -Nrup linux-2.6.9/net/core/net-sysfs.c linux-2.6.9-netns/net/core/net-sysfs.c
> --- linux-2.6.9/net/core/net-sysfs.c	2004-10-18 16:55:07.000000000 -0500
> +++ linux-2.6.9-netns/net/core/net-sysfs.c	2004-10-20 12:24:19.000000000 -0500
> @@ -174,6 +174,33 @@ static ssize_t store_tx_queue_len(struct
>  static CLASS_DEVICE_ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len, 
>  			 store_tx_queue_len);
>  
> +extern void ns_remove_dev(struct network_ns *ns, struct net_device *dev);
> +
> +static ssize_t hide_net_dev(struct class_device *dev, const char *buf, size_t len)
> +{
> +	struct net_device *net = to_net_dev(dev);
> +
> +	printk(KERN_NOTICE "%s: asked to del device %s\n",
> +		__FUNCTION__, net->name);
> +
> +	if (current->network_ns == init_task.network_ns)
> +		return -EINVAL;
> +
> +	printk(KERN_NOTICE "%s: checking perms to del device %s\n",
> +		__FUNCTION__, net->name);
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	printk(KERN_NOTICE "%s: deleting device %s\n",
> +		__FUNCTION__, net->name);
> +	ns_remove_dev(current->network_ns, net);
> +
> +	return len;
> +}
> +
> +/* sysfs file to hide a network device from a namespace */
> +static CLASS_DEVICE_ATTR(hide, S_IWUGO, NULL, hide_net_dev);
> +
>  
>  static struct class_device_attribute *net_class_attributes[] = {
>  	&class_device_attr_ifindex,
> @@ -186,6 +213,7 @@ static struct class_device_attribute *ne
>  	&class_device_attr_type,
>  	&class_device_attr_address,
>  	&class_device_attr_broadcast,
> +	&class_device_attr_hide,
>  	NULL
>  };
>  
> diff -Nrup linux-2.6.9/net/ipv4/af_inet.c linux-2.6.9-netns/net/ipv4/af_inet.c
> --- linux-2.6.9/net/ipv4/af_inet.c	2004-10-18 16:53:21.000000000 -0500
> +++ linux-2.6.9-netns/net/ipv4/af_inet.c	2004-10-19 15:42:26.000000000 -0500
> @@ -421,6 +421,10 @@ int inet_bind(struct socket *sock, struc
>  	    chk_addr_ret != RTN_BROADCAST)
>  		goto out;
>  
> +	if (!is_root_netns(current) && !netns_contains_local_addr(current,
> +		addr->sin_addr.s_addr))
> +		goto out;
> +
>  	snum = ntohs(addr->sin_port);
>  	err = -EACCES;
>  	if (snum && snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
> diff -Nrup linux-2.6.9/net/ipv4/devinet.c linux-2.6.9-netns/net/ipv4/devinet.c
> --- linux-2.6.9/net/ipv4/devinet.c	2004-10-18 16:53:43.000000000 -0500
> +++ linux-2.6.9-netns/net/ipv4/devinet.c	2004-10-20 12:38:16.000000000 -0500
> @@ -736,6 +736,9 @@ static int inet_gifconf(struct net_devic
>  	struct ifreq ifr;
>  	int done = 0;
>  
> +	if (!netns_contains_dev(current, dev))
> +		goto out;
> +
>  	if (!in_dev || (ifa = in_dev->ifa_list) == NULL)
>  		goto out;
>  
> diff -Nrup linux-2.6.9/net/ipv4/fib_frontend.c linux-2.6.9-netns/net/ipv4/fib_frontend.c
> --- linux-2.6.9/net/ipv4/fib_frontend.c	2004-10-18 16:55:29.000000000 -0500
> +++ linux-2.6.9-netns/net/ipv4/fib_frontend.c	2004-10-20 12:05:32.000000000 -0500
> @@ -524,6 +524,26 @@ static void fib_disable_ip(struct net_de
>  	arp_ifdown(dev);
>  }
>  
> +int netns_contains_local_addr(struct task_struct *tsk, u32 s_addr)
> +{
> +	struct hlist_node *tmp;
> +	struct netdev_wrap *devw;
> +	struct net_device *dev;
> +
> +	dev = ip_dev_find(s_addr);
> +	if (!dev)
> +		return 0;
> +
> +	hlist_for_each(tmp, &tsk->network_ns->dev_base) {
> +		devw = hlist_entry(tmp, struct netdev_wrap, next);
> +		if (devw->dev == dev)
> +			return 1;
> +	}
> +	return 0;
> +}
> +
> +EXPORT_SYMBOL(netns_contains_local_addr);
> +
>  static int fib_inetaddr_event(struct notifier_block *this, unsigned long event, void *ptr)
>  {
>  	struct in_ifaddr *ifa = (struct in_ifaddr*)ptr;

-- 
James R. Leu
jleu@mindspring.com
