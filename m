From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 3/32] rt2x00: use pci_*_consistent for DMA mapping
Date: Fri, 28 Apr 2006 15:24:07 +0200
Message-ID: <200604281524.11670.IvDoorn@gmail.com>
References: <200604280002.52839.IvDoorn@gmail.com> <200604281457.35460.IvDoorn@gmail.com> <20060428131533.GB3288@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1354374.3XDKVA0oo1";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.191]:61931 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1030373AbWD1NXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 09:23:03 -0400
Received: by nproxy.gmail.com with SMTP id n29so1577750nfc
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 06:23:01 -0700 (PDT)
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060428131533.GB3288@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1354374.3XDKVA0oo1
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 15:15, Christoph Hellwig wrote:
> On Fri, Apr 28, 2006 at 02:57:31PM +0200, Ivo van Doorn wrote:
> > On Friday 28 April 2006 00:11, Christoph Hellwig wrote:
> > > On Fri, Apr 28, 2006 at 12:02:52AM +0200, Ivo van Doorn wrote:
> > > > From: Ivo van Doorn <IvDoorn@gmail.com>
> > > >=20
> > > > Instead of dma_*_coherent
> > > > use pci_*consistent functions.
> > >=20
> > > No point in doing that, quite reverse as you use the gfp_mask argument
> > > which is a (small) pessimation here.
> >=20
> > Would it be recommended that I replace the usb_alloc_buffers in the
> > rt2570 driver with dma_*coherent?
> > This would get the dma rings allocation and freeing a bit more generic
> > between PCI and USB and could reduce some duplicate code between them.
> > But I am not sure if there is any major difference between the two.
>=20
> I don't have the full code for your driver anywhere near me so I can't
> comment on this.  Maybe you could send the code of 'usb_alloc_buffers'
> for comments?

Below is the function of the rt2500usb_alloc_ring, it works very similar
to the pci equivalent, except that urbs are allocated and usb_buffer_alloc =
is used.
The data_ring structure where the information is stored in is also the same=
 as
used in the pci driver.

Basicly what I want to do is move the urbs to somewhere else,
the data_ring structure has been very generic, and the only real difference
between the pci and usb version of the data_entry has been the urb structur=
e pointer.
If the usb_buffer_* calls could be replaced by dma_*coherent a lot
of duplicate code in the pci and usb drivers could be moved into
a seperate header or source file.

struct data_ring{
	/*
	 * net_device where this ring belongs to.
	 */
	struct net_device			*net_dev;

	/*
	 * Work structure for bottom half interrupt handling.
	 */
	struct work_struct			irq_work;

	/*
	 * Base address for the device specific data entries.
	 */
	void					*entry;

	/*
	 * TX queue statistic info.
	 */
	struct ieee80211_tx_queue_stats_data	stats;

	/*
	 * TX Queue parameters.
	 */
	struct ieee80211_tx_queue_params	tx_params;

	/*
	 * Base address for data ring.
	 */
	dma_addr_t				data_dma;
	void					*data_addr;

	/*
	 * Index variables.
	 */
	u8					index;
	u8					index_done;

	/*
	 * Size of device specific data entry structure.
	 */
	u16					entry_size;

	/*
	 * Size of packet and descriptor in bytes.
	 */
	u16					data_size;
	u16					desc_size;
} __attribute__ ((packed));

static int
rt2500usb_alloc_ring(
	struct rt2x00_usb *rt2x00usb,
	struct data_ring *ring,
	void (*handler)(void *),
	const u16 max_entries,
	const u16 data_size,
	const u16 desc_size)
{
	struct data_entry	*entry;
	u8			counter;
	int			status;

	/*
	 *Set device structure.
	 */
	ring->net_dev =3D usb_get_intfdata(rt2x00usb->usb_intf);

	/*
	 * Initialize work structure for deferred work.
	 */
	INIT_WORK(&ring->irq_work, handler, ring);

	/*
	 * Initialize ring parameters.
	 */
	ring->tx_params.aifs =3D 2;
	ring->tx_params.cw_min =3D 5;	/* cw_min: 2^5 =3D 32. */
	ring->tx_params.cw_max =3D 10;	/* cw_max: 2^10 =3D 1024. */

	rt2x00_ring_index_clear(ring);

	ring->stats.limit =3D max_entries;
	ring->entry_size =3D sizeof(struct data_entry);
	ring->data_size =3D data_size;
	ring->desc_size =3D desc_size;

	/*
	 * Allocate all ring entries.
	 */
	ring->entry =3D kmalloc(ring->stats.limit * ring->entry_size,
		GFP_KERNEL);
	if (!ring->entry)
		return -ENOMEM;

	/*
	 * Allocate DMA memory for descriptor and buffer.
	 */
	ring->data_addr =3D usb_buffer_alloc(
		interface_to_usbdev(rt2x00usb->usb_intf),
		rt2x00_get_ring_size(ring), GFP_KERNEL, &ring->data_dma);
	if (!ring->data_addr) {
		kfree(ring->entry);
		return -ENOMEM;
	}

	/*
	 * Initialize all ring entries to contain valid
	 * addresses.
	 */
	status =3D 0;
	entry =3D ring->entry;
	for (counter =3D 0; counter < ring->stats.limit; counter++) {
		entry[counter].ring =3D ring;
		if (!status)
			entry[counter].urb =3D usb_alloc_urb(0, GFP_KERNEL);
		else
			entry[counter].urb =3D NULL;
		if (!entry[counter].urb)
			status =3D -ENOMEM;
		entry[counter].skb =3D NULL;
		entry[counter].data_addr =3D ring->data_addr
			+ (counter * ring->desc_size)
			+ (counter * ring->data_size);
		entry[counter].data_dma =3D ring->data_dma
			+ (counter * ring->desc_size)
			+ (counter * ring->data_size);
	}

	return status;
}

static void
rt2500usb_free_ring(struct rt2x00_usb *rt2x00usb, struct data_ring *ring)
{
	struct	data_entry	*entry;
	u8			counter;

	if (!ring->entry)
		goto exit;

	entry =3D ring->entry;
	for (counter =3D 0; counter < ring->stats.limit; counter++) {
		usb_kill_urb(entry[counter].urb);
		usb_free_urb(entry[counter].urb);
	}

	kfree(ring->entry);
	ring->entry =3D NULL;

exit:
	if (ring->data_addr)
		usb_buffer_free(
			interface_to_usbdev(rt2x00usb->usb_intf),
			rt2x00_get_ring_size(ring), ring->data_addr,
			ring->data_dma);
	ring->data_addr =3D NULL;
}

--nextPart1354374.3XDKVA0oo1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD4DBQBEUhd7aqndE37Em0gRAlvcAJ0V5s8W43beL6eIvNgibyxR2N6/kgCXb+Rg
YtVMFuYf3cBHqUl30N0pEQ==
=0T1y
-----END PGP SIGNATURE-----

--nextPart1354374.3XDKVA0oo1--
