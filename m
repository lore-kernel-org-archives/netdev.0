From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 00/46] Clean up RX copybreak and DMA handling
Date: Mon, 11 Jul 2011 13:36:35 +0100
Message-ID: <1310387795.8783.94.camel@localhost>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
	 <20110710.235458.1549578255936886669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:44999 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667Ab1GKMgi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 08:36:38 -0400
In-Reply-To: <20110710.235458.1549578255936886669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-07-10 at 23:54 -0700, David Miller wrote:
> From: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> Date: Mon, 11 Jul 2011 02:52:46 +0200 (CEST)
>=20
> >   1. under packet storm and memory pressure NIC keeps generating in=
terrupts
> >      (if non-NAPI) and indicating new buffers because it always has=
 free
> >      RX buffers --- this only wastes CPU and bus bandwidth transfer=
ring
> >      data that is going to be immediately discarded;
>=20
> Actually, this is exactly how I, and others advise people to implemen=
t
> drivers.  It is the right thing to do.
>=20
> The worst thing that can happen is to let the RX ring empty of
> buffers.  Some cards hang as a result of this, and also it causes hea=
d
> of line blocking on multiqueue cards, etc.

The controllers you are familiar with might do head-of-line blocking
when a single RX queue is empty.  But any multiqueue controller that is
supposed to support untrusted queues (required for SR-IOV) had better
not.  This is certainly not done on Solarflare controllers (packets for
that queue just get dropped until it's refilled) and I doubt it's done
on many others.

I also think it's quite reasonable for the RX queue to stop interruptin=
g
when the host is already too busy to refill it.  Some drivers might not
recover correctly, but this is not a hardware issue.

> So the first thing the driver should do is try to allocate a
> replacement buffer.
>=20
> And if that fails, it should give the RX packet right back to the
> card, and not pass it up the stack.

I agree this is a reasonable and generic way to deal with empty RX
queues.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

