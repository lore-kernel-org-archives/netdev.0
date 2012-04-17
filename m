From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 03/12] netfilter: generic proto sysctl support for net
 namespace
Date: Tue, 17 Apr 2012 18:22:42 +0800
Message-ID: <4F8D4472.6080606@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com> <1334631383-12326-4-git-send-email-gaofeng@cn.fujitsu.com> <20120417085813.GD2100@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120417085813.GD2100@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B404=E6=9C=8817=E6=97=A5 16:58, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Tue, Apr 17, 2012 at 10:56:14AM +0800, Gao feng wrote:
>> register the generic proto's sysctl in pernet_operations.init.
>> and use net->ct.proto.sysctl_generic_timeout replaces nf_ct_generic_=
timeout.
>>
>> in the after patch,the timeout_nlattr_to_obj will be modified too.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  net/netfilter/nf_conntrack_core.c          |    6 ++
>>  net/netfilter/nf_conntrack_proto_generic.c |   93 +++++++++++++++++=
++++++++---
>>  2 files changed, 91 insertions(+), 8 deletions(-)
>>
>> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_co=
nntrack_core.c
>> index 729f157..bf11dd6 100644
>> --- a/net/netfilter/nf_conntrack_core.c
>> +++ b/net/netfilter/nf_conntrack_core.c
>> @@ -1358,6 +1358,7 @@ static void nf_conntrack_cleanup_net(struct ne=
t *net)
>>  	nf_conntrack_tstamp_fini(net);
>>  	nf_conntrack_acct_fini(net);
>>  	nf_conntrack_expect_fini(net);
>> +	nf_conntrack_proto_generic_net_fini(net);
>>  	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
>>  	kfree(net->ct.slabname);
>>  	free_percpu(net->ct.stat);
>> @@ -1573,6 +1574,9 @@ static int nf_conntrack_init_net(struct net *n=
et)
>>  		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
>>  		goto err_hash;
>>  	}
>> +	ret =3D nf_conntrack_proto_generic_net_init(net);
>> +	if (ret < 0)
>> +		goto err_generic;
>>  	ret =3D nf_conntrack_expect_init(net);
>>  	if (ret < 0)
>>  		goto err_expect;
>> @@ -1600,6 +1604,8 @@ err_tstamp:
>>  err_acct:
>>  	nf_conntrack_expect_fini(net);
>>  err_expect:
>> +	nf_conntrack_proto_generic_net_fini(net);
>> +err_generic:
>>  	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
>>  err_hash:
>>  	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
>> diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfil=
ter/nf_conntrack_proto_generic.c
>> index 835e24c..0d4545b 100644
>> --- a/net/netfilter/nf_conntrack_proto_generic.c
>> +++ b/net/netfilter/nf_conntrack_proto_generic.c
>> @@ -42,7 +42,7 @@ static int generic_print_tuple(struct seq_file *s,
>> =20
>>  static unsigned int *generic_get_timeouts(struct net *net)
>>  {
>> -	return &nf_ct_generic_timeout;
>> +	return &(net->ct.proto.sysctl_generic_timeout);
>>  }
>> =20
>>  /* Returns verdict for packet, or -1 for invalid. */
>> @@ -105,11 +105,10 @@ generic_timeout_nla_policy[CTA_TIMEOUT_GENERIC=
_MAX+1] =3D {
>>  #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
>> =20
>>  #ifdef CONFIG_SYSCTL
>> -static struct ctl_table_header *generic_sysctl_header;
>>  static struct ctl_table generic_sysctl_table[] =3D {
>>  	{
>>  		.procname	=3D "nf_conntrack_generic_timeout",
>> -		.data		=3D &nf_ct_generic_timeout,
>> +		.data		=3D &init_net.ct.proto.sysctl_generic_timeout,
>>  		.maxlen		=3D sizeof(unsigned int),
>>  		.mode		=3D 0644,
>>  		.proc_handler	=3D proc_dointvec_jiffies,
>> @@ -120,7 +119,7 @@ static struct ctl_table generic_sysctl_table[] =3D=
 {
>>  static struct ctl_table generic_compat_sysctl_table[] =3D {
>>  	{
>>  		.procname	=3D "ip_conntrack_generic_timeout",
>> -		.data		=3D &nf_ct_generic_timeout,
>> +		.data		=3D &init_net.ct.proto.sysctl_generic_timeout,
>>  		.maxlen		=3D sizeof(unsigned int),
>>  		.mode		=3D 0644,
>>  		.proc_handler	=3D proc_dointvec_jiffies,
>> @@ -150,11 +149,89 @@ struct nf_conntrack_l4proto nf_conntrack_l4pro=
to_generic __read_mostly =3D
>>  		.nla_policy	=3D generic_timeout_nla_policy,
>>  	},
>>  #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
>> +};
>> +
>> +int nf_conntrack_proto_generic_net_init(struct net *net)
>=20
> Please, check int nf_conntrack_ecache_init(struct net *net) for
> instance on how we're doing the per-net registration of netfilter
> modules.


nf_conntrack_l4proto_generic is registered when loading nf_conntrack mo=
dule.
so we should register sysctl in nf_conntrack_init_net.

I don't know what's wrong here...

>=20
> Basically, we register the module only once for the init_net case.
> Then, we register one sysctl per-net.
>=20
>> +{
>> +	struct ctl_table *table;
>> +	int ret =3D 0;
>>  #ifdef CONFIG_SYSCTL
>> -	.ctl_table_header	=3D &generic_sysctl_header,
>> -	.ctl_table		=3D generic_sysctl_table,
>>  #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
>> -	.ctl_compat_table	=3D generic_compat_sysctl_table,
>> +	struct ctl_table *compat_table;
>>  #endif
>>  #endif
>> -};
>> +	net->ct.proto.sysctl_generic_timeout =3D nf_ct_generic_timeout;
>> +#ifdef CONFIG_SYSCTL
>> +	table =3D kmemdup(generic_sysctl_table,
>> +			sizeof(generic_sysctl_table),
>> +			GFP_KERNEL);
>> +	if (!table)
>> +		return -ENOMEM;
>> +=09
>> +	table[0].data =3D &net->ct.proto.sysctl_generic_timeout;
>> +
>> +	ret =3D nf_ct_register_net_sysctl(net,
>> +					&net->ct.proto.generic_sysctl_header,
>> +					nf_net_netfilter_sysctl_path,
>> +					table,
>> +					NULL);
>> +	if (ret < 0) {
>> +		printk(KERN_ERR=20
>> +			"nf_conntrack_proto_generic:"
>> +			" can't register to sysctl.\n");
>> +		kfree(table);
>> +		return ret;
>> +	}
>> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
>> +	compat_table =3D kmemdup(generic_compat_sysctl_table,
>> +			       sizeof(generic_compat_sysctl_table),
>> +			       GFP_KERNEL);
>> +	if (!compat_table) {
>> +		ret =3D -ENOMEM;
>> +		goto out_compat;
>> +	}
>> +	compat_table[0].data =3D &net->ct.proto.sysctl_generic_timeout;
>> +	ret =3D nf_ct_register_net_sysctl(net,
>> +					&net->ct.proto.generic_compat_header,
>> +					nf_net_ipv4_netfilter_sysctl_path,
>> +					compat_table,
>> +					NULL);
>> +	if (ret < 0) {
>> +		printk(KERN_ERR=20
>> +			"nf_conntrack_proto_generic:"
>> +			" can't register to compat sysctl.\n");
>> +		goto out_compat_register;
>> +	}
>> +#endif
>> +	return 0;
>> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
>> +out_compat_register:
>> +	kfree(compat_table);
>> +out_compat:
>> +	nf_ct_unregister_net_sysctl(&net->ct.proto.generic_sysctl_header,
>> +				    table,
>> +				    NULL);
>> +#endif
>> +#endif
>> +	return ret;
>> +}
>> +
>> +void nf_conntrack_proto_generic_net_fini(struct net *net)
>> +{
>> +#ifdef CONFIG_SYSCTL
>> +	struct ctl_table *table;
>> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
>> +	struct ctl_table *compat_table;
>> +#endif
>> +	table =3D net->ct.proto.generic_sysctl_header->ctl_table_arg;
>> +	nf_ct_unregister_net_sysctl(&net->ct.proto.generic_sysctl_header,
>> +				    table,
>> +				    NULL);
>> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
>> +	compat_table =3D net->ct.proto.generic_compat_header->ctl_table_ar=
g;
>> +	nf_ct_unregister_net_sysctl(&net->ct.proto.generic_compat_header,
>> +				    compat_table,
>> +				    NULL);
>> +#endif
>> +#endif
>> +}
>> --=20
>> 1.7.7.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
