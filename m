From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Please pull 'adm8211' branch of wireless-2.6
Date: Sat, 15 Sep 2007 20:16:58 -0400
Message-ID: <200709152017.02646.flamingice@sourmilk.net>
References: <20070915132220.GE6060@tuxdriver.com> <46EC4F78.4050700@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart8442332.VnvWhInxmh";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <46EC4F78.4050700-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart8442332.VnvWhInxmh
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 15 September 2007 17:32, Jeff Garzik wrote:
> Review summary:  many minor issues, only one major one:  irq handler loop
>
CCing me would help.

> John W. Linville wrote:
> > +static unsigned int tx_ring_size __read_mostly =3D 16;
> > +static unsigned int rx_ring_size __read_mostly =3D 16;
> > +
> > +module_param(tx_ring_size, uint, 0);
> > +module_param(rx_ring_size, uint, 0);
>
> should be in ethtool (or another per-interface runtime config tool), not
> a module parameter.
>
ethtool is not accessible to mac80211 drivers. I'll just make it a constant=
=20
because tuning the ring size doesn't help much.

> > +	} else if ((flags & IFF_ALLMULTI) || (mc_count > -1)) {
>
> mc_count > -1 ?
>
> what kind of bogus placeholder is that?
>
Hm, right, I disabled the multicast filter config for some reason by doing=
=20
s/32/-1/ and I forgot to reenable it. Will fix.

> > +	if (flags & IFF_PROMISC)
> > +		dev->flags |=3D IEEE80211_HW_RX_INCLUDES_FCS;
> > +	else
> > +		dev->flags &=3D ~IEEE80211_HW_RX_INCLUDES_FCS;
>
> why does promisc dictate inclusion of FCS?
>
Because that's the way the hardware works.

> not this driver's fault, but, ieee80211_wake_queue() warrants revisiting
> now that MQ stuff is in
>
> when queue=3D=3D0 is hardcoded, you can just use netif_wake/stop_queue() =
AFAICS
>
mac80211 have no access to any struct net_device.

> the '%' operator is expensive.  mask combined with power-of-2 is better
>
Sure.

> > +static irqreturn_t adm8211_interrupt(int irq, void *dev_id)
> > +{
> > +#define ADM8211_INT(x)							   \
> > +do {									   \
> > +	if (unlikely(stsr & ADM8211_STSR_ ## x))			   \
> > +		printk(KERN_DEBUG "%s: " #x "\n", wiphy_name(dev->wiphy)); \
> > +} while (0)
> > +
> > +	struct ieee80211_hw *dev =3D dev_id;
> > +	struct adm8211_priv *priv =3D dev->priv;
> > +	unsigned int count =3D 0;
> > +	u32 stsr;
> > +
> > +	do {
> > +		stsr =3D ADM8211_CSR_READ(STSR);
> > +		ADM8211_CSR_WRITE(STSR, stsr);
> > +		if (stsr =3D=3D 0xffffffff)
> > +			return IRQ_HANDLED;
> > +
> > +		if (!(stsr & (ADM8211_STSR_NISS | ADM8211_STSR_AISS)))
> > +			break;
> > +
> > +		if (stsr & ADM8211_STSR_RCI)
> > +			adm8211_interrupt_rci(dev);
> > +		if (stsr & ADM8211_STSR_TCI)
> > +			adm8211_interrupt_tci(dev);
> > +
> > +		/*ADM8211_INT(LinkOn);*/
> > +		/*ADM8211_INT(LinkOff);*/
> > +
> > +		ADM8211_INT(PCF);
> > +		ADM8211_INT(BCNTC);
> > +		ADM8211_INT(GPINT);
> > +		ADM8211_INT(ATIMTC);
> > +		ADM8211_INT(TSFTF);
> > +		ADM8211_INT(TSCZ);
> > +		ADM8211_INT(SQL);
> > +		ADM8211_INT(WEPTD);
> > +		ADM8211_INT(ATIME);
> > +		/*ADM8211_INT(TBTT);*/
> > +		ADM8211_INT(TEIS);
> > +		ADM8211_INT(FBE);
> > +		ADM8211_INT(REIS);
> > +		ADM8211_INT(GPTT);
> > +		ADM8211_INT(RPS);
> > +		ADM8211_INT(RDU);
> > +		ADM8211_INT(TUF);
> > +		/*ADM8211_INT(TRT);*/
> > +		/*ADM8211_INT(TLT);*/
> > +		/*ADM8211_INT(TDU);*/
> > +		ADM8211_INT(TPS);
>
> lame.  WAY too many branches, even if marked with unlikely()
>
> this should be surrounded by a single "if stsr &
> BITS_WE_SHOULD_NEVER_SEE" test
>
I'm just gonna delete these. This was only mildly interesting when the driv=
er=20
was younger.

> > +	} while (count++ < 20);
>
> NAK -- talk about back to the past.
>
> It's bogus to loop in the interrupt handler, then loop again in both RX
> and TX paths.  You are getting close to reinventing the wheel here.
>
> Use NAPI rather than doing such a loop.
>
This is old interrupt handler code from Jouni's original driver. I never=20
bothered to replace it with the simpler designs used in newer drivers I've=
=20
worked on.

Also - mac80211 drivers have no access to NAPI.

> > +#define
> > WRITE_SYN(name,v_mask,v_shift,a_mask,a_shift,bits,prewrite,postwrite)\
> > +static void adm8211_rf_write_syn_ ## name (struct ieee80211_hw *dev,	 =
 =20
> >  \ +					   u16 addr, u32 value) {	     \
> > +	struct adm8211_priv *priv =3D dev->priv;				     \
> > +	unsigned int i;							     \
> > +	u32 reg, bitbuf;						     \
> > +									     \
> > +	value &=3D v_mask;						     \
> > +	addr &=3D a_mask;							     \
> > +	bitbuf =3D (value << v_shift) | (addr << a_shift);		     \
> > +									     \
> > +	ADM8211_CSR_WRITE(SYNRF, ADM8211_SYNRF_IF_SELECT_1);		     \
> > +	ADM8211_CSR_READ(SYNRF);					     \
> > +	ADM8211_CSR_WRITE(SYNRF, ADM8211_SYNRF_IF_SELECT_0);		     \
> > +	ADM8211_CSR_READ(SYNRF);					     \
> > +									     \
> > +	if (prewrite) {							     \
> > +		ADM8211_CSR_WRITE(SYNRF, ADM8211_SYNRF_WRITE_SYNDATA_0);     \
> > +		ADM8211_CSR_READ(SYNRF);				     \
> > +	}								     \
> > +									     \
> > +	for (i =3D 0; i <=3D bits; i++) {					     \
> > +		if (bitbuf & (1 << (bits - i)))				     \
> > +			reg =3D ADM8211_SYNRF_WRITE_SYNDATA_1;		     \
> > +		else							     \
> > +			reg =3D ADM8211_SYNRF_WRITE_SYNDATA_0;		     \
> > +									     \
> > +		ADM8211_CSR_WRITE(SYNRF, reg);				     \
> > +		ADM8211_CSR_READ(SYNRF);				     \
> > +									     \
> > +		ADM8211_CSR_WRITE(SYNRF, reg | ADM8211_SYNRF_WRITE_CLOCK_1); \
> > +		ADM8211_CSR_READ(SYNRF);				     \
> > +		ADM8211_CSR_WRITE(SYNRF, reg | ADM8211_SYNRF_WRITE_CLOCK_0); \
> > +		ADM8211_CSR_READ(SYNRF);				     \
> > +	}								     \
> > +									     \
> > +	if (postwrite =3D=3D 1) {						     \
> > +		ADM8211_CSR_WRITE(SYNRF, reg | ADM8211_SYNRF_IF_SELECT_0);   \
> > +		ADM8211_CSR_READ(SYNRF);				     \
> > +	}								     \
> > +	if (postwrite =3D=3D 2) {						     \
> > +		ADM8211_CSR_WRITE(SYNRF, reg | ADM8211_SYNRF_IF_SELECT_1);   \
> > +		ADM8211_CSR_READ(SYNRF);				     \
> > +	}								     \
> > +									     \
> > +	ADM8211_CSR_WRITE(SYNRF, 0);					     \
> > +	ADM8211_CSR_READ(SYNRF);					     \
> > +}
> > +
> > +WRITE_SYN(max2820,  0x00FFF, 0, 0x0F, 12, 15, 1, 1)
> > +WRITE_SYN(al2210l,  0xFFFFF, 4, 0x0F,  0, 23, 1, 1)
> > +WRITE_SYN(rfmd2958, 0x3FFFF, 0, 0x1F, 18, 23, 0, 1)
> > +WRITE_SYN(rfmd2948, 0x0FFFF, 4, 0x0F,  0, 21, 0, 2)
>
> code bloat from hell.  just pass these arguments (or a pointer to an
> entry in a table that contains this info)
>
Yeah sure. I wrote that code a long time ago,, would never do something lik=
e=20
that now. :p

> > +static void adm8211_hw_init(struct ieee80211_hw *dev)
> > +{
> > +	struct adm8211_priv *priv =3D dev->priv;
> > +	u32 reg;
> > +	u8 cline;
> > +
> > +	reg =3D le32_to_cpu(ADM8211_CSR_READ(PAR));
> > +	reg |=3D ADM8211_PAR_MRLE | ADM8211_PAR_MRME;
> > +	reg &=3D ~(ADM8211_PAR_BAR | ADM8211_PAR_CAL);
>
> what do BAR and CAL bits do?
>
Need to dig up the specs to find out.

> > +	if (!pci_set_mwi(priv->pdev)) {
> > +		reg |=3D 0x1 << 24;
> > +		pci_read_config_byte(priv->pdev, PCI_CACHE_LINE_SIZE, &cline);
> > +
> > +		switch (cline) {
> > +		case  0x8: reg |=3D (0x1 << 14);
> > +			   break;
> > +		case 0x16: reg |=3D (0x2 << 14);
> > +			   break;
> > +		case 0x32: reg |=3D (0x3 << 14);
> > +			   break;
> > +		  default: reg |=3D (0x0 << 14);
> > +			   break;
> > +		}
> > +	}
> > +
> > +	ADM8211_CSR_WRITE(PAR, reg);
>
> this should be set regardless of MWI usage AFAICS
>
Sure.

> > +		rx_info->skb =3D dev_alloc_skb(RX_PKT_SIZE);
> > +		if (rx_info->skb =3D=3D NULL)
> > +			break;
>
> it seems highly bogus to set RX_PKT_SIZE for all RX descriptors, then
> bail if allocation starts failing.  the state of the ring becomes out of
> sync with reality.
>
Yeah, probably. Much of the tx/rx ring code is somewhat old and questionabl=
e.=20
(but tested and working!)

> > +	if (priv->cur_tx - priv->dirty_tx =3D=3D priv->tx_ring_size - 2)
>
> extra parens would be nice for readability
>
Ok.

> > +	priv->tx_buffers[entry].skb =3D skb;
> > +	priv->tx_buffers[entry].mapping =3D mapping;
> > +	memcpy(&priv->tx_buffers[entry].tx_control, control, sizeof(*control)=
);
> > +	priv->tx_buffers[entry].hdrlen =3D hdrlen;
> > +	priv->tx_ring[entry].buffer1 =3D cpu_to_le32(mapping);
> > +
> > +	if (entry =3D=3D priv->tx_ring_size - 1)
> > +		flag |=3D TDES1_CONTROL_TER;
> > +	priv->tx_ring[entry].length =3D cpu_to_le32(flag | skb->len);
> > +
> > +	/* Set TX rate (SIGNAL field in PLCP PPDU format) */
> > +	flag =3D TDES0_CONTROL_OWN | (plcp_signal << 20) | 8 /* ? */;
> > +	priv->tx_ring[entry].status =3D cpu_to_le32(flag);
> > +
> > +	priv->cur_tx++;
> > +
> > +	spin_unlock_irqrestore(&priv->lock, flags);
> > +
> > +	/* Trigger transmit poll */
> > +	ADM8211_CSR_WRITE(TDR, 0);
> > +}
> > +
> > +/* Put adm8211_tx_hdr on skb and transmit */
> > +static int adm8211_tx(struct ieee80211_hw *dev, struct sk_buff *skb,
> > +		      struct ieee80211_tx_control *control)
> > +{
> > +	struct adm8211_tx_hdr *txhdr;
> > +	u16 fc;
> > +	size_t payload_len, hdrlen;
> > +	int plcp, dur, len, plcp_signal, short_preamble;
> > +	struct ieee80211_hdr *hdr;
> > +
> > +	if (control->tx_rate < 0) {
> > +		short_preamble =3D 1;
> > +		plcp_signal =3D -control->tx_rate;
> > +	} else {
> > +		short_preamble =3D 0;
> > +		plcp_signal =3D control->tx_rate;
> > +	}
> > +
> > +	hdr =3D (struct ieee80211_hdr *)skb->data;
> > +	fc =3D le16_to_cpu(hdr->frame_control) & ~IEEE80211_FCTL_PROTECTED;
> > +	hdrlen =3D ieee80211_get_hdrlen(fc);
> > +	memcpy(skb->cb, skb->data, hdrlen);
>
> to confirm:  I thought skb->cb was owned by the skb creator?  In this
> the driver is definitely _not_ the skb creator
>
Once the skb is passed to the driver, the driver owns cb. cb is owned by th=
e=20
layer which has the skb.

> > +static int adm8211_alloc_rings(struct ieee80211_hw *dev)
> > +{
> > +	struct adm8211_priv *priv =3D dev->priv;
> > +	unsigned int ring_size;
> > +
> > +	priv->rx_buffers =3D kmalloc(sizeof(*priv->rx_buffers) *
> > priv->rx_ring_size + +				   sizeof(*priv->tx_buffers) *
> > priv->tx_ring_size, GFP_KERNEL); +	if (!priv->rx_buffers)
> > +		return -ENOMEM;
> > +
> > +	priv->tx_buffers =3D (void *)priv->rx_buffers +
> > +			   sizeof(*priv->rx_buffers) * priv->rx_ring_size;
> > +
> > +	/* Allocate TX/RX descriptors */
> > +	ring_size =3D sizeof(struct adm8211_desc) * priv->rx_ring_size +
> > +		    sizeof(struct adm8211_desc) * priv->tx_ring_size;
> > +	priv->rx_ring =3D pci_alloc_consistent(priv->pdev, ring_size,
> > +					     &priv->rx_ring_dma);
> > +
> > +	if (!priv->rx_ring) {
> > +		kfree(priv->rx_buffers);
> > +		priv->rx_buffers =3D NULL;
> > +		priv->tx_buffers =3D NULL;
> > +		return -ENOMEM;
> > +	}
> > +
> > +	priv->tx_ring =3D (struct adm8211_desc *)(priv->rx_ring +
> > +						priv->rx_ring_size);
> > +	priv->tx_ring_dma =3D priv->rx_ring_dma +
> > +			    sizeof(struct adm8211_desc) * priv->rx_ring_size;
> > +
>
> why not alloc ring contents (skbs) here too?
>
I really don't like this function. It allocates some ring structures at pci=
=20
initialization when it can really be deferred to open time. So, instead of=
=20
allocating the ring contents here, the ring should be allocated at the same=
=20
place where the ring contents are allocated. Doing that reduces the number =
of=20
things that can fail at pci init time.

> > +static int __devinit adm8211_probe(struct pci_dev *pdev,
> > +				   const struct pci_device_id *id)
> > +{
> > +	struct ieee80211_hw *dev;
> > +	struct adm8211_priv *priv;
> > +	unsigned long mem_addr, mem_len;
> > +	unsigned int io_addr, io_len;
> > +	int err;
> > +	u32 reg;
> > +	u8 perm_addr[ETH_ALEN];
> > +
> > +#ifndef MODULE
> > +	static unsigned int cardidx;
> > +	if (!cardidx++)
> > +		printk(version);
> > +#endif
>
> this is silly leftover logic from ancient days.
>
> unconditionally printk() the version here, and remove from module init
>
Sure.

> > +	err =3D pci_enable_device(pdev);
> > +	if (err) {
> > +		printk(KERN_ERR "%s (adm8211): Cannot enable new PCI device\n",
> > +		       pci_name(pdev));
>
> no need for printk, PCI layer already does this
>
Ok.

> > +	err =3D pci_request_regions(pdev, "adm8211");
> > +	if (err) {
> > +		printk(KERN_ERR "%s (adm8211): Cannot obtain PCI resources\n",
> > +		       pci_name(pdev));
>
> ditto
>
Ok.

> > +		return err; /* someone else grabbed it? don't disable it */
> > +	}
> > +
> > +	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) ||
> > +	    pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK)) {
> > +		printk(KERN_ERR "%s (adm8211): No suitable DMA available\n",
> > +		       pci_name(pdev));
> > +		goto err_free_reg;
> > +	}
> > +
> > +	pci_set_master(pdev);
> > +
> > +	dev =3D ieee80211_alloc_hw(sizeof(*priv), &adm8211_ops);
> > +	if (!dev) {
> > +		printk(KERN_ERR "%s (adm8211): ieee80211 alloc failed\n",
> > +		       pci_name(pdev));
> > +		err =3D -ENOMEM;
> > +		goto err_free_reg;
> > +	}
> > +	priv =3D dev->priv;
> > +	priv->pdev =3D pdev;
> > +
> > +	spin_lock_init(&priv->lock);
> > +
> > +	SET_IEEE80211_DEV(dev, &pdev->dev);
> > +
> > +	pci_set_drvdata(pdev, dev);
> > +
> > +	priv->map =3D pci_iomap(pdev, 1, mem_len);
> > +	if (!priv->map)
> > +		priv->map =3D pci_iomap(pdev, 0, io_len);
>
> is this paranoia?
>
> just code 100% MMIO only, and ditch the iomap per-register-access overhead
>
Will do.

> > +	pci_read_config_byte(pdev, PCI_CLASS_REVISION, &priv->revid);
>
> this is in struct pci_dev now
>
Convenient.

> > +/* CSR (Host Control and Status Registers) */
> > +struct adm8211_csr {
>[snip]
> > +} __attribute__ ((packed));
>
> attributed(packed) is unneccesary here, and its use results in
> sub-optimal code
>
How? Doesn't this just turn into a bunch of offsets?

> enums are preferred.  they do not disappear at the cpp stage, and confer
> type information.
>
I'd rather not.

> > +#define ADM8211_IDLE_RX() 						\
> > +do {									\
> > +	if (priv->nar & ADM8211_NAR_SR) {				\
> > +		ADM8211_CSR_WRITE(NAR, priv->nar & ~ADM8211_NAR_SR);	\
> > +		ADM8211_CSR_READ(NAR);					\
> > +		mdelay(20);						\
> > +	}								\
> > +} while (0)
>
> should be msleep() AFAICS
>
Nope, this can be called in atomic context. Admittedly, 20 ms delay is=20
ridiculously long.. I'll find a better way to handle this.

> use of <tab> to separate type and name greatly enhances readability.
> look at many other net drivers, to see the positive effects
>
Sure, will do.

Thanks,
=2DMichael Wu

--nextPart8442332.VnvWhInxmh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBG7HX+T3Oqt9AH4aERAnugAKC7iBw827BMV6X+gIjfCDktXFL87ACeK3N8
uI/6jwkXwhh/x+h5eIKAOu0=
=HUpU
-----END PGP SIGNATURE-----

--nextPart8442332.VnvWhInxmh--
