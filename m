From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 1/1] tcp: fix spurious undos in CA_Open
Date: Mon, 12 Dec 2011 14:40:36 -0500
Message-ID: <CADVnQy=kw6MgySY+xF7WcB+0fXyDYk66Phc1R+dBK8=emu6kXQ@mail.gmail.com>
References: <alpine.DEB.2.00.1111170715060.23028@melkinpaasi.cs.helsinki.fi>
	<CADVnQykNffEvpr5bnLiLyNGZiuhxx=5wxqFaZjC+Dk4mxe1Okw@mail.gmail.com>
	<alpine.DEB.2.00.1111221347290.31705@wel-95.cs.helsinki.fi>
	<20111127.185857.475440859115872225.davem@davemloft.net>
	<CADVnQykS7w_OzQBa=Lqw=EU=qkXxsXeWSwfVrRj+_Yx4NgxHGw@mail.gmail.com>
	<alpine.DEB.2.00.1112121359470.15137@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, nanditad@google.com,
	Yuchung Cheng <ycheng@google.com>, therbert@google.com
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:33375 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227Ab1LLTlF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 14:41:05 -0500
Received: by qcqz2 with SMTP id z2so3868306qcq.19
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 11:41:04 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1112121359470.15137@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2011 at 7:05 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Mon, 28 Nov 2011, Neal Cardwell wrote:
>
>> On Sun, Nov 27, 2011 at 6:58 PM, David Miller <davem@davemloft.net> =
wrote:
>>
>> >> Also, one (serious) word of caution! This change, by its extendin=
g of
>> >> CA_Open state, is somewhat similar to what I made FRTO years ago,=
 and
>> >> managed to introduces subtle breaking to the state machine. Pleas=
e check
>> >> that the problem similar to what was fixed by
>> >> a1c1f281b84a751fdb5ff919da3b09df7297619f does not reappear (possi=
bly in
>> >> some other form causing spurious undos). ...To me it seems that
>> >> tcp_packet_delayed might be similarly confused after the given pa=
tch.
>> >
>> > Neil, please look into this so we can have any such issues fixed
>> > in time for the next merge window.
>>
>> Absolutely. I will look into the areas that Ilpo mentioned.
>
> Unfortunately nothing has happened? So I finally had to come up somet=
hing
> myself. ...Compile tested only.

Sorry for the radio silence, but I have been looking at this. So far
it's been a time-consuming process, as we've uncovered a number of
pre-existing issues in tcp_packet_delayed that seem like quite serious
bugs:

1) tcp_packet_delayed implicitly assumes, but does not verify, that
the ACK in question (whose ECR field precedes retrans_stamp) covers
all retransmitted segments. So if we retransmit segments 1 and 2, and
then get an ACK for 1 that has an ECR indicating it was for the
original copy of segment 1, then we undo,  even in cases where segment
2 really was lost and needed to be retransmitted.

2) tcp_packet_delayed implicitly assumes that if we retransmit a
packet that was truly lost then any ACK for the retransmitted instance
of that packet will echo the timestamp field in the retransmitted
packet. But if the receiver is implementing delayed ACKs and correctly
implements timestamps per RFC 1323, then the receiver will be obeying
this clause: "Thus, when delayed ACKs are in use, the receiver should
reply with the TSval field from the earliest unacknowledged segment."
Thus tcp_packet_delayed can cause spurious undos in the following
circumstances:

- send segment 1 with tsval 10
- receiver is doing delayed ACKs and does not ACK 1 but sets TS.Recent =
to 10
- send segment 2 with tsval 20
- segment 2 is lost in transit
- RTO, retransmit segment 2 with tsval 30
- receiver sends delayed ACK for packets 1 and 2 with TS.Recent of 10
- sender receives ACK for packet 2 with tsecho of 10, lower than 30,
and thinks RTO was spurious

=46or better or worse, both of these bugs appear to be inherited from
the Eifel Detection Algorithm RFC (RFC 3522).

In any case, we've been working on coming up with a solution for these =
issues.

> --
> [PATCH 1/1] tcp: fix spurious undos in CA_Open
>
> There's a landmine in tcp_packet_delayed. In CA_Open the
> retrans_stamp is very eagerly cleared which falsely triggers
> packet-delayed detection. Therefore this code cannot be used
> in CA_Open if the retrans_stamp was already cleared.
>
> This became issue once DSACK detection was extended to happen
> in CA_Open state too (f698204bd0b, tcp: allow undo from
> reordered DSACKs). Essentially the whole congestion control
> is disabled because the undos now always restore the previous
> window. I wonder if this was already in production... ...at
> least the Internet didn't melt ;-).

I'm pretty sure this commit is unnecessary. It seems like a NOP. Note
that tcp_may_undo and tcp_packet_delayed are never called in state
TCP_CA_Open. tcp_may_undo is only called from tcp_try_undo_recovery,
tcp_try_undo_partial, and tcp_try_undo_loss, and to call any of these
functions you must be in either TCP_CA_Loss or TCP_CA_Recovery. Only
tcp_try_undo_dsack is called from TCP_CA_Open, but it makes no
reference to retrans_stamp.

Please let me know if I'm missing something, or if there's a specific
scenario you're concerned about.

thanks,
neal
