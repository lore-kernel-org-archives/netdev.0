From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC 3/4] net: netfilter conntrack - add per-net functionality
 for SCTP protocol
Date: Tue, 10 Mar 2009 11:21:09 +0100
Message-ID: <49B63F15.4030902@free.fr>
References: <20090309181628.109019157@gmail.com> <20090309182731.907328228@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, xemul@openvz.org, adobriyan@gmail.com,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090309182731.907328228@gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cyrill Gorcunov wrote:
> Module specific data moved into per-net site and being allocated/freed
> during net namespace creation/deletion.
>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---
>  net/netfilter/nf_conntrack_proto_sctp.c |  179 ++++++++++++++++++++++++--------
>  1 file changed, 139 insertions(+), 40 deletions(-)
>
> Index: linux-2.6.git/net/netfilter/nf_conntrack_proto_sctp.c
> ===================================================================
> --- linux-2.6.git.orig/net/netfilter/nf_conntrack_proto_sctp.c
> +++ linux-2.6.git/net/netfilter/nf_conntrack_proto_sctp.c
> @@ -21,6 +21,9 @@
>  #include <linux/spinlock.h>
>  #include <linux/interrupt.h>
>  
> +#include <net/net_namespace.h>
> +#include <net/netns/generic.h>
> +
>  #include <net/netfilter/nf_conntrack.h>
>  #include <net/netfilter/nf_conntrack_l4proto.h>
>  #include <net/netfilter/nf_conntrack_ecache.h>
> @@ -49,16 +52,6 @@ static const char *const sctp_conntrack_
>  #define HOURS * 60 MINS
>  #define DAYS  * 24 HOURS
>  
> -static unsigned int sctp_timeouts[SCTP_CONNTRACK_MAX] __read_mostly = {
> -	[SCTP_CONNTRACK_CLOSED]			= 10 SECS,
> -	[SCTP_CONNTRACK_COOKIE_WAIT]		= 3 SECS,
> -	[SCTP_CONNTRACK_COOKIE_ECHOED]		= 3 SECS,
> -	[SCTP_CONNTRACK_ESTABLISHED]		= 5 DAYS,
> -	[SCTP_CONNTRACK_SHUTDOWN_SENT]		= 300 SECS / 1000,
> -	[SCTP_CONNTRACK_SHUTDOWN_RECD]		= 300 SECS / 1000,
> -	[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT]	= 3 SECS,
> -};
> -
>  #define sNO SCTP_CONNTRACK_NONE
>  #define	sCL SCTP_CONNTRACK_CLOSED
>  #define	sCW SCTP_CONNTRACK_COOKIE_WAIT
> @@ -130,6 +123,25 @@ static const u8 sctp_conntracks[2][9][SC
>  	}
>  };
>  
> +/* this module per-net specifics */
> +static int sctp_net_id;
> +struct sctp_net {
> +	unsigned int sctp_timeouts[SCTP_CONNTRACK_MAX];
> +#ifdef CONFIG_SYSCTL
> +	struct ctl_table_header *sysctl_header;
> +	struct ctl_table *sysctl_table;
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +	struct ctl_table_header *compat_sysctl_header;
> +	struct ctl_table *compat_sysctl_table;
> +#endif
> +#endif
> +};
> +
> +static inline struct sctp_net *sctp_pernet(struct net *net)
> +{
> +	return net_generic(net, sctp_net_id);
> +}
> +
>  static bool sctp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
>  			      struct nf_conntrack_tuple *tuple)
>  {
> @@ -297,6 +309,7 @@ static int sctp_packet(struct nf_conn *c
>  	const struct sctp_chunkhdr *sch;
>  	struct sctp_chunkhdr _sch;
>  	u_int32_t offset, count;
> +	struct sctp_net *sn;
>  	unsigned long map[256 / sizeof(unsigned long)] = { 0 };
>  
>  	sh = skb_header_pointer(skb, dataoff, sizeof(_sctph), &_sctph);
> @@ -373,7 +386,8 @@ static int sctp_packet(struct nf_conn *c
>  	}
>  	write_unlock_bh(&sctp_lock);
>  
> -	nf_ct_refresh_acct(ct, ctinfo, skb, sctp_timeouts[new_state]);
> +	sn = sctp_pernet(nf_ct_net(ct));
> +	nf_ct_refresh_acct(ct, ctinfo, skb, sn->sctp_timeouts[new_state]);
>  
>  	if (old_state == SCTP_CONNTRACK_COOKIE_ECHOED &&
>  	    dir == IP_CT_DIR_REPLY &&
> @@ -540,54 +554,49 @@ static int nlattr_to_sctp(struct nlattr 
>  #endif
>  
>  #ifdef CONFIG_SYSCTL
> -static unsigned int sctp_sysctl_table_users;
> -static struct ctl_table_header *sctp_sysctl_header;
> +/*
> + * we use these tables as templates when create per-net syctl tables
> + * tables data will be assigned later
> + */
>  static struct ctl_table sctp_sysctl_table[] = {
>  	{
>  		.procname	= "nf_conntrack_sctp_timeout_closed",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_CLOSED],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	= "nf_conntrack_sctp_timeout_cookie_wait",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	= "nf_conntrack_sctp_timeout_cookie_echoed",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	= "nf_conntrack_sctp_timeout_established",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	= "nf_conntrack_sctp_timeout_shutdown_sent",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	= "nf_conntrack_sctp_timeout_shutdown_recd",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	= "nf_conntrack_sctp_timeout_shutdown_ack_sent",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
> @@ -601,49 +610,42 @@ static struct ctl_table sctp_sysctl_tabl
>  static struct ctl_table sctp_compat_sysctl_table[] = {
>  	{
>  		.procname	= "ip_conntrack_sctp_timeout_closed",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_CLOSED],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	= "ip_conntrack_sctp_timeout_cookie_wait",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	= "ip_conntrack_sctp_timeout_cookie_echoed",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	= "ip_conntrack_sctp_timeout_established",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	= "ip_conntrack_sctp_timeout_shutdown_sent",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	= "ip_conntrack_sctp_timeout_shutdown_recd",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	= "ip_conntrack_sctp_timeout_shutdown_ack_sent",
> -		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
> @@ -653,7 +655,7 @@ static struct ctl_table sctp_compat_sysc
>  	}
>  };
>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
> -#endif
> +#endif /* CONFIG_SYSCTL */
>  
>  static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
>  	.l3proto		= PF_INET,
> @@ -673,14 +675,6 @@ static struct nf_conntrack_l4proto nf_co
>  	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
>  	.nla_policy		= nf_ct_port_nla_policy,
>  #endif
> -#ifdef CONFIG_SYSCTL
> -	.ctl_table_users	= &sctp_sysctl_table_users,
> -	.ctl_table_header	= &sctp_sysctl_header,
> -	.ctl_table		= sctp_sysctl_table,
> -#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> -	.ctl_compat_table	= sctp_compat_sysctl_table,
> -#endif
> -#endif
>  };
>  
>  static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
> @@ -701,21 +695,123 @@ static struct nf_conntrack_l4proto nf_co
>  	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
>  	.nla_policy		= nf_ct_port_nla_policy,
>  #endif
> +};
> +
> +static __net_init int sctp_net_init(struct net *net)
> +{
> +	struct sctp_net *sn;
> +	int err;
> +
> +	sn = kmalloc(sizeof(*sn), GFP_KERNEL);
> +	if (!sn)
> +		return -ENOMEM;
> +
> +	/* default values */
> +	sn->sctp_timeouts[SCTP_CONNTRACK_CLOSED]	= 10 SECS;
> +	sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT]	= 3 SECS;
> +	sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED]	= 3 SECS;
> +	sn->sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED]	= 5 DAYS;
> +	sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT]	= 300 SECS / 1000;
> +	sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD]	= 300 SECS / 1000;
> +	sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT] = 3 SECS;
> +
> +	err = net_assign_generic(net, sctp_net_id, sn);
> +	if (err)
> +		goto out;
> +
>  #ifdef CONFIG_SYSCTL
> -	.ctl_table_users	= &sctp_sysctl_table_users,
> -	.ctl_table_header	= &sctp_sysctl_header,
> -	.ctl_table		= sctp_sysctl_table,
> +	err = -ENOMEM;
> +	sn->sysctl_table = kmemdup(sctp_sysctl_table,
> +			sizeof(sctp_sysctl_table), GFP_KERNEL);
> +	if (!sn->sysctl_table)
> +		goto out;
> +
> +	sn->sysctl_table[0].data = &sn->sctp_timeouts[SCTP_CONNTRACK_CLOSED];
> +	sn->sysctl_table[1].data = &sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT];
> +	sn->sysctl_table[2].data = &sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED];
> +	sn->sysctl_table[3].data = &sn->sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED];
> +	sn->sysctl_table[4].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
> +	sn->sysctl_table[5].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
> +	sn->sysctl_table[6].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
> +
> +	sn->sysctl_header = register_net_sysctl_table(net,
> +			nf_net_netfilter_sysctl_path, sn->sysctl_table);
> +	if (!sn->sysctl_header)
> +		goto out_free;
> +
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +	sn->compat_sysctl_table = kmemdup(sctp_compat_sysctl_table,
> +			sizeof(sctp_compat_sysctl_table), GFP_KERNEL);
> +	if (!sn->compat_sysctl_table)
> +		goto out_sysctl;
> +
> +	sn->compat_sysctl_table[0].data = &sn->sctp_timeouts[SCTP_CONNTRACK_CLOSED];
> +	sn->compat_sysctl_table[1].data = &sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT];
> +	sn->compat_sysctl_table[2].data = &sn->sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED];
> +	sn->compat_sysctl_table[3].data = &sn->sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED];
> +	sn->compat_sysctl_table[4].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
> +	sn->compat_sysctl_table[5].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
> +	sn->compat_sysctl_table[6].data = &sn->sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
> +
> +	sn->compat_sysctl_header = register_net_sysctl_table(net,
> +			nf_net_ipv4_netfilter_sysctl_path, sn->compat_sysctl_table);
> +	if (!sn->compat_sysctl_header)
> +		goto out_free_compat;
> +#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
> +#endif /* CONFIG_SYSCTL */
> +
> +	return 0;
> +
> +#ifdef CONFIG_SYSCTL
> +
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +out_free_compat:
> +	kfree(sn->compat_sysctl_table);
> +#endif
> +out_sysctl:
> +	unregister_net_sysctl_table(sn->sysctl_header);
> +out_free:
> +	kfree(sn->sysctl_table);
> +#endif
> +
> +out:
> +	kfree(sn);
> +	return err;
> +}
> +
> +static __net_exit void sctp_net_exit(struct net *net)
> +{
> +	struct sctp_net *sn = sctp_pernet(net);
> +#ifdef CONFIG_SYSCTL
> +	unregister_net_sysctl_table(sn->sysctl_header);
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +	unregister_net_sysctl_table(sn->compat_sysctl_header);
> +	kfree(sn->compat_sysctl_table);
> +#endif
> +	kfree(sn->sysctl_table);
>  #endif
> +	kfree(sn);
> +
> +	net_assign_generic(net, sctp_net_id, NULL);
> +}
> +
> +static struct pernet_operations sctp_net_ops = {
> +	.init = sctp_net_init,
> +	.exit = sctp_net_exit,
>  };
>  
>  static int __init nf_conntrack_proto_sctp_init(void)
>  {
>  	int ret;
>  
> +	ret = register_pernet_gen_device(&sctp_net_id, &sctp_net_ops);
>   
register_pernet_gen_subsys ?
> +	if (ret < 0)
> +		goto out;
> +
>  	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp4);
>  	if (ret) {
>  		printk("nf_conntrack_l4proto_sctp4: protocol register failed\n");
> -		goto out;
> +		goto cleanup_net;
>  	}
>  	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp6);
>  	if (ret) {
> @@ -727,12 +823,15 @@ static int __init nf_conntrack_proto_sct
>  
>   cleanup_sctp4:
>  	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
> + cleanup_net:
> +	unregister_pernet_gen_device(sctp_net_id, &sctp_net_ops);
>   out:
>  	return ret;
>  }
>  
>  static void __exit nf_conntrack_proto_sctp_fini(void)
>  {
> +	unregister_pernet_gen_device(sctp_net_id, &sctp_net_ops);
>  	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp6);
>  	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
>  }
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   
