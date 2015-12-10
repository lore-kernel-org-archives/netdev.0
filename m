From: Per Hurtig <per.hurtig@kau.se>
Subject: Re: [RFC PATCHv2 net-next 1/2] tcp: RTO Restart (RTOR)
Date: Thu, 10 Dec 2015 22:11:25 +0100
Message-ID: <3A30BA3E-2586-4F12-B748-1CABFA0122EF@kau.se>
References: <cover.1449478261.git.per.hurtig@kau.se> <cover.1449561786.git.per.hurtig@kau.se> <8cd2c4817d86e30b09fe398c6bfcb7a89521bdb3.1449561786.git.per.hurtig@kau.se> <1449582430.7632.18.camel@edumazet-glaptop2.roam.corp.google.com> <475C1718-ADEE-4839-AC8C-77E3C1353DF4@kau.se> <CADVnQyn4X57Tz8GxJRU84=Jr2x1j29ZK8xJfdLjnb2a2g45S0A@mail.gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Yuchung Cheng <ycheng@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Florian Westphal <fw@strlen.de>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Willem de Bruijn <willemb@google.com>,
	=?utf-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Pasi Sarolahti <pasi.sarolahti@iki.fi>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	=?utf-8?Q?Anna_Brunstr=C3=B6m?= <anna.brunstrom@kau.se>,
	Andreas Petlund <apetlund@simula.no>,
	Michael Welzl <michawe@ifi.uio.no>,
	Mohammad Rajiullah <mohammad.rajiullah@kau.se>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.38]:34394 "EHLO tiger.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750790AbbLJVLb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 16:11:31 -0500
In-Reply-To: <CADVnQyn4X57Tz8GxJRU84=Jr2x1j29ZK8xJfdLjnb2a2g45S0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> 10 dec. 2015 kl. 16:37 skrev Neal Cardwell <ncardwell@google.com>:
>=20
>> On Thu, Dec 10, 2015 at 1:51 AM, Per Hurtig <per.hurtig@kau.se> wrot=
e:
>>=20
>>> On 08 Dec 2015, at 14:47, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
>>>=20
>>> On Tue, 2015-12-08 at 10:19 +0100, Per Hurtig wrote:
>>>=20
>>>> +static u32 tcp_unsent_pkts(const struct sock *sk, u32 ulimit)
>>>> +{
>>>> +    struct sk_buff *skb =3D tcp_send_head(sk);
>>>> +    u32 pkts =3D 0;
>>>> +
>>>> +    if (skb)
>>>> +            tcp_for_write_queue_from(skb, sk) {
>>>> +                    pkts +=3D tcp_skb_pcount(skb);
>>>> +
>>>> +                    if (ulimit && pkts >=3D ulimit)
>>>> +                            return ulimit;
>>>> +            }
>>>> +
>>>> +    return pkts;
>>>> +}
>>>=20
>>>=20
>>> Considering Yuchung feedback, have you looked at using an approxima=
tion
>>> instead ?
>>>=20
>>> (ie using tp->write_seq - tp->snd_nxt)
>>=20
>> Well, an approximation is rather =E2=80=9Cdangerous=E2=80=9D as miss=
ing a single packet
>> could inhibit the desired behaviour. If looping is undesired, I thin=
k a
>> better solution is to actually *not* do this check at all and instea=
d rely
>> solely on the
>>=20
>> tp->packets_out < TCP_RTORESTART_THRESH
>=20
> Yes, this simpler version seems very much preferable, IMHO. I agree
> that it does not seem worth the complexity to try to cover the kind o=
f
> corner cases you outline.
>=20
> I would also suggest a TCP_RTORESTART_THRESH value higher than 4.
>=20
> In the ID at https://tools.ietf.org/html/draft-ietf-tcpm-rtorestart-1=
0 it says:
>=20
>   The RECOMMENDED value of rrthresh is four, as this value will ensur=
e
>   that RTOR is only used when fast retransmit cannot be triggered.
>=20
> But my sense is that fast retransmit is often not triggered at
> in-flight counts of much higher than 4, due to drop-tail queues, TSO
> bursts, the initial IW10 being unpaced, etc. It would be interesting
> to see A/B experiments for a few TCP_RTORESTART_THRESH values, say, 4
> vs 10.
>=20
> neal
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Sure. One idea could also be to use the "reordering" value as a dynamic=
 threshhold?

-- Per
