From: Per Hurtig <per.hurtig@kau.se>
Subject: Re: [PATCH 1/1] net: tcp: RTO restart
Date: Wed, 26 Feb 2014 10:50:46 +0100
Message-ID: <D6FBF93A-8057-497F-A39E-DF6211999DC1@kau.se>
References: <20140218181205.GA7780@kau.se> <CAK6E8=ekVXA9JrajwmJk88bUKcJSi=T5+SFXs0VoG5iQkWBcRw@mail.gmail.com> <20140219105041.GA9981@kau.se> <CAK6E8=cQVr_J6YQGT6z0H3R41tBCpD=1BToqYxzYis4wKxqhew@mail.gmail.com> <C8E05F6E-62B4-4B5A-8DE1-3F166F2705CA@kau.se> <CAK6E8=e9LiA32SZ0_jD7woGeJYxzixsw3hQxjZvgyoqpoJSeyg@mail.gmail.com> <CAK6E8=c0JVRjUHRuLBrH0nfbKcK818C0h2tkBeWydP67-osumQ@mail.gmail.com>
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
Received: from smtp.kau.se ([193.10.220.38]:61714 "EHLO tiger.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750913AbaBZJ7w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 04:59:52 -0500
In-Reply-To: <CAK6E8=c0JVRjUHRuLBrH0nfbKcK818C0h2tkBeWydP67-osumQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 25 Feb 2014, at 01:03, Yuchung Cheng <ycheng@google.com> wrote:

> On Fri, Feb 21, 2014 at 8:53 AM, Yuchung Cheng <ycheng@google.com> wr=
ote:
>> On Fri, Feb 21, 2014 at 2:48 AM, Per Hurtig <per.hurtig@kau.se> wrot=
e:
>>>=20
>>> On 19 Feb 2014, at 18:51, Yuchung Cheng <ycheng@google.com> wrote:
>>>=20
>>>> On Wed, Feb 19, 2014 at 2:50 AM, Per Hurtig <per.hurtig@kau.se> wr=
ote:
>>>>> Hi Yuchung,
>>>>>=20
>>>>> see inline
>>>>>=20
>>>>> On Tue, Feb 18, 2014 at 10:46:18AM -0800, Yuchung Cheng wrote:
>>>>>> On Tue, Feb 18, 2014 at 10:12 AM, Per Hurtig <per.hurtig@kau.se>=
 wrote:
>>>>>>> This patch implements the RTO restart modification described in
>>>>>>> http://tools.ietf.org/html/draft-ietf-tcpm-rtorestart-02
>>>>>>>=20
>>>>>>> RTO Restart's goal is to provide quicker loss recovery for segm=
ents lost in the
>>>>>>> end of a burst/connection. To accomplish this the algorithm adj=
usts the RTO
>>>>>>> value on each rearm of the retransmission timer to be exactly R=
TO ms after the
>>>>>>> earliest outstanding segment was sent. The offsetting against t=
he earliest
>>>>>>> outstanding segment is not done by the regular rearm algorithm,=
 which causes
>>>>>>> RTOs to occur, on average, after RTO+RTT ms.
>>>>>>>=20
>>>>>>> As a faster timeout is only beneficial in scenarios where fast =
retransmit/early
>>>>>>> retransmit cannot be triggered the algorithm will only kick in =
when there is a
>>>>>>> small amount of outstanding segments.
>>>>>> (repost in plaine-text, sorry for the duplication)
>>>>>>=20
>>>>>> I am not sure this works well with Linux min-RTO=3D200ms, and do=
n't feel
>>>>>> comfortable this is default on without some real experiments.
>>>>>>=20
>>>>>> I've implemented (a nearly identical version of) rto-restart on =
Google
>>>>>> web servers and found #timeouts increased by ~30%.
>>>=20
>>> How did your version work, did it apply the modified restart for an=
y amount of
>>> outstanding segments? If so, I=92m not surprised if the #timeouts i=
ncreased
>>> dramatically.
>>>=20
>>>=20
>>>>>> Although the fast
>>>>>> timeout helps really short flows, it has a very negative side-ef=
fect:
>>>>>> resetting cwnd to 1. Thus the next HTTP response may start with =
a
>>>>>> small cwnd. In contrast, TCP loss probe has fast timeout (1.5RTT=
) to
>>>>>> do fast recovery to avoid the side-effect. In other words, I am
>>>>>> doubtful we need rto-restart with TCP loss probe, but applying
>>>>>> RTO-restart on TLP timer may be useful.
>>>>>=20
>>>>> As we have discussed, I agree that RTO restart can also be applie=
d to TLP and
>>>>> this is also mentioned in the ietf draft. However, I think they a=
re also
>>>>> complementary in reducing loss recovery delay.
>>>>>=20
>>>>>>=20
>>>>>> I've voiced this concern multiple times in ietf tcpm discussion =
when
>>>>>> we discuss this draft: that the idea itself is fine, but we'll n=
eed to
>>>>>> change Linux RTO algorithm together, not just the timer itself.
>>>>>>=20
>>>>>> I am happy to post some more detailed data if people are interes=
ted.
>>>>>=20
>>>>> We would love to see the data. The last time we discussed this, y=
ou were not
>>>> Sure I can gather some data this week for rto-restart.
>>>=20
>>> That would be great! If you will be in London for the IETF perhaps =
we could also
>>> schedule a time to discuss it?
>> Sure but I should have the data by this weekend. I tweaked your patc=
h
>> about the rto overflow issue.
>>=20
>> I think it's worth the effort to evaluate RTO more thoroughly and
>> preferably use the same re-arming logic for retransmission. In other
>> words, always offset the time elapsed since last sent when re-arming=
 a
>> retransmit timer, and relax the RTO calculation formula but not
>> depending on the inflight. For example, we already use similar logic
>> when handling ICMP dest-unreach. in tcp_ipv{4|6}.c.
>=20
> I tested your patch on two co-located Google servers in North America=
=2E
> I use all the default upstream TCP features (sack, FACK, tlp, frto,
> IW10, etc) but vary the rto-restart knob. The latency didn't really
> change. If anything it's slightly worse but that's within the 1%
> noise. The retransmission rate are nearly identical. The breakdown of
> various retranmission stats are the same too and SpuriousRtxHostQueue=
s
> are negligible. Each experiment has x+-1% millions of samples over a
> course of 4 days.
>=20
> *HTTP response latency.
> baseline: 673ms, rto-restart:678ms, retrans-rate: 3.6%
>=20
> HTTP response latency of size <=3D 3 MSS packets
> baseline: 166ms, rto-restart: 171ms, retrans-rate: 3.0%
>=20
> HTTP response latency is the interval from the first byte of the
> response is sent out to the last byte is acked.
>=20
> So it does not hurt nor does it really help in my test.

Thanks for sharing the data,

Do you know, or is it possible to determine, how the flows that saw
loss were affected by the modified restart, in terms of latency? From
measurements we=92re currently conducting its rather common that the av=
erage
performance benefit for all flows, including those without loss, is low=
=2E
However, for flows that do experience loss, there can be significant im=
provements.

Also, as your setup includes TLP we only have the RTO restart over TLP =
gain to start
with.

Cheers,
Per
>=20
>>=20
>>>=20
>>>>=20
>>>>> able to find it. From the latest discussions in the tcpm group I =
understood you
>>>>> didn't think it was that big of a problem anymore
>>>> rto-restart draft is OK with the context of hypothetical stack
>>>> implementing only RFC standards. But Linux is (much) more complex:
>>>> min-RTO=3D200ms, TLP, FACK, etc. Changing how the default timer is=
 armed
>>>> needs to be carefully tested in real world before making rto-resta=
rt
>>>> default. Shortening timer (retry faster) always help short connect=
ions
>>>> but the long connections may suffer the cwnd reset due to spurious
>>>> timeout, *especially* Linux is already running a very aggressive
>>>> min-rto.
>>>>=20
>>>> btw, the rto -=3D delta may overflow if the socket was locked when=
 the
>>>> timer fired previously?
>>>=20
>>> Thanks for pointing that out, I think you might be right.
>>>=20
>>>=20
>>> Best Regards,
>>> Per Hurtig
>>>>=20
>>>>>=20
>>>>>=20
>>>>> Best Regards,
>>>>> Per Hurtig
>>>>>>=20
>>>>>>>=20
>>>>>>> The RTO Restart proposal is accepted as a working group item in=
 the IETF TCP
>>>>>>> Maintenance and Minor Extensions (tcpm) TCP wg and is intended =
for experimental
>>>>>>> RFC status.
>>>>>>>=20
>>>>>>> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>>>>>>> ---
>>>>>>> include/net/tcp.h          |    1 +
>>>>>>> net/ipv4/sysctl_net_ipv4.c |    7 +++++++
>>>>>>> net/ipv4/tcp_input.c       |   11 +++++++++++
>>>>>>> 3 files changed, 19 insertions(+)
>>>>>>>=20
>>>>>>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>>>>>>> index 56fc366..575e82a 100644
>>>>>>> --- a/include/net/tcp.h
>>>>>>> +++ b/include/net/tcp.h
>>>>>>> @@ -278,6 +278,7 @@ extern int sysctl_tcp_slow_start_after_idle=
;
>>>>>>> extern int sysctl_tcp_thin_linear_timeouts;
>>>>>>> extern int sysctl_tcp_thin_dupack;
>>>>>>> extern int sysctl_tcp_early_retrans;
>>>>>>> +extern int sysctl_tcp_rto_restart;
>>>>>>> extern int sysctl_tcp_limit_output_bytes;
>>>>>>> extern int sysctl_tcp_challenge_ack_limit;
>>>>>>> extern unsigned int sysctl_tcp_notsent_lowat;
>>>>>>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_i=
pv4.c
>>>>>>> index 44eba05..c605f4f 100644
>>>>>>> --- a/net/ipv4/sysctl_net_ipv4.c
>>>>>>> +++ b/net/ipv4/sysctl_net_ipv4.c
>>>>>>> @@ -717,6 +717,13 @@ static struct ctl_table ipv4_table[] =3D {
>>>>>>>               .extra2         =3D &four,
>>>>>>>       },
>>>>>>>       {
>>>>>>> +               .procname       =3D "tcp_rto_restart",
>>>>>>> +               .data           =3D &sysctl_tcp_rto_restart,
>>>>>>> +               .maxlen         =3D sizeof(int),
>>>>>>> +               .mode           =3D 0644,
>>>>>>> +               .proc_handler   =3D proc_dointvec,
>>>>>>> +       },
>>>>>>> +       {
>>>>>>>               .procname       =3D "tcp_min_tso_segs",
>>>>>>>               .data           =3D &sysctl_tcp_min_tso_segs,
>>>>>>>               .maxlen         =3D sizeof(int),
>>>>>>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>>>>>>> index 227cba7..450ee30 100644
>>>>>>> --- a/net/ipv4/tcp_input.c
>>>>>>> +++ b/net/ipv4/tcp_input.c
>>>>>>> @@ -98,6 +98,7 @@ int sysctl_tcp_thin_dupack __read_mostly;
>>>>>>>=20
>>>>>>> int sysctl_tcp_moderate_rcvbuf __read_mostly =3D 1;
>>>>>>> int sysctl_tcp_early_retrans __read_mostly =3D 3;
>>>>>>> +int sysctl_tcp_rto_restart __read_mostly =3D 1;
>>>>>>>=20
>>>>>>> #define FLAG_DATA              0x01 /* Incoming frame contained=
 data.          */
>>>>>>> #define FLAG_WIN_UPDATE                0x02 /* Incoming ACK was=
 a window update.       */
>>>>>>> @@ -2972,6 +2973,16 @@ void tcp_rearm_rto(struct sock *sk)
>>>>>>>                        */
>>>>>>>                       if (delta > 0)
>>>>>>>                               rto =3D delta;
>>>>>>> +               } else if (icsk->icsk_pending =3D=3D ICSK_TIME_=
RETRANS &&
>>>>>>> +                          sysctl_tcp_rto_restart &&
>>>>>>> +                          sk->sk_send_head =3D=3D NULL &&
>>>>>>> +                          tp->packets_out < 4) {
>>>>>>> +                       struct sk_buff *skb =3D tcp_write_queue=
_head(sk);
>>>>>>> +                       const u32 rto_time_stamp =3D TCP_SKB_CB=
(skb)->when;
>>>>>>> +                       s32 delta =3D (s32)(tcp_time_stamp - rt=
o_time_stamp);
>>>>>>> +
>>>>>>> +                       if (delta > 0)
>>>>>>> +                               rto -=3D delta;
>>>>>>>               }
>>>>>>>               inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, =
rto,
>>>>>>>                                         TCP_RTO_MAX);
>>>>>>> --
>>>>>>> 1.7.9.5
>>>>>>>=20
>>>>>>> --
>>>>>>> To unsubscribe from this list: send the line "unsubscribe netde=
v" in
>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.h=
tml
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe netdev=
" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.ht=
ml
>>>>>=20
>>>=20
>>>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
