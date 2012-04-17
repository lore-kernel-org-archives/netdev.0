From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 10/12] netfilter: sctp proto sysctl support for net namespace
Date: Tue, 17 Apr 2012 18:30:14 +0800
Message-ID: <4F8D4636.2080906@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com> <1334631383-12326-11-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, ebiederm@xmission.com,
	serge.hallyn@canonical.com, dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1334631383-12326-11-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B404=E6=9C=8817=E6=97=A5 10:56, Gao feng =E5=86=99=
=E9=81=93:
> register pernet_operations nf_conntrack_net_proto_sctp_ops
> when loading nf_conntrack_proto_sctp module,and unregister
> it when removing.
>=20
> It makes no senes to register subsys for sctp and sctp6,because
> the nf_conntrack_l4proto_sctp4 and nf_conntrack_l4proto_sctp6 are
> register or unregister together.
>=20
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>


I think it's better to impletement this as dccp,
dccp stores the timeouts and ctl_table in net_generic.

This will don't cause waste when sctp module is not loaded.

> ---
>  net/netfilter/nf_conntrack_proto_sctp.c |  205 +++++++++++++++++++++=
+++++-----
>  1 files changed, 175 insertions(+), 30 deletions(-)
>=20
> diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/=
nf_conntrack_proto_sctp.c
> index 72b5088..866d151 100644
> --- a/net/netfilter/nf_conntrack_proto_sctp.c
> +++ b/net/netfilter/nf_conntrack_proto_sctp.c
> @@ -281,7 +281,7 @@ static int sctp_new_state(enum ip_conntrack_dir d=
ir,
> =20
>  static unsigned int *sctp_get_timeouts(struct net *net)
>  {
> -	return sctp_timeouts;
> +	return net->ct.proto.sysctl_sctp_timeouts;
>  }
> =20
>  /* Returns verdict for packet, or -NF_ACCEPT for invalid. */
> @@ -599,56 +599,60 @@ sctp_timeout_nla_policy[CTA_TIMEOUT_SCTP_MAX+1]=
 =3D {
>  };
>  #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
> =20
> -
>  #ifdef CONFIG_SYSCTL
> -static unsigned int sctp_sysctl_table_users;
> -static struct ctl_table_header *sctp_sysctl_header;
>  static struct ctl_table sctp_sysctl_table[] =3D {
>  	{
>  		.procname	=3D "nf_conntrack_sctp_timeout_closed",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_CLOSED],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_CLOSED],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	=3D "nf_conntrack_sctp_timeout_cookie_wait",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	=3D "nf_conntrack_sctp_timeout_cookie_echoed",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	=3D "nf_conntrack_sctp_timeout_established",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	=3D "nf_conntrack_sctp_timeout_shutdown_sent",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	=3D "nf_conntrack_sctp_timeout_shutdown_recd",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	=3D "nf_conntrack_sctp_timeout_shutdown_ack_sent",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
> @@ -660,49 +664,56 @@ static struct ctl_table sctp_sysctl_table[] =3D=
 {
>  static struct ctl_table sctp_compat_sysctl_table[] =3D {
>  	{
>  		.procname	=3D "ip_conntrack_sctp_timeout_closed",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_CLOSED],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_CLOSED],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	=3D "ip_conntrack_sctp_timeout_cookie_wait",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	=3D "ip_conntrack_sctp_timeout_cookie_echoed",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	=3D "ip_conntrack_sctp_timeout_established",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	=3D "ip_conntrack_sctp_timeout_shutdown_sent",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	=3D "ip_conntrack_sctp_timeout_shutdown_recd",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	=3D "ip_conntrack_sctp_timeout_shutdown_ack_sent",
> -		.data		=3D &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
> +		.data		=3D &init_net.ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
> @@ -742,14 +753,6 @@ static struct nf_conntrack_l4proto nf_conntrack_=
l4proto_sctp4 __read_mostly =3D {
>  		.nla_policy	=3D sctp_timeout_nla_policy,
>  	},
>  #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
> -#ifdef CONFIG_SYSCTL
> -	.ctl_table_users	=3D &sctp_sysctl_table_users,
> -	.ctl_table_header	=3D &sctp_sysctl_header,
> -	.ctl_table		=3D sctp_sysctl_table,
> -#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> -	.ctl_compat_table	=3D sctp_compat_sysctl_table,
> -#endif
> -#endif
>  };
> =20
>  static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read=
_mostly =3D {
> @@ -782,11 +785,146 @@ static struct nf_conntrack_l4proto nf_conntrac=
k_l4proto_sctp6 __read_mostly =3D {
>  	},
>  #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
>  #endif
> +};
> +
> +static int nf_conntrack_proto_sctp_net_init(struct net *net)
> +{
> +	struct ctl_table *table;
> +	int i, ret =3D 0;
> +	for (i =3D 0; i < SCTP_CONNTRACK_MAX; i++)
> +		net->ct.proto.sysctl_sctp_timeouts[i] =3D sctp_timeouts[i];
> +
>  #ifdef CONFIG_SYSCTL
> -	.ctl_table_users	=3D &sctp_sysctl_table_users,
> -	.ctl_table_header	=3D &sctp_sysctl_header,
> -	.ctl_table		=3D sctp_sysctl_table,
> +	table =3D kmemdup(sctp_sysctl_table,
> +			sizeof(sctp_sysctl_table),
> +			GFP_KERNEL);
> +	if (!table)
> +		return -ENOMEM;
> +	table[0].data =3D &net->ct.proto.
> +			sysctl_sctp_timeouts[SCTP_CONNTRACK_CLOSED];
> +	table[1].data =3D &net->ct.proto.
> +			sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT];
> +	table[2].data =3D &net->ct.proto.
> +			sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED];
> +	table[3].data =3D &net->ct.proto.
> +			sysctl_sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED];
> +	table[4].data =3D &net->ct.proto.
> +			sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
> +	table[5].data =3D &net->ct.proto.
> +			sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
> +	table[6].data =3D &net->ct.proto.
> +			sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
> +
> +	ret =3D nf_ct_register_net_sysctl(net,
> +					&net->ct.proto.sctp_sysctl_header,
> +					nf_net_netfilter_sysctl_path,
> +					table,
> +					NULL);
> +	if (ret < 0) {
> +		printk(KERN_ERR
> +			"nf_conntrack_proto_sctp:"
> +			" can't register to sysctl.\n");
> +		goto out_register;
> +	}
> +	return 0;
> +out_register:
> +	kfree(table);
>  #endif
> +	return ret;
> +}
> +
> +static void nf_conntrack_proto_sctp_net_fini(struct net *net)
> +{
> +#ifdef CONFIG_SYSCTL
> +	struct ctl_table *table;
> +	table =3D net->ct.proto.sctp_sysctl_header->ctl_table_arg;
> +
> +	nf_ct_unregister_net_sysctl(&net->ct.proto.sctp_sysctl_header,
> +				    table,
> +				    NULL);
> +#endif
> +}
> +
> +static int nf_conntrack_proto_sctp_compat_init(struct net *net)
> +{
> +	int ret =3D 0;
> +#ifdef CONFIG_SYSCTL
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +	struct ctl_table *compat_table;
> +	compat_table =3D kmemdup(sctp_compat_sysctl_table,
> +			       sizeof(sctp_compat_sysctl_table),
> +			       GFP_KERNEL);
> +	if (!compat_table)
> +		return -ENOMEM;
> +
> +	compat_table[0].data =3D &net->ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_CLOSED];
> +	compat_table[1].data =3D &net->ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT];
> +	compat_table[2].data =3D &net->ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED];
> +	compat_table[3].data =3D &net->ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED];
> +	compat_table[4].data =3D &net->ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
> +	compat_table[5].data =3D &net->ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
> +	compat_table[6].data =3D &net->ct.proto.
> +				sysctl_sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
> +
> +	ret =3D nf_ct_register_net_sysctl(net,
> +					&net->ct.proto.sctp_compat_header,
> +					nf_net_ipv4_netfilter_sysctl_path,
> +					compat_table,
> +					NULL);
> +	if (ret < 0) {
> +		printk(KERN_ERR
> +			"nf_conntrack_proto_sctp:"
> +			" can't register to compat sysctl.\n");
> +		goto out_register;
> +	}
> +	return 0;
> +out_register:
> +	kfree(compat_table);
> +#endif
> +#endif
> +	return ret;
> +}
> +
> +static void nf_conntrack_proto_sctp_compat_fini(struct net *net)
> +{
> +#ifdef CONFIG_SYSCTL
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +	struct ctl_table *compat_table;
> +	compat_table =3D net->ct.proto.sctp_compat_header->ctl_table_arg;
> +	nf_ct_unregister_net_sysctl(&net->ct.proto.sctp_compat_header,
> +				    compat_table,
> +				    NULL);
> +#endif
> +#endif
> +}
> +
> +static int nf_conntrack_net_proto_sctp_init(struct net *net)
> +{
> +	int ret;
> +	ret =3D nf_conntrack_proto_sctp_net_init(net);
> +	if (ret < 0)
> +		return ret;
> +	ret =3D nf_conntrack_proto_sctp_compat_init(net);
> +	if (ret < 0)
> +		nf_conntrack_proto_sctp_net_fini(net);
> +	return ret;
> +}
> +
> +static void nf_conntrack_net_proto_sctp_fini(struct net *net)
> +{
> +	nf_conntrack_proto_sctp_compat_fini(net);
> +	nf_conntrack_proto_sctp_net_fini(net);
> +}
> +
> +static struct pernet_operations nf_conntrack_net_proto_sctp_ops =3D =
{
> +	.init =3D nf_conntrack_net_proto_sctp_init,
> +	.exit =3D nf_conntrack_net_proto_sctp_fini,
>  };
> =20
>  static int __init nf_conntrack_proto_sctp_init(void)
> @@ -803,9 +941,15 @@ static int __init nf_conntrack_proto_sctp_init(v=
oid)
>  		pr_err("nf_conntrack_l4proto_sctp6: protocol register failed\n");
>  		goto cleanup_sctp4;
>  	}
> -
> +	ret =3D register_pernet_subsys(&nf_conntrack_net_proto_sctp_ops);
> +	if (ret) {
> +		pr_err("nf_conntrack: sctp pernet subsys register failed\n");
> +		goto cleanup_sctp6;
> +	}
>  	return ret;
> =20
> + cleanup_sctp6:
> +	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp6);
>   cleanup_sctp4:
>  	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
>   out:
> @@ -814,6 +958,7 @@ static int __init nf_conntrack_proto_sctp_init(vo=
id)
> =20
>  static void __exit nf_conntrack_proto_sctp_fini(void)
>  {
> +	unregister_pernet_subsys(&nf_conntrack_net_proto_sctp_ops);
>  	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp6);
>  	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
>  }

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
