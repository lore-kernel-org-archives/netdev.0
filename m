From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH net-next v2 01/12] netfilter: fix problem with proto register
Date: Mon, 18 Jun 2012 08:59:11 +0800
Message-ID: <4FDE7D5F.5080703@cn.fujitsu.com>
References: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com> <20120616105037.GA18251@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120616105037.GA18251@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8816=E6=97=A5 18:50, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Sat, Jun 16, 2012 at 11:41:12AM +0800, Gao feng wrote:
>> commit 2c352f444ccfa966a1aa4fd8e9ee29381c467448
>> (netfilter: nf_conntrack: prepare namespace support for
>> l4 protocol trackers) register proto before register sysctl.
>>
>> it changes the behavior that when register sysctl failed, the
>> proto should not be registered too.
>>
>> so change to register sysctl before register protos.
>=20
> Could you explain why we need to change the order in the registration=
?
> ie. now first proto->init_net then sysctl things.

before commit 2c352f444ccfa966a1aa4fd8e9ee29381c467448, we register sys=
ctl before
register protos, so if sysctl is registered faild, the protos will not =
be registered.

but now, we register protos first, and when register sysctl failed, we =
can use protos
too, it's different from before.

>=20
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  net/netfilter/nf_conntrack_proto.c |   37 ++++++++++++++++++++++---=
----------
>>  1 files changed, 23 insertions(+), 14 deletions(-)
>>
>> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_c=
onntrack_proto.c
>> index 1ea9194..a434dd7 100644
>> --- a/net/netfilter/nf_conntrack_proto.c
>> +++ b/net/netfilter/nf_conntrack_proto.c
>> @@ -253,18 +253,23 @@ int nf_conntrack_l3proto_register(struct net *=
net,
>>  {
>>  	int ret =3D 0;
>> =20
>> -	if (net =3D=3D &init_net)
>> -		ret =3D nf_conntrack_l3proto_register_net(proto);
>> +	if (proto->init_net) {
>> +		ret =3D proto->init_net(net);
>> +		if (ret < 0)
>> +			return ret;
>> +	}
>> =20
>> +	ret =3D nf_ct_l3proto_register_sysctl(net, proto);
>>  	if (ret < 0)
>>  		return ret;
>> =20
>> -	if (proto->init_net) {
>> -		ret =3D proto->init_net(net);
>> +	if (net =3D=3D &init_net) {
>> +		ret =3D nf_conntrack_l3proto_register_net(proto);
>>  		if (ret < 0)
>> -			return ret;
>> +			nf_ct_l3proto_unregister_sysctl(net, proto);
>>  	}
>> -	return nf_ct_l3proto_register_sysctl(net, proto);
>> +
>> +	return ret;
>>  }
>>  EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_register);
>> =20
>> @@ -454,19 +459,23 @@ int nf_conntrack_l4proto_register(struct net *=
net,
>>  				  struct nf_conntrack_l4proto *l4proto)
>>  {
>>  	int ret =3D 0;
>> -	if (net =3D=3D &init_net)
>> -		ret =3D nf_conntrack_l4proto_register_net(l4proto);
>> -
>> -	if (ret < 0)
>> -		return ret;
>> -
>> -	if (l4proto->init_net)
>> +	if (l4proto->init_net) {
>>  		ret =3D l4proto->init_net(net);
>> +		if (ret < 0)
>> +			return ret;
>> +	}
>> =20
>> +	ret =3D nf_ct_l4proto_register_sysctl(net, l4proto);
>>  	if (ret < 0)
>>  		return ret;
>> =20
>> -	return nf_ct_l4proto_register_sysctl(net, l4proto);
>> +	if (net =3D=3D &init_net) {
>> +		ret =3D nf_conntrack_l4proto_register_net(l4proto);
>> +		if (ret < 0)
>> +			nf_ct_l4proto_unregister_sysctl(net, l4proto);
>> +	}
>> +
>> +	return ret;
>>  }
>>  EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
>> =20
>> --=20
>> 1.7.7.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netfilter-=
devel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
