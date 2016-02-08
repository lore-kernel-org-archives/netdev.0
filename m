From: "=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?=" <bro.devel@gmail.com>
Subject: Re: [PATCH v3 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Mon, 8 Feb 2016 18:30:49 +0100
Message-ID: <56B8D0C9.9010509@gmail.com>
References: <1454440995-18457-1-git-send-email-bro.devel+kernel@gmail.com>
 <1454440995-18457-3-git-send-email-bro.devel+kernel@gmail.com>
 <1454445306.7627.204.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAF8eE=XxUeoe7pC8C6wgOi=GUR4daRNvFq8ZTrUCifZVa5zn+Q@mail.gmail.com>
 <1454528083.7627.284.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAF8eE=VOuoNLQHtkRwM9ZG+vJ-uH2ufVW5y_pS24rGqWh4Qa2g@mail.gmail.com>
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
To: =?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?= <bro.devel@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:36800 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474AbcBHRbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 12:31:13 -0500
Received: by mail-lb0-f193.google.com with SMTP id zr1so4667828lbb.3
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 09:31:12 -0800 (PST)
In-Reply-To: <CAF8eE=VOuoNLQHtkRwM9ZG+vJ-uH2ufVW5y_pS24rGqWh4Qa2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry guys, I messed up that email by including HTML, and it got
rejected by netdev@vger.kernel.org. I'll resend it properly formatted.

Bendik

On 08/02/16 18:17, Bendik R=C3=B8nning Opstad wrote:
> Eric, thank you for the feedback!
>=20
> On Wed, Feb 3, 2016 at 8:34 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>> On Wed, 2016-02-03 at 19:17 +0100, Bendik R=C3=B8nning Opstad wrote:
>>> On Tue, Feb 2, 2016 at 9:35 PM, Eric Dumazet <eric.dumazet@gmail.co=
m>
> wrote:
>>>> Really this looks very complicated.
>>>
>>> Can you be more specific?
>>
>> A lot of code added, needing maintenance cost for years to come.
>=20
> Yes, that is understandable.
>=20
>>>> Why not simply append the new skb content to prior one ?
>>>
>>> It's not clear to me what you mean. At what stage in the output eng=
ine
>>> do you refer to?
>>>
>>> We want to avoid modifying the data of the SKBs in the output queue=
,
>>
>> Why ? We already do that, as I pointed out.
>=20
> I suspect that we might be talking past each other. It wasn't clear t=
o
> me that we were discussing how to implement this in a different way.
>=20
> The current retrans collapse functionality only merges SKBs that
> contain data that has already been sent and is about to be
> retransmitted.
>=20
> This differs significantly from RDB, which combines both already
> transmitted data and unsent data in the same packet without changing
> how the data is stored (and the state tracked) in the output queue.
> Another difference is that RDB includes un-ACKed data that is not
> considered lost.
>=20
>>> therefore we allocate a new SKB (This SKB is named rdb_skb in the c=
ode).
>>> The header and payload of the first SKB containing data we want to
>>> redundantly transmit is then copied. Then the payload of the SKBs
> following
>>> next in the output queue is appended onto the rdb_skb. The last pay=
load
>>> that is appended is from the first SKB with unsent data, i.e. the
>>> sk_send_head.
>>>
>>> Would you suggest a different approach?
>>>
>>>> skb_still_in_host_queue(sk, prior_skb) would also tell you if the =
skb
> is
>>>> really available (ie its clone not sitting/waiting in a qdisc on t=
he
>>>> host)
>>>
>>> Where do you suggest this should be used?
>>
>> To detect if appending data to prior skb is possible.
>=20
> I see. As the implementation intentionally avoids modifying SKBs in
> the output queue, this was not obvious.
>=20
>> If the prior packet is still in qdisc, no change is allowed,
>> and it is fine : DRB should not trigger anyway.
>=20
> Actually, whether the data in the prior SKB is on the wire or is stil=
l
> on the host (in qdisc/driver queue) is not relevant. RDB always wants
> to redundantly resend the data if there is room in the packet, becaus=
e
> the previous packet may become lost.
>=20
>>>> Note : select_size() always allocate skb with SKB_WITH_OVERHEAD(20=
48 -
>>>> MAX_TCP_HEADER) available bytes in skb->data.
>>>
>>> Sure, rdb_build_skb() could use this instead of the calculated
>>> bytes_in_rdb_skb.
>>
>> Point is : small packets already have tail room in skb->head
>=20
> Yes, I'm aware of that. But we do not allocate new SKBs because we
> think the existing SKBs do not have enough space available. We do it
> to avoid modifications to the SKBs in the output queue.
>=20
>> When RDB decides a packet should be merged into the prior one, you c=
an
>> simply copy payload into the tailroom, then free the skb.
>>
>> No skb allocations are needed, only freeing.
>=20
> It wasn't clear to me that you suggest a completely different
> implementation approach altogether.
>=20
> As I understand you, the approach you suggest is as follows:
>=20
> 1. An SKB containing unsent data is processed for transmission (lets
>    call it T_SKB)
> 2. Check if the previous SKB (lets call it P_SKB) (containing sent bu=
t
>    un-ACKed data) has available (tail) room for the payload contained
>    in T_SKB.
> 3. If room in P_SKB:
>   * Copy the unsent data from T_SKB to P_SKB by appending it to the
>     linear data and update sequence numbers.
>   * Remove T_SKB (which contains only the new and unsent data) from
>     the output queue.
>   * Transmit P_SKB, which now contains some already sent data and som=
e
>     unsent data.
>=20
>=20
> If I have misunderstood, can you please elaborate in detail what you
> mean?
>=20
> If this is the approach you suggest, I can think of some potential
> downsides that require further considerations:
>=20
>=20
> 1) ACK-accounting will work differently
>=20
> When the previous SKB (P_SKB) is modified by appending the data of th=
e
> next SKB (T_SKB), what should happen when an incoming ACK
> acknowledges the data that was sent in the original transmission
> (before the SKB was modified), but not the data that was appended
> later? tcp_clean_rtx_queue currently handles partially ACKed SKBs due
> to TSO, in which case the tcp_skb_pcount(skb) > 1. So this function
> would need to be modified to handle this for RDB modified SKBs in the
> queue, where all the data is located in the linear data buffer (no GS=
O
> segs).
>=20
> How should SACK and retrans flags be handled when one SKB in the
> output queue can represent multiple transmitted packets?
>=20
>=20
> 2) Timestamps and RTT measurements
>=20
> How should RTT measurements work when you don't have a timestamp for
> the data that was newly appended to the existing SKB containing sent
> but un-ACKed data? Or should the skb->skb_mstamp be updated when the
> SKB with newly appended data is sent again? That would make any RTT
> measurements based on ACKs on the originally sent packet unusable.
>=20
>=20
> 3) Retransmit and lost SKB hints
>=20
> Appending unsent data to SKBs with sent data will affect the usage of
> tp->retransmit_skb_hint and tp->lost_skb_hint. As these variables
> contain pointers to SKBs in the output queue, it is implied that all
> the data in an SKB has the same state, such as retransmitted or lost.
>=20
>=20
> 4) RDB's loss accounting
>=20
> RDB detects loss by looking at how many segments that are ACKed. If a=
n
> incoming ACK acknowledges data in multiples SKBs, we can infer that
> loss has occurred (ignoring the possibility of reordering). With the
> approach you suggest, we lose the information about how many packets
> we originally had, and how much of the payload was redundant
> (considering SKBs are updated with new data and sent out again). We
> would need additional variables in order to keep track of this.
>=20
>=20
> 5) Forced bundling on retransmissions
>=20
> Since the SKBs in the output queue are modified to contain redundant
> data, retransmissions of the SKBs will necessarily only contain the
> redundant data unless the SKBs are modified before the retransmission=
=2E
>=20
>=20
> 6) Configuring how much is bundled becomes complex
>=20
> When previous SKBs are to be used by appending the new data to be
> sent, it is no longer possible to configure the amount of data to
> bundle. We are forced to bundle all the data in the previous SKB.
>=20
> Say we have 3 SKBs in the queue, with unsent segments 1, 2, 3:
> [1] [2] [3]
>=20
> Send 1:
> [1] ->
> Try to send 2, but first merge 2 with 1:
> [1,2] [3]
> Send merged SKB:
> [1,2] ->
>=20
> When we want to send segment 3, we are forced to bundle both 1 and 2.
> Try to send 3, but first merge 3 with 1,2.
> [1,2,3]
> Send merged SKB:
> [1,2,3] ->
>=20
> Transmitting only 2,3 in a packet then becomes difficult without
> additional logic for RDB record keeping.
>=20
>=20
>> RDB could be implemented in a more concise way.
>=20
> I'm open for suggestions to improvements. However, I can't see how th=
e
> suggested approach (as I've understood it) can be implemented without
> making extensive modifications to the current TCP engine. Having one
> SKB represent multiple packets, where each packet contains different =
data
> and possibly in different states (retransmitted/lost), seems very com=
plex.
>=20
> By avoiding any modifications to the output queue we ensure the
> default code branch is completely unaffected, avoiding any special
> handling in multiple locations in the codebase.
>=20
>=20
> Regards,
>=20
> Bendik
>=20
