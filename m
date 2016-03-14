From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v6 net-next 0/2] tcp: Redundant Data Bundling (RDB)
Date: Mon, 14 Mar 2016 14:59:07 -0700
Message-ID: <CAK6E8=e5tVX3cfwvaXxN7LEq6XggeT5Y7T0j4KcKRsA1b-77mQ@mail.gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
 <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
 <CAK6E8=eKu_0ReSDLYdyajxMyX2MaN=wDLHvq=u_tyNnMRS31sw@mail.gmail.com> <56E5F54F.3050507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=C3=A5l_Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: =?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35847 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbcCNV7s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 17:59:48 -0400
Received: by mail-wm0-f44.google.com with SMTP id n186so127603789wmn.1
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 14:59:48 -0700 (PDT)
In-Reply-To: <56E5F54F.3050507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 13, 2016 at 4:18 PM, Bendik R=C3=B8nning Opstad
<bro.devel@gmail.com> wrote:
> On 03/10/2016 01:20 AM, Yuchung Cheng wrote:
>> I read the paper. I think the underlying idea is neat. but the
>> implementation is little heavy-weight that requires changes on fast
>> path (tcp_write_xmit) and space in skb control blocks.
>
> Yuchung, thank you for taking the time to review the patch submission
> and read the paper.
>
> I must admit I was not particularly happy about the extra if-test on =
the
> fast path, and I fully understand the wish to keep the fast path as
> simple and clean as possible.
> However, is the performance hit that significant considering the bran=
ch
> prediction hint for the non-RDB path?
>
> The extra variable needed in the SKB CB does not require increasing t=
he
> CB buffer size due to the "tcp: refactor struct tcp_skb_cb" patch:
> http://patchwork.ozlabs.org/patch/510674 and uses only some of the sp=
ace
> made available in the outgoing SKBs' CB. Therefore I hoped the extra
> variable would be acceptable.
>
>> ultimately this
>> patch is meant for a small set of specific applications.
>
> Yes, the RDB mechanism is aimed at a limited set of applications,
> specifically time-dependent applications that produce non-greedy,
> application limited (thin) flows. However, our hope is that RDB may
> greatly improve TCP's position as a viable alternative for applicatio=
ns
> transmitting latency sensitive data.
>
>> In my mental model (please correct me if I am wrong), losses on thes=
e
>> thin streams would mostly resort to RTOs instead of fast recovery, d=
ue
>> to the bursty nature of Internet losses.
>
> This depends on the transmission pattern of the applications, which
> varies to a great deal, also between the different types of
> time-dependent applications that produce thin streams. For short flow=
s,
> (bursty) loss at the end will result in an RTO (if TLP does not probe=
),
> but the thin streams are often long lived, and the applications
> producing them continue to write small data segments to the socket at
> intervals of tens to hundreds of milliseconds.
>
> What controls if an RTO and not fast retransmit will resend the packe=
t,
> is the number of PIFs, which directly correlates to how often the
> application writes data to the socket in relation to the RTT. As long=
 as
> the number of packets successfully completing a round trip before the
> RTO is >=3D the dupACK threshold, they will not depend on RTOs (not
> considering TLP). Early retransmit and the TCP_THIN_DUPACK socket opt=
ion
> will also affect the likelihood of RTOs vs fast retransmits.
>
>> The HOLB comes from RTO only
>> retransmit the first (tiny) unacked packet while a small of new data=
 is
>> readily available. But since Linux congestion control is packet-base=
d,
>> and loss cwnd is 1, the new data needs to wait until the 1st packet =
is
>> acked which is for another RTT.
>
> If I understand you correctly, you are referring to HOLB on the sende=
r
> side, which is the extra delay on new data that is held back when the
> connection is CWND-limited. In the paper, we refer to this extra dela=
y
> as increased sojourn times for the outgoing data segments.
>
> We do not include this additional sojourn time for the segments on th=
e
> sender side in the ACK Latency plots (Fig. 4 in the paper). This is
> simply because the pcap traces contain the timestamps when the packet=
s
> are sent, and not when the segments are added to the output queue.
>
> When we refer to the HOLB effect in the paper as well as the thesis, =
we
> refer to the extra delays (sojourn times) on the receiver side where
> segments are held back (not made available to user space) due to gaps=
 in
> the sequence range when packets are lost (we had no reordering).
>
> So, when considering the increased delays due to HOLB on the receiver
> side, HOLB is not at all limited to RTOs. Actually, it's mostly not d=
ue
> to RTOs in the tests we've run, however, this also depends very much =
on
> the transmission pattern of the application as well as loss levels.
> In general, HOLB on the receiver side will affect any flow that
> transmits a packet with new data after a packet is lost (sender may n=
ot
> know yet), where the lost packet has not already been retransmitted.
OK that makes sense.

I left some detailed comments on the actual patches. I would encourage
to submit an IETF draft to gather feedback from tcpm b/c the feature
seems portable.

>
> Consider a sender application that performs write calls every 30 ms o=
n a
> 150 ms RTT link. It will need a CWND that allows 5-6 PIFs to be able =
to
> transmit all new data segments with no extra sojourn times on the sen=
der
> side.
> When one packet is lost, the next 5 packets that are sent will be hel=
d
> back on the receiver side due to the missing segment (HOLB). In the b=
est
> case scenario, the first dupACK triggers a fast retransmit around the
> same time as the fifth packet (after the lost packet) is sent. In tha=
t
> case, the first segment sent after the lost segment is held back on t=
he
> receiver for 150 ms (the time it takes for the dupACK to reach the
> sender, and the fast retrans to arrive at the receiver). The second i=
s
> held back 120 ms, the third 90 ms, the fourth 60 ms, an the fifth 30 =
ms.
>
> All of this extra delay is added before the sender even knows there w=
as
> a loss. How it decides to react to the loss signal (dupACKs) will
> further decide how much extra delays will be added in addition to the
> delays already inflicted on the segments by the HOLB.
>
>> Instead what if we only perform RDB on the (first and recurring) RTO
>> retransmission?
>
> That will change RDB from being a proactive mechanism, to being
> reactive, i.e. change how the sender responds to the loss signal. The
> problem is that by this point (when the sender has received the loss
> signal), the HOLB on the receiver side has already caused significant
> increases to the application layer latency.
>
> The reason the RDB streams (in red) in fig. 4 in the paper get such l=
ow
> latencies is because there are almost no retransmissions. With 10%
> uniform loss, the latency for 90% of the packets is not affected at a=
ll.
> The latency for most of the lost segments is only increased by 30 ms,
> which is when the next RDB packet arrives at the receiver with the lo=
st
> segment bundled in the payload.
> For the regular TCP streams (blue), the latency for 40% of the segmen=
ts
> is affected, where almost 30% of the segments have additional delays =
of
> 150 ms or more.
> It is important to note that the increases to the latencies for the
> regular TCP streams compared to the RDB streams are solely due to HOL=
B
> on the receiver side.
>
> The longer the RTT, the greater the gains are by using RDB, consideri=
ng
> the best case scenario of minimum one RTT required for a retransmissi=
on.
> As such, RDB will reduce the latencies the most for those that also n=
eed
> it the most.
>
> However, even with an RTT of 20 ms, an application writing a data
> segment every 10 ms will still get significant latency reductions sim=
ply
> because a retransmission will require a minimum of 20 ms, compared to
> the 10 ms it takes for the next RDB packet to arrive at the receiver.
>
>
> Bendik
