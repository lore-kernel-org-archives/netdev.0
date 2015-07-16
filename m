From: Simon Guinot <simon.guinot@sequanux.org>
Subject: Re: [PATCH] net: mvneta: fix refilling for Rx DMA buffers
Date: Thu, 16 Jul 2015 02:25:30 +0200
Message-ID: <20150716002530.GD10671@kw.sim.vm.gnt>
References: <1436738697-21652-1-git-send-email-simon.guinot@sequanux.org>
 <20150715.155256.1854323748613951804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fOHHtNG4YXGJ0yqR"
Cc: thomas.petazzoni@free-electrons.com, jason@lakedaemon.net,
	andrew@lunn.ch, gregory.clement@free-electrons.com,
	sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, vdonnefort@gmail.com,
	yoann@sculo.fr, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vm1.sequanux.org ([188.165.36.56]:44643 "EHLO vm1.sequanux.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754299AbbGPAZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2015 20:25:34 -0400
Content-Disposition: inline
In-Reply-To: <20150715.155256.1854323748613951804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--fOHHtNG4YXGJ0yqR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 15, 2015 at 03:52:56PM -0700, David Miller wrote:
> From: Simon Guinot <simon.guinot@sequanux.org>
> Date: Mon, 13 Jul 2015 00:04:57 +0200
>=20
> > On some Armada 370-based NAS, I have experimented kernel bugs and
> > crashes when the mvneta Ethernet driver fails to refill Rx DMA buffers
> > due to memory shortage.
> >=20
> > With the actual code, if the memory allocation fails while refilling a
> > Rx DMA buffer, then the corresponding descriptor is let with the address
> > of an unmapped DMA buffer already passed to the network stack. Since the
> > driver still increments the non-occupied counter for Rx descriptor (if a
> > next packet is handled successfully), then the Ethernet controller is
> > allowed to reuse the unfilled Rx descriptor...
> >=20
> > As a fix, this patch first refills a Rx descriptor before handling the
> > stored data and unmapping the associated Rx DMA buffer. Additionally the
> > occupied and non-occupied counters for the Rx descriptors queues are now
> > both updated with the rx_done value: the number of descriptors ready to
> > be returned to the networking controller. Moreover note that there is no
> > point in using different values for this counters because both the
> > mvneta driver and the Ethernet controller are unable to handle holes in
> > the Rx descriptors queues.
> >=20
> > Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
> > Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP net=
work unit")
> > Cc: <stable@vger.kernel.org> # v3.8+
> > Tested-by: Yoann Sculo <yoann@sculo.fr>

Hi David,

>=20
> Failed memory allocations, are normal and if necessary kernel log
> messages will be triggered by the core memory allocator.  So there is
> zero reason to do anything other than bump the drop counter in your
> driver.

Sure.

>=20
> If I understand the rest of your logic, if the allocator fails, we
> will reuse the original SKB and place it back into the RX ring?
> Right?

Yes that's what does the patch.

Without this patch, in case of memory allocation error, the original
buffer is both passed to the networking stack in a SKB _and_ let in
the Rx ring. This leads to various kernel oops and crashes.

Here are the problems with the original code:

- Rx descriptor refilling is tried after passing the SKB to the
  networking stack.
- In case of refilling error, the buffer (passed in the SKB) is also
  let in the Rx ring (as an unmapped DMA buffer).
- And (always in case of refilling error), the non-occupied counter of
  the Rx queue (hardware register) is not incremented. The idea was
  maybe to prevent the networking controller to reuse the non-refilled
  descriptor. But since this counter is incremented as soon as a next
  descriptor is handled successfully, it is not correct.

The patch:

- Moves Rx descriptor refilling ahead of passing the SKB to the
  networking stack.
- places the buffer back into the Rx ring in case of refilling error.
- And updates correctly the non-occupied descriptors counter of the Rx
  queue.

Simon

--fOHHtNG4YXGJ0yqR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlWm+foACgkQgtp0PDeOcDqtcQCfcS+AhPjzq53V99ariyJ6C/5U
VE0An3ZN1adeIHTOpswPyRN9T2mK6iS9
=XH8a
-----END PGP SIGNATURE-----

--fOHHtNG4YXGJ0yqR--
