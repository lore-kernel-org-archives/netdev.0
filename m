From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 03/17] netfilter: add namespace support for l3proto
Date: Thu, 24 May 2012 09:58:02 +0800
Message-ID: <4FBD95AA.8070301@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com> <1336985547-31960-4-git-send-email-gaofeng@cn.fujitsu.com> <20120523102910.GC2836@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:34250 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751167Ab2EXB5c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 21:57:32 -0400
In-Reply-To: <20120523102910.GC2836@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8823=E6=97=A5 18:29, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Mon, May 14, 2012 at 04:52:13PM +0800, Gao feng wrote:
>> -Add the struct net as param of nf_conntrack_l3proto_(un)register.
>>  register or unregister the l3proto only when the net is init_net.
>>
>> -The new struct nf_ip_net is used to store the sysctl header and dat=
a
>>  of l3proto_ipv4,l4proto_tcp(6),l4proto_udp(6),l4proto_icmp(v6).
>>  because the protos such tcp and tcp6 use the same data,so making
>>  nf_ip_net as a field of netns_ct is the easiest way to manager it.
>>
>> -nf_ct_l3proto_register_sysctl call init_net to initial the pernet d=
ata
>>  of l3proto.
>>
>> -nf_ct_l3proto_net is used to get the pernet data of l3proto.
>>
>> -export nf_conntrack_l3proto_(un)register
>>
>> -use init_net as param of nf_conntrack_l3proto_(un)register.
>>
>> Acked-by: Eric W. Biederman <ebiederm@xmission.com>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  include/net/netfilter/nf_conntrack_l3proto.h   |    6 +-
>>  include/net/netns/conntrack.h                  |    8 ++
>>  net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    6 +-
>>  net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    6 +-
>>  net/netfilter/nf_conntrack_proto.c             |  127 +++++++++++++=
++---------
>>  5 files changed, 97 insertions(+), 56 deletions(-)
>>
>> diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/=
net/netfilter/nf_conntrack_l3proto.h
>> index 9766005..d6df8c7 100644
>> --- a/include/net/netfilter/nf_conntrack_l3proto.h
>> +++ b/include/net/netfilter/nf_conntrack_l3proto.h
>> @@ -79,8 +79,10 @@ struct nf_conntrack_l3proto {
>>  extern struct nf_conntrack_l3proto __rcu *nf_ct_l3protos[AF_MAX];
>> =20
>>  /* Protocol registration. */
>> -extern int nf_conntrack_l3proto_register(struct nf_conntrack_l3prot=
o *proto);
>> -extern void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3p=
roto *proto);
>> +extern int nf_conntrack_l3proto_register(struct net *net,
>> +					 struct nf_conntrack_l3proto *proto);
>> +extern void nf_conntrack_l3proto_unregister(struct net *net,
>> +					    struct nf_conntrack_l3proto *proto);
>>  extern struct nf_conntrack_l3proto *nf_ct_l3proto_find_get(u_int16_=
t l3proto);
>>  extern void nf_ct_l3proto_put(struct nf_conntrack_l3proto *p);
>> =20
>> diff --git a/include/net/netns/conntrack.h b/include/net/netns/connt=
rack.h
>> index 1f53038..94992e9 100644
>> --- a/include/net/netns/conntrack.h
>> +++ b/include/net/netns/conntrack.h
>> @@ -20,6 +20,13 @@ struct nf_proto_net {
>>  	unsigned int		users;
>>  };
>> =20
>> +struct nf_ip_net {
>> +#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMP=
AT)
>> +	struct ctl_table_header *ctl_table_header;
>> +	struct ctl_table	*ctl_table;
>> +#endif
>> +};
>> +
>>  struct netns_ct {
>>  	atomic_t		count;
>>  	unsigned int		expect_count;
>> @@ -40,6 +47,7 @@ struct netns_ct {
>>  	unsigned int		sysctl_log_invalid; /* Log invalid packets */
>>  	int			sysctl_auto_assign_helper;
>>  	bool			auto_assign_helper_warned;
>> +	struct nf_ip_net	proto;
>                                 ^^^^^
> please, rename this to something like nf_ct_proto.

Get it ;)

>=20
>>  #ifdef CONFIG_SYSCTL
>>  	struct ctl_table_header	*sysctl_header;
>>  	struct ctl_table_header	*acct_sysctl_header;
>> diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ip=
v4/netfilter/nf_conntrack_l3proto_ipv4.c
>> index 46ec515..0c0fb90 100644
>> --- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
>> +++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
>> @@ -409,7 +409,7 @@ static int __init nf_conntrack_l3proto_ipv4_init=
(void)
>>  		goto cleanup_udp;
>>  	}
>> =20
>> -	ret =3D nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv4);
>> +	ret =3D nf_conntrack_l3proto_register(&init_net, &nf_conntrack_l3p=
roto_ipv4);
>>  	if (ret < 0) {
>>  		pr_err("nf_conntrack_ipv4: can't register ipv4\n");
>>  		goto cleanup_icmp;
>> @@ -432,7 +432,7 @@ static int __init nf_conntrack_l3proto_ipv4_init=
(void)
>>  	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_=
ops));
>>  #endif
>>   cleanup_ipv4:
>> -	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
>> +	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_i=
pv4);
>>   cleanup_icmp:
>>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_i=
cmp);
>>   cleanup_udp:
>> @@ -451,7 +451,7 @@ static void __exit nf_conntrack_l3proto_ipv4_fin=
i(void)
>>  	nf_conntrack_ipv4_compat_fini();
>>  #endif
>>  	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_=
ops));
>> -	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
>> +	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_i=
pv4);
>>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_i=
cmp);
>>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_u=
dp4);
>>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_t=
cp4);
>> diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ip=
v6/netfilter/nf_conntrack_l3proto_ipv6.c
>> index 55f379f..6cfbe7b 100644
>> --- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
>> +++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
>> @@ -359,7 +359,7 @@ static int __init nf_conntrack_l3proto_ipv6_init=
(void)
>>  		goto cleanup_udp;
>>  	}
>> =20
>> -	ret =3D nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv6);
>> +	ret =3D nf_conntrack_l3proto_register(&init_net, &nf_conntrack_l3p=
roto_ipv6);
>>  	if (ret < 0) {
>>  		pr_err("nf_conntrack_ipv6: can't register ipv6\n");
>>  		goto cleanup_icmpv6;
>> @@ -375,7 +375,7 @@ static int __init nf_conntrack_l3proto_ipv6_init=
(void)
>>  	return ret;
>> =20
>>   cleanup_ipv6:
>> -	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
>> +	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_i=
pv6);
>>   cleanup_icmpv6:
>>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_i=
cmpv6);
>>   cleanup_udp:
>> @@ -389,7 +389,7 @@ static void __exit nf_conntrack_l3proto_ipv6_fin=
i(void)
>>  {
>>  	synchronize_net();
>>  	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_=
ops));
>> -	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
>> +	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_i=
pv6);
>>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_i=
cmpv6);
>>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_u=
dp6);
>>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_t=
cp6);
>> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_c=
onntrack_proto.c
>> index 6d68727..7ee6653 100644
>> --- a/net/netfilter/nf_conntrack_proto.c
>> +++ b/net/netfilter/nf_conntrack_proto.c
>> @@ -170,85 +170,116 @@ static int kill_l4proto(struct nf_conn *i, vo=
id *data)
>>  	       nf_ct_l3num(i) =3D=3D l4proto->l3proto;
>>  }
>> =20
>> -static int nf_ct_l3proto_register_sysctl(struct nf_conntrack_l3prot=
o *l3proto)
>> +static struct nf_ip_net *nf_ct_l3proto_net(struct net *net,
>> +					   struct nf_conntrack_l3proto *l3proto)
>> +{
>> +	if (l3proto->l3proto =3D=3D PF_INET)
>> +		return &net->ct.proto;
>> +	else
>> +		return NULL;
>> +}
>> +
>> +static int nf_ct_l3proto_register_sysctl(struct net *net,
>> +					 struct nf_conntrack_l3proto *l3proto)
>>  {
>>  	int err =3D 0;
>> +	struct nf_ip_net *in =3D nf_ct_l3proto_net(net, l3proto);
>> =20
>> -#ifdef CONFIG_SYSCTL
>> -	if (l3proto->ctl_table !=3D NULL) {
>> -		err =3D nf_ct_register_sysctl(&init_net,
>> -					    &l3proto->ctl_table_header,
>> +	if (in =3D=3D NULL)
>> +		return 0;
>=20
> Under what circunstances that in be NULL?

Because l3proto_ipv6 doesn't need sysctl,so l3proto_ipv6's nf_ip_net is=
 NULL,
please see function nf_ct_l3proto_net above.

>=20
>> +
>> +#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMP=
AT)
>> +	if (in->ctl_table !=3D NULL) {
>> +		err =3D nf_ct_register_sysctl(net,
>> +					    &in->ctl_table_header,
>>  					    l3proto->ctl_table_path,
>> -					    l3proto->ctl_table, NULL);
>> +					    in->ctl_table,
>> +					    NULL);
>> +		if (err < 0) {
>> +			kfree(in->ctl_table);
>> +			in->ctl_table =3D NULL;
>=20
> do we need this extra NULL assignment?
>=20
>> +		}
>>  	}
>>  #endif
>>  	return err;
>>  }
>> =20
>> -static void nf_ct_l3proto_unregister_sysctl(struct nf_conntrack_l3p=
roto *l3proto)
>> +static void nf_ct_l3proto_unregister_sysctl(struct net *net,
>> +					    struct nf_conntrack_l3proto *l3proto)
>>  {
>> -#ifdef CONFIG_SYSCTL
>> -	if (l3proto->ctl_table_header !=3D NULL)
>> -		nf_ct_unregister_sysctl(&l3proto->ctl_table_header,
>> -					&l3proto->ctl_table, NULL);
>> +	struct nf_ip_net *in =3D nf_ct_l3proto_net(net, l3proto);
>> +
>> +	if (in =3D=3D NULL)
>> +		return;
>> +#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMP=
AT)
>> +	if (in->ctl_table_header !=3D NULL)
>> +		nf_ct_unregister_sysctl(&in->ctl_table_header,
>> +					&in->ctl_table,
>> +					NULL);
>>  #endif
>>  }
>> =20
>> -int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *prot=
o)
>> +int nf_conntrack_l3proto_register(struct net *net,
>> +				  struct nf_conntrack_l3proto *proto)
>>  {
>>  	int ret =3D 0;
>> -	struct nf_conntrack_l3proto *old;
>> -
>> -	if (proto->l3proto >=3D AF_MAX)
>> -		return -EBUSY;
>> =20
>> -	if (proto->tuple_to_nlattr && !proto->nlattr_tuple_size)
>> -		return -EINVAL;
>> +	if (net =3D=3D &init_net) {
>=20
> Same things as in previous patch. Move...
>=20
> if (net =3D=3D &init_net) {
>      ... this code ...
> }
>=20
> into some static int nf_conntrack_l3proto_register_net function.
>=20

Get it.
thanks
