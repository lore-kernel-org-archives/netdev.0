From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: Re: [PATCH] netfilter: nf_conntrack_sip: CSeq 0 is a valid CSeq
Date: Mon, 4 Jul 2016 08:14:52 +0200
Message-ID: <bb18da60-bd09-05e0-0244-49942abbd1bd@c-s.fr>
References: <20160701094833.B281E1A23A2@localhost.localdomain>
 <CAML_gOdB=SjFyXosSb4MtaEymsAGV3beQwQqZMyhbezy=yDgxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Liping Zhang <zlpnobody@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAML_gOdB=SjFyXosSb4MtaEymsAGV3beQwQqZMyhbezy=yDgxQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Le 04/07/2016 =C3=A0 07:48, Liping Zhang a =C3=A9crit :
> 2016-07-01 17:48 GMT+08:00 Christophe Leroy <christophe.leroy@c-s.fr>=
:
>> Do not drop packet when CSeq is 0 as 0 is also a valid value for CSe=
q.
>>
>> --- a/net/netfilter/nf_conntrack_sip.c
>> +++ b/net/netfilter/nf_conntrack_sip.c
>> @@ -1368,6 +1368,7 @@ static int process_sip_response(struct sk_buff=
 *skb, unsigned int protoff,
>>         struct nf_conn *ct =3D nf_ct_get(skb, &ctinfo);
>>         unsigned int matchoff, matchlen, matchend;
>>         unsigned int code, cseq, i;
>> +       char buf[21];
>>
>>         if (*datalen < strlen("SIP/2.0 200"))
>>                 return NF_ACCEPT;
>> @@ -1382,8 +1383,13 @@ static int process_sip_response(struct sk_buf=
f *skb, unsigned int protoff,
>>                 nf_ct_helper_log(skb, ct, "cannot parse cseq");
>>                 return NF_DROP;
>>         }
>> -       cseq =3D simple_strtoul(*dptr + matchoff, NULL, 10);
>> -       if (!cseq) {
>
> I think there is no need to convert simple_strtoul to kstrtouint, add
> a further check seems better?
> Like this:
>  -       if (!cseq) {
> +       if (!cseq && *(*dptr + matchoff) !=3D '0') {
>

And what about an invalid CSeq that would look like CSeq: 0abzk852 ?
Should we check it is 0 + space instead ?

>> +       if (matchlen > sizeof(buf) - 1) {
>> +               nf_ct_helper_log(skb, ct, "cannot parse cseq (too bi=
g)");
>> +               return NF_DROP;
>> +       }
>> +       memcpy(buf, *dptr + matchoff, matchlen);
>> +       buf[matchlen] =3D 0;
>> +       if (kstrtouint(buf, 10, &cseq)) {
>>                 nf_ct_helper_log(skb, ct, "cannot get cseq");
>>                 return NF_DROP;
>>         }
