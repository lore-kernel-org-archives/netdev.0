From: "=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?=" <bro.devel@gmail.com>
Subject: Re: [PATCH v6 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Thu, 16 Jun 2016 19:12:58 +0200
Message-ID: <5762DE1A.5000904@gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
 <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
 <1457028388-18226-3-git-send-email-bro.devel+kernel@gmail.com>
 <CAK6E8=eXH1HEXEWiAnUTT65i9=M=j1W1v3MQFSxvk2xF_TNLZg@mail.gmail.com>
 <56EB3D2E.7090303@gmail.com>
 <CAK6E8=cZUkTUzSh_qymBMozZyxgwBQsvq6bx38LzpGJehcLQiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=c3=a5l_Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35761 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548AbcFPRPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 13:15:18 -0400
Received: by mail-lf0-f67.google.com with SMTP id w130so6172487lfd.2
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:15:17 -0700 (PDT)
In-Reply-To: <CAK6E8=cZUkTUzSh_qymBMozZyxgwBQsvq6bx38LzpGJehcLQiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/03/16 19:54, Yuchung Cheng wrote:
> On Thu, Mar 17, 2016 at 4:26 PM, Bendik R=C3=B8nning Opstad
> <bro.devel@gmail.com> wrote:
>>
>>>> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentatio=
n/networking/ip-sysctl.txt
>>>> index 6a92b15..8f3f3bf 100644
>>>> --- a/Documentation/networking/ip-sysctl.txt
>>>> +++ b/Documentation/networking/ip-sysctl.txt
>>>> @@ -716,6 +716,21 @@ tcp_thin_dpifl_itt_lower_bound - INTEGER
>>>>         calculated, which is used to classify whether a stream is =
thin.
>>>>         Default: 10000
>>>>
>>>> +tcp_rdb - BOOLEAN
>>>> +       Enable RDB for all new TCP connections.
>>>   Please describe RDB briefly, perhaps with a pointer to your paper=
=2E
>>
>> Ah, yes, that description may have been a bit too brief...
>>
>> What about pointing to tcp-thin.txt in the brief description, and
>> rewrite tcp-thin.txt with a more detailed description of RDB along
>> with a paper reference?
> +1
>>
>>>    I suggest have three level of controls:
>>>    0: disable RDB completely
>>>    1: enable indiv. thin-stream conn. to use RDB via TCP_RDB socket
>>> options
>>>    2: enable RDB on all thin-stream conn. by default
>>>
>>>    currently it only provides mode 1 and 2. but there may be cases =
where
>>>    the administrator wants to disallow it (e.g., broken middle-boxe=
s).
>>
>> Good idea. Will change this.

I have implemented your suggestion in the next patch.

>>> It also seems better to
>>> allow individual socket to select the redundancy level (e.g.,
>>> setsockopt TCP_RDB=3D3 means <=3D3 pkts per bundle) vs a global set=
ting.
>>> This requires more bits in tcp_sock but 2-3 more is suffice.
>>
>> Most certainly. We decided not to implement this for the patch to ke=
ep
>> it as simple as possible, however, we surely prefer to have this
>> functionality included if possible.

Next patch version has a socket option to allow modifying the different
RDB settings.

>>>> +int tcp_transmit_rdb_skb(struct sock *sk, struct sk_buff *xmit_sk=
b,
>>>> +                        unsigned int mss_now, gfp_t gfp_mask)
>>>> +{
>>>> +       struct sk_buff *rdb_skb =3D NULL;
>>>> +       struct sk_buff *first_to_bundle;
>>>> +       u32 bytes_in_rdb_skb =3D 0;
>>>> +
>>>> +       /* How we detect that RDB was used. When equal, no RDB dat=
a was sent */
>>>> +       TCP_SKB_CB(xmit_skb)->tx.rdb_start_seq =3D TCP_SKB_CB(xmit=
_skb)->seq;
>>>
>>>> +
>>>> +       if (!tcp_stream_is_thin_dpifl(tcp_sk(sk)))
>>> During loss recovery tcp inflight fluctuates and would like to trig=
ger
>>> this check even for non-thin-stream connections.
>>
>> Good point.
>>
>>> Since the loss
>>> already occurs, RDB can only take advantage from limited-transmit,
>>> which it likely does not have (b/c its a thin-stream). It might be
>>> checking if the state is open.
>>
>> You mean to test for open state to avoid calling rdb_can_bundle_test=
()
>> unnecessarily if we (presume to) know it cannot bundle anyway? That
>> makes sense, however, I would like to do some tests on whether "stat=
e
>> !=3D open" is a good indicator on when bundling is not possible.

When testing this I found that bundling can often be performed when
not in Open state. For the most part in CWR mode, but also the other
modes, so this does not seem like a good indicator.

The only problem with tcp_stream_is_thin_dpifl() triggering for
non-thin streams in loss recovery would be the performance penalty of
calling rdb_can_bundle_test(). It would not be able to bundle anyways
since the previous SKB would contain >=3D mss worth of data.

The most reliable test is to check available space in the previous
SKB, i.e. if (xmit_skb->prev->len =3D=3D mss_now). Do you suggest, for
performance reasons, to do this before the call to
tcp_stream_is_thin_dpifl()?

>>> since RDB will cause DSACKs, and we only blindly count DSACKs to
>>> perform CWND undo. How does RDB handle that false positives?
>>
>> That is a very good question. The simple answer is that the
>> implementation does not handle any such false positives, which I
>> expect can result in incorrectly undoing CWND reduction in some case=
s.
>> This gets a bit complicated, so I'll have to do some more testing on
>> this to verify with certainty when it happens.
>>
>> When there is no loss, and each RDB packet arriving at the receiver
>> contains both already received and new data, the receiver will respo=
nd
>> with an ACK that acknowledges new data (moves snd_una), with the SAC=
K
>> field populated with the already received sequence range (DSACK).
>>
>> The DSACKs in these incoming ACKs are not counted (tp->undo_retrans-=
-)
>> unless tp->undo_marker has been set by tcp_init_undo(), which is
>> called by either tcp_enter_loss() or tcp_enter_recovery(). However,
>> whenever a loss is detected by rdb_detect_loss(), tcp_enter_cwr() is
>> called, which disables CWND undo. Therefore, I believe the incorrect
> thanks for the clarification. it might worth a short comment on why w=
e
> use tcp_enter_cwr() (to disable undo)
>
>
>> counting of DSACKs from ACKs on RDB packets will only be a problem
>> after the regular loss detection mechanisms (Fast Retransmit/RTO) ha=
ve
>> been triggered (i.e. we are in either TCP_CA_Recovery or TCP_CA_Loss=
).
>>
>> We have recorded the CWND values for both RDB and non-RDB streams in
>> our experiments, and have not found any obvious red flags when
>> analysing the results, so I presume (hope may be more precise) this =
is
>> not a major issue we have missed. Nevertheless, I will investigate
>> this in detail and get back to you.

I've looked into this and tried to figure out in which cases this is
actually a problem, but I have failed to find any.

One scenario I considered is when an RDB packet is sent right after a
retransmit, which would result in DSACK in the ACK in response to the
RDB packet.

With a bundling limit of 1 packet, two packets must be lost for RDB to
fail to repair the loss, causing dupACKs. So if three packets are sent,
where the first two are lost, the last packet will cause a dupACK,
resulting in a fast retransmit (and entering recovery which calls
tcp_init_undo()).

By writing new data to the socket right after the fast retransmit,
a new RDB packet is built with some old data that was just
retransmitted.

On the ACK on the fast retransmit the state is changed from Recovery
to Open. The next incoming ACK (on the RDB packet) will contain a DSACK
range, but it will not be considered dubious (tcp_ack_is_dubious())
since "!(flag & FLAG_NOT_DUP)" is false (new data was acked), state is
Open, and "flag & FLAG_CA_ALERT" evaluates to false.


=46eel free to suggest scenarios (as detailed as possible) with the
potential to cause such false positives, and I'll test them with
packetdrill.

Bendik
