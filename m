From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 01/13] netfilter: fix problem with proto register
Date: Tue, 26 Jun 2012 11:40:14 +0800
Message-ID: <4FE92F1E.9020901@cn.fujitsu.com>
References: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com> <20120625111253.GA4607@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:9655 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755017Ab2FZDsh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 23:48:37 -0400
In-Reply-To: <20120625111253.GA4607@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo:

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8825=E6=97=A5 19:12, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Thu, Jun 21, 2012 at 10:36:38PM +0800, Gao feng wrote:
>> before commit 2c352f444ccfa966a1aa4fd8e9ee29381c467448
>> (netfilter: nf_conntrack: prepare namespace support for
>> l4 protocol trackers), we register sysctl before register
>> protos, so if sysctl is registered faild, the protos will
>> not be registered.
>>
>> but now, we register protos first, and when register
>> sysctl failed, we can use protos too, it's different
>> from before.
>=20
> No, this has to be an all-or-nothing game. If one fails, everything
> else that you've registered has to be unregistered.

indeed,this is an all-or-nothing game right now,please look at the ipv4=
_net_init,
when we register nf_conntrack_l3proto_ipv4 failed,we will unregister th=
e already
registered l4protoes, and in nf_conntrack_l4proto_unregister,we will ca=
ll
nf_ct_l4proto_unregister_sysctl to free the sysctl table.

>=20
>> so change to register sysctl before register protos.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  net/netfilter/nf_conntrack_proto.c |   36 +++++++++++++++++++++++--=
-----------
>>  1 files changed, 23 insertions(+), 13 deletions(-)
>>
>> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_c=
onntrack_proto.c
>> index 1ea9194..9bd88aa 100644
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
>=20
> This is still wrong.
>=20
> If nf_ct_l3proto_register_sysctl fails, we'll leak the memory that ha=
s
> been reserved by proto->init_net.
>=20

we have freed the memory in nf_ct_l[3,4]proto_register_sysctl when we
call nf_ct_register_sysctl failed, so there is no need to free this mem=
ory
in nf_conntrack_l[3,4]proto_register.

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
>> @@ -454,19 +459,24 @@ int nf_conntrack_l4proto_register(struct net *=
net,
>>  				  struct nf_conntrack_l4proto *l4proto)
>>  {
>>  	int ret =3D 0;
>> -	if (net =3D=3D &init_net)
>> -		ret =3D nf_conntrack_l4proto_register_net(l4proto);
>> =20
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
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
