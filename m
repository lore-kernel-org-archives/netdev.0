From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/1] tcp: fix spurious undos in CA_Open
Date: Wed, 14 Dec 2011 10:57:07 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1112141034010.7753@melkinpaasi.cs.helsinki.fi>
References: <alpine.DEB.2.00.1111170715060.23028@melkinpaasi.cs.helsinki.fi> <CADVnQykNffEvpr5bnLiLyNGZiuhxx=5wxqFaZjC+Dk4mxe1Okw@mail.gmail.com> <alpine.DEB.2.00.1111221347290.31705@wel-95.cs.helsinki.fi> <20111127.185857.475440859115872225.davem@davemloft.net>
 <CADVnQykS7w_OzQBa=Lqw=EU=qkXxsXeWSwfVrRj+_Yx4NgxHGw@mail.gmail.com> <alpine.DEB.2.00.1112121359470.15137@wel-95.cs.helsinki.fi> <CADVnQy=kw6MgySY+xF7WcB+0fXyDYk66Phc1R+dBK8=emu6kXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1174564309-1323853027=:7753"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, nanditad@google.com,
	Yuchung Cheng <ycheng@google.com>, therbert@google.com
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55387 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734Ab1LNI5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 03:57:09 -0500
In-Reply-To: <CADVnQy=kw6MgySY+xF7WcB+0fXyDYk66Phc1R+dBK8=emu6kXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1174564309-1323853027=:7753
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 12 Dec 2011, Neal Cardwell wrote:

> On Mon, Dec 12, 2011 at 7:05 AM, Ilpo Järvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
> > On Mon, 28 Nov 2011, Neal Cardwell wrote:
> >
> >> On Sun, Nov 27, 2011 at 6:58 PM, David Miller <davem@davemloft.net> wrote:
> >>
> >> >> Also, one (serious) word of caution! This change, by its extending of
> >> >> CA_Open state, is somewhat similar to what I made FRTO years ago, and
> >> >> managed to introduces subtle breaking to the state machine. Please check
> >> >> that the problem similar to what was fixed by
> >> >> a1c1f281b84a751fdb5ff919da3b09df7297619f does not reappear (possibly in
> >> >> some other form causing spurious undos). ...To me it seems that
> >> >> tcp_packet_delayed might be similarly confused after the given patch.
> >> >
> >> > Neil, please look into this so we can have any such issues fixed
> >> > in time for the next merge window.
> >>
> >> Absolutely. I will look into the areas that Ilpo mentioned.
> >
> > Unfortunately nothing has happened? So I finally had to come up something
> > myself. ...Compile tested only.
> 
> Sorry for the radio silence, but I have been looking at this. So far
> it's been a time-consuming process, as we've uncovered a number of
> pre-existing issues in tcp_packet_delayed that seem like quite serious
> bugs:
> 
> 1) tcp_packet_delayed implicitly assumes, but does not verify, that
> the ACK in question (whose ECR field precedes retrans_stamp) covers
> all retransmitted segments. So if we retransmit segments 1 and 2, and
> then get an ACK for 1 that has an ECR indicating it was for the
> original copy of segment 1, then we undo,  even in cases where segment
> 2 really was lost and needed to be retransmitted.

I think this might be an mis-implementation in tcp_try_undo_partial.

> 2) tcp_packet_delayed implicitly assumes that if we retransmit a
> packet that was truly lost then any ACK for the retransmitted instance
> of that packet will echo the timestamp field in the retransmitted
> packet. But if the receiver is implementing delayed ACKs and correctly
> implements timestamps per RFC 1323, then the receiver will be obeying
> this clause: "Thus, when delayed ACKs are in use, the receiver should
> reply with the TSval field from the earliest unacknowledged segment."
> Thus tcp_packet_delayed can cause spurious undos in the following
> circumstances:
>
> - send segment 1 with tsval 10
> - receiver is doing delayed ACKs and does not ACK 1 but sets TS.Recent to 10
> - send segment 2 with tsval 20
> - segment 2 is lost in transit
> - RTO, retransmit segment 2 with tsval 30
> - receiver sends delayed ACK for packets 1 and 2 with TS.Recent of 10
> - sender receives ACK for packet 2 with tsecho of 10, lower than 30,
> and thinks RTO was spurious

About this I'm actually aware of, I have even some long email postponed 
related to this to discuss in context of 1323bis (as 1323bis seems pretty 
much standstill I'm not in a big hurry :-)). I think 1323 algo is flawed 
anyway and it was fixed/clarified/better in the bis (which doesn't 
address this well enough though).

I discovered this while I setup a network with ACK losses to figure out 
other issue. I discovered that the RTT measurements occassionally took 
"the wrong TS" bloating the RTT estimate. As RTT samples included RTO 
delays, with enough ACK losses the RTO eventually hits the max value. 
...As a result, not very nice performance was acquired for that such a 
flow.

I think there are two possible solutions:
  1) Echo latest timestamp for below window packets (I'm not sure if 
  there's can of worms w.r.t. security in this approach). A good thing
  in this would be that it would really solve the rexmit ambiguity problem 
  which the current approach does not do.
  2) Ignore packets with DSACK in RTT measurement.

1323bis is not of much help in this which TS to echo (which is why I 
intented to mention it on tcpm). IIRC, it depended on which takes 
precedence: RFC793 in-window check or the given TS algorithm, which is 
not discussed anywhere.

> For better or worse, both of these bugs appear to be inherited from
> the Eifel Detection Algorithm RFC (RFC 3522).

RFC3522 does not have the issue 1) as it's working after RTO+first ACK 
only. The second issue is valid for it though.

> In any case, we've been working on coming up with a solution for these issues.
> 
> > --
> > [PATCH 1/1] tcp: fix spurious undos in CA_Open
> >
> > There's a landmine in tcp_packet_delayed. In CA_Open the
> > retrans_stamp is very eagerly cleared which falsely triggers
> > packet-delayed detection. Therefore this code cannot be used
> > in CA_Open if the retrans_stamp was already cleared.
> >
> > This became issue once DSACK detection was extended to happen
> > in CA_Open state too (f698204bd0b, tcp: allow undo from
> > reordered DSACKs). Essentially the whole congestion control
> > is disabled because the undos now always restore the previous
> > window. I wonder if this was already in production... ...at
> > least the Internet didn't melt ;-).
> 
> I'm pretty sure this commit is unnecessary. It seems like a NOP. Note
> that tcp_may_undo and tcp_packet_delayed are never called in state
> TCP_CA_Open. tcp_may_undo is only called from tcp_try_undo_recovery,
> tcp_try_undo_partial, and tcp_try_undo_loss, and to call any of these
> functions you must be in either TCP_CA_Loss or TCP_CA_Recovery. Only
> tcp_try_undo_dsack is called from TCP_CA_Open, but it makes no
> reference to retrans_stamp.

It seems that I've missed this difference in tcp_try_undo_dsack (well, 
seen it but never thought it that much). I think you're right. Thanks for 
taking a look.

Some WARN_ON to enforce this !CA_Open condition there might not hurt 
though.

-- 
 i.
--8323329-1174564309-1323853027=:7753--
