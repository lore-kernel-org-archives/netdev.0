From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net-next v3] pktgen: support net namespace
Date: Mon, 28 Jan 2013 22:14:20 -0800
Message-ID: <87txq0h5xf.fsf@xmission.com>
References: <1359438953-23703-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:51054 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753697Ab3A2GOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 01:14:34 -0500
In-Reply-To: <1359438953-23703-1-git-send-email-amwang@redhat.com> (Cong
	Wang's message of "Tue, 29 Jan 2013 13:55:53 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:

> From: Cong Wang <amwang@redhat.com>
>
> v3: make pktgen_threads list per-namespace
> v2: remove a useless check
>
> This patch add net namespace to pktgen, so that
> we can use pktgen in different namespaces.
>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

This looks like a basic straight forward conversion to me.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>


>
> ---
>  net/core/pktgen.c |  196 +++++++++++++++++++++++++++++++---------------------
>  1 files changed, 117 insertions(+), 79 deletions(-)
>
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index b29dacf..7977695 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -164,6 +164,7 @@
>  #ifdef CONFIG_XFRM
>  #include <net/xfrm.h>
>  #endif
> +#include <net/netns/generic.h>
>  #include <asm/byteorder.h>
>  #include <linux/rcupdate.h>
>  #include <linux/bitops.h>
> @@ -212,7 +213,6 @@
>  #define PKTGEN_MAGIC 0xbe9be955
>  #define PG_PROC_DIR "pktgen"
>  #define PGCTRL	    "pgctrl"
> -static struct proc_dir_entry *pg_proc_dir;
>  
>  #define MAX_CFLOWS  65536
>  
> @@ -397,7 +397,15 @@ struct pktgen_hdr {
>  	__be32 tv_usec;
>  };
>  
> -static bool pktgen_exiting __read_mostly;
> +
> +static int pg_net_id __read_mostly;
> +
> +struct pktgen_net {
> +	struct net		*net;
> +	struct proc_dir_entry	*proc_dir;
> +	struct list_head	pktgen_threads;
> +	bool			pktgen_exiting;
> +};
>  
>  struct pktgen_thread {
>  	spinlock_t if_lock;		/* for list of devices */
> @@ -414,6 +422,7 @@ struct pktgen_thread {
>  
>  	wait_queue_head_t queue;
>  	struct completion start_done;
> +	struct pktgen_net *net;
>  };
>  
>  #define REMOVE 1
> @@ -428,9 +437,9 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname);
>  static struct pktgen_dev *pktgen_find_dev(struct pktgen_thread *t,
>  					  const char *ifname, bool exact);
>  static int pktgen_device_event(struct notifier_block *, unsigned long, void *);
> -static void pktgen_run_all_threads(void);
> -static void pktgen_reset_all_threads(void);
> -static void pktgen_stop_all_threads_ifs(void);
> +static void pktgen_run_all_threads(struct pktgen_net *pn);
> +static void pktgen_reset_all_threads(struct pktgen_net *pn);
> +static void pktgen_stop_all_threads_ifs(struct pktgen_net *pn);
>  
>  static void pktgen_stop(struct pktgen_thread *t);
>  static void pktgen_clear_counters(struct pktgen_dev *pkt_dev);
> @@ -442,7 +451,6 @@ static int pg_clone_skb_d  __read_mostly;
>  static int debug  __read_mostly;
>  
>  static DEFINE_MUTEX(pktgen_thread_lock);
> -static LIST_HEAD(pktgen_threads);
>  
>  static struct notifier_block pktgen_notifier_block = {
>  	.notifier_call = pktgen_device_event,
> @@ -464,6 +472,7 @@ static ssize_t pgctrl_write(struct file *file, const char __user *buf,
>  {
>  	int err = 0;
>  	char data[128];
> +	struct pktgen_net *pn = net_generic(current->nsproxy->net_ns, pg_net_id);
>  
>  	if (!capable(CAP_NET_ADMIN)) {
>  		err = -EPERM;
> @@ -480,13 +489,13 @@ static ssize_t pgctrl_write(struct file *file, const char __user *buf,
>  	data[count - 1] = 0;	/* Make string */
>  
>  	if (!strcmp(data, "stop"))
> -		pktgen_stop_all_threads_ifs();
> +		pktgen_stop_all_threads_ifs(pn);
>  
>  	else if (!strcmp(data, "start"))
> -		pktgen_run_all_threads();
> +		pktgen_run_all_threads(pn);
>  
>  	else if (!strcmp(data, "reset"))
> -		pktgen_reset_all_threads();
> +		pktgen_reset_all_threads(pn);
>  
>  	else
>  		pr_warning("Unknown command: %s\n", data);
> @@ -1824,13 +1833,14 @@ static const struct file_operations pktgen_thread_fops = {
>  };
>  
>  /* Think find or remove for NN */
> -static struct pktgen_dev *__pktgen_NN_threads(const char *ifname, int remove)
> +static struct pktgen_dev *__pktgen_NN_threads(const struct pktgen_net *pn,
> +					      const char *ifname, int remove)
>  {
>  	struct pktgen_thread *t;
>  	struct pktgen_dev *pkt_dev = NULL;
>  	bool exact = (remove == FIND);
>  
> -	list_for_each_entry(t, &pktgen_threads, th_list) {
> +	list_for_each_entry(t, &pn->pktgen_threads, th_list) {
>  		pkt_dev = pktgen_find_dev(t, ifname, exact);
>  		if (pkt_dev) {
>  			if (remove) {
> @@ -1848,7 +1858,7 @@ static struct pktgen_dev *__pktgen_NN_threads(const char *ifname, int remove)
>  /*
>   * mark a device for removal
>   */
> -static void pktgen_mark_device(const char *ifname)
> +static void pktgen_mark_device(const struct pktgen_net *pn, const char *ifname)
>  {
>  	struct pktgen_dev *pkt_dev = NULL;
>  	const int max_tries = 10, msec_per_try = 125;
> @@ -1859,7 +1869,7 @@ static void pktgen_mark_device(const char *ifname)
>  
>  	while (1) {
>  
> -		pkt_dev = __pktgen_NN_threads(ifname, REMOVE);
> +		pkt_dev = __pktgen_NN_threads(pn, ifname, REMOVE);
>  		if (pkt_dev == NULL)
>  			break;	/* success */
>  
> @@ -1880,21 +1890,21 @@ static void pktgen_mark_device(const char *ifname)
>  	mutex_unlock(&pktgen_thread_lock);
>  }
>  
> -static void pktgen_change_name(struct net_device *dev)
> +static void pktgen_change_name(const struct pktgen_net *pn, struct net_device *dev)
>  {
>  	struct pktgen_thread *t;
>  
> -	list_for_each_entry(t, &pktgen_threads, th_list) {
> +	list_for_each_entry(t, &pn->pktgen_threads, th_list) {
>  		struct pktgen_dev *pkt_dev;
>  
>  		list_for_each_entry(pkt_dev, &t->if_list, list) {
>  			if (pkt_dev->odev != dev)
>  				continue;
>  
> -			remove_proc_entry(pkt_dev->entry->name, pg_proc_dir);
> +			remove_proc_entry(pkt_dev->entry->name, pn->proc_dir);
>  
>  			pkt_dev->entry = proc_create_data(dev->name, 0600,
> -							  pg_proc_dir,
> +							  pn->proc_dir,
>  							  &pktgen_if_fops,
>  							  pkt_dev);
>  			if (!pkt_dev->entry)
> @@ -1909,8 +1919,9 @@ static int pktgen_device_event(struct notifier_block *unused,
>  			       unsigned long event, void *ptr)
>  {
>  	struct net_device *dev = ptr;
> +	struct pktgen_net *pn = net_generic(dev_net(dev), pg_net_id);
>  
> -	if (!net_eq(dev_net(dev), &init_net) || pktgen_exiting)
> +	if (pn->pktgen_exiting)
>  		return NOTIFY_DONE;
>  
>  	/* It is OK that we do not hold the group lock right now,
> @@ -1919,18 +1930,19 @@ static int pktgen_device_event(struct notifier_block *unused,
>  
>  	switch (event) {
>  	case NETDEV_CHANGENAME:
> -		pktgen_change_name(dev);
> +		pktgen_change_name(pn, dev);
>  		break;
>  
>  	case NETDEV_UNREGISTER:
> -		pktgen_mark_device(dev->name);
> +		pktgen_mark_device(pn, dev->name);
>  		break;
>  	}
>  
>  	return NOTIFY_DONE;
>  }
>  
> -static struct net_device *pktgen_dev_get_by_name(struct pktgen_dev *pkt_dev,
> +static struct net_device *pktgen_dev_get_by_name(const struct pktgen_net *pn,
> +						 struct pktgen_dev *pkt_dev,
>  						 const char *ifname)
>  {
>  	char b[IFNAMSIZ+5];
> @@ -1944,13 +1956,14 @@ static struct net_device *pktgen_dev_get_by_name(struct pktgen_dev *pkt_dev,
>  	}
>  	b[i] = 0;
>  
> -	return dev_get_by_name(&init_net, b);
> +	return dev_get_by_name(pn->net, b);
>  }
>  
>  
>  /* Associate pktgen_dev with a device. */
>  
> -static int pktgen_setup_dev(struct pktgen_dev *pkt_dev, const char *ifname)
> +static int pktgen_setup_dev(const struct pktgen_net *pn,
> +			    struct pktgen_dev *pkt_dev, const char *ifname)
>  {
>  	struct net_device *odev;
>  	int err;
> @@ -1961,7 +1974,7 @@ static int pktgen_setup_dev(struct pktgen_dev *pkt_dev, const char *ifname)
>  		pkt_dev->odev = NULL;
>  	}
>  
> -	odev = pktgen_dev_get_by_name(pkt_dev, ifname);
> +	odev = pktgen_dev_get_by_name(pn, pkt_dev, ifname);
>  	if (!odev) {
>  		pr_err("no such netdevice: \"%s\"\n", ifname);
>  		return -ENODEV;
> @@ -2203,9 +2216,10 @@ static inline int f_pick(struct pktgen_dev *pkt_dev)
>  static void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
>  {
>  	struct xfrm_state *x = pkt_dev->flows[flow].x;
> +	struct pktgen_net *pn = net_generic(dev_net(pkt_dev->odev), pg_net_id);
>  	if (!x) {
>  		/*slow path: we dont already have xfrm_state*/
> -		x = xfrm_stateonly_find(&init_net, DUMMY_MARK,
> +		x = xfrm_stateonly_find(pn->net, DUMMY_MARK,
>  					(xfrm_address_t *)&pkt_dev->cur_daddr,
>  					(xfrm_address_t *)&pkt_dev->cur_saddr,
>  					AF_INET,
> @@ -2912,7 +2926,7 @@ static void pktgen_run(struct pktgen_thread *t)
>  		t->control &= ~(T_STOP);
>  }
>  
> -static void pktgen_stop_all_threads_ifs(void)
> +static void pktgen_stop_all_threads_ifs(struct pktgen_net *pn)
>  {
>  	struct pktgen_thread *t;
>  
> @@ -2920,7 +2934,7 @@ static void pktgen_stop_all_threads_ifs(void)
>  
>  	mutex_lock(&pktgen_thread_lock);
>  
> -	list_for_each_entry(t, &pktgen_threads, th_list)
> +	list_for_each_entry(t, &pn->pktgen_threads, th_list)
>  		t->control |= T_STOP;
>  
>  	mutex_unlock(&pktgen_thread_lock);
> @@ -2956,28 +2970,28 @@ signal:
>  	return 0;
>  }
>  
> -static int pktgen_wait_all_threads_run(void)
> +static int pktgen_wait_all_threads_run(struct pktgen_net *pn)
>  {
>  	struct pktgen_thread *t;
>  	int sig = 1;
>  
>  	mutex_lock(&pktgen_thread_lock);
>  
> -	list_for_each_entry(t, &pktgen_threads, th_list) {
> +	list_for_each_entry(t, &pn->pktgen_threads, th_list) {
>  		sig = pktgen_wait_thread_run(t);
>  		if (sig == 0)
>  			break;
>  	}
>  
>  	if (sig == 0)
> -		list_for_each_entry(t, &pktgen_threads, th_list)
> +		list_for_each_entry(t, &pn->pktgen_threads, th_list)
>  			t->control |= (T_STOP);
>  
>  	mutex_unlock(&pktgen_thread_lock);
>  	return sig;
>  }
>  
> -static void pktgen_run_all_threads(void)
> +static void pktgen_run_all_threads(struct pktgen_net *pn)
>  {
>  	struct pktgen_thread *t;
>  
> @@ -2985,7 +2999,7 @@ static void pktgen_run_all_threads(void)
>  
>  	mutex_lock(&pktgen_thread_lock);
>  
> -	list_for_each_entry(t, &pktgen_threads, th_list)
> +	list_for_each_entry(t, &pn->pktgen_threads, th_list)
>  		t->control |= (T_RUN);
>  
>  	mutex_unlock(&pktgen_thread_lock);
> @@ -2993,10 +3007,10 @@ static void pktgen_run_all_threads(void)
>  	/* Propagate thread->control  */
>  	schedule_timeout_interruptible(msecs_to_jiffies(125));
>  
> -	pktgen_wait_all_threads_run();
> +	pktgen_wait_all_threads_run(pn);
>  }
>  
> -static void pktgen_reset_all_threads(void)
> +static void pktgen_reset_all_threads(struct pktgen_net *pn)
>  {
>  	struct pktgen_thread *t;
>  
> @@ -3004,7 +3018,7 @@ static void pktgen_reset_all_threads(void)
>  
>  	mutex_lock(&pktgen_thread_lock);
>  
> -	list_for_each_entry(t, &pktgen_threads, th_list)
> +	list_for_each_entry(t, &pn->pktgen_threads, th_list)
>  		t->control |= (T_REMDEVALL);
>  
>  	mutex_unlock(&pktgen_thread_lock);
> @@ -3012,7 +3026,7 @@ static void pktgen_reset_all_threads(void)
>  	/* Propagate thread->control  */
>  	schedule_timeout_interruptible(msecs_to_jiffies(125));
>  
> -	pktgen_wait_all_threads_run();
> +	pktgen_wait_all_threads_run(pn);
>  }
>  
>  static void show_results(struct pktgen_dev *pkt_dev, int nr_frags)
> @@ -3154,9 +3168,7 @@ static void pktgen_rem_all_ifs(struct pktgen_thread *t)
>  static void pktgen_rem_thread(struct pktgen_thread *t)
>  {
>  	/* Remove from the thread list */
> -
> -	remove_proc_entry(t->tsk->comm, pg_proc_dir);
> -
> +	remove_proc_entry(t->tsk->comm, t->net->proc_dir);
>  }
>  
>  static void pktgen_resched(struct pktgen_dev *pkt_dev)
> @@ -3302,7 +3314,7 @@ static int pktgen_thread_worker(void *arg)
>  		pkt_dev = next_to_run(t);
>  
>  		if (unlikely(!pkt_dev && t->control == 0)) {
> -			if (pktgen_exiting)
> +			if (t->net->pktgen_exiting)
>  				break;
>  			wait_event_interruptible_timeout(t->queue,
>  							 t->control != 0,
> @@ -3424,7 +3436,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
>  
>  	/* We don't allow a device to be on several threads */
>  
> -	pkt_dev = __pktgen_NN_threads(ifname, FIND);
> +	pkt_dev = __pktgen_NN_threads(t->net, ifname, FIND);
>  	if (pkt_dev) {
>  		pr_err("ERROR: interface already used\n");
>  		return -EBUSY;
> @@ -3459,13 +3471,13 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
>  	pkt_dev->svlan_id = 0xffff;
>  	pkt_dev->node = -1;
>  
> -	err = pktgen_setup_dev(pkt_dev, ifname);
> +	err = pktgen_setup_dev(t->net, pkt_dev, ifname);
>  	if (err)
>  		goto out1;
>  	if (pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)
>  		pkt_dev->clone_skb = pg_clone_skb_d;
>  
> -	pkt_dev->entry = proc_create_data(ifname, 0600, pg_proc_dir,
> +	pkt_dev->entry = proc_create_data(ifname, 0600, t->net->proc_dir,
>  					  &pktgen_if_fops, pkt_dev);
>  	if (!pkt_dev->entry) {
>  		pr_err("cannot create %s/%s procfs entry\n",
> @@ -3490,7 +3502,7 @@ out1:
>  	return err;
>  }
>  
> -static int __init pktgen_create_thread(int cpu)
> +static int __net_init pktgen_create_thread(int cpu, struct pktgen_net *pn)
>  {
>  	struct pktgen_thread *t;
>  	struct proc_dir_entry *pe;
> @@ -3508,7 +3520,7 @@ static int __init pktgen_create_thread(int cpu)
>  
>  	INIT_LIST_HEAD(&t->if_list);
>  
> -	list_add_tail(&t->th_list, &pktgen_threads);
> +	list_add_tail(&t->th_list, &pn->pktgen_threads);
>  	init_completion(&t->start_done);
>  
>  	p = kthread_create_on_node(pktgen_thread_worker,
> @@ -3524,7 +3536,7 @@ static int __init pktgen_create_thread(int cpu)
>  	kthread_bind(p, cpu);
>  	t->tsk = p;
>  
> -	pe = proc_create_data(t->tsk->comm, 0600, pg_proc_dir,
> +	pe = proc_create_data(t->tsk->comm, 0600, pn->proc_dir,
>  			      &pktgen_thread_fops, t);
>  	if (!pe) {
>  		pr_err("cannot create %s/%s procfs entry\n",
> @@ -3535,6 +3547,7 @@ static int __init pktgen_create_thread(int cpu)
>  		return -EINVAL;
>  	}
>  
> +	t->net = pn;
>  	wake_up_process(p);
>  	wait_for_completion(&t->start_done);
>  
> @@ -3560,6 +3573,7 @@ static void _rem_dev_from_if_list(struct pktgen_thread *t,
>  static int pktgen_remove_device(struct pktgen_thread *t,
>  				struct pktgen_dev *pkt_dev)
>  {
> +	struct pktgen_net *pn = t->net;
>  
>  	pr_debug("remove_device pkt_dev=%p\n", pkt_dev);
>  
> @@ -3580,7 +3594,7 @@ static int pktgen_remove_device(struct pktgen_thread *t,
>  	_rem_dev_from_if_list(t, pkt_dev);
>  
>  	if (pkt_dev->entry)
> -		remove_proc_entry(pkt_dev->entry->name, pg_proc_dir);
> +		remove_proc_entry(pkt_dev->entry->name, pn->proc_dir);
>  
>  #ifdef CONFIG_XFRM
>  	free_SAs(pkt_dev);
> @@ -3592,63 +3606,63 @@ static int pktgen_remove_device(struct pktgen_thread *t,
>  	return 0;
>  }
>  
> -static int __init pg_init(void)
> +static int __net_init pg_net_init(struct net *net)
>  {
> -	int cpu;
> +	struct pktgen_net *pn = net_generic(net, pg_net_id);
>  	struct proc_dir_entry *pe;
> -	int ret = 0;
> -
> -	pr_info("%s", version);
> -
> -	pg_proc_dir = proc_mkdir(PG_PROC_DIR, init_net.proc_net);
> -	if (!pg_proc_dir)
> +	int cpu, ret = 0;
> +
> +	pn->net = net;
> +	INIT_LIST_HEAD(&pn->pktgen_threads);
> +	pn->pktgen_exiting = false;
> +	pn->proc_dir = proc_mkdir(PG_PROC_DIR, pn->net->proc_net);
> +	if (!pn->proc_dir) {
> +		pr_warn("cannot create /proc/net/%s\n", PG_PROC_DIR);
>  		return -ENODEV;
> -
> -	pe = proc_create(PGCTRL, 0600, pg_proc_dir, &pktgen_fops);
> +	}
> +	pe = proc_create(PGCTRL, 0600, pn->proc_dir, &pktgen_fops);
>  	if (pe == NULL) {
> -		pr_err("ERROR: cannot create %s procfs entry\n", PGCTRL);
> +		pr_err("cannot create %s procfs entry\n", PGCTRL);
>  		ret = -EINVAL;
> -		goto remove_dir;
> +		goto remove;
>  	}
>  
> -	register_netdevice_notifier(&pktgen_notifier_block);
> -
>  	for_each_online_cpu(cpu) {
>  		int err;
>  
> -		err = pktgen_create_thread(cpu);
> +		err = pktgen_create_thread(cpu, pn);
>  		if (err)
> -			pr_warning("WARNING: Cannot create thread for cpu %d (%d)\n",
> +			pr_warn("Cannot create thread for cpu %d (%d)\n",
>  				   cpu, err);
>  	}
>  
> -	if (list_empty(&pktgen_threads)) {
> -		pr_err("ERROR: Initialization failed for all threads\n");
> +	if (list_empty(&pn->pktgen_threads)) {
> +		pr_err("Initialization failed for all threads\n");
>  		ret = -ENODEV;
> -		goto unregister;
> +		goto remove_entry;
>  	}
>  
>  	return 0;
>  
> - unregister:
> -	unregister_netdevice_notifier(&pktgen_notifier_block);
> -	remove_proc_entry(PGCTRL, pg_proc_dir);
> - remove_dir:
> -	proc_net_remove(&init_net, PG_PROC_DIR);
> +remove_entry:
> +	remove_proc_entry(PGCTRL, pn->proc_dir);
> +remove:
> +	proc_net_remove(pn->net, PG_PROC_DIR);
>  	return ret;
>  }
>  
> -static void __exit pg_cleanup(void)
> +static void __net_exit pg_net_exit(struct net *net)
>  {
> +	struct pktgen_net *pn = net_generic(net, pg_net_id);
>  	struct pktgen_thread *t;
>  	struct list_head *q, *n;
>  	LIST_HEAD(list);
>  
>  	/* Stop all interfaces & threads */
> -	pktgen_exiting = true;
> +	pn->pktgen_exiting = true;
>  
>  	mutex_lock(&pktgen_thread_lock);
> -	list_splice_init(&pktgen_threads, &list);
> +	list_splice_init(&pn->pktgen_threads, &list);
>  	mutex_unlock(&pktgen_thread_lock);
>  
>  	list_for_each_safe(q, n, &list) {
> @@ -3658,12 +3672,36 @@ static void __exit pg_cleanup(void)
>  		kfree(t);
>  	}
>  
> -	/* Un-register us from receiving netdevice events */
> -	unregister_netdevice_notifier(&pktgen_notifier_block);
> +	remove_proc_entry(PGCTRL, pn->proc_dir);
> +	proc_net_remove(pn->net, PG_PROC_DIR);
> +}
> +
> +static struct pernet_operations pg_net_ops = {
> +	.init = pg_net_init,
> +	.exit = pg_net_exit,
> +	.id   = &pg_net_id,
> +	.size = sizeof(struct pktgen_net),
> +};
> +
> +static int __init pg_init(void)
> +{
> +	int ret = 0;
>  
> -	/* Clean up proc file system */
> -	remove_proc_entry(PGCTRL, pg_proc_dir);
> -	proc_net_remove(&init_net, PG_PROC_DIR);
> +	pr_info("%s", version);
> +	ret = register_pernet_subsys(&pg_net_ops);
> +	if (ret)
> +		return ret;
> +	ret = register_netdevice_notifier(&pktgen_notifier_block);
> +	if (ret)
> +		unregister_pernet_subsys(&pg_net_ops);
> +
> +	return ret;
> +}
> +
> +static void __exit pg_cleanup(void)
> +{
> +	unregister_netdevice_notifier(&pktgen_notifier_block);
> +	unregister_pernet_subsys(&pg_net_ops);
>  }
>  
>  module_init(pg_init);
