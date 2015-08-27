From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [RFC PATCH v6 net-next 3/4] tcp: add in_flight to tcp_skb_cb
Date: Thu, 27 Aug 2015 23:27:54 +0000
Message-ID: <D204E9B0.7469%brakmo@fb.com>
References: <1440545634-3901299-1-git-send-email-brakmo@fb.com>
 <1440545634-3901299-4-git-send-email-brakmo@fb.com>
 <CAK6E8=dYOhLeYhGUWJg-mhHqQfrv1GaLzKt=TFLj=koOCMdVUg@mail.gmail.com>
 <D204DC2A.7420%brakmo@fb.com>
 <CAK6E8=daN=sBiJVyi5tiVdfrFzB99=HGdzCZZbx_Rq10NAWjBg@mail.gmail.com>
 <CAK6E8=fNk-x6=QLHT0rjFRh3bARfkErA+VW_PgxRUcu-3fm9pQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>,
	"Neal Cardwell" <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:14239 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753105AbbH0X2H convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2015 19:28:07 -0400
In-Reply-To: <CAK6E8=fNk-x6=QLHT0rjFRh3bARfkErA+VW_PgxRUcu-3fm9pQ@mail.gmail.com>
Content-Language: en-US
Content-ID: <7F9B3E10B6797041A82DA9DE855FE3D1@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 8/27/15, 3:57 PM, "Yuchung Cheng" <ycheng@google.com> wrote:

>On Thu, Aug 27, 2015 at 3:54 PM, Yuchung Cheng <ycheng@google.com> wro=
te:
>> On Thu, Aug 27, 2015 at 3:44 PM, Lawrence Brakmo <brakmo@fb.com> wro=
te:
>>> Yuchung, thank you for reviewing these patches. Response inline bel=
ow.
>>>
>>> On 8/27/15, 3:00 PM, "Yuchung Cheng" <ycheng@google.com> wrote:
>>>
>>>>On Tue, Aug 25, 2015 at 4:33 PM, Lawrence Brakmo <brakmo@fb.com> wr=
ote:
>>>>> Add in_flight (bytes in flight when packet was sent) field
>>>>> to tx component of tcp_skb_cb and make it available to
>>>>> congestion modules' pkts_acked() function through the
>>>>> ack_sample function argument.
>>>>>
>>>>> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
>> Acked-by: Yuchung Cheng <ycheng@google.com>
>>
>>>>> ---
>>>>>  include/net/tcp.h     | 2 ++
>>>>>  net/ipv4/tcp_input.c  | 5 ++++-
>>>>>  net/ipv4/tcp_output.c | 4 +++-
>>>>>  3 files changed, 9 insertions(+), 2 deletions(-)
>>>>>
>>>>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>>>>> index a086a98..cdd93e5 100644
>>>>> --- a/include/net/tcp.h
>>>>> +++ b/include/net/tcp.h
>>>>> @@ -757,6 +757,7 @@ struct tcp_skb_cb {
>>>>>         union {
>>>>>                 struct {
>>>>>                         /* There is space for up to 20 bytes */
>>>>> +                       __u32 in_flight;/* Bytes in flight when
>>>>>packet
>>>>>sent */
>>>>>                 } tx;   /* only used for outgoing skbs */
>>>>>                 union {
>>>>>                         struct inet_skb_parm    h4;
>>>>> @@ -842,6 +843,7 @@ union tcp_cc_info;
>>>>>  struct ack_sample {
>>>>>         u32 pkts_acked;
>>>>>         s32 rtt_us;
>>>>> +       u32 in_flight;
>>>>>  };
>>>>>
>>>>>  struct tcp_congestion_ops {
>>>>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>>>>> index f506a0a..338e6bb 100644
>>>>> --- a/net/ipv4/tcp_input.c
>>>>> +++ b/net/ipv4/tcp_input.c
>>>>> @@ -3069,6 +3069,7 @@ static int tcp_clean_rtx_queue(struct sock =
*sk,
>>>>>int prior_fackets,
>>>>>         long ca_rtt_us =3D -1L;
>>>>>         struct sk_buff *skb;
>>>>>         u32 pkts_acked =3D 0;
>>>>> +       u32 last_in_flight =3D 0;
>>>>>         bool rtt_update;
>>>>>         int flag =3D 0;
>>>>>
>>>>> @@ -3108,6 +3109,7 @@ static int tcp_clean_rtx_queue(struct sock =
*sk,
>>>>>int prior_fackets,
>>>>>                         if (!first_ackt.v64)
>>>>>                                 first_ackt =3D last_ackt;
>>>>>
>>>>> +                       last_in_flight =3D
>>>>>TCP_SKB_CB(skb)->tx.in_flight;
>>>>>                         reord =3D min(pkts_acked, reord);
>>>>>                         if (!after(scb->end_seq, tp->high_seq))
>>>>>                                 flag |=3D FLAG_ORIG_SACK_ACKED;
>>>>> @@ -3197,7 +3199,8 @@ static int tcp_clean_rtx_queue(struct sock =
*sk,
>>>>>int prior_fackets,
>>>>>         }
>>>>>
>>>>>         if (icsk->icsk_ca_ops->pkts_acked) {
>>>>> -               struct ack_sample sample =3D {pkts_acked, ca_rtt_=
us};
>>>>> +               struct ack_sample sample =3D {pkts_acked, ca_rtt_=
us,
>>>>> +                                           last_in_flight};
>>>>>
>>>>>                 icsk->icsk_ca_ops->pkts_acked(sk, &sample);
>>>>>         }
>>>>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>>>>> index 444ab5b..244d201 100644
>>>>> --- a/net/ipv4/tcp_output.c
>>>>> +++ b/net/ipv4/tcp_output.c
>>>>> @@ -920,9 +920,12 @@ static int tcp_transmit_skb(struct sock *sk,
>>>>>struct sk_buff *skb, int clone_it,
>>>>>         int err;
>>>>>
>>>>>         BUG_ON(!skb || !tcp_skb_pcount(skb));
>>>>> +       tp =3D tcp_sk(sk);
>>>>>
>>>>>         if (clone_it) {
>>>>>                 skb_mstamp_get(&skb->skb_mstamp);
>>>>> +               TCP_SKB_CB(skb)->tx.in_flight =3D
>>>>>TCP_SKB_CB(skb)->end_seq
>>>>> +                       - tp->snd_una;
>>>>what if skb is a retransmitted packet? e.g. the first retransmissio=
n
>>>>in fast recovery would always record an inflight of 1 packet?
>>>
>>> Yes.
>>> This does not affect NV for 2 reasons: 1) NV does not use ACKs when
>>> ca_state is not Open or Disorder to determine congestion state, 2)
>>>even if
>>> we used it, the small inflight means that the computed throughput w=
ill
>>>be
>>> small so it will not cause a non-congestion signal, but will not ca=
use
>>>a
>>> congestion signal either because NV needs many (~60) measurements
>>>before
>>> determining there is congestion.
>>>
>>> However, other consumers may prefer a different value. From a
>>>congestion
>>> avoidance perspective, it is unclear we will be able to compute an
>>> accurate throughput when retransmitting, so we may as well give a l=
ower
>>> bound.
>> I see. Then this is OK for now since only NV uses it. We can enhance
>> and track tput even during other CA states later. Would that be a
>> useful feature for NV as well?
>For example, we (at Google servers) have seen some flows staying in
>very long CA_Recovery due to rate limiter or CA_Disorder state due to
>high path reordering. It'd be beneficial to have CC continue to
>operate in these circumstances in the future.

Hopefully congestion avoidance in NV would adapt to a rate limiter and
prevent
losses or large queues.
However, for the time being NV is only recommended for data center traf=
fic
since 1) I=B9ve only tested in small RTT environments and 2) cannot com=
pete
fairly with Cubic (at least in small RTT environments).

>
>>
>>>
>>> What do you think?
>>>
>>>>
>>>>>
>>>>>                 if (unlikely(skb_cloned(skb)))
>>>>>                         skb =3D pskb_copy(skb, gfp_mask);
>>>>> @@ -933,7 +936,6 @@ static int tcp_transmit_skb(struct sock *sk,
>>>>>struct
>>>>>sk_buff *skb, int clone_it,
>>>>>         }
>>>>>
>>>>>         inet =3D inet_sk(sk);
>>>>> -       tp =3D tcp_sk(sk);
>>>>>         tcb =3D TCP_SKB_CB(skb);
>>>>>         memset(&opts, 0, sizeof(opts));
>>>>>
>>>>> --
>>>>> 1.8.1
>>>>>
>>>
