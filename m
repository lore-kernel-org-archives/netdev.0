From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH 1/1] net: tcp: RTO restart
Date: Fri, 21 Feb 2014 08:53:26 -0800
Message-ID: <CAK6E8=e9LiA32SZ0_jD7woGeJYxzixsw3hQxjZvgyoqpoJSeyg@mail.gmail.com>
References: <20140218181205.GA7780@kau.se> <CAK6E8=ekVXA9JrajwmJk88bUKcJSi=T5+SFXs0VoG5iQkWBcRw@mail.gmail.com>
 <20140219105041.GA9981@kau.se> <CAK6E8=cQVr_J6YQGT6z0H3R41tBCpD=1BToqYxzYis4wKxqhew@mail.gmail.com>
 <C8E05F6E-62B4-4B5A-8DE1-3F166F2705CA@kau.se>
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
Received: from mail-oa0-f52.google.com ([209.85.219.52]:38035 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933206AbaBUQyH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 11:54:07 -0500
Received: by mail-oa0-f52.google.com with SMTP id i4so4212248oah.25
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 08:54:07 -0800 (PST)
In-Reply-To: <C8E05F6E-62B4-4B5A-8DE1-3F166F2705CA@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 21, 2014 at 2:48 AM, Per Hurtig <per.hurtig@kau.se> wrote:
>
> On 19 Feb 2014, at 18:51, Yuchung Cheng <ycheng@google.com> wrote:
>
>> On Wed, Feb 19, 2014 at 2:50 AM, Per Hurtig <per.hurtig@kau.se> wrot=
e:
>>> Hi Yuchung,
>>>
>>> see inline
>>>
>>> On Tue, Feb 18, 2014 at 10:46:18AM -0800, Yuchung Cheng wrote:
>>>> On Tue, Feb 18, 2014 at 10:12 AM, Per Hurtig <per.hurtig@kau.se> w=
rote:
>>>>> This patch implements the RTO restart modification described in
>>>>> http://tools.ietf.org/html/draft-ietf-tcpm-rtorestart-02
>>>>>
>>>>> RTO Restart's goal is to provide quicker loss recovery for segmen=
ts lost in the
>>>>> end of a burst/connection. To accomplish this the algorithm adjus=
ts the RTO
>>>>> value on each rearm of the retransmission timer to be exactly RTO=
 ms after the
>>>>> earliest outstanding segment was sent. The offsetting against the=
 earliest
>>>>> outstanding segment is not done by the regular rearm algorithm, w=
hich causes
>>>>> RTOs to occur, on average, after RTO+RTT ms.
>>>>>
>>>>> As a faster timeout is only beneficial in scenarios where fast re=
transmit/early
>>>>> retransmit cannot be triggered the algorithm will only kick in wh=
en there is a
>>>>> small amount of outstanding segments.
>>>> (repost in plaine-text, sorry for the duplication)
>>>>
>>>> I am not sure this works well with Linux min-RTO=3D200ms, and don'=
t feel
>>>> comfortable this is default on without some real experiments.
>>>>
>>>> I've implemented (a nearly identical version of) rto-restart on Go=
ogle
>>>> web servers and found #timeouts increased by ~30%.
>
> How did your version work, did it apply the modified restart for any =
amount of
> outstanding segments? If so, I=E2=80=99m not surprised if the #timeou=
ts increased
> dramatically.
>
>
>>>> Although the fast
>>>> timeout helps really short flows, it has a very negative side-effe=
ct:
>>>> resetting cwnd to 1. Thus the next HTTP response may start with a
>>>> small cwnd. In contrast, TCP loss probe has fast timeout (1.5RTT) =
to
>>>> do fast recovery to avoid the side-effect. In other words, I am
>>>> doubtful we need rto-restart with TCP loss probe, but applying
>>>> RTO-restart on TLP timer may be useful.
>>>
>>> As we have discussed, I agree that RTO restart can also be applied =
to TLP and
>>> this is also mentioned in the ietf draft. However, I think they are=
 also
>>> complementary in reducing loss recovery delay.
>>>
>>>>
>>>> I've voiced this concern multiple times in ietf tcpm discussion wh=
en
>>>> we discuss this draft: that the idea itself is fine, but we'll nee=
d to
>>>> change Linux RTO algorithm together, not just the timer itself.
>>>>
>>>> I am happy to post some more detailed data if people are intereste=
d.
>>>
>>> We would love to see the data. The last time we discussed this, you=
 were not
>> Sure I can gather some data this week for rto-restart.
>
> That would be great! If you will be in London for the IETF perhaps we=
 could also
> schedule a time to discuss it?
Sure but I should have the data by this weekend. I tweaked your patch
about the rto overflow issue.

I think it's worth the effort to evaluate RTO more thoroughly and
preferably use the same re-arming logic for retransmission. In other
words, always offset the time elapsed since last sent when re-arming a
retransmit timer, and relax the RTO calculation formula but not
depending on the inflight. For example, we already use similar logic
when handling ICMP dest-unreach. in tcp_ipv{4|6}.c.

>
>>
>>> able to find it. From the latest discussions in the tcpm group I un=
derstood you
>>> didn't think it was that big of a problem anymore
>> rto-restart draft is OK with the context of hypothetical stack
>> implementing only RFC standards. But Linux is (much) more complex:
>> min-RTO=3D200ms, TLP, FACK, etc. Changing how the default timer is a=
rmed
>> needs to be carefully tested in real world before making rto-restart
>> default. Shortening timer (retry faster) always help short connectio=
ns
>> but the long connections may suffer the cwnd reset due to spurious
>> timeout, *especially* Linux is already running a very aggressive
>> min-rto.
>>
>> btw, the rto -=3D delta may overflow if the socket was locked when t=
he
>> timer fired previously?
>
> Thanks for pointing that out, I think you might be right.
>
>
> Best Regards,
> Per Hurtig
>>
>>>
>>>
>>> Best Regards,
>>> Per Hurtig
>>>>
>>>>>
>>>>> The RTO Restart proposal is accepted as a working group item in t=
he IETF TCP
>>>>> Maintenance and Minor Extensions (tcpm) TCP wg and is intended fo=
r experimental
>>>>> RFC status.
>>>>>
>>>>> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>>>>> ---
>>>>> include/net/tcp.h          |    1 +
>>>>> net/ipv4/sysctl_net_ipv4.c |    7 +++++++
>>>>> net/ipv4/tcp_input.c       |   11 +++++++++++
>>>>> 3 files changed, 19 insertions(+)
>>>>>
>>>>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>>>>> index 56fc366..575e82a 100644
>>>>> --- a/include/net/tcp.h
>>>>> +++ b/include/net/tcp.h
>>>>> @@ -278,6 +278,7 @@ extern int sysctl_tcp_slow_start_after_idle;
>>>>> extern int sysctl_tcp_thin_linear_timeouts;
>>>>> extern int sysctl_tcp_thin_dupack;
>>>>> extern int sysctl_tcp_early_retrans;
>>>>> +extern int sysctl_tcp_rto_restart;
>>>>> extern int sysctl_tcp_limit_output_bytes;
>>>>> extern int sysctl_tcp_challenge_ack_limit;
>>>>> extern unsigned int sysctl_tcp_notsent_lowat;
>>>>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv=
4.c
>>>>> index 44eba05..c605f4f 100644
>>>>> --- a/net/ipv4/sysctl_net_ipv4.c
>>>>> +++ b/net/ipv4/sysctl_net_ipv4.c
>>>>> @@ -717,6 +717,13 @@ static struct ctl_table ipv4_table[] =3D {
>>>>>                .extra2         =3D &four,
>>>>>        },
>>>>>        {
>>>>> +               .procname       =3D "tcp_rto_restart",
>>>>> +               .data           =3D &sysctl_tcp_rto_restart,
>>>>> +               .maxlen         =3D sizeof(int),
>>>>> +               .mode           =3D 0644,
>>>>> +               .proc_handler   =3D proc_dointvec,
>>>>> +       },
>>>>> +       {
>>>>>                .procname       =3D "tcp_min_tso_segs",
>>>>>                .data           =3D &sysctl_tcp_min_tso_segs,
>>>>>                .maxlen         =3D sizeof(int),
>>>>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>>>>> index 227cba7..450ee30 100644
>>>>> --- a/net/ipv4/tcp_input.c
>>>>> +++ b/net/ipv4/tcp_input.c
>>>>> @@ -98,6 +98,7 @@ int sysctl_tcp_thin_dupack __read_mostly;
>>>>>
>>>>> int sysctl_tcp_moderate_rcvbuf __read_mostly =3D 1;
>>>>> int sysctl_tcp_early_retrans __read_mostly =3D 3;
>>>>> +int sysctl_tcp_rto_restart __read_mostly =3D 1;
>>>>>
>>>>> #define FLAG_DATA              0x01 /* Incoming frame contained d=
ata.          */
>>>>> #define FLAG_WIN_UPDATE                0x02 /* Incoming ACK was a=
 window update.       */
>>>>> @@ -2972,6 +2973,16 @@ void tcp_rearm_rto(struct sock *sk)
>>>>>                         */
>>>>>                        if (delta > 0)
>>>>>                                rto =3D delta;
>>>>> +               } else if (icsk->icsk_pending =3D=3D ICSK_TIME_RE=
TRANS &&
>>>>> +                          sysctl_tcp_rto_restart &&
>>>>> +                          sk->sk_send_head =3D=3D NULL &&
>>>>> +                          tp->packets_out < 4) {
>>>>> +                       struct sk_buff *skb =3D tcp_write_queue_h=
ead(sk);
>>>>> +                       const u32 rto_time_stamp =3D TCP_SKB_CB(s=
kb)->when;
>>>>> +                       s32 delta =3D (s32)(tcp_time_stamp - rto_=
time_stamp);
>>>>> +
>>>>> +                       if (delta > 0)
>>>>> +                               rto -=3D delta;
>>>>>                }
>>>>>                inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, r=
to,
>>>>>                                          TCP_RTO_MAX);
>>>>> --
>>>>> 1.7.9.5
>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe netdev"=
 in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.htm=
l
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" =
in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>
>
