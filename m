From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH 1/1] net: tcp: RTO restart
Date: Mon, 24 Feb 2014 16:03:27 -0800
Message-ID: <CAK6E8=c0JVRjUHRuLBrH0nfbKcK818C0h2tkBeWydP67-osumQ@mail.gmail.com>
References: <20140218181205.GA7780@kau.se> <CAK6E8=ekVXA9JrajwmJk88bUKcJSi=T5+SFXs0VoG5iQkWBcRw@mail.gmail.com>
 <20140219105041.GA9981@kau.se> <CAK6E8=cQVr_J6YQGT6z0H3R41tBCpD=1BToqYxzYis4wKxqhew@mail.gmail.com>
 <C8E05F6E-62B4-4B5A-8DE1-3F166F2705CA@kau.se> <CAK6E8=e9LiA32SZ0_jD7woGeJYxzixsw3hQxjZvgyoqpoJSeyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?Q?Anna_Brunstr=C3=B6m?= <anna.brunstrom@kau.se>,
	Andreas Petlund <apetlund@simula.no>,
	Michael Welzl <michawe@ifi.uio.no>,
	=?UTF-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:55675 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639AbaBYAEI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:04:08 -0500
Received: by mail-ie0-f180.google.com with SMTP id ar20so4205288iec.11
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 16:04:07 -0800 (PST)
In-Reply-To: <CAK6E8=e9LiA32SZ0_jD7woGeJYxzixsw3hQxjZvgyoqpoJSeyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 21, 2014 at 8:53 AM, Yuchung Cheng <ycheng@google.com> wrot=
e:
> On Fri, Feb 21, 2014 at 2:48 AM, Per Hurtig <per.hurtig@kau.se> wrote=
:
>>
>> On 19 Feb 2014, at 18:51, Yuchung Cheng <ycheng@google.com> wrote:
>>
>>> On Wed, Feb 19, 2014 at 2:50 AM, Per Hurtig <per.hurtig@kau.se> wro=
te:
>>>> Hi Yuchung,
>>>>
>>>> see inline
>>>>
>>>> On Tue, Feb 18, 2014 at 10:46:18AM -0800, Yuchung Cheng wrote:
>>>>> On Tue, Feb 18, 2014 at 10:12 AM, Per Hurtig <per.hurtig@kau.se> =
wrote:
>>>>>> This patch implements the RTO restart modification described in
>>>>>> http://tools.ietf.org/html/draft-ietf-tcpm-rtorestart-02
>>>>>>
>>>>>> RTO Restart's goal is to provide quicker loss recovery for segme=
nts lost in the
>>>>>> end of a burst/connection. To accomplish this the algorithm adju=
sts the RTO
>>>>>> value on each rearm of the retransmission timer to be exactly RT=
O ms after the
>>>>>> earliest outstanding segment was sent. The offsetting against th=
e earliest
>>>>>> outstanding segment is not done by the regular rearm algorithm, =
which causes
>>>>>> RTOs to occur, on average, after RTO+RTT ms.
>>>>>>
>>>>>> As a faster timeout is only beneficial in scenarios where fast r=
etransmit/early
>>>>>> retransmit cannot be triggered the algorithm will only kick in w=
hen there is a
>>>>>> small amount of outstanding segments.
>>>>> (repost in plaine-text, sorry for the duplication)
>>>>>
>>>>> I am not sure this works well with Linux min-RTO=3D200ms, and don=
't feel
>>>>> comfortable this is default on without some real experiments.
>>>>>
>>>>> I've implemented (a nearly identical version of) rto-restart on G=
oogle
>>>>> web servers and found #timeouts increased by ~30%.
>>
>> How did your version work, did it apply the modified restart for any=
 amount of
>> outstanding segments? If so, I=E2=80=99m not surprised if the #timeo=
uts increased
>> dramatically.
>>
>>
>>>>> Although the fast
>>>>> timeout helps really short flows, it has a very negative side-eff=
ect:
>>>>> resetting cwnd to 1. Thus the next HTTP response may start with a
>>>>> small cwnd. In contrast, TCP loss probe has fast timeout (1.5RTT)=
 to
>>>>> do fast recovery to avoid the side-effect. In other words, I am
>>>>> doubtful we need rto-restart with TCP loss probe, but applying
>>>>> RTO-restart on TLP timer may be useful.
>>>>
>>>> As we have discussed, I agree that RTO restart can also be applied=
 to TLP and
>>>> this is also mentioned in the ietf draft. However, I think they ar=
e also
>>>> complementary in reducing loss recovery delay.
>>>>
>>>>>
>>>>> I've voiced this concern multiple times in ietf tcpm discussion w=
hen
>>>>> we discuss this draft: that the idea itself is fine, but we'll ne=
ed to
>>>>> change Linux RTO algorithm together, not just the timer itself.
>>>>>
>>>>> I am happy to post some more detailed data if people are interest=
ed.
>>>>
>>>> We would love to see the data. The last time we discussed this, yo=
u were not
>>> Sure I can gather some data this week for rto-restart.
>>
>> That would be great! If you will be in London for the IETF perhaps w=
e could also
>> schedule a time to discuss it?
> Sure but I should have the data by this weekend. I tweaked your patch
> about the rto overflow issue.
>
> I think it's worth the effort to evaluate RTO more thoroughly and
> preferably use the same re-arming logic for retransmission. In other
> words, always offset the time elapsed since last sent when re-arming =
a
> retransmit timer, and relax the RTO calculation formula but not
> depending on the inflight. For example, we already use similar logic
> when handling ICMP dest-unreach. in tcp_ipv{4|6}.c.

I tested your patch on two co-located Google servers in North America.
I use all the default upstream TCP features (sack, FACK, tlp, frto,
IW10, etc) but vary the rto-restart knob. The latency didn't really
change. If anything it's slightly worse but that's within the 1%
noise. The retransmission rate are nearly identical. The breakdown of
various retranmission stats are the same too and SpuriousRtxHostQueues
are negligible. Each experiment has x+-1% millions of samples over a
course of 4 days.

*HTTP response latency.
baseline: 673ms, rto-restart:678ms, retrans-rate: 3.6%

HTTP response latency of size <=3D 3 MSS packets
baseline: 166ms, rto-restart: 171ms, retrans-rate: 3.0%

HTTP response latency is the interval from the first byte of the
response is sent out to the last byte is acked.

So it does not hurt nor does it really help in my test.

>
>>
>>>
>>>> able to find it. From the latest discussions in the tcpm group I u=
nderstood you
>>>> didn't think it was that big of a problem anymore
>>> rto-restart draft is OK with the context of hypothetical stack
>>> implementing only RFC standards. But Linux is (much) more complex:
>>> min-RTO=3D200ms, TLP, FACK, etc. Changing how the default timer is =
armed
>>> needs to be carefully tested in real world before making rto-restar=
t
>>> default. Shortening timer (retry faster) always help short connecti=
ons
>>> but the long connections may suffer the cwnd reset due to spurious
>>> timeout, *especially* Linux is already running a very aggressive
>>> min-rto.
>>>
>>> btw, the rto -=3D delta may overflow if the socket was locked when =
the
>>> timer fired previously?
>>
>> Thanks for pointing that out, I think you might be right.
>>
>>
>> Best Regards,
>> Per Hurtig
>>>
>>>>
>>>>
>>>> Best Regards,
>>>> Per Hurtig
>>>>>
>>>>>>
>>>>>> The RTO Restart proposal is accepted as a working group item in =
the IETF TCP
>>>>>> Maintenance and Minor Extensions (tcpm) TCP wg and is intended f=
or experimental
>>>>>> RFC status.
>>>>>>
>>>>>> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>>>>>> ---
>>>>>> include/net/tcp.h          |    1 +
>>>>>> net/ipv4/sysctl_net_ipv4.c |    7 +++++++
>>>>>> net/ipv4/tcp_input.c       |   11 +++++++++++
>>>>>> 3 files changed, 19 insertions(+)
>>>>>>
>>>>>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>>>>>> index 56fc366..575e82a 100644
>>>>>> --- a/include/net/tcp.h
>>>>>> +++ b/include/net/tcp.h
>>>>>> @@ -278,6 +278,7 @@ extern int sysctl_tcp_slow_start_after_idle;
>>>>>> extern int sysctl_tcp_thin_linear_timeouts;
>>>>>> extern int sysctl_tcp_thin_dupack;
>>>>>> extern int sysctl_tcp_early_retrans;
>>>>>> +extern int sysctl_tcp_rto_restart;
>>>>>> extern int sysctl_tcp_limit_output_bytes;
>>>>>> extern int sysctl_tcp_challenge_ack_limit;
>>>>>> extern unsigned int sysctl_tcp_notsent_lowat;
>>>>>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ip=
v4.c
>>>>>> index 44eba05..c605f4f 100644
>>>>>> --- a/net/ipv4/sysctl_net_ipv4.c
>>>>>> +++ b/net/ipv4/sysctl_net_ipv4.c
>>>>>> @@ -717,6 +717,13 @@ static struct ctl_table ipv4_table[] =3D {
>>>>>>                .extra2         =3D &four,
>>>>>>        },
>>>>>>        {
>>>>>> +               .procname       =3D "tcp_rto_restart",
>>>>>> +               .data           =3D &sysctl_tcp_rto_restart,
>>>>>> +               .maxlen         =3D sizeof(int),
>>>>>> +               .mode           =3D 0644,
>>>>>> +               .proc_handler   =3D proc_dointvec,
>>>>>> +       },
>>>>>> +       {
>>>>>>                .procname       =3D "tcp_min_tso_segs",
>>>>>>                .data           =3D &sysctl_tcp_min_tso_segs,
>>>>>>                .maxlen         =3D sizeof(int),
>>>>>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>>>>>> index 227cba7..450ee30 100644
>>>>>> --- a/net/ipv4/tcp_input.c
>>>>>> +++ b/net/ipv4/tcp_input.c
>>>>>> @@ -98,6 +98,7 @@ int sysctl_tcp_thin_dupack __read_mostly;
>>>>>>
>>>>>> int sysctl_tcp_moderate_rcvbuf __read_mostly =3D 1;
>>>>>> int sysctl_tcp_early_retrans __read_mostly =3D 3;
>>>>>> +int sysctl_tcp_rto_restart __read_mostly =3D 1;
>>>>>>
>>>>>> #define FLAG_DATA              0x01 /* Incoming frame contained =
data.          */
>>>>>> #define FLAG_WIN_UPDATE                0x02 /* Incoming ACK was =
a window update.       */
>>>>>> @@ -2972,6 +2973,16 @@ void tcp_rearm_rto(struct sock *sk)
>>>>>>                         */
>>>>>>                        if (delta > 0)
>>>>>>                                rto =3D delta;
>>>>>> +               } else if (icsk->icsk_pending =3D=3D ICSK_TIME_R=
ETRANS &&
>>>>>> +                          sysctl_tcp_rto_restart &&
>>>>>> +                          sk->sk_send_head =3D=3D NULL &&
>>>>>> +                          tp->packets_out < 4) {
>>>>>> +                       struct sk_buff *skb =3D tcp_write_queue_=
head(sk);
>>>>>> +                       const u32 rto_time_stamp =3D TCP_SKB_CB(=
skb)->when;
>>>>>> +                       s32 delta =3D (s32)(tcp_time_stamp - rto=
_time_stamp);
>>>>>> +
>>>>>> +                       if (delta > 0)
>>>>>> +                               rto -=3D delta;
>>>>>>                }
>>>>>>                inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, =
rto,
>>>>>>                                          TCP_RTO_MAX);
>>>>>> --
>>>>>> 1.7.9.5
>>>>>>
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe netdev=
" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.ht=
ml
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe netdev"=
 in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.htm=
l
>>>>
>>
>>
