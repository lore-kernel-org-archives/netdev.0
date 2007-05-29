From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 0/9]: tcp-2.6 patchset
Date: Tue, 29 May 2007 14:15:27 -0700
Message-ID: <20070529141527.21e6dbec@freepuppy>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20070526.164418.115928217.davem@davemloft.net>
	<Pine.LNX.4.64.0705271039060.2532@kivilampi-30.cs.helsinki.fi>
	<20070527.021104.74747736.davem@davemloft.net>
	<Pine.LNX.4.64.0705271319310.2663@kivilampi-30.cs.helsinki.fi>
	<20070527140430.GA30299@galon.ev-en.org>
	<Pine.LNX.4.64.0705271933440.2832@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0705281253340.14736@kivilampi-30.cs.helsinki.fi>
	<20070529091415.03a14216@freepuppy>
	<Pine.LNX.4.64.0705292150390.23565@kivilampi-30.cs.helsinki.fi>
	<20070529131951.1d9a5b84@freepuppy>
	<Pine.LNX.4.64.0705292335080.23565@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Baruch Even <baruch@ev-en.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVuIg==?= <ilpo.jarvinen@helsinki.fi>"@smtp.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:41886 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbXE2VZB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 17:25:01 -0400
In-Reply-To: <Pine.LNX.4.64.0705292335080.23565@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 May 2007 23:58:39 +0300 (EEST)
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> On Tue, 29 May 2007, Stephen Hemminger wrote:
>=20
> > On Tue, 29 May 2007 23:07:00 +0300 (EEST)
> > "Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> >=20
> > > On Tue, 29 May 2007, Stephen Hemminger wrote:
> > >=20
> > > > Since we don't invoke congestion control modules until after th=
e SYN
> > > > handshake this is not a problem.
> > >=20
> > > Just curious, do you mean that cc modules cannot measure, e.g., i=
nitial
> > > RTT through this mechanism (though they could do that in init() c=
b then
> > > I suppose)... Or do you mean that they are called already for the=
 ACK
> > > that completes the SYN handshake and therefore its skb is being c=
leaned=20
> > > from the queue right now (this is the case I above refer to)?=20
> > > In the first case the decrementer code is NOP. If the latter, the=
n it
> > > is just interface specification question, i.e., if SYNs are treat=
ed as=20
> > > zero or one in num_acked for the pkts_acked callback (I have no o=
pinion
> > > on this but was just trying to make sure cc modules get what they
> > > expect :-)).=20
> >=20
> > We don't switch a socket out of Reno until after the initial handsh=
ake.
>=20
> ...It's still not very clear to me what exactly your "after" means (b=
oth=20
> here and in your earlier description), i.e., whether clean_rtx_queue =
call=20
> that cleans SYN skb from the queue happens before or after the switch=
 out=20
> of reno or not... If I understand the code correctly, this specific=20
> clean_rtx_queue call happens after "your after" but I could be=20
> misunderstanding the current 3-way handshake code. :-)

The call to clean_rtx_queue and congestion control routine happens here=
:
    tcp_ack
       tcp_clean_rtx_queue
          cong->pkts_acked

Setup of congestion control happens here:
    tcp_ack
    tcp_rcv_syn_sent_state_process
      tcp_init_congestion_control

or here:
    tcp_ack
    tcp_rcv_state_process (case ack of TCP_SYN_RECV)
       tcp_init_congestion_control
    =20
Another benefit of this, is that when tcp_init_congestion_control is ca=
lled
things like the srtt and initial sequence number have already been setu=
p.

> > As an interface, it makes sense to keep the API with the SYN counti=
ng
> > as a packet.
>=20
> Ok, this one answers the remaining question concerning the patch, her=
e
> is it without the decrementer for SYN case (which IMHO wasn't very=20
> beautiful looking anyway :-)).
>=20
> Dave, please consider this to net-2.6. It could be a stable candidate=
=20
> as well, haven't tested yet if it applies cleanly to stable:


--=20
Stephen Hemminger <shemminger@linux-foundation.org>
