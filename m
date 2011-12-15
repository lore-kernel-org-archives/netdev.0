From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: twice past the taps, thence out to net?
Date: Thu, 15 Dec 2011 18:43:18 +0100
Message-ID: <1323970998.2769.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EE8F884.1010304@hp.com>
	 <CAGK4HS-+jj9cvvirDm96oRvRJdwC+2kjE_LnSOXBuQy0pfnQjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, tcpdump-workers@lists.tcpdump.org,
	netdev@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62469 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab1LORnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 12:43:24 -0500
Received: by eaaj10 with SMTP id j10so2163893eaa.19
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 09:43:23 -0800 (PST)
In-Reply-To: <CAGK4HS-+jj9cvvirDm96oRvRJdwC+2kjE_LnSOXBuQy0pfnQjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 d=C3=A9cembre 2011 =C3=A0 18:12 -0800, Vijay Subramanian=
 a =C3=A9crit :
> On 14 December 2011 11:27, Rick Jones <rick.jones2@hp.com> wrote:
> > While looking at "something else" with tcpdump/tcptrace, tcptrace e=
mitted
> > lots of notices about hardware duplicated packets being detected (s=
ame TCP
> > sequence number and IP datagram ID).  Sure enough, if I go into the=
 tcpdump
> > trace (taken on the sender) I can find instances of what it was tal=
king
> > about, separated in time by rather less than I would expect to be t=
he RTO,
> > and often as not with few if any intervening arriving ACKs to trigg=
er
> > anything like fast retransmit.  And besides, those would have a dif=
ferent IP
> > datagram ID no?
> >
> > I did manage to reproduce the issue with plain netperf tcp_stream t=
ests. I
> > had one sending system with 30 concurrent netperf tcp_stream tests =
to 30
> > other receiving systems.  There are "hardware duplicates" in the se=
nding
> > trace, but no duplicate segments (that I can find thus far) in the =
two
> > receiver side traces I took.  Of course that doesn't mean "conclusi=
vely"
> > there were two actual sends but it suggests there werent.
> >
> > While I work through the "obtain permission" path to post the packe=
t traces
> > (don't ask...) I thought I would ask if anyone else has seen someth=
ing
> > similar.
> >
> > In this case, all the systems are running a 2.6.38-8 Ubuntu kernel =
(the same
> > sorts of issues which delay my just putting the traces up on netper=
f.org
> > preclude a later kernel, and I've no other test systems :( ), with =
Intel
> > 82576 interfaces being driven by:
> >
> > $ sudo ethtool -i eth0
> > driver: igb
> > version: 2.1.0-k2
> > firmware-version: 1.8-2
> > bus-info: 0000:05:00.0
> >
> > All the systems were connected to the same switch.
> >
>=20
> Rick,
> This may be of help.
> http://www.tcptrace.org/faq_ans.html#FAQ%2021

More exactly, we call dev_queue_xmit_nit() from dev_hard_start_xmit()
_before_ giving skb to device driver.

If device driver returns NETDEV_TX_BUSY, and a qdisc was setup on the
device, packet is requeued.

Later, when queue is allowed to send again packets, packet is
retransmitted (and traced a second time in dev_queue_xmit_nit())

You can see the 'requeues' counter from "tc -s -d qdisc" output :

qdisc mq 0: dev eth2 root=20
 Sent 29421597369 bytes 20301716 pkt (dropped 0, overlimits 0 requeues =
371)=20
 backlog 0b 0p requeues 371=20
