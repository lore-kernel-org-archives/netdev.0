From: Per Hurtig <per.hurtig@kau.se>
Subject: Re: [PATCH 1/1] net: tcp: RTO restart
Date: Fri, 21 Feb 2014 11:48:53 +0100
Message-ID: <C8E05F6E-62B4-4B5A-8DE1-3F166F2705CA@kau.se>
References: <20140218181205.GA7780@kau.se> <CAK6E8=ekVXA9JrajwmJk88bUKcJSi=T5+SFXs0VoG5iQkWBcRw@mail.gmail.com> <20140219105041.GA9981@kau.se> <CAK6E8=cQVr_J6YQGT6z0H3R41tBCpD=1BToqYxzYis4wKxqhew@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	=?windows-1252?Q?Anna_Brunstr=F6m?= <anna.brunstrom@kau.se>,
	Andreas Petlund <apetlund@simula.no>,
	Michael Welzl <michawe@ifi.uio.no>,
	=?windows-1252?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.38]:32281 "EHLO tiger.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753000AbaBUK7j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 05:59:39 -0500
In-Reply-To: <CAK6E8=cQVr_J6YQGT6z0H3R41tBCpD=1BToqYxzYis4wKxqhew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 19 Feb 2014, at 18:51, Yuchung Cheng <ycheng@google.com> wrote:

> On Wed, Feb 19, 2014 at 2:50 AM, Per Hurtig <per.hurtig@kau.se> wrote=
:
>> Hi Yuchung,
>>=20
>> see inline
>>=20
>> On Tue, Feb 18, 2014 at 10:46:18AM -0800, Yuchung Cheng wrote:
>>> On Tue, Feb 18, 2014 at 10:12 AM, Per Hurtig <per.hurtig@kau.se> wr=
ote:
>>>> This patch implements the RTO restart modification described in
>>>> http://tools.ietf.org/html/draft-ietf-tcpm-rtorestart-02
>>>>=20
>>>> RTO Restart's goal is to provide quicker loss recovery for segment=
s lost in the
>>>> end of a burst/connection. To accomplish this the algorithm adjust=
s the RTO
>>>> value on each rearm of the retransmission timer to be exactly RTO =
ms after the
>>>> earliest outstanding segment was sent. The offsetting against the =
earliest
>>>> outstanding segment is not done by the regular rearm algorithm, wh=
ich causes
>>>> RTOs to occur, on average, after RTO+RTT ms.
>>>>=20
>>>> As a faster timeout is only beneficial in scenarios where fast ret=
ransmit/early
>>>> retransmit cannot be triggered the algorithm will only kick in whe=
n there is a
>>>> small amount of outstanding segments.
>>> (repost in plaine-text, sorry for the duplication)
>>>=20
>>> I am not sure this works well with Linux min-RTO=3D200ms, and don't=
 feel
>>> comfortable this is default on without some real experiments.
>>>=20
>>> I've implemented (a nearly identical version of) rto-restart on Goo=
gle
>>> web servers and found #timeouts increased by ~30%.

How did your version work, did it apply the modified restart for any am=
ount of
outstanding segments? If so, I=92m not surprised if the #timeouts incre=
ased
dramatically.


>>> Although the fast
>>> timeout helps really short flows, it has a very negative side-effec=
t:
>>> resetting cwnd to 1. Thus the next HTTP response may start with a
>>> small cwnd. In contrast, TCP loss probe has fast timeout (1.5RTT) t=
o
>>> do fast recovery to avoid the side-effect. In other words, I am
>>> doubtful we need rto-restart with TCP loss probe, but applying
>>> RTO-restart on TLP timer may be useful.
>>=20
>> As we have discussed, I agree that RTO restart can also be applied t=
o TLP and
>> this is also mentioned in the ietf draft. However, I think they are =
also
>> complementary in reducing loss recovery delay.
>>=20
>>>=20
>>> I've voiced this concern multiple times in ietf tcpm discussion whe=
n
>>> we discuss this draft: that the idea itself is fine, but we'll need=
 to
>>> change Linux RTO algorithm together, not just the timer itself.
>>>=20
>>> I am happy to post some more detailed data if people are interested=
=2E
>>=20
>> We would love to see the data. The last time we discussed this, you =
were not
> Sure I can gather some data this week for rto-restart.

That would be great! If you will be in London for the IETF perhaps we c=
ould also
schedule a time to discuss it?

>=20
>> able to find it. From the latest discussions in the tcpm group I und=
erstood you
>> didn't think it was that big of a problem anymore
> rto-restart draft is OK with the context of hypothetical stack
> implementing only RFC standards. But Linux is (much) more complex:
> min-RTO=3D200ms, TLP, FACK, etc. Changing how the default timer is ar=
med
> needs to be carefully tested in real world before making rto-restart
> default. Shortening timer (retry faster) always help short connection=
s
> but the long connections may suffer the cwnd reset due to spurious
> timeout, *especially* Linux is already running a very aggressive
> min-rto.
>=20
> btw, the rto -=3D delta may overflow if the socket was locked when th=
e
> timer fired previously?

Thanks for pointing that out, I think you might be right.


Best Regards,
Per Hurtig
>=20
>>=20
>>=20
>> Best Regards,
>> Per Hurtig
>>>=20
>>>>=20
>>>> The RTO Restart proposal is accepted as a working group item in th=
e IETF TCP
>>>> Maintenance and Minor Extensions (tcpm) TCP wg and is intended for=
 experimental
>>>> RFC status.
>>>>=20
>>>> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>>>> ---
>>>> include/net/tcp.h          |    1 +
>>>> net/ipv4/sysctl_net_ipv4.c |    7 +++++++
>>>> net/ipv4/tcp_input.c       |   11 +++++++++++
>>>> 3 files changed, 19 insertions(+)
>>>>=20
>>>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>>>> index 56fc366..575e82a 100644
>>>> --- a/include/net/tcp.h
>>>> +++ b/include/net/tcp.h
>>>> @@ -278,6 +278,7 @@ extern int sysctl_tcp_slow_start_after_idle;
>>>> extern int sysctl_tcp_thin_linear_timeouts;
>>>> extern int sysctl_tcp_thin_dupack;
>>>> extern int sysctl_tcp_early_retrans;
>>>> +extern int sysctl_tcp_rto_restart;
>>>> extern int sysctl_tcp_limit_output_bytes;
>>>> extern int sysctl_tcp_challenge_ack_limit;
>>>> extern unsigned int sysctl_tcp_notsent_lowat;
>>>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4=
=2Ec
>>>> index 44eba05..c605f4f 100644
>>>> --- a/net/ipv4/sysctl_net_ipv4.c
>>>> +++ b/net/ipv4/sysctl_net_ipv4.c
>>>> @@ -717,6 +717,13 @@ static struct ctl_table ipv4_table[] =3D {
>>>>                .extra2         =3D &four,
>>>>        },
>>>>        {
>>>> +               .procname       =3D "tcp_rto_restart",
>>>> +               .data           =3D &sysctl_tcp_rto_restart,
>>>> +               .maxlen         =3D sizeof(int),
>>>> +               .mode           =3D 0644,
>>>> +               .proc_handler   =3D proc_dointvec,
>>>> +       },
>>>> +       {
>>>>                .procname       =3D "tcp_min_tso_segs",
>>>>                .data           =3D &sysctl_tcp_min_tso_segs,
>>>>                .maxlen         =3D sizeof(int),
>>>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>>>> index 227cba7..450ee30 100644
>>>> --- a/net/ipv4/tcp_input.c
>>>> +++ b/net/ipv4/tcp_input.c
>>>> @@ -98,6 +98,7 @@ int sysctl_tcp_thin_dupack __read_mostly;
>>>>=20
>>>> int sysctl_tcp_moderate_rcvbuf __read_mostly =3D 1;
>>>> int sysctl_tcp_early_retrans __read_mostly =3D 3;
>>>> +int sysctl_tcp_rto_restart __read_mostly =3D 1;
>>>>=20
>>>> #define FLAG_DATA              0x01 /* Incoming frame contained da=
ta.          */
>>>> #define FLAG_WIN_UPDATE                0x02 /* Incoming ACK was a =
window update.       */
>>>> @@ -2972,6 +2973,16 @@ void tcp_rearm_rto(struct sock *sk)
>>>>                         */
>>>>                        if (delta > 0)
>>>>                                rto =3D delta;
>>>> +               } else if (icsk->icsk_pending =3D=3D ICSK_TIME_RET=
RANS &&
>>>> +                          sysctl_tcp_rto_restart &&
>>>> +                          sk->sk_send_head =3D=3D NULL &&
>>>> +                          tp->packets_out < 4) {
>>>> +                       struct sk_buff *skb =3D tcp_write_queue_he=
ad(sk);
>>>> +                       const u32 rto_time_stamp =3D TCP_SKB_CB(sk=
b)->when;
>>>> +                       s32 delta =3D (s32)(tcp_time_stamp - rto_t=
ime_stamp);
>>>> +
>>>> +                       if (delta > 0)
>>>> +                               rto -=3D delta;
>>>>                }
>>>>                inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, rt=
o,
>>>>                                          TCP_RTO_MAX);
>>>> --
>>>> 1.7.9.5
>>>>=20
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" =
in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
