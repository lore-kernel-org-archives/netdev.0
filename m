From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 3/5] net: pppol2tp - introduce net-namespace functionality
Date: Tue, 20 Jan 2009 21:54:35 +0000
Message-ID: <4976481B.3000603@katalix.com>
References: <20090120140510.228815074@gmail.com>> <4975dc12.0c07560a.7d35.ffffcc78@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760410AbZATWET@vger.kernel.org>
In-Reply-To: <4975dc12.0c07560a.7d35.ffffcc78@mx.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cyrill Gorcunov wrote:
> - Each tunnel and appropriate lock are inside own namespace now.
> - pppox code allows to create per-namespace sockets for
>   both PX_PROTO_OE and PX_PROTO_OL2TP protocols. Actually since
>   now pppox_create support net-namespaces new PPPo... protocols
>   (if they ever will be) should support net-namespace too otherwise
>   explicit check for &init_net would be needed.
> 
> CC: James Chapman <jchapman@katalix.com>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

Changes look fine for pppol2tp. I tested again in my L2TP setup.

Signed-off-by: James Chapman <jchapman@katalix.com>

> ---
>  drivers/net/pppol2tp.c |  160 +++++++++++++++++++++++++++++++++++--------------
>  drivers/net/pppox.c    |    4 -
>  2 files changed, 117 insertions(+), 47 deletions(-)
> 
> Index: linux-2.6.git/drivers/net/pppol2tp.c
> ===================================================================
> --- linux-2.6.git.orig/drivers/net/pppol2tp.c
> +++ linux-2.6.git/drivers/net/pppol2tp.c
> @@ -90,7 +90,9 @@
>  #include <linux/hash.h>
>  #include <linux/sort.h>
>  #include <linux/proc_fs.h>
> +#include <linux/nsproxy.h>
>  #include <net/net_namespace.h>
> +#include <net/netns/generic.h>
>  #include <net/dst.h>
>  #include <net/ip.h>
>  #include <net/udp.h>
> @@ -204,6 +206,7 @@ struct pppol2tp_tunnel
>  	struct sock		*sock;		/* Parent socket */
>  	struct list_head	list;		/* Keep a list of all open
>  						 * prepared sockets */
> +	struct net		*pppol2tp_net;	/* the net we belong to */
>  
>  	atomic_t		ref_count;
>  };
> @@ -227,8 +230,20 @@ static atomic_t pppol2tp_tunnel_count;
>  static atomic_t pppol2tp_session_count;
>  static struct ppp_channel_ops pppol2tp_chan_ops = { pppol2tp_xmit , NULL };
>  static struct proto_ops pppol2tp_ops;
> -static LIST_HEAD(pppol2tp_tunnel_list);
> -static DEFINE_RWLOCK(pppol2tp_tunnel_list_lock);
> +
> +/* per-net private data for this module */
> +static unsigned int pppol2tp_net_id;
> +struct pppol2tp_net {
> +	struct list_head pppol2tp_tunnel_list;
> +	rwlock_t pppol2tp_tunnel_list_lock;
> +};
> +
> +static inline struct pppol2tp_net *pppol2tp_pernet(struct net *net)
> +{
> +	BUG_ON(!net);
> +
> +	return net_generic(net, pppol2tp_net_id);
> +}
>  
>  /* Helpers to obtain tunnel/session contexts from sockets.
>   */
> @@ -321,18 +336,19 @@ pppol2tp_session_find(struct pppol2tp_tu
>  
>  /* Lookup a tunnel by id
>   */
> -static struct pppol2tp_tunnel *pppol2tp_tunnel_find(u16 tunnel_id)
> +static struct pppol2tp_tunnel *pppol2tp_tunnel_find(struct net *net, u16 tunnel_id)
>  {
> -	struct pppol2tp_tunnel *tunnel = NULL;
> +	struct pppol2tp_tunnel *tunnel;
> +	struct pppol2tp_net *pn = pppol2tp_pernet(net);
>  
> -	read_lock_bh(&pppol2tp_tunnel_list_lock);
> -	list_for_each_entry(tunnel, &pppol2tp_tunnel_list, list) {
> +	read_lock_bh(&pn->pppol2tp_tunnel_list_lock);
> +	list_for_each_entry(tunnel, &pn->pppol2tp_tunnel_list, list) {
>  		if (tunnel->stats.tunnel_id == tunnel_id) {
> -			read_unlock_bh(&pppol2tp_tunnel_list_lock);
> +			read_unlock_bh(&pn->pppol2tp_tunnel_list_lock);
>  			return tunnel;
>  		}
>  	}
> -	read_unlock_bh(&pppol2tp_tunnel_list_lock);
> +	read_unlock_bh(&pn->pppol2tp_tunnel_list_lock);
>  
>  	return NULL;
>  }
> @@ -1287,10 +1303,12 @@ again:
>   */
>  static void pppol2tp_tunnel_free(struct pppol2tp_tunnel *tunnel)
>  {
> +	struct pppol2tp_net *pn = pppol2tp_pernet(tunnel->pppol2tp_net);
> +
>  	/* Remove from socket list */
> -	write_lock_bh(&pppol2tp_tunnel_list_lock);
> +	write_lock_bh(&pn->pppol2tp_tunnel_list_lock);
>  	list_del_init(&tunnel->list);
> -	write_unlock_bh(&pppol2tp_tunnel_list_lock);
> +	write_unlock_bh(&pn->pppol2tp_tunnel_list_lock);
>  
>  	atomic_dec(&pppol2tp_tunnel_count);
>  	kfree(tunnel);
> @@ -1444,13 +1462,14 @@ error:
>  /* Internal function to prepare a tunnel (UDP) socket to have PPPoX
>   * sockets attached to it.
>   */
> -static struct sock *pppol2tp_prepare_tunnel_socket(int fd, u16 tunnel_id,
> -						   int *error)
> +static struct sock *pppol2tp_prepare_tunnel_socket(struct net *net,
> +					int fd, u16 tunnel_id, int *error)
>  {
>  	int err;
>  	struct socket *sock = NULL;
>  	struct sock *sk;
>  	struct pppol2tp_tunnel *tunnel;
> +	struct pppol2tp_net *pn;
>  	struct sock *ret = NULL;
>  
>  	/* Get the tunnel UDP socket from the fd, which was opened by
> @@ -1524,11 +1543,15 @@ static struct sock *pppol2tp_prepare_tun
>  	/* Misc init */
>  	rwlock_init(&tunnel->hlist_lock);
>  
> +	/* The net we belong to */
> +	tunnel->pppol2tp_net = net;
> +	pn = pppol2tp_pernet(net);
> +
>  	/* Add tunnel to our list */
>  	INIT_LIST_HEAD(&tunnel->list);
> -	write_lock_bh(&pppol2tp_tunnel_list_lock);
> -	list_add(&tunnel->list, &pppol2tp_tunnel_list);
> -	write_unlock_bh(&pppol2tp_tunnel_list_lock);
> +	write_lock_bh(&pn->pppol2tp_tunnel_list_lock);
> +	list_add(&tunnel->list, &pn->pppol2tp_tunnel_list);
> +	write_unlock_bh(&pn->pppol2tp_tunnel_list_lock);
>  	atomic_inc(&pppol2tp_tunnel_count);
>  
>  	/* Bump the reference count. The tunnel context is deleted
> @@ -1629,7 +1652,8 @@ static int pppol2tp_connect(struct socke
>  	 * tunnel id.
>  	 */
>  	if ((sp->pppol2tp.s_session == 0) && (sp->pppol2tp.d_session == 0)) {
> -		tunnel_sock = pppol2tp_prepare_tunnel_socket(sp->pppol2tp.fd,
> +		tunnel_sock = pppol2tp_prepare_tunnel_socket(sock_net(sk),
> +							     sp->pppol2tp.fd,
>  							     sp->pppol2tp.s_tunnel,
>  							     &error);
>  		if (tunnel_sock == NULL)
> @@ -1637,7 +1661,7 @@ static int pppol2tp_connect(struct socke
>  
>  		tunnel = tunnel_sock->sk_user_data;
>  	} else {
> -		tunnel = pppol2tp_tunnel_find(sp->pppol2tp.s_tunnel);
> +		tunnel = pppol2tp_tunnel_find(sock_net(sk), sp->pppol2tp.s_tunnel);
>  
>  		/* Error if we can't find the tunnel */
>  		error = -ENOENT;
> @@ -2347,8 +2371,9 @@ end:
>  #include <linux/seq_file.h>
>  
>  struct pppol2tp_seq_data {
> -	struct pppol2tp_tunnel *tunnel; /* current tunnel */
> -	struct pppol2tp_session *session; /* NULL means get first session in tunnel */
> +	struct net *seq_net;			/* net of inode */
> +	struct pppol2tp_tunnel *tunnel;		/* current tunnel */
> +	struct pppol2tp_session *session;	/* NULL means get first session in tunnel */
>  };
>  
>  static struct pppol2tp_session *next_session(struct pppol2tp_tunnel *tunnel, struct pppol2tp_session *curr)
> @@ -2384,17 +2409,18 @@ out:
>  	return session;
>  }
>  
> -static struct pppol2tp_tunnel *next_tunnel(struct pppol2tp_tunnel *curr)
> +static struct pppol2tp_tunnel *next_tunnel(struct pppol2tp_net *pn,
> +					   struct pppol2tp_tunnel *curr)
>  {
>  	struct pppol2tp_tunnel *tunnel = NULL;
>  
> -	read_lock_bh(&pppol2tp_tunnel_list_lock);
> -	if (list_is_last(&curr->list, &pppol2tp_tunnel_list)) {
> +	read_lock_bh(&pn->pppol2tp_tunnel_list_lock);
> +	if (list_is_last(&curr->list, &pn->pppol2tp_tunnel_list)) {
>  		goto out;
>  	}
>  	tunnel = list_entry(curr->list.next, struct pppol2tp_tunnel, list);
>  out:
> -	read_unlock_bh(&pppol2tp_tunnel_list_lock);
> +	read_unlock_bh(&pn->pppol2tp_tunnel_list_lock);
>  
>  	return tunnel;
>  }
> @@ -2402,6 +2428,7 @@ out:
>  static void *pppol2tp_seq_start(struct seq_file *m, loff_t *offs)
>  {
>  	struct pppol2tp_seq_data *pd = SEQ_START_TOKEN;
> +	struct pppol2tp_net *pn;
>  	loff_t pos = *offs;
>  
>  	if (!pos)
> @@ -2409,14 +2436,15 @@ static void *pppol2tp_seq_start(struct s
>  
>  	BUG_ON(m->private == NULL);
>  	pd = m->private;
> +	pn = pppol2tp_pernet(pd->seq_net);
>  
>  	if (pd->tunnel == NULL) {
> -		if (!list_empty(&pppol2tp_tunnel_list))
> -			pd->tunnel = list_entry(pppol2tp_tunnel_list.next, struct pppol2tp_tunnel, list);
> +		if (!list_empty(&pn->pppol2tp_tunnel_list))
> +			pd->tunnel = list_entry(pn->pppol2tp_tunnel_list.next, struct pppol2tp_tunnel, list);
>  	} else {
>  		pd->session = next_session(pd->tunnel, pd->session);
>  		if (pd->session == NULL) {
> -			pd->tunnel = next_tunnel(pd->tunnel);
> +			pd->tunnel = next_tunnel(pn, pd->tunnel);
>  		}
>  	}
>  
> @@ -2532,6 +2560,7 @@ static int pppol2tp_proc_open(struct ino
>  {
>  	struct seq_file *m;
>  	struct pppol2tp_seq_data *pd;
> +	struct net *net;
>  	int ret = 0;
>  
>  	ret = seq_open(file, &pppol2tp_seq_ops);
> @@ -2542,12 +2571,15 @@ static int pppol2tp_proc_open(struct ino
>  
>  	/* Allocate and fill our proc_data for access later */
>  	ret = -ENOMEM;
> -	m->private = kzalloc(sizeof(struct pppol2tp_seq_data), GFP_KERNEL);
> +	m->private = kzalloc(sizeof(*pd), GFP_KERNEL);
>  	if (m->private == NULL)
>  		goto out;
>  
>  	pd = m->private;
> -	ret = 0;
> +	net = maybe_get_net(PDE_NET(PDE(inode)));
> +	BUG_ON(!net);
> +	pd->seq_net = net;
> +	return 0;
>  
>  out:
>  	return ret;
> @@ -2558,6 +2590,9 @@ out:
>  static int pppol2tp_proc_release(struct inode *inode, struct file *file)
>  {
>  	struct seq_file *m = (struct seq_file *)file->private_data;
> +	struct pppol2tp_seq_data *pd = m->private;
> +
> +	put_net(pd->seq_net);
>  
>  	kfree(m->private);
>  	m->private = NULL;
> @@ -2573,8 +2608,6 @@ static struct file_operations pppol2tp_p
>  	.release	= pppol2tp_proc_release,
>  };
>  
> -static struct proc_dir_entry *pppol2tp_proc;
> -
>  #endif /* CONFIG_PROC_FS */
>  
>  /*****************************************************************************
> @@ -2606,6 +2639,57 @@ static struct pppox_proto pppol2tp_proto
>  	.ioctl		= pppol2tp_ioctl
>  };
>  
> +static __net_init int pppol2tp_init_net(struct net *net)
> +{
> +	struct pppol2tp_net *pn;
> +	struct proc_dir_entry *pde;
> +	int err;
> +
> +	pn = kzalloc(sizeof(*pn), GFP_KERNEL);
> +	if (!pn)
> +		return -ENOMEM;
> +
> +	INIT_LIST_HEAD(&pn->pppol2tp_tunnel_list);
> +	rwlock_init(&pn->pppol2tp_tunnel_list_lock);
> +
> +	err = net_assign_generic(net, pppol2tp_net_id, pn);
> +	if (err)
> +		goto out;
> +
> +	pde = proc_net_fops_create(net, "pppol2tp", S_IRUGO, &pppol2tp_proc_fops);
> +#ifdef CONFIG_PROC_FS
> +	if (!pde) {
> +		err = -ENOMEM;
> +		goto out;
> +	}
> +#endif
> +
> +	return 0;
> +
> +out:
> +	kfree(pn);
> +	return err;
> +}
> +
> +static __net_exit void pppol2tp_exit_net(struct net *net)
> +{
> +	struct pppoe_net *pn;
> +
> +	proc_net_remove(net, "pppol2tp");
> +	pn = net_generic(net, pppol2tp_net_id);
> +	/*
> +	 * if someone has cached our net then
> +	 * further net_generic call will return NULL
> +	 */
> +	net_assign_generic(net, pppol2tp_net_id, NULL);
> +	kfree(pn);
> +}
> +
> +static __net_initdata struct pernet_operations pppol2tp_net_ops = {
> +	.init = pppol2tp_init_net,
> +	.exit = pppol2tp_exit_net,
> +};
> +
>  static int __init pppol2tp_init(void)
>  {
>  	int err;
> @@ -2617,23 +2701,17 @@ static int __init pppol2tp_init(void)
>  	if (err)
>  		goto out_unregister_pppol2tp_proto;
>  
> -#ifdef CONFIG_PROC_FS
> -	pppol2tp_proc = proc_net_fops_create(&init_net, "pppol2tp", 0,
> -					     &pppol2tp_proc_fops);
> -	if (!pppol2tp_proc) {
> -		err = -ENOMEM;
> +	err = register_pernet_gen_device(&pppol2tp_net_id, &pppol2tp_net_ops);
> +	if (err)
>  		goto out_unregister_pppox_proto;
> -	}
> -#endif /* CONFIG_PROC_FS */
> +
>  	printk(KERN_INFO "PPPoL2TP kernel driver, %s\n",
>  	       PPPOL2TP_DRV_VERSION);
>  
>  out:
>  	return err;
> -#ifdef CONFIG_PROC_FS
>  out_unregister_pppox_proto:
>  	unregister_pppox_proto(PX_PROTO_OL2TP);
> -#endif
>  out_unregister_pppol2tp_proto:
>  	proto_unregister(&pppol2tp_sk_proto);
>  	goto out;
> @@ -2642,10 +2720,6 @@ out_unregister_pppol2tp_proto:
>  static void __exit pppol2tp_exit(void)
>  {
>  	unregister_pppox_proto(PX_PROTO_OL2TP);
> -
> -#ifdef CONFIG_PROC_FS
> -	remove_proc_entry("pppol2tp", init_net.proc_net);
> -#endif
>  	proto_unregister(&pppol2tp_sk_proto);
>  }
>  
> Index: linux-2.6.git/drivers/net/pppox.c
> ===================================================================
> --- linux-2.6.git.orig/drivers/net/pppox.c
> +++ linux-2.6.git/drivers/net/pppox.c
> @@ -111,10 +111,6 @@ static int pppox_create(struct net *net,
>  	if (protocol < 0 || protocol > PX_MAX_PROTO)
>  		goto out;
>  
> -	/* we support net-namespaces for PPPoE only (yet) */
> -	if (protocol != PX_PROTO_OE && net != &init_net)
> -		return -EAFNOSUPPORT;
> -
>  	rc = -EPROTONOSUPPORT;
>  	if (!pppox_protos[protocol])
>  		request_module("pppox-proto-%d", protocol);
> 


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
