From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 02/17] netfilter: add namespace support for l4proto
Date: Thu, 24 May 2012 09:52:51 +0800
Message-ID: <4FBD9473.5050304@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com> <1336985547-31960-3-git-send-email-gaofeng@cn.fujitsu.com> <20120523102557.GB2836@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120523102557.GB2836@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8823=E6=97=A5 18:25, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Mon, May 14, 2012 at 04:52:12PM +0800, Gao feng wrote:
>> From: Gao feng <gaofeng@cn.fujitus.com>
>>
>> -nf_ct_(un)register_sysctl are changed to support net namespace,
>>  use (un)register_net_sysctl_table replaces (un)register_sysctl_path=
s.
>>  and in nf_ct_unregister_sysctl,kfree table only when users is 0.
>>
>> -Add the struct net as param of nf_conntrack_l4proto_(un)register.
>>  register or unregister the l4proto only when the net is init_net.
>>
>> -nf_conntrack_l4proto_register call init_net to initial the pernet
>>  data of l4proto.
>>
>> -nf_ct_l4proto_net is used to get the pernet data of l4proto.
>>
>> -use init_net as a param of nf_conntrack_l4proto_(un)register.
>>
>> Acked-by: Eric W. Biederman <ebiederm@xmission.com>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitus.com>
>> ---
>>  include/net/netfilter/nf_conntrack_l4proto.h   |   13 +-
>>  net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   18 +-
>>  net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   18 +-
>>  net/netfilter/nf_conntrack_proto.c             |  245 +++++++++++++=
+----------
>>  net/netfilter/nf_conntrack_proto_dccp.c        |   10 +-
>>  net/netfilter/nf_conntrack_proto_gre.c         |    6 +-
>>  net/netfilter/nf_conntrack_proto_sctp.c        |   10 +-
>>  net/netfilter/nf_conntrack_proto_udplite.c     |   10 +-
>>  8 files changed, 191 insertions(+), 139 deletions(-)
>>
>> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/=
net/netfilter/nf_conntrack_l4proto.h
>> index a90eab5..a93dcd5 100644
>> --- a/include/net/netfilter/nf_conntrack_l4proto.h
>> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
>> @@ -12,7 +12,7 @@
>>  #include <linux/netlink.h>
>>  #include <net/netlink.h>
>>  #include <net/netfilter/nf_conntrack.h>
>> -
>> +#include <net/netns/generic.h>
>=20
> Minor nitpick: make sure there's still one line between this structur=
e
> below and the include headers.

thanks! I will fix it.

>=20
>>  struct seq_file;
>> =20
>>  struct nf_conntrack_l4proto {
>> @@ -129,8 +129,15 @@ nf_ct_l4proto_find_get(u_int16_t l3proto, u_int=
8_t l4proto);
>>  extern void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p);
>> =20
>>  /* Protocol registration. */
>> -extern int nf_conntrack_l4proto_register(struct nf_conntrack_l4prot=
o *proto);
>> -extern void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4p=
roto *proto);
>> +extern int nf_conntrack_l4proto_register(struct net *net,
>> +					 struct nf_conntrack_l4proto *proto);
>> +extern void nf_conntrack_l4proto_unregister(struct net *net,
>> +					    struct nf_conntrack_l4proto *proto);
>> +
>> +extern int nf_ct_l4proto_register_sysctl(struct net *net,
>> +					 struct nf_conntrack_l4proto *l4proto);
>> +extern void nf_ct_l4proto_unregister_sysctl(struct net *net,
>> +					    struct nf_conntrack_l4proto *l4proto);
>> =20
>>  /* Generic netlink helpers */
>>  extern int nf_ct_port_tuple_to_nlattr(struct sk_buff *skb,
>> diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ip=
v4/netfilter/nf_conntrack_l3proto_ipv4.c
>> index 91747d4..46ec515 100644
>> --- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
>> +++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
>> @@ -391,19 +391,19 @@ static int __init nf_conntrack_l3proto_ipv4_in=
it(void)
>>  		return ret;
>>  	}
>> =20
>> -	ret =3D nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp4);
>> +	ret =3D nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4p=
roto_tcp4);
>>  	if (ret < 0) {
>>  		pr_err("nf_conntrack_ipv4: can't register tcp.\n");
>>  		goto cleanup_sockopt;
>>  	}
>> =20
>> -	ret =3D nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp4);
>> +	ret =3D nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4p=
roto_udp4);
>>  	if (ret < 0) {
>>  		pr_err("nf_conntrack_ipv4: can't register udp.\n");
>>  		goto cleanup_tcp;
>>  	}
>> =20
>> -	ret =3D nf_conntrack_l4proto_register(&nf_conntrack_l4proto_icmp);
>> +	ret =3D nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4p=
roto_icmp);
>>  	if (ret < 0) {
>>  		pr_err("nf_conntrack_ipv4: can't register icmp.\n");
>>  		goto cleanup_udp;
>> @@ -434,11 +434,11 @@ static int __init nf_conntrack_l3proto_ipv4_in=
it(void)
>>   cleanup_ipv4:
>>  	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
>>   cleanup_icmp:
>> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmp);
>> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_i=
cmp);
>>   cleanup_udp:
>> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp4);
>> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_u=
dp4);
>>   cleanup_tcp:
>> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
>> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_t=
cp4);
>>   cleanup_sockopt:
>>  	nf_unregister_sockopt(&so_getorigdst);
>>  	return ret;
>> @@ -452,9 +452,9 @@ static void __exit nf_conntrack_l3proto_ipv4_fin=
i(void)
>>  #endif
>>  	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_=
ops));
>>  	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
>> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmp);
>> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp4);
>> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
>> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_i=
cmp);
>> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_u=
dp4);
>> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_t=
cp4);
>>  	nf_unregister_sockopt(&so_getorigdst);
>>  }
>> =20
>> diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ip=
v6/netfilter/nf_conntrack_l3proto_ipv6.c
>> index fe925e4..55f379f 100644
>> --- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
>> +++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
>> @@ -341,19 +341,19 @@ static int __init nf_conntrack_l3proto_ipv6_in=
it(void)
>>  	need_conntrack();
>>  	nf_defrag_ipv6_enable();
>> =20
>> -	ret =3D nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp6);
>> +	ret =3D nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4p=
roto_tcp6);
>>  	if (ret < 0) {
>>  		pr_err("nf_conntrack_ipv6: can't register tcp.\n");
>>  		return ret;
>>  	}
>> =20
>> -	ret =3D nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp6);
>> +	ret =3D nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4p=
roto_udp6);
>>  	if (ret < 0) {
>>  		pr_err("nf_conntrack_ipv6: can't register udp.\n");
>>  		goto cleanup_tcp;
>>  	}
>> =20
>> -	ret =3D nf_conntrack_l4proto_register(&nf_conntrack_l4proto_icmpv6=
);
>> +	ret =3D nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4p=
roto_icmpv6);
>>  	if (ret < 0) {
>>  		pr_err("nf_conntrack_ipv6: can't register icmpv6.\n");
>>  		goto cleanup_udp;
>> @@ -377,11 +377,11 @@ static int __init nf_conntrack_l3proto_ipv6_in=
it(void)
>>   cleanup_ipv6:
>>  	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
>>   cleanup_icmpv6:
>> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
>> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_i=
cmpv6);
>>   cleanup_udp:
>> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
>> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_u=
dp6);
>>   cleanup_tcp:
>> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
>> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_t=
cp6);
>>  	return ret;
>>  }
>> =20
>> @@ -390,9 +390,9 @@ static void __exit nf_conntrack_l3proto_ipv6_fin=
i(void)
>>  	synchronize_net();
>>  	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_=
ops));
>>  	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
>> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
>> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
>> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
>> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_i=
cmpv6);
>> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_u=
dp6);
>> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_t=
cp6);
>>  }
>> =20
>>  module_init(nf_conntrack_l3proto_ipv6_init);
>> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_c=
onntrack_proto.c
>> index 8b631b0..6d68727 100644
>> --- a/net/netfilter/nf_conntrack_proto.c
>> +++ b/net/netfilter/nf_conntrack_proto.c
>> @@ -35,30 +35,39 @@ EXPORT_SYMBOL_GPL(nf_ct_l3protos);
>>  static DEFINE_MUTEX(nf_ct_proto_mutex);
>> =20
>>  #ifdef CONFIG_SYSCTL
>> -static int
>> -nf_ct_register_sysctl(struct ctl_table_header **header, const char =
*path,
>> -		      struct ctl_table *table, unsigned int *users)
>> +int
>> +nf_ct_register_sysctl(struct net *net,
>> +		      struct ctl_table_header **header,
>> +		      const char *path,
>> +		      struct ctl_table *table,
>> +		      unsigned int *users)
>>  {
>>  	if (*header =3D=3D NULL) {
>> -		*header =3D register_net_sysctl(&init_net, path, table);
>> +		*header =3D register_net_sysctl(net, path, table);
>>  		if (*header =3D=3D NULL)
>>  			return -ENOMEM;
>>  	}
>>  	if (users !=3D NULL)
>>  		(*users)++;
>> +
>>  	return 0;
>>  }
>> +EXPORT_SYMBOL_GPL(nf_ct_register_sysctl);
>=20
> I don't see why we need to export nf_ct_register_sysctl. I think this
> is a left-over from the previous patchset.

I miss it...
thanks

>=20
>> -static void
>> +void
>>  nf_ct_unregister_sysctl(struct ctl_table_header **header,
>> -			struct ctl_table *table, unsigned int *users)
>> +			struct ctl_table **table,
>> +			unsigned int *users)
>>  {
>>  	if (users !=3D NULL && --*users > 0)
>>  		return;
>> =20
>>  	unregister_net_sysctl_table(*header);
>> +	kfree(*table);
>>  	*header =3D NULL;
>> +	*table =3D NULL;
>>  }
>> +EXPORT_SYMBOL_GPL(nf_ct_unregister_sysctl);
>=20
> Same thing. I don't find any external user of this new exported
> function in your entire patchset.
>=20
> You have to fix this.
>=20
>>  #endif
>> =20
>>  struct nf_conntrack_l4proto *
>> @@ -167,7 +176,8 @@ static int nf_ct_l3proto_register_sysctl(struct =
nf_conntrack_l3proto *l3proto)
>> =20
>>  #ifdef CONFIG_SYSCTL
>>  	if (l3proto->ctl_table !=3D NULL) {
>> -		err =3D nf_ct_register_sysctl(&l3proto->ctl_table_header,
>> +		err =3D nf_ct_register_sysctl(&init_net,
>> +					    &l3proto->ctl_table_header,
>>  					    l3proto->ctl_table_path,
>>  					    l3proto->ctl_table, NULL);
>>  	}
>> @@ -180,7 +190,7 @@ static void nf_ct_l3proto_unregister_sysctl(stru=
ct nf_conntrack_l3proto *l3proto
>>  #ifdef CONFIG_SYSCTL
>>  	if (l3proto->ctl_table_header !=3D NULL)
>>  		nf_ct_unregister_sysctl(&l3proto->ctl_table_header,
>> -					l3proto->ctl_table, NULL);
>> +					&l3proto->ctl_table, NULL);
>>  #endif
>>  }
>> =20
>> @@ -243,137 +253,172 @@ void nf_conntrack_l3proto_unregister(struct =
nf_conntrack_l3proto *proto)
>>  }
>>  EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
>> =20
>> -static int nf_ct_l4proto_register_sysctl(struct nf_conntrack_l4prot=
o *l4proto)
>> +static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
>> +					      struct nf_conntrack_l4proto *l4proto)
>>  {
>> -	int err =3D 0;
>> +	if (l4proto->net_id)
>> +		return net_generic(net, *l4proto->net_id);
>> +	else
>> +		return NULL;
>> +}
>> =20
>> +int nf_ct_l4proto_register_sysctl(struct net *net,
>> +				  struct nf_conntrack_l4proto *l4proto)
>> +{
>> +	int err =3D 0;
>> +	struct nf_proto_net *pn =3D nf_ct_l4proto_net(net, l4proto);
>> +	if (pn =3D=3D NULL)
>> +		return 0;
>>  #ifdef CONFIG_SYSCTL
>> -	if (l4proto->ctl_table !=3D NULL) {
>> -		err =3D nf_ct_register_sysctl(l4proto->ctl_table_header,
>> +	if (pn->ctl_table !=3D NULL) {
>> +		err =3D nf_ct_register_sysctl(net,
>> +					    &pn->ctl_table_header,
>>  					    "net/netfilter",
>> -					    l4proto->ctl_table,
>> -					    l4proto->ctl_table_users);
>> -		if (err < 0)
>> +					    pn->ctl_table,
>> +					    &pn->users);
>> +		if (err < 0) {
>> +			kfree(pn->ctl_table);
>> +			pn->ctl_table =3D NULL;
>                                ^^^^^^^^^^^
> Do you really need to set this above to NULL? Is there any existing
> bug trap? If not, it's superfluous, please, remove it.
>=20
yes,l4proto_tcp(udp,icmp)'s ctl_table is stored in netns_ct.proto,
so when we register l4proto_tcp's sysctl failed,ctl_table will still
point to the kfreed memory. this will cause panic the next
time we register l4proto_tcp's sysctl.

>>  			goto out;
>> +		}
>>  	}
>>  #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
>> -	if (l4proto->ctl_compat_table !=3D NULL) {
>> -		err =3D nf_ct_register_sysctl(&l4proto->ctl_compat_table_header,
>> +	if (l4proto->compat && pn->ctl_compat_table !=3D NULL) {
>> +		err =3D nf_ct_register_sysctl(net,
>> +					    &pn->ctl_compat_header,
>>  					    "net/ipv4/netfilter",
>> -					    l4proto->ctl_compat_table, NULL);
>> +					    pn->ctl_compat_table,
>> +					    NULL);
>>  		if (err =3D=3D 0)
>>  			goto out;
>> -		nf_ct_unregister_sysctl(l4proto->ctl_table_header,
>> -					l4proto->ctl_table,
>> -					l4proto->ctl_table_users);
>> +
>> +		kfree(pn->ctl_compat_table);
>> +		pn->ctl_compat_table =3D NULL;
>> +		nf_ct_unregister_sysctl(&pn->ctl_table_header,
>> +					&pn->ctl_table,
>> +					&pn->users);
>>  	}
>>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
>>  out:
>>  #endif /* CONFIG_SYSCTL */
>>  	return err;
>>  }
>> +EXPORT_SYMBOL_GPL(nf_ct_l4proto_register_sysctl);
>> =20
>> -static void nf_ct_l4proto_unregister_sysctl(struct nf_conntrack_l4p=
roto *l4proto)
>> +void nf_ct_l4proto_unregister_sysctl(struct net *net,
>> +				     struct nf_conntrack_l4proto *l4proto)
>>  {
>> +	struct nf_proto_net *pn =3D nf_ct_l4proto_net(net, l4proto);
>> +	if (pn =3D=3D NULL)
>> +		return;
>>  #ifdef CONFIG_SYSCTL
>> -	if (l4proto->ctl_table_header !=3D NULL &&
>> -	    *l4proto->ctl_table_header !=3D NULL)
>> -		nf_ct_unregister_sysctl(l4proto->ctl_table_header,
>> -					l4proto->ctl_table,
>> -					l4proto->ctl_table_users);
>> +	if (pn->ctl_table_header !=3D NULL)
>> +		nf_ct_unregister_sysctl(&pn->ctl_table_header,
>> +					&pn->ctl_table,
>> +					&pn->users);
>> +
>>  #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
>> -	if (l4proto->ctl_compat_table_header !=3D NULL)
>> -		nf_ct_unregister_sysctl(&l4proto->ctl_compat_table_header,
>> -					l4proto->ctl_compat_table, NULL);
>> +	if (l4proto->compat && pn->ctl_compat_header !=3D NULL)
>> +		nf_ct_unregister_sysctl(&pn->ctl_compat_header,
>> +					&pn->ctl_compat_table,
>> +					NULL);
>>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
>> +#else
>> +	pn->users--;
>>  #endif /* CONFIG_SYSCTL */
>>  }
>> +EXPORT_SYMBOL_GPL(nf_ct_l4proto_unregister_sysctl);
>> =20
>>  /* FIXME: Allow NULL functions and sub in pointers to generic for
>>     them. --RR */
>> -int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *l4pr=
oto)
>> +int nf_conntrack_l4proto_register(struct net *net,
>> +				  struct nf_conntrack_l4proto *l4proto)
>>  {
>>  	int ret =3D 0;
>=20
> Minor nitpick: you save this amount of edits in this function that
> result from the extra tabbing by moving all ...
>=20
> if (net =3D=3D &init_net) {
>     ... this code ...
> }
>=20
> into some new static int nf_conntrack_l4proto_register_net(...) that
> will be called by nf_conntrack_l4proto_register.
>=20
> It will result more maintainable code. We still stick to 80-chars
> columns, saving that extra tabbing makes the code more readable.
>=20

Yes,it will be more readable,I will do it.

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
