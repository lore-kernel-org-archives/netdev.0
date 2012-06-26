From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 04/13] netfilter: regard users as refcount for l4proto's
 per-net data
Date: Tue, 26 Jun 2012 11:58:45 +0800
Message-ID: <4FE93375.1080803@cn.fujitsu.com>
References: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com> <1340289410-17642-4-git-send-email-gaofeng@cn.fujitsu.com> <20120625112029.GB4607@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120625112029.GB4607@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo:
=E4=BA=8E 2012=E5=B9=B406=E6=9C=8825=E6=97=A5 19:20, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Thu, Jun 21, 2012 at 10:36:41PM +0800, Gao feng wrote:
>> Now, nf_proto_net's users is confusing.
>> we should regard it as the refcount for l4proto's per-net data,
>> because maybe there are two l4protos use the same per-net data.
>>
>> so increment pn->users when nf_conntrack_l4proto_register
>> success, and decrement it for nf_conntrack_l4_unregister case.
>>
>> because nf_conntrack_l3proto_ipv[4|6] don't use the same per-net
>> data,so we don't need to add a refcnt for their per-net data.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  net/netfilter/nf_conntrack_proto.c |   76 ++++++++++++++++++++++---=
-----------
>>  1 files changed, 46 insertions(+), 30 deletions(-)
>>
>> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_c=
onntrack_proto.c
>> index 9d6b6ab..63612e6 100644
>> --- a/net/netfilter/nf_conntrack_proto.c
>> +++ b/net/netfilter/nf_conntrack_proto.c
> [...]
>> @@ -458,23 +446,32 @@ int nf_conntrack_l4proto_register(struct net *=
net,
>>  				  struct nf_conntrack_l4proto *l4proto)
>>  {
>>  	int ret =3D 0;
>> +	struct nf_proto_net *pn =3D NULL;
>> =20
>>  	if (l4proto->init_net) {
>>  		ret =3D l4proto->init_net(net, l4proto->l3proto);
>>  		if (ret < 0)
>> -			return ret;
>> +			goto out;
>>  	}
>> =20
>> -	ret =3D nf_ct_l4proto_register_sysctl(net, l4proto);
>> +	pn =3D nf_ct_l4proto_net(net, l4proto);
>> +	if (pn =3D=3D NULL)
>> +		goto out;
>=20
> Same thing here, we're leaking memory allocated by l4proto->init_net.

if pn is NULL,init_net can't allocate memory for pn->ctl_table.
So I think it's not memory leak here.

>=20
>> +	ret =3D nf_ct_l4proto_register_sysctl(net, pn, l4proto);
>>  	if (ret < 0)
>> -		return ret;
>> +		goto out;
>> =20
>>  	if (net =3D=3D &init_net) {
>>  		ret =3D nf_conntrack_l4proto_register_net(l4proto);
>> -		if (ret < 0)
>> -			nf_ct_l4proto_unregister_sysctl(net, l4proto);
>> +		if (ret < 0) {
>> +			nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
>> +			goto out;
>=20
> Better replace the two lines above by:
>=20
> goto out_register_net;
>=20
> and then...
>=20
>> +		}
>>  	}
>> =20
>> +	pn->users++;
>=20
> out_register_net:
>         nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
>=20
>> +out:
>>  	return ret;
>=20
> I think that this change is similar to patch 1/1, I think you should
> send it as a separated patch.
>=20

Yes, It looks better.
should I change this and rebase whole patchset or
maybe you just apply this patchset and then I send a cleanup patch to d=
o this?

>>  }
>>  EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
>> @@ -499,10 +496,18 @@ nf_conntrack_l4proto_unregister_net(struct nf_=
conntrack_l4proto *l4proto)
>>  void nf_conntrack_l4proto_unregister(struct net *net,
>>  				     struct nf_conntrack_l4proto *l4proto)
>>  {
>> +	struct nf_proto_net *pn =3D NULL;
>> +
>>  	if (net =3D=3D &init_net)
>>  		nf_conntrack_l4proto_unregister_net(l4proto);
>> =20
>> -	nf_ct_l4proto_unregister_sysctl(net, l4proto);
>> +	pn =3D nf_ct_l4proto_net(net, l4proto);
>> +	if (pn =3D=3D NULL)
>> +		return;
>> +
>> +	pn->users--;
>> +	nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
>> +
>>  	/* Remove all contrack entries for this protocol */
>>  	rtnl_lock();
>>  	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
>> @@ -514,11 +519,15 @@ int nf_conntrack_proto_init(struct net *net)
>>  {
>>  	unsigned int i;
>>  	int err;
>> +	struct nf_proto_net *pn =3D nf_ct_l4proto_net(net,
>> +					&nf_conntrack_l4proto_generic);
>> +
>>  	err =3D nf_conntrack_l4proto_generic.init_net(net,
>>  					nf_conntrack_l4proto_generic.l3proto);
>>  	if (err < 0)
>>  		return err;
>>  	err =3D nf_ct_l4proto_register_sysctl(net,
>> +					    pn,
>>  					    &nf_conntrack_l4proto_generic);
>>  	if (err < 0)
>>  		return err;
>> @@ -528,13 +537,20 @@ int nf_conntrack_proto_init(struct net *net)
>>  			rcu_assign_pointer(nf_ct_l3protos[i],
>>  					   &nf_conntrack_l3proto_generic);
>>  	}
>> +
>> +	pn->users++;
>>  	return 0;
>>  }
>> =20
>>  void nf_conntrack_proto_fini(struct net *net)
>>  {
>>  	unsigned int i;
>> +	struct nf_proto_net *pn =3D nf_ct_l4proto_net(net,
>> +					&nf_conntrack_l4proto_generic);
>> +
>> +	pn->users--;
>>  	nf_ct_l4proto_unregister_sysctl(net,
>> +					pn,
>>  					&nf_conntrack_l4proto_generic);
>>  	if (net =3D=3D &init_net) {
>>  		/* free l3proto protocol tables */
>> --=20
>> 1.7.7.6
>>
>=20

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
