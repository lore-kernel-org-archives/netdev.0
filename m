From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 1/1] tcp: fix spurious undos in CA_Open
Date: Sun, 18 Dec 2011 13:23:00 -0500
Message-ID: <CADVnQykHUn8GKF9xp8ACh+pNHVJstvkmDi2Nax2_oFJaz3rc_Q@mail.gmail.com>
References: <alpine.DEB.2.00.1111170715060.23028@melkinpaasi.cs.helsinki.fi>
	<CADVnQykNffEvpr5bnLiLyNGZiuhxx=5wxqFaZjC+Dk4mxe1Okw@mail.gmail.com>
	<alpine.DEB.2.00.1111221347290.31705@wel-95.cs.helsinki.fi>
	<20111127.185857.475440859115872225.davem@davemloft.net>
	<CADVnQykS7w_OzQBa=Lqw=EU=qkXxsXeWSwfVrRj+_Yx4NgxHGw@mail.gmail.com>
	<alpine.DEB.2.00.1112121359470.15137@wel-95.cs.helsinki.fi>
	<CADVnQy=kw6MgySY+xF7WcB+0fXyDYk66Phc1R+dBK8=emu6kXQ@mail.gmail.com>
	<alpine.DEB.2.00.1112141034010.7753@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, nanditad@google.com,
	Yuchung Cheng <ycheng@google.com>, therbert@google.com
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:56722 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751841Ab1LRSXB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2011 13:23:01 -0500
Received: by qcqz2 with SMTP id z2so2709955qcq.19
        for <netdev@vger.kernel.org>; Sun, 18 Dec 2011 10:23:00 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1112141034010.7753@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 14, 2011 at 3:57 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Mon, 12 Dec 2011, Neal Cardwell wrote:
>
>> On Mon, Dec 12, 2011 at 7:05 AM, Ilpo J=E4rvinen
>> <ilpo.jarvinen@helsinki.fi> wrote:
>> > On Mon, 28 Nov 2011, Neal Cardwell wrote:
>> >
>> >> On Sun, Nov 27, 2011 at 6:58 PM, David Miller <davem@davemloft.ne=
t> wrote:
>> >>
>> >> >> Also, one (serious) word of caution! This change, by its exten=
ding of
>> >> >> CA_Open state, is somewhat similar to what I made FRTO years a=
go, and
>> >> >> managed to introduces subtle breaking to the state machine. Pl=
ease check
>> >> >> that the problem similar to what was fixed by
>> >> >> a1c1f281b84a751fdb5ff919da3b09df7297619f does not reappear (po=
ssibly in
>> >> >> some other form causing spurious undos). ...To me it seems tha=
t
>> >> >> tcp_packet_delayed might be similarly confused after the given=
 patch.
>> >> >
>> >> > Neil, please look into this so we can have any such issues fixe=
d
>> >> > in time for the next merge window.
>> >>
>> >> Absolutely. I will look into the areas that Ilpo mentioned.
>> >
>> > Unfortunately nothing has happened? So I finally had to come up so=
mething
>> > myself. ...Compile tested only.
>>
>> Sorry for the radio silence, but I have been looking at this. So far
>> it's been a time-consuming process, as we've uncovered a number of
>> pre-existing issues in tcp_packet_delayed that seem like quite serio=
us
>> bugs:
>>
>> 1) tcp_packet_delayed implicitly assumes, but does not verify, that
>> the ACK in question (whose ECR field precedes retrans_stamp) covers
>> all retransmitted segments. So if we retransmit segments 1 and 2, an=
d
>> then get an ACK for 1 that has an ECR indicating it was for the
>> original copy of segment 1, then we undo, =A0even in cases where seg=
ment
>> 2 really was lost and needed to be retransmitted.
>
> I think this might be an mis-implementation in tcp_try_undo_partial.

Yeah, I'm pretty sure this is a bug. There needs to be some additional
logic, whether in tcp_try_undo_partial or tcp_packet_delayed, or
somewhere else, to fix this bug.


>> 2) tcp_packet_delayed implicitly assumes that if we retransmit a
>> packet that was truly lost then any ACK for the retransmitted instan=
ce
>> of that packet will echo the timestamp field in the retransmitted
>> packet. But if the receiver is implementing delayed ACKs and correct=
ly
>> implements timestamps per RFC 1323, then the receiver will be obeyin=
g
>> this clause: "Thus, when delayed ACKs are in use, the receiver shoul=
d
>> reply with the TSval field from the earliest unacknowledged segment.=
"
>> Thus tcp_packet_delayed can cause spurious undos in the following
>> circumstances:
>>
>> - send segment 1 with tsval 10
>> - receiver is doing delayed ACKs and does not ACK 1 but sets TS.Rece=
nt to 10
>> - send segment 2 with tsval 20
>> - segment 2 is lost in transit
>> - RTO, retransmit segment 2 with tsval 30
>> - receiver sends delayed ACK for packets 1 and 2 with TS.Recent of 1=
0
>> - sender receives ACK for packet 2 with tsecho of 10, lower than 30,
>> and thinks RTO was spurious
>
> About this I'm actually aware of, I have even some long email postpon=
ed
> related to this to discuss in context of 1323bis (as 1323bis seems pr=
etty
> much standstill I'm not in a big hurry :-)). I think 1323 algo is fla=
wed
> anyway and it was fixed/clarified/better in the bis (which doesn't
> address this well enough though).
>
> I discovered this while I setup a network with ACK losses to figure o=
ut
> other issue. I discovered that the RTT measurements occassionally too=
k
> "the wrong TS" bloating the RTT estimate. As RTT samples included RTO
> delays, with enough ACK losses the RTO eventually hits the max value.
> ...As a result, not very nice performance was acquired for that such =
a
> flow.
>
> I think there are two possible solutions:
> =A01) Echo latest timestamp for below window packets (I'm not sure if
> =A0there's can of worms w.r.t. security in this approach). A good thi=
ng
> =A0in this would be that it would really solve the rexmit ambiguity p=
roblem
> =A0which the current approach does not do.
> =A02) Ignore packets with DSACK in RTT measurement.
>
> 1323bis is not of much help in this which TS to echo (which is why I
> intented to mention it on tcpm). IIRC, it depended on which takes
> precedence: RFC793 in-window check or the given TS algorithm, which i=
s
> not discussed anywhere.

Interesting. I hope the standards get improved in this area.


>> For better or worse, both of these bugs appear to be inherited from
>> the Eifel Detection Algorithm RFC (RFC 3522).
>
> RFC3522 does not have the issue 1) as it's working after RTO+first AC=
K
> only. The second issue is valid for it though.

Actually RFC 3522 does have issue 1) because it is also in effect for
fast retransmit / fast recovery; RFC 3522 says "If the Eifel detection
algorithm is used, the following steps MUST be taken by a TCP sender,
but only upon initiation of loss recovery, i.e., when either the
timeout-based retransmit or the fast retransmit is sent."

In addition, RFC 3517 allows senders to send out multiple
retransmissions upon the first ACK that initiates fast recovery:
Section 5., Algorithm Details, says "(5) In order to take advantage of
potential additional available cwnd, proceed to step (C) below. ...
(C) If cwnd - pipe >=3D 1 SMSS the sender SHOULD transmit one or more
segments." As a consequence, senders can have multiple retransmissions
in flight at the point they get the first ACK during fast recovery, at
which point they run the Eifel detection algorithm.

So I'm pretty sure 1) is an issue both in the RFCs and in Linux.


>> In any case, we've been working on coming up with a solution for the=
se issues.
>>
>> > --
>> > [PATCH 1/1] tcp: fix spurious undos in CA_Open
>> >
>> > There's a landmine in tcp_packet_delayed. In CA_Open the
>> > retrans_stamp is very eagerly cleared which falsely triggers
>> > packet-delayed detection. Therefore this code cannot be used
>> > in CA_Open if the retrans_stamp was already cleared.
>> >
>> > This became issue once DSACK detection was extended to happen
>> > in CA_Open state too (f698204bd0b, tcp: allow undo from
>> > reordered DSACKs). Essentially the whole congestion control
>> > is disabled because the undos now always restore the previous
>> > window. I wonder if this was already in production... ...at
>> > least the Internet didn't melt ;-).
>>
>> I'm pretty sure this commit is unnecessary. It seems like a NOP. Not=
e
>> that tcp_may_undo and tcp_packet_delayed are never called in state
>> TCP_CA_Open. tcp_may_undo is only called from tcp_try_undo_recovery,
>> tcp_try_undo_partial, and tcp_try_undo_loss, and to call any of thes=
e
>> functions you must be in either TCP_CA_Loss or TCP_CA_Recovery. Only
>> tcp_try_undo_dsack is called from TCP_CA_Open, but it makes no
>> reference to retrans_stamp.
>
> It seems that I've missed this difference in tcp_try_undo_dsack (well=
,
> seen it but never thought it that much). I think you're right. Thanks=
 for
> taking a look.
>
> Some WARN_ON to enforce this !CA_Open condition there might not hurt
> though.

Sounds reasonable. I'll think about this as I work on coming up with a
fix for the 1) and 2) bugs discussed above.

neal
