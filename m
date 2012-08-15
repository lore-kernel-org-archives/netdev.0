From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 7/9] sctp: Make the proc files per network namespace.
Date: Tue, 14 Aug 2012 23:19:58 -0400
Message-ID: <502B155E.8060809@gmail.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com> <87mx27rig7.fsf@xmission.com> <87zk67q31q.fsf_-_@xmission.com> <87wr1boo5g.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Ariyasu <jan.ariyasu@hp.com>,
	Jan Ariyasu <jan.ariyasu@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>, Xi Wang <xi.wang@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87wr1boo5g.fsf_-_@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2012 02:45 PM, Eric W. Biederman wrote:
>
> - Convert all of the files under /proc/net/sctp to be per
>    network namespace.
>
> - Don't print anything for /proc/net/sctp/snmp except in
>    the initial network namespaces as the snmp counters still
>    have to be converted to be per network namespace.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

> ---
>   include/net/netns/sctp.h |    5 +++
>   include/net/sctp/sctp.h  |   16 +++++-----
>   net/sctp/proc.c          |   59 +++++++++++++++++++++++------------
>   net/sctp/protocol.c      |   77 +++++++++++++++++++--------------------------
>   4 files changed, 85 insertions(+), 72 deletions(-)
>
> diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
> index 29e36b4..9c20a82 100644
> --- a/include/net/netns/sctp.h
> +++ b/include/net/netns/sctp.h
> @@ -2,8 +2,13 @@
>   #define __NETNS_SCTP_H__
>
>   struct sock;
> +struct proc_dir_entry;
>
>   struct netns_sctp {
> +#ifdef CONFIG_PROC_FS
> +	struct proc_dir_entry *proc_net_sctp;
> +#endif
> +
>   	/* This is the global socket data structure used for responding to
>   	 * the Out-of-the-blue (OOTB) packets.  A control sock will be created
>   	 * for this socket at the initialization time.
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index 550a81b..ca716da 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -172,14 +172,14 @@ void sctp_backlog_migrate(struct sctp_association *assoc,
>   /*
>    * sctp/proc.c
>    */
> -int sctp_snmp_proc_init(void);
> -void sctp_snmp_proc_exit(void);
> -int sctp_eps_proc_init(void);
> -void sctp_eps_proc_exit(void);
> -int sctp_assocs_proc_init(void);
> -void sctp_assocs_proc_exit(void);
> -int sctp_remaddr_proc_init(void);
> -void sctp_remaddr_proc_exit(void);
> +int sctp_snmp_proc_init(struct net *net);
> +void sctp_snmp_proc_exit(struct net *net);
> +int sctp_eps_proc_init(struct net *net);
> +void sctp_eps_proc_exit(struct net *net);
> +int sctp_assocs_proc_init(struct net *net);
> +void sctp_assocs_proc_exit(struct net *net);
> +int sctp_remaddr_proc_init(struct net *net);
> +void sctp_remaddr_proc_exit(struct net *net);
>
>
>   /*
> diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> index 1e2eee8..dc79a3a 100644
> --- a/net/sctp/proc.c
> +++ b/net/sctp/proc.c
> @@ -80,8 +80,12 @@ static const struct snmp_mib sctp_snmp_list[] = {
>   /* Display sctp snmp mib statistics(/proc/net/sctp/snmp). */
>   static int sctp_snmp_seq_show(struct seq_file *seq, void *v)
>   {
> +	struct net *net = seq->private;
>   	int i;
>
> +	if (!net_eq(net, &init_net))
> +		return 0;
> +
>   	for (i = 0; sctp_snmp_list[i].name != NULL; i++)
>   		seq_printf(seq, "%-32s\t%ld\n", sctp_snmp_list[i].name,
>   			   snmp_fold_field((void __percpu **)sctp_statistics,
> @@ -93,7 +97,7 @@ static int sctp_snmp_seq_show(struct seq_file *seq, void *v)
>   /* Initialize the seq file operations for 'snmp' object. */
>   static int sctp_snmp_seq_open(struct inode *inode, struct file *file)
>   {
> -	return single_open(file, sctp_snmp_seq_show, NULL);
> +	return single_open_net(inode, file, sctp_snmp_seq_show);
>   }
>
>   static const struct file_operations sctp_snmp_seq_fops = {
> @@ -105,11 +109,12 @@ static const struct file_operations sctp_snmp_seq_fops = {
>   };
>
>   /* Set up the proc fs entry for 'snmp' object. */
> -int __init sctp_snmp_proc_init(void)
> +int __net_init sctp_snmp_proc_init(struct net *net)
>   {
>   	struct proc_dir_entry *p;
>
> -	p = proc_create("snmp", S_IRUGO, proc_net_sctp, &sctp_snmp_seq_fops);
> +	p = proc_create("snmp", S_IRUGO, net->sctp.proc_net_sctp,
> +			&sctp_snmp_seq_fops);
>   	if (!p)
>   		return -ENOMEM;
>
> @@ -117,9 +122,9 @@ int __init sctp_snmp_proc_init(void)
>   }
>
>   /* Cleanup the proc fs entry for 'snmp' object. */
> -void sctp_snmp_proc_exit(void)
> +void sctp_snmp_proc_exit(struct net *net)
>   {
> -	remove_proc_entry("snmp", proc_net_sctp);
> +	remove_proc_entry("snmp", net->sctp.proc_net_sctp);
>   }
>
>   /* Dump local addresses of an association/endpoint. */
> @@ -197,6 +202,7 @@ static void * sctp_eps_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>   /* Display sctp endpoints (/proc/net/sctp/eps). */
>   static int sctp_eps_seq_show(struct seq_file *seq, void *v)
>   {
> +	struct seq_net_private *priv = seq->private;
>   	struct sctp_hashbucket *head;
>   	struct sctp_ep_common *epb;
>   	struct sctp_endpoint *ep;
> @@ -213,6 +219,8 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
>   	sctp_for_each_hentry(epb, node, &head->chain) {
>   		ep = sctp_ep(epb);
>   		sk = epb->sk;
> +		if (!net_eq(sock_net(sk), priv->net))
> +			continue;
>   		seq_printf(seq, "%8pK %8pK %-3d %-3d %-4d %-5d %5d %5lu ", ep, sk,
>   			   sctp_sk(sk)->type, sk->sk_state, hash,
>   			   epb->bind_addr.port,
> @@ -238,7 +246,8 @@ static const struct seq_operations sctp_eps_ops = {
>   /* Initialize the seq file operations for 'eps' object. */
>   static int sctp_eps_seq_open(struct inode *inode, struct file *file)
>   {
> -	return seq_open(file, &sctp_eps_ops);
> +	return seq_open_net(inode, file, &sctp_eps_ops,
> +			    sizeof(struct seq_net_private));
>   }
>
>   static const struct file_operations sctp_eps_seq_fops = {
> @@ -249,11 +258,12 @@ static const struct file_operations sctp_eps_seq_fops = {
>   };
>
>   /* Set up the proc fs entry for 'eps' object. */
> -int __init sctp_eps_proc_init(void)
> +int __net_init sctp_eps_proc_init(struct net *net)
>   {
>   	struct proc_dir_entry *p;
>
> -	p = proc_create("eps", S_IRUGO, proc_net_sctp, &sctp_eps_seq_fops);
> +	p = proc_create("eps", S_IRUGO, net->sctp.proc_net_sctp,
> +			&sctp_eps_seq_fops);
>   	if (!p)
>   		return -ENOMEM;
>
> @@ -261,9 +271,9 @@ int __init sctp_eps_proc_init(void)
>   }
>
>   /* Cleanup the proc fs entry for 'eps' object. */
> -void sctp_eps_proc_exit(void)
> +void sctp_eps_proc_exit(struct net *net)
>   {
> -	remove_proc_entry("eps", proc_net_sctp);
> +	remove_proc_entry("eps", net->sctp.proc_net_sctp);
>   }
>
>
> @@ -300,6 +310,7 @@ static void * sctp_assocs_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>   /* Display sctp associations (/proc/net/sctp/assocs). */
>   static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
>   {
> +	struct seq_net_private *priv = seq->private;
>   	struct sctp_hashbucket *head;
>   	struct sctp_ep_common *epb;
>   	struct sctp_association *assoc;
> @@ -316,6 +327,8 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
>   	sctp_for_each_hentry(epb, node, &head->chain) {
>   		assoc = sctp_assoc(epb);
>   		sk = epb->sk;
> +		if (!net_eq(sock_net(sk), priv->net))
> +			continue;
>   		seq_printf(seq,
>   			   "%8pK %8pK %-3d %-3d %-2d %-4d "
>   			   "%4d %8d %8d %7d %5lu %-5d %5d ",
> @@ -354,7 +367,8 @@ static const struct seq_operations sctp_assoc_ops = {
>   /* Initialize the seq file operations for 'assocs' object. */
>   static int sctp_assocs_seq_open(struct inode *inode, struct file *file)
>   {
> -	return seq_open(file, &sctp_assoc_ops);
> +	return seq_open_net(inode, file, &sctp_assoc_ops,
> +			    sizeof(struct seq_net_private));
>   }
>
>   static const struct file_operations sctp_assocs_seq_fops = {
> @@ -365,11 +379,11 @@ static const struct file_operations sctp_assocs_seq_fops = {
>   };
>
>   /* Set up the proc fs entry for 'assocs' object. */
> -int __init sctp_assocs_proc_init(void)
> +int __net_init sctp_assocs_proc_init(struct net *net)
>   {
>   	struct proc_dir_entry *p;
>
> -	p = proc_create("assocs", S_IRUGO, proc_net_sctp,
> +	p = proc_create("assocs", S_IRUGO, net->sctp.proc_net_sctp,
>   			&sctp_assocs_seq_fops);
>   	if (!p)
>   		return -ENOMEM;
> @@ -378,9 +392,9 @@ int __init sctp_assocs_proc_init(void)
>   }
>
>   /* Cleanup the proc fs entry for 'assocs' object. */
> -void sctp_assocs_proc_exit(void)
> +void sctp_assocs_proc_exit(struct net *net)
>   {
> -	remove_proc_entry("assocs", proc_net_sctp);
> +	remove_proc_entry("assocs", net->sctp.proc_net_sctp);
>   }
>
>   static void *sctp_remaddr_seq_start(struct seq_file *seq, loff_t *pos)
> @@ -412,6 +426,7 @@ static void sctp_remaddr_seq_stop(struct seq_file *seq, void *v)
>
>   static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
>   {
> +	struct seq_net_private *priv = seq->private;
>   	struct sctp_hashbucket *head;
>   	struct sctp_ep_common *epb;
>   	struct sctp_association *assoc;
> @@ -426,6 +441,8 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
>   	sctp_local_bh_disable();
>   	read_lock(&head->lock);
>   	sctp_for_each_hentry(epb, node, &head->chain) {
> +		if (!net_eq(sock_net(epb->sk), priv->net))
> +			continue;
>   		assoc = sctp_assoc(epb);
>   		list_for_each_entry(tsp, &assoc->peer.transport_addr_list,
>   					transports) {
> @@ -489,14 +506,15 @@ static const struct seq_operations sctp_remaddr_ops = {
>   };
>
>   /* Cleanup the proc fs entry for 'remaddr' object. */
> -void sctp_remaddr_proc_exit(void)
> +void sctp_remaddr_proc_exit(struct net *net)
>   {
> -	remove_proc_entry("remaddr", proc_net_sctp);
> +	remove_proc_entry("remaddr", net->sctp.proc_net_sctp);
>   }
>
>   static int sctp_remaddr_seq_open(struct inode *inode, struct file *file)
>   {
> -	return seq_open(file, &sctp_remaddr_ops);
> +	return seq_open_net(inode, file, &sctp_remaddr_ops,
> +			    sizeof(struct seq_net_private));
>   }
>
>   static const struct file_operations sctp_remaddr_seq_fops = {
> @@ -506,11 +524,12 @@ static const struct file_operations sctp_remaddr_seq_fops = {
>   	.release = seq_release,
>   };
>
> -int __init sctp_remaddr_proc_init(void)
> +int __net_init sctp_remaddr_proc_init(struct net *net)
>   {
>   	struct proc_dir_entry *p;
>
> -	p = proc_create("remaddr", S_IRUGO, proc_net_sctp, &sctp_remaddr_seq_fops);
> +	p = proc_create("remaddr", S_IRUGO, net->sctp.proc_net_sctp,
> +			&sctp_remaddr_seq_fops);
>   	if (!p)
>   		return -ENOMEM;
>   	return 0;
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 976d765..72b3aa7 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -71,10 +71,6 @@
>   struct sctp_globals sctp_globals __read_mostly;
>   DEFINE_SNMP_STAT(struct sctp_mib, sctp_statistics) __read_mostly;
>
> -#ifdef CONFIG_PROC_FS
> -struct proc_dir_entry	*proc_net_sctp;
> -#endif
> -
>   struct idr sctp_assocs_id;
>   DEFINE_SPINLOCK(sctp_assocs_id_lock);
>
> @@ -91,60 +87,52 @@ int sysctl_sctp_rmem[3];
>   int sysctl_sctp_wmem[3];
>
>   /* Set up the proc fs entry for the SCTP protocol. */
> -static __init int sctp_proc_init(void)
> +static __net_init int sctp_proc_init(struct net *net)
>   {
>   #ifdef CONFIG_PROC_FS
> -	if (!proc_net_sctp) {
> -		proc_net_sctp = proc_mkdir("sctp", init_net.proc_net);
> -		if (!proc_net_sctp)
> -			goto out_free_percpu;
> -	}
> -
> -	if (sctp_snmp_proc_init())
> +	net->sctp.proc_net_sctp = proc_net_mkdir(net, "sctp", net->proc_net);
> +	if (!net->sctp.proc_net_sctp)
> +		goto out_proc_net_sctp;
> +	if (sctp_snmp_proc_init(net))
>   		goto out_snmp_proc_init;
> -	if (sctp_eps_proc_init())
> +	if (sctp_eps_proc_init(net))
>   		goto out_eps_proc_init;
> -	if (sctp_assocs_proc_init())
> +	if (sctp_assocs_proc_init(net))
>   		goto out_assocs_proc_init;
> -	if (sctp_remaddr_proc_init())
> +	if (sctp_remaddr_proc_init(net))
>   		goto out_remaddr_proc_init;
>
>   	return 0;
>
>   out_remaddr_proc_init:
> -	sctp_assocs_proc_exit();
> +	sctp_assocs_proc_exit(net);
>   out_assocs_proc_init:
> -	sctp_eps_proc_exit();
> +	sctp_eps_proc_exit(net);
>   out_eps_proc_init:
> -	sctp_snmp_proc_exit();
> +	sctp_snmp_proc_exit(net);
>   out_snmp_proc_init:
> -	if (proc_net_sctp) {
> -		proc_net_sctp = NULL;
> -		remove_proc_entry("sctp", init_net.proc_net);
> -	}
> -out_free_percpu:
> -#else
> -	return 0;
> -#endif /* CONFIG_PROC_FS */
> +	remove_proc_entry("sctp", net->proc_net);
> +	net->sctp.proc_net_sctp = NULL;
> +out_proc_net_sctp:
>   	return -ENOMEM;
> +#endif /* CONFIG_PROC_FS */
> +	return 0;
>   }
>
>   /* Clean up the proc fs entry for the SCTP protocol.
>    * Note: Do not make this __exit as it is used in the init error
>    * path.
>    */
> -static void sctp_proc_exit(void)
> +static void sctp_proc_exit(struct net *net)
>   {
>   #ifdef CONFIG_PROC_FS
> -	sctp_snmp_proc_exit();
> -	sctp_eps_proc_exit();
> -	sctp_assocs_proc_exit();
> -	sctp_remaddr_proc_exit();
> -
> -	if (proc_net_sctp) {
> -		proc_net_sctp = NULL;
> -		remove_proc_entry("sctp", init_net.proc_net);
> -	}
> +	sctp_snmp_proc_exit(net);
> +	sctp_eps_proc_exit(net);
> +	sctp_assocs_proc_exit(net);
> +	sctp_remaddr_proc_exit(net);
> +
> +	remove_proc_entry("sctp", net->proc_net);
> +	net->sctp.proc_net_sctp = NULL;
>   #endif
>   }
>
> @@ -1180,6 +1168,11 @@ static int sctp_net_init(struct net *net)
>   {
>   	int status;
>
> +	/* Initialize proc fs directory.  */
> +	status = sctp_proc_init(net);
> +	if (status)
> +		goto err_init_proc;
> +
>   	/* Initialize the control inode/socket for handling OOTB packets.  */
>   	if ((status = sctp_ctl_sock_init(net))) {
>   		pr_err("Failed to initialize the SCTP control sock\n");
> @@ -1202,6 +1195,8 @@ static int sctp_net_init(struct net *net)
>   	return 0;
>
>   err_ctl_sock_init:
> +	sctp_proc_exit(net);
> +err_init_proc:
>   	return status;
>   }
>
> @@ -1213,6 +1208,8 @@ static void sctp_net_exit(struct net *net)
>
>   	/* Free the control endpoint.  */
>   	inet_ctl_sock_destroy(net->sctp.ctl_sock);
> +
> +	sctp_proc_exit(net);
>   }
>
>   static struct pernet_operations sctp_net_ops = {
> @@ -1259,11 +1256,6 @@ SCTP_STATIC __init int sctp_init(void)
>   	if (status)
>   		goto err_percpu_counter_init;
>
> -	/* Initialize proc fs directory.  */
> -	status = sctp_proc_init();
> -	if (status)
> -		goto err_init_proc;
> -
>   	/* Initialize object count debugging.  */
>   	sctp_dbg_objcnt_init();
>
> @@ -1477,8 +1469,6 @@ err_ehash_alloc:
>   			     sizeof(struct sctp_hashbucket)));
>   err_ahash_alloc:
>   	sctp_dbg_objcnt_exit();
> -	sctp_proc_exit();
> -err_init_proc:
>   	percpu_counter_destroy(&sctp_sockets_allocated);
>   err_percpu_counter_init:
>   	cleanup_sctp_mibs();
> @@ -1522,7 +1512,6 @@ SCTP_STATIC __exit void sctp_exit(void)
>
>   	sctp_dbg_objcnt_exit();
>   	percpu_counter_destroy(&sctp_sockets_allocated);
> -	sctp_proc_exit();
>   	cleanup_sctp_mibs();
>
>   	rcu_barrier(); /* Wait for completion of call_rcu()'s */
>
