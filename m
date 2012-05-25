From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 05/17] netfilter: add namespace support for l4proto_tcp
Date: Fri, 25 May 2012 14:05:40 +0800
Message-ID: <4FBF2134.1020903@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com> <1336985547-31960-6-git-send-email-gaofeng@cn.fujitsu.com> <20120525030015.GB21076@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120525030015.GB21076@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8825=E6=97=A5 11:00, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> Hi Gao,
>=20
> While having a look at this again, I have two new requests:
>=20
> On Mon, May 14, 2012 at 04:52:15PM +0800, Gao feng wrote:
> [...]
>> diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/=
nf_conntrack_proto_tcp.c
>> index 4dfbfa8..dd19350 100644
>> --- a/net/netfilter/nf_conntrack_proto_tcp.c
>> +++ b/net/netfilter/nf_conntrack_proto_tcp.c
> [...]
>> @@ -1549,10 +1532,80 @@ static struct ctl_table tcp_compat_sysctl_ta=
ble[] =3D {
>>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
>>  #endif /* CONFIG_SYSCTL */
>>
>> +static int tcp_init_net(struct net *net, u_int8_t compat)
>> +{
>> +	int i;
>> +	struct nf_tcp_net *tn =3D tcp_pernet(net);
>> +	struct nf_proto_net *pn =3D (struct nf_proto_net *)tn;
>> +#ifdef CONFIG_SYSCTL
>> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
>> +	if (compat) {
>> +		pn->ctl_compat_table =3D kmemdup(tcp_compat_sysctl_table,
>> +					       sizeof(tcp_compat_sysctl_table),
>> +					       GFP_KERNEL);
>> +		if (!pn->ctl_compat_table)
>> +			return -ENOMEM;
>> +
>> +		pn->ctl_compat_table[0].data =3D &tn->timeouts[TCP_CONNTRACK_SYN_=
SENT];
>> +		pn->ctl_compat_table[1].data =3D &tn->timeouts[TCP_CONNTRACK_SYN_=
SENT2];
>> +		pn->ctl_compat_table[2].data =3D &tn->timeouts[TCP_CONNTRACK_SYN_=
RECV];
>> +		pn->ctl_compat_table[3].data =3D &tn->timeouts[TCP_CONNTRACK_ESTA=
BLISHED];
>> +		pn->ctl_compat_table[4].data =3D &tn->timeouts[TCP_CONNTRACK_FIN_=
WAIT];
>> +		pn->ctl_compat_table[5].data =3D &tn->timeouts[TCP_CONNTRACK_CLOS=
E_WAIT];
>> +		pn->ctl_compat_table[6].data =3D &tn->timeouts[TCP_CONNTRACK_LAST=
_ACK];
>> +		pn->ctl_compat_table[7].data =3D &tn->timeouts[TCP_CONNTRACK_TIME=
_WAIT];
>> +		pn->ctl_compat_table[8].data =3D &tn->timeouts[TCP_CONNTRACK_CLOS=
E];
>> +		pn->ctl_compat_table[9].data =3D &tn->timeouts[TCP_CONNTRACK_RETR=
ANS];
>> +		pn->ctl_compat_table[10].data =3D &tn->tcp_loose;
>> +		pn->ctl_compat_table[11].data =3D &tn->tcp_be_liberal;
>> +		pn->ctl_compat_table[12].data =3D &tn->tcp_max_retrans;
>=20
> You can make a generic function to set the ctl_data that you can
> reuse for this code above and the one below.
>=20

Actually I want reuse this code too,
But Unfortunately the ctl_data has different order or different size.
ctl_compat_table[1].data =3D &tn->timeouts[TCP_CONNTRACK_SYN_SENT2]
but
ctl_table[1].data =3D &tn->timeouts[TCP_CONNTRACK_SYN_RECV];


>> +	}
>> +#endif
>> +	if (!pn->ctl_table) {
>> +#else
>> +	if (!pn->user++) {
>> +#endif
>> +		for (i =3D 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
>> +			tn->timeouts[i] =3D tcp_timeouts[i];
>> +		tn->tcp_loose =3D nf_ct_tcp_loose;
>> +		tn->tcp_be_liberal =3D nf_ct_tcp_be_liberal;
>> +		tn->tcp_max_retrans =3D nf_ct_tcp_max_retrans;
>> +#ifdef CONFIG_SYSCTL
>> +		pn->ctl_table =3D kmemdup(tcp_sysctl_table,
>> +					sizeof(tcp_sysctl_table),
>> +					GFP_KERNEL);
>> +		if (!pn->ctl_table) {
>> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
>> +			if (compat) {
>> +				kfree(pn->ctl_compat_table);
>> +				pn->ctl_compat_table =3D NULL;
>> +			}
>> +#endif
>> +			return -ENOMEM;
>> +		}
>> +		pn->ctl_table[0].data =3D &tn->timeouts[TCP_CONNTRACK_SYN_SENT];
>> +		pn->ctl_table[1].data =3D &tn->timeouts[TCP_CONNTRACK_SYN_RECV];
>> +		pn->ctl_table[2].data =3D &tn->timeouts[TCP_CONNTRACK_ESTABLISHED=
];
>> +		pn->ctl_table[3].data =3D &tn->timeouts[TCP_CONNTRACK_FIN_WAIT];
>> +		pn->ctl_table[4].data =3D &tn->timeouts[TCP_CONNTRACK_CLOSE_WAIT]=
;
>> +		pn->ctl_table[5].data =3D &tn->timeouts[TCP_CONNTRACK_LAST_ACK];
>> +		pn->ctl_table[6].data =3D &tn->timeouts[TCP_CONNTRACK_TIME_WAIT];
>> +		pn->ctl_table[7].data =3D &tn->timeouts[TCP_CONNTRACK_CLOSE];
>> +		pn->ctl_table[8].data =3D &tn->timeouts[TCP_CONNTRACK_RETRANS];
>> +		pn->ctl_table[9].data =3D &tn->timeouts[TCP_CONNTRACK_UNACK];
>> +		pn->ctl_table[10].data =3D &tn->tcp_loose;
>> +		pn->ctl_table[11].data =3D &tn->tcp_be_liberal;
>> +		pn->ctl_table[12].data =3D &tn->tcp_max_retrans;
>> +#endif
>=20
> I have bad experience with code that has lots of #ifdef's.
>=20
> Please, split all *_init_net into smaller functions.

It did look ugly,I will try my best to make code clear. ;)

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
