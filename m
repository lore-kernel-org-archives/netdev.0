From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 22/32] rt2x00: Allocate ring structures in single array
Date: Fri, 28 Apr 2006 16:25:09 +0200
Message-ID: <200604281625.13165.IvDoorn@gmail.com>
References: <200604280003.14287.IvDoorn@gmail.com> <20060428125201.4f20ece2@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6235402.xp2Z84s6bF";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.187]:39576 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1030262AbWD1OYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 10:24:04 -0400
Received: by nproxy.gmail.com with SMTP id n29so1589277nfc
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 07:24:03 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060428125201.4f20ece2@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6235402.xp2Z84s6bF
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 12:52, Jiri Benc wrote:
> On Fri, 28 Apr 2006 00:03:13 +0200, Ivo van Doorn wrote:
> > Use seperate function to convert a dscape ring ID
> > to the address of the actual ring.
>=20
> Just minor things:
>=20
> > [...]
> > @@ -1386,20 +1412,19 @@ rt2400pci_tx(struct net_device *net_dev,
> > =20
> >  	rt2x00_register_read(rt2x00pci, TXCSR0, &reg);
> > =20
> > -	if (control->queue =3D=3D IEEE80211_TX_QUEUE_DATA0) {
> > -		ring =3D &rt2x00pci->prio;
> > -		rt2x00_set_field32(&reg, TXCSR0_KICK_PRIO, 1);
> > -	} else if (control->queue =3D=3D IEEE80211_TX_QUEUE_DATA1) {
> > -		ring =3D &rt2x00pci->tx;
> > -		rt2x00_set_field32(&reg, TXCSR0_KICK_TX, 1);
> > -	} else if (control->queue =3D=3D IEEE80211_TX_QUEUE_AFTER_BEACON) {
> > -		ring =3D &rt2x00pci->atim;
> > -		rt2x00_set_field32(&reg, TXCSR0_KICK_ATIM, 1);
> > -	} else {
> > -		ERROR("Frame received for invalid queue.");
> > +	/*
> > +	 * Determine which ring to put packet on.
> > +	 */
> > +	ring =3D rt2x00pci_get_ring(rt2x00pci, control->queue);
> > +	if (unlikely(!ring)) {
>=20
> Should not happen. Maybe some message that user should report a bug?

I am not really fan on such messages. But when the control->queue is indeed
invalid, it is a serious bug. Perhaps a BUG() should be used as well?
If so, I'll put it into a new patch along with the fixes below.

> > +		ERROR("Attempt to send packet over invalid queue %d.\n",
> > +			control->queue);
> >  		return NET_RX_DROP;
> >  	}
> > =20
> > +	if (rt2x00_ring_full(ring))
> > +		return NET_RX_DROP;
>=20
> NET_XMIT_DROP?

Absolutely true, I'll fix this as well.

> > +
> >  	entry =3D rt2x00_get_data_entry(ring);
> >  	txd =3D entry->desc_addr;
> > =20
> > [...]
> > @@ -1780,14 +1813,17 @@ rt2400pci_conf_tx(struct net_device *net
> >  	int queue, const struct ieee80211_tx_queue_params *params)
> >  {
> >  	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
> > -	struct data_ring	*ring;
> > +	struct data_ring	*ring =3D &rt2x00pci->ring[RING_TX];
> > =20
> > -	if (queue =3D=3D IEEE80211_TX_QUEUE_DATA0)
> > -		ring =3D &rt2x00pci->prio;
> > -	else if (queue =3D=3D IEEE80211_TX_QUEUE_DATA1)
> > -		ring =3D &rt2x00pci->tx;
> > -	else
> > -		return -EINVAL;
> > +	/*
> > +	 * We don't support variating cw_min and cw_max variables
> > +	 * per queue. So by default we only configure the TX queue,
> > +	 * and ignore all other configurations.
> > +	 */
> > +	if (queue !=3D IEEE80211_TX_QUEUE_DATA0) {
> > +		NOTICE("Ignoring configuration for queue %d.\n", queue);
> > +		return 0;
>=20
> Is there a reason for not returning a proper error code?

Good question, in rt2400pci the behaviour is something that is not
somethign the dscape could expect. Since we don't allow the
configuration of all available tx queues.
I had made it return 0, since I wasn't sure how the stack would
appreciate this behaviour.
But I have checked this in the stack since then, and apparently,
tx_conf is called without any notice of available tx queues.
Only when WMM is available the return value is checked,
so it is safe to return a error value.
But this behaviour should never have appeared in rt2500pci and rt2500usb,
so I'll put this fix in the patch as well.

Thanks.

--nextPart6235402.xp2Z84s6bF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUiXJaqndE37Em0gRAn0XAKC4tVQfsFPUwoXUWDzosNiActzRkwCg0d25
x3FJ9wBS7N9J+thmgtUmlGI=
=qDJV
-----END PGP SIGNATURE-----

--nextPart6235402.xp2Z84s6bF--
