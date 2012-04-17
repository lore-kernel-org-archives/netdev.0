From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 02/12] netfilter: don't register sysctl when register
 proto
Date: Tue, 17 Apr 2012 18:25:57 +0800
Message-ID: <4F8D4535.1040509@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com> <1334631383-12326-3-git-send-email-gaofeng@cn.fujitsu.com> <20120417085617.GC2100@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120417085617.GC2100@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B404=E6=9C=8817=E6=97=A5 16:56, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Tue, Apr 17, 2012 at 10:56:13AM +0800, Gao feng wrote:
>> delete nf_ct_l[3,4]proto_register_sysctl when register l[3,4]proto.
>> and add nf_ct_register_net_sysctl,nf_ct_unregister_net_sysctl to
>> register the sysctl for net namespace.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  net/netfilter/nf_conntrack_proto.c |  109 +++++--------------------=
-----------
>>  1 files changed, 15 insertions(+), 94 deletions(-)
>>
>> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_c=
onntrack_proto.c
>> index be3da2c..207cdd8 100644
>> --- a/net/netfilter/nf_conntrack_proto.c
>> +++ b/net/netfilter/nf_conntrack_proto.c
>> @@ -35,12 +35,15 @@ EXPORT_SYMBOL_GPL(nf_ct_l3protos);
>>  static DEFINE_MUTEX(nf_ct_proto_mutex);
>> =20
>>  #ifdef CONFIG_SYSCTL
>> -static int
>> -nf_ct_register_sysctl(struct ctl_table_header **header, struct ctl_=
path *path,
>> -		      struct ctl_table *table, unsigned int *users)
>> +int
>> +nf_ct_register_net_sysctl(struct net *net,=20
>> +			  struct ctl_table_header **header,
>> +			  struct ctl_path *path,
>> +			  struct ctl_table *table,
>> +			  unsigned int *users)
>=20
> Please, don't rename this function. Just add the *net parameter
> instead.
>=20

OK,i will modify it.

>>  {
>>  	if (*header =3D=3D NULL) {
>> -		*header =3D register_sysctl_paths(path, table);
>> +		*header =3D register_net_sysctl_table(net, path, table);
>>  		if (*header =3D=3D NULL)
>>  			return -ENOMEM;
>>  	}
>> @@ -48,17 +51,21 @@ nf_ct_register_sysctl(struct ctl_table_header **=
header, struct ctl_path *path,
>>  		(*users)++;
>>  	return 0;
>>  }
>> +EXPORT_SYMBOL_GPL(nf_ct_register_net_sysctl);
>> =20
>> -static void
>> -nf_ct_unregister_sysctl(struct ctl_table_header **header,
>> -			struct ctl_table *table, unsigned int *users)
>> +void
>> +nf_ct_unregister_net_sysctl(struct ctl_table_header **header,
>> +			    struct ctl_table *table,
>> +			    unsigned int *users)
>>  {
>>  	if (users !=3D NULL && --*users > 0)
>>  		return;
>> =20
>>  	unregister_sysctl_table(*header);
>> +	kfree(table);
>>  	*header =3D NULL;
>>  }
>> +EXPORT_SYMBOL_GPL(nf_ct_unregister_net_sysctl);
>>  #endif
>> =20
>>  struct nf_conntrack_l4proto *
>> @@ -161,29 +168,6 @@ static int kill_l4proto(struct nf_conn *i, void=
 *data)
>>  	       nf_ct_l3num(i) =3D=3D l4proto->l3proto;
>>  }
>> =20
>> -static int nf_ct_l3proto_register_sysctl(struct nf_conntrack_l3prot=
o *l3proto)
>> -{
>> -	int err =3D 0;
>> -
>> -#ifdef CONFIG_SYSCTL
>> -	if (l3proto->ctl_table !=3D NULL) {
>> -		err =3D nf_ct_register_sysctl(&l3proto->ctl_table_header,
>> -					    l3proto->ctl_table_path,
>> -					    l3proto->ctl_table, NULL);
>> -	}
>> -#endif
>> -	return err;
>> -}
>> -
>> -static void nf_ct_l3proto_unregister_sysctl(struct nf_conntrack_l3p=
roto *l3proto)
>> -{
>> -#ifdef CONFIG_SYSCTL
>> -	if (l3proto->ctl_table_header !=3D NULL)
>> -		nf_ct_unregister_sysctl(&l3proto->ctl_table_header,
>> -					l3proto->ctl_table, NULL);
>> -#endif
>> -}
>> -
>>  int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *prot=
o)
>>  {
>>  	int ret =3D 0;
>> @@ -203,10 +187,6 @@ int nf_conntrack_l3proto_register(struct nf_con=
ntrack_l3proto *proto)
>>  		goto out_unlock;
>>  	}
>> =20
>> -	ret =3D nf_ct_l3proto_register_sysctl(proto);
>> -	if (ret < 0)
>> -		goto out_unlock;
>> -
>>  	if (proto->nlattr_tuple_size)
>>  		proto->nla_size =3D 3 * proto->nlattr_tuple_size();
>> =20
>> @@ -230,7 +210,6 @@ void nf_conntrack_l3proto_unregister(struct nf_c=
onntrack_l3proto *proto)
>>  					 ) !=3D proto);
>>  	rcu_assign_pointer(nf_ct_l3protos[proto->l3proto],
>>  			   &nf_conntrack_l3proto_generic);
>> -	nf_ct_l3proto_unregister_sysctl(proto);
>>  	mutex_unlock(&nf_ct_proto_mutex);
>> =20
>>  	synchronize_rcu();
>> @@ -243,52 +222,6 @@ void nf_conntrack_l3proto_unregister(struct nf_=
conntrack_l3proto *proto)
>>  }
>>  EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
>> =20
>> -static int nf_ct_l4proto_register_sysctl(struct nf_conntrack_l4prot=
o *l4proto)
>> -{
>> -	int err =3D 0;
>> -
>> -#ifdef CONFIG_SYSCTL
>> -	if (l4proto->ctl_table !=3D NULL) {
>> -		err =3D nf_ct_register_sysctl(l4proto->ctl_table_header,
>> -					    nf_net_netfilter_sysctl_path,
>> -					    l4proto->ctl_table,
>> -					    l4proto->ctl_table_users);
>> -		if (err < 0)
>> -			goto out;
>> -	}
>> -#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
>> -	if (l4proto->ctl_compat_table !=3D NULL) {
>> -		err =3D nf_ct_register_sysctl(&l4proto->ctl_compat_table_header,
>> -					    nf_net_ipv4_netfilter_sysctl_path,
>> -					    l4proto->ctl_compat_table, NULL);
>> -		if (err =3D=3D 0)
>> -			goto out;
>> -		nf_ct_unregister_sysctl(l4proto->ctl_table_header,
>> -					l4proto->ctl_table,
>> -					l4proto->ctl_table_users);
>> -	}
>> -#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
>> -out:
>> -#endif /* CONFIG_SYSCTL */
>> -	return err;
>> -}
>> -
>> -static void nf_ct_l4proto_unregister_sysctl(struct nf_conntrack_l4p=
roto *l4proto)
>> -{
>> -#ifdef CONFIG_SYSCTL
>> -	if (l4proto->ctl_table_header !=3D NULL &&
>> -	    *l4proto->ctl_table_header !=3D NULL)
>> -		nf_ct_unregister_sysctl(l4proto->ctl_table_header,
>> -					l4proto->ctl_table,
>> -					l4proto->ctl_table_users);
>> -#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
>> -	if (l4proto->ctl_compat_table_header !=3D NULL)
>> -		nf_ct_unregister_sysctl(&l4proto->ctl_compat_table_header,
>> -					l4proto->ctl_compat_table, NULL);
>> -#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
>> -#endif /* CONFIG_SYSCTL */
>> -}
>> -
>=20
> Where did this function go?


nf_ct_l4proto_unregister_sysctl just register sysctl,and we move this l=
ogic
to the pernet_operations.init, so this function has no use.

>=20
>>  /* FIXME: Allow NULL functions and sub in pointers to generic for
>>     them. --RR */
>>  int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *l4pr=
oto)
>> @@ -333,10 +266,6 @@ int nf_conntrack_l4proto_register(struct nf_con=
ntrack_l4proto *l4proto)
>>  		goto out_unlock;
>>  	}
>> =20
>> -	ret =3D nf_ct_l4proto_register_sysctl(l4proto);
>> -	if (ret < 0)
>> -		goto out_unlock;
>> -
>>  	l4proto->nla_size =3D 0;
>>  	if (l4proto->nlattr_size)
>>  		l4proto->nla_size +=3D l4proto->nlattr_size();
>> @@ -365,7 +294,6 @@ void nf_conntrack_l4proto_unregister(struct nf_c=
onntrack_l4proto *l4proto)
>>  			) !=3D l4proto);
>>  	rcu_assign_pointer(nf_ct_protos[l4proto->l3proto][l4proto->l4proto=
],
>>  			   &nf_conntrack_l4proto_generic);
>> -	nf_ct_l4proto_unregister_sysctl(l4proto);
>>  	mutex_unlock(&nf_ct_proto_mutex);
>> =20
>>  	synchronize_rcu();
>> @@ -380,12 +308,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregist=
er);
>> =20
>>  int nf_conntrack_proto_init(void)
>>  {
>> -	unsigned int i;
>> -	int err;
>> -
>> -	err =3D nf_ct_l4proto_register_sysctl(&nf_conntrack_l4proto_generi=
c);
>> -	if (err < 0)
>> -		return err;
>> +	unsigned int i;=09
>> =20
>>  	for (i =3D 0; i < AF_MAX; i++)
>>  		rcu_assign_pointer(nf_ct_l3protos[i],
>> @@ -397,8 +320,6 @@ void nf_conntrack_proto_fini(void)
>>  {
>>  	unsigned int i;
>> =20
>> -	nf_ct_l4proto_unregister_sysctl(&nf_conntrack_l4proto_generic);
>> -
>>  	/* free l3proto protocol tables */
>>  	for (i =3D 0; i < PF_MAX; i++)
>>  		kfree(nf_ct_protos[i]);
>> --=20
>> 1.7.7.6
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
