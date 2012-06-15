From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 05/10] netfilter: merge tcpv[4,6]_net_init into tcp_net_init
Date: Fri, 15 Jun 2012 20:30:33 +0800
Message-ID: <4FDB2AE9.1060506@cn.fujitsu.com>
References: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com> <1339668445-23848-5-git-send-email-gaofeng@cn.fujitsu.com> <20120615114425.GA14449@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120615114425.GA14449@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8815=E6=97=A5 19:44, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Thu, Jun 14, 2012 at 06:07:20PM +0800, Gao feng wrote:
>> merge tcpv4_net_init and tcpv6_net_init into tcp_net_init to
>> reduce the redundancy codes.
>>
>> and use nf_proto_net.users to identify if it's the first time
>> we use the nf_proto_net. when it's the first time,we will
>> initialized it.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  net/netfilter/nf_conntrack_proto_tcp.c |   57 ++++++++-------------=
-----------
>>  1 files changed, 14 insertions(+), 43 deletions(-)
>>
>> diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/=
nf_conntrack_proto_tcp.c
>> index 6db9d3c..e3d5427 100644
>> --- a/net/netfilter/nf_conntrack_proto_tcp.c
>> +++ b/net/netfilter/nf_conntrack_proto_tcp.c
>> @@ -1593,18 +1593,14 @@ static int tcp_kmemdup_compat_sysctl_table(s=
truct nf_proto_net *pn)
>>  	return 0;
>>  }
>> =20
>> -static int tcpv4_init_net(struct net *net, u_int16_t proto)
>> +static int tcp_init_net(struct net *net, u_int16_t proto)
>>  {
>> -	int i;
>>  	int ret =3D 0;
>>  	struct nf_tcp_net *tn =3D tcp_pernet(net);
>>  	struct nf_proto_net *pn =3D (struct nf_proto_net *)tn;
>=20
> while at it, it would be fine if you use &tn->pn instead. I know this
> cast is making the trick, but what I propose is better practise.
>=20

OK, I will change it.

>> -#ifdef CONFIG_SYSCTL
>> -	if (!pn->ctl_table) {
>> -#else
>> -	if (!pn->users++) {
>> -#endif
>> +	if (!pn->users) {
>> +		int i =3D 0;
>>  		for (i =3D 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
>>  			tn->timeouts[i] =3D tcp_timeouts[i];
>> =20
>> @@ -1613,45 +1609,20 @@ static int tcpv4_init_net(struct net *net, u=
_int16_t proto)
>>  		tn->tcp_max_retrans =3D nf_ct_tcp_max_retrans;
>>  	}
>> =20
>> -	ret =3D tcp_kmemdup_compat_sysctl_table(pn);
>> +	if (proto =3D=3D AF_INET) {
>> +		ret =3D tcp_kmemdup_compat_sysctl_table(pn);
>> +		if (ret < 0)
>> +			return ret;
>> =20
>> -	if (ret < 0)
>> -		return ret;
>> +		ret =3D tcp_kmemdup_sysctl_table(pn);
>=20
> One thing I noticed: This kmemdup will happen twice, once for IPv4 an=
d
> once for IPv6. I think this should happen only once, as both TCP
> tracker for IPv4 and IPv6 are sharing the same nf_proto_net.
>=20
> So it should happen inside the if (!pn->users) thing.
>=20
> AFAICS, then this should look like the following:
>=20
> if (pn->users)
>         return 0;

maybe we register IPv6's l4proto first, it will only kmemdup the sysctl=
 table.
if we return here, when we register Ipv4's l4proto,the compat sysctl ta=
ble will
not be allocated, so the netfilter will have no compat sysctl entries.

>=20
> /*
>  * here comes all per-net initialization
>  */
>=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
