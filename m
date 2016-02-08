From: "=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?=" <bro.devel@gmail.com>
Subject: Re: [PATCH v3 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Mon, 8 Feb 2016 18:38:09 +0100
Message-ID: <56B8D281.30903@gmail.com>
References: <1454440995-18457-1-git-send-email-bro.devel+kernel@gmail.com>
 <1454440995-18457-3-git-send-email-bro.devel+kernel@gmail.com>
 <1454445306.7627.204.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAF8eE=XxUeoe7pC8C6wgOi=GUR4daRNvFq8ZTrUCifZVa5zn+Q@mail.gmail.com>
 <1454528083.7627.284.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=c3=a5l_Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?= <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:33451 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbcBHRic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 12:38:32 -0500
Received: by mail-lb0-f196.google.com with SMTP id bc4so4682057lbc.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 09:38:31 -0800 (PST)
In-Reply-To: <1454528083.7627.284.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric, thank you for the feedback!

On Wed, Feb 3, 2016 at 8:34 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> On Wed, 2016-02-03 at 19:17 +0100, Bendik R=C3=B8nning Opstad wrote:
>> On Tue, Feb 2, 2016 at 9:35 PM, Eric Dumazet <eric.dumazet@gmail.com=
>
wrote:
>>> Really this looks very complicated.
>>
>> Can you be more specific?
>
> A lot of code added, needing maintenance cost for years to come.

Yes, that is understandable.

>>> Why not simply append the new skb content to prior one ?
>>
>> It's not clear to me what you mean. At what stage in the output engi=
ne
>> do you refer to?
>>
>> We want to avoid modifying the data of the SKBs in the output queue,
>
> Why ? We already do that, as I pointed out.

I suspect that we might be talking past each other. It wasn't clear to
me that we were discussing how to implement this in a different way.

The current retrans collapse functionality only merges SKBs that
contain data that has already been sent and is about to be
retransmitted.

This differs significantly from RDB, which combines both already
transmitted data and unsent data in the same packet without changing
how the data is stored (and the state tracked) in the output queue.
Another difference is that RDB includes un-ACKed data that is not
considered lost.


>> therefore we allocate a new SKB (This SKB is named rdb_skb in the co=
de).
>> The header and payload of the first SKB containing data we want to
>> redundantly transmit is then copied. Then the payload of the SKBs fo=
llowing
>> next in the output queue is appended onto the rdb_skb. The last payl=
oad
>> that is appended is from the first SKB with unsent data, i.e. the
>> sk_send_head.
>>
>> Would you suggest a different approach?
>>
>>> skb_still_in_host_queue(sk, prior_skb) would also tell you if the s=
kb is
>>> really available (ie its clone not sitting/waiting in a qdisc on th=
e
>>> host)
>>
>> Where do you suggest this should be used?
>
> To detect if appending data to prior skb is possible.

I see. As the implementation intentionally avoids modifying SKBs in
the output queue, this was not obvious.

> If the prior packet is still in qdisc, no change is allowed,
> and it is fine : DRB should not trigger anyway.

Actually, whether the data in the prior SKB is on the wire or is still
on the host (in qdisc/driver queue) is not relevant. RDB always wants
to redundantly resend the data if there is room in the packet, because
the previous packet may become lost.

>>> Note : select_size() always allocate skb with SKB_WITH_OVERHEAD(204=
8 -
>>> MAX_TCP_HEADER) available bytes in skb->data.
>>
>> Sure, rdb_build_skb() could use this instead of the calculated
>> bytes_in_rdb_skb.
>
> Point is : small packets already have tail room in skb->head

Yes, I'm aware of that. But we do not allocate new SKBs because we
think the existing SKBs do not have enough space available. We do it
to avoid modifications to the SKBs in the output queue.

> When RDB decides a packet should be merged into the prior one, you ca=
n
> simply copy payload into the tailroom, then free the skb.
>
> No skb allocations are needed, only freeing.

It wasn't clear to me that you suggest a completely different
implementation approach altogether.

As I understand you, the approach you suggest is as follows:

1. An SKB containing unsent data is processed for transmission (lets
   call it T_SKB)
2. Check if the previous SKB (lets call it P_SKB) (containing sent but
   un-ACKed data) has available (tail) room for the payload contained
   in T_SKB.
3. If room in P_SKB:
  * Copy the unsent data from T_SKB to P_SKB by appending it to the
    linear data and update sequence numbers.
  * Remove T_SKB (which contains only the new and unsent data) from
    the output queue.
  * Transmit P_SKB, which now contains some already sent data and some
    unsent data.


If I have misunderstood, can you please elaborate in detail what you
mean?

If this is the approach you suggest, I can think of some potential
downsides that require further considerations:


1) ACK-accounting will work differently

When the previous SKB (P_SKB) is modified by appending the data of the
next SKB (T_SKB), what should happen when an incoming ACK acknowledges
the data that was sent in the original transmission (before the SKB
was modified), but not the data that was appended later?
tcp_clean_rtx_queue currently handles partially ACKed SKBs due to TSO,
in which case the tcp_skb_pcount(skb) > 1. So this function would need
to be modified to handle this for RDB modified SKBs in the queue,
where all the data is located in the linear data buffer (no GSO segs).

How should SACK and retrans flags be handled when one SKB in the
output queue can represent multiple transmitted packets?


2) Timestamps and RTT measurements

How should RTT measurements work when you don't have a timestamp for
the data that was newly appended to the existing SKB containing sent
but un-ACKed data? Or should the skb->skb_mstamp be updated when the
SKB with newly appended data is sent again? That would make any RTT
measurements based on ACKs on the originally sent packet unusable.


3) Retransmit and lost SKB hints

Appending unsent data to SKBs with sent data will affect the usage of
tp->retransmit_skb_hint and tp->lost_skb_hint. As these variables
contain pointers to SKBs in the output queue, it is implied that all
the data in an SKB has the same state, such as retransmitted or lost.


4) RDB's loss accounting

RDB detects loss by looking at how many segments that are ACKed. If an
incoming ACK acknowledges data in multiples SKBs, we can infer that
loss has occurred (ignoring the possibility of reordering). With the
approach you suggest, we lose the information about how many packets
we originally had, and how much of the payload was redundant
(considering SKBs are updated with new data and sent out again). We
would need additional variables in order to keep track of this.


5) Forced bundling on retransmissions

Since the SKBs in the output queue are modified to contain redundant
data, retransmissions of the SKBs will necessarily only contain the
redundant data unless the SKBs are modified before the retransmission.


6) Configuring how much is bundled becomes complex

When previous SKBs are to be used by appending the new data to be
sent, it is no longer possible to configure the amount of data to
bundle. We are forced to bundle all the data in the previous SKB.

Say we have 3 SKBs in the queue, with unsent segments 1, 2, 3:
[1] [2] [3]

Send 1:
[1] ->
Try to send 2, but first merge 2 with 1:
[1,2] [3]
Send merged SKB:
[1,2] ->

When we want to send segment 3, we are forced to bundle both 1 and 2.
Try to send 3, but first merge 3 with 1,2.
[1,2,3]
Send merged SKB:
[1,2,3] ->

Transmitting only 2,3 in a packet then becomes difficult without
additional logic for RDB record keeping.


> RDB could be implemented in a more concise way.

I'm open for suggestions to improvements. However, I can't see how the
suggested approach (as I've understood it) can be implemented without
making extensive modifications to the current TCP engine. Having one
SKB represent multiple packets, where each packet contains different
data and possibly in different states (retransmitted/lost), seems very
complex.

By avoiding any modifications to the output queue we ensure the
default code branch is completely unaffected, avoiding any special
handling in multiple locations in the codebase.


Regards,

Bendik
