From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH RFC 5/6] net/faraday: Enable NCSI interface
Date: Tue, 10 Nov 2015 21:34:49 +1100
Message-ID: <1447151689.31884.79.camel@kernel.crashing.org>
References: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
	 <1447027806-4744-6-git-send-email-gwshan@linux.vnet.ibm.com>
	 <1447029127.8727.29.camel@kernel.crashing.org>
	 <20151109073032.GA10235@gwshan>
	 <1447100904.31884.26.camel@kernel.crashing.org>
	 <20151110061249.GA8006@gwshan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	sergei.shtylyov@cogentembedded.com
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40216 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752305AbbKJKfA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2015 05:35:00 -0500
In-Reply-To: <20151110061249.GA8006@gwshan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-10 at 17:12 +1100, Gavin Shan wrote:
>=20
> > So we require the interface to be opened to talk, so far so good,
> > the NC-SI stack doesn't even need to open it itself, it's acceptabl=
e
> > to require userspace to do it. IE. Userspace will chose what interf=
ace
> > to use, open it (for DHCP etc... or whatever other reason) and *tha=
t*
> > will then trigger the NC-SI negociation.
> >=20
>=20
> Yes, NCSI is smiliar to PHY to some extent. However, PHY's negotiatio=
n
> is purly electrical procedure, no packets received from MAC for it. W=
e
> have the same situation when the NCSI/PHY is going to be brought down=
=2E

Right but we similarily only support PHY nego once the driver is open,
at least on most drivers. The only difference really is that we only
set the netif_carrier_on() when the PHY detects a link, while for NC-SI=
=20
we currently need to keep it on always or we lose the queues, but that
can be looked at separately.

> At the beginning, the NCSI packets can be received and transmitted af=
ter
> the interface is opened.

Right.

>  Before NCSI negotiation is done, no other packets
> can be received and transmitted.

The interface doesn't care. We can transmit them, they just may not go
anywhere, its not our problem. Similarily, the companion NIC may or may
not forward incoming packets before the nego is complete, we don't
actually have to care or enforce anything here.

>  For the Rx path (for other packets), the
> NCSI link isn't enabled when NCSI negotiation isn't finished. There m=
ight
> have lots of egress packets whose IP addresses can't be resolved to M=
AC
> address as ARP resolution doesn't work before NCSI negotiation is don=
e.

Correct, but is that a problem ? it's the same thing when we don't have
a link, though I suppose we have a faster path to drop them when the
carrier is down.

> So there is a weird window: interface is up, but no packets (except N=
CSI
> packets) can be received or transmitted.

Right but that's similar to what we used to do before we had
"intelligent" PHY control... our drivers didn't always know when the
link was up or even if there was a cable plugged.

I agree, it would be nicer to have the "Carrier" follow the
establishment of the NC-SI link, and we should look into fixing that
separately, possibly by establishing a special queue discipline rather
than noop when in that "limbo" mode, but that shouldn't be a blocker
for the patches and certainly doesn't require your driver change that
deals with interrupts while the interface is closed.

> When the interface is brought down, for example by "ifconfig eth0 dow=
n",
> The NCSI interface needs to be teared down by transmitting and receiv=
ing
> NCSI commands and responses.

That can be done synchronously from the close callback (With timeouts),
can't it ? If the core messes around with our state before close is
called, then we need to do something in the netdev core. However, it's
probably fine to just not do anything, worst case the companion NIC
will forward packets to a closed interface. Not a big deal and
definitely not a show stopper.

>  Similiarly, it introduces another weird window:
> interface is down, but NCSI packets still can be transmitted and rece=
ived.

No, when interface is down, it's down. Nothing comes in and out, we
free the rings, rx skb's, interrupt, it's all gone. We even power down
the NIC in most cases.

Ben.

> > Cheers,
> > Ben.
> >=20
>=20
> Thanks,
> Gavin
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at=C2=A0=C2=A0http://vger.kernel.org/majordomo-in=
fo.html
