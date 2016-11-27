From: =?UTF-8?Q?Markus_B=c3=b6hme?= <markus.boehme@mailbox.org>
Subject: Re: [PATCH v3 net-next 1/2] net: ethernet: slicoss: add slicoss
 gigabit ethernet driver
Date: Sun, 27 Nov 2016 18:59:30 +0100
Message-ID: <910890ec-7acf-1ced-55c6-d854ee2cdccc@mailbox.org>
References: <1480162850-8014-1-git-send-email-LinoSanfilippo@gmx.de>
 <1480162850-8014-2-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>, davem@davemloft.net,
        charrer@alacritech.com, liodot@gmail.com,
        gregkh@linuxfoundation.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mailbox.org ([80.241.60.215]:47017 "EHLO mx2.mailbox.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752187AbcK0R7p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 12:59:45 -0500
In-Reply-To: <1480162850-8014-2-git-send-email-LinoSanfilippo@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Lino,

just some things barely worth mentioning:

On 11/26/2016 01:20 PM, Lino Sanfilippo wrote:
> Add driver for Alacritech gigabit ethernet cards with SLIC (session-layer
> interface control) technology. The driver provides basic support without
> SLIC for the following devices:
> 
> - Mojave cards (single port PCI Gigabit) both copper and fiber
> - Oasis cards (single and dual port PCI-x Gigabit) copper and fiber
> - Kalahari cards (dual and quad port PCI-e Gigabit) copper and fiber
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
> ---
>  drivers/net/ethernet/Kconfig              |    1 +
>  drivers/net/ethernet/Makefile             |    1 +
>  drivers/net/ethernet/alacritech/Kconfig   |   28 +
>  drivers/net/ethernet/alacritech/Makefile  |    4 +
>  drivers/net/ethernet/alacritech/slic.h    |  576 +++++++++
>  drivers/net/ethernet/alacritech/slicoss.c | 1867 +++++++++++++++++++++++++++++
>  6 files changed, 2477 insertions(+)
>  create mode 100644 drivers/net/ethernet/alacritech/Kconfig
>  create mode 100644 drivers/net/ethernet/alacritech/Makefile
>  create mode 100644 drivers/net/ethernet/alacritech/slic.h
>  create mode 100644 drivers/net/ethernet/alacritech/slicoss.c
> 

[...]

> diff --git a/drivers/net/ethernet/alacritech/slic.h b/drivers/net/ethernet/alacritech/slic.h
> new file mode 100644
> index 0000000..c62d46b
> --- /dev/null
> +++ b/drivers/net/ethernet/alacritech/slic.h
> @@ -0,0 +1,576 @@
> +
> +#ifndef _SLIC_H
> +#define _SLIC_H


I found a bunch of unused #defines in slic.h. I cannot judge if they are
worth keeping:

	SLIC_VRHSTATB_LONGE
	SLIC_VRHSTATB_PREA
	SLIC_ISR_IO
	SLIC_ISR_PING_MASK
	SLIC_GIG_SPEED_MASK
	SLIC_GMCR_RESET
	SLIC_XCR_RESET
	SLIC_XCR_XMTEN
	SLIC_XCR_PAUSEEN
	SLIC_XCR_LOADRNG
	SLIC_REG_DBAR
	SLIC_REG_PING
	SLIC_REG_DUMP_CMD
	SLIC_REG_DUMP_DATA
	SLIC_REG_WRHOSTID
	SLIC_REG_LOW_POWER
	SLIC_REG_RESET_IFACE
	SLIC_REG_ADDR_UPPER
	SLIC_REG_HBAR64
	SLIC_REG_DBAR64
	SLIC_REG_CBAR64
	SLIC_REG_RBAR64
	SLIC_REG_WRVLANID
	SLIC_REG_READ_XF_INFO
	SLIC_REG_WRITE_XF_INFO
	SLIC_REG_TICKS_PER_SEC

These device IDs are not used, either, but maybe it's good to keep them
for documentation purposes:

	PCI_SUBDEVICE_ID_ALACRITECH_1000X1_2
	PCI_SUBDEVICE_ID_ALACRITECH_SES1001T
	PCI_SUBDEVICE_ID_ALACRITECH_SEN2002XT
	PCI_SUBDEVICE_ID_ALACRITECH_SEN2001XT
	PCI_SUBDEVICE_ID_ALACRITECH_SEN2104ET
	PCI_SUBDEVICE_ID_ALACRITECH_SEN2102ET

[...]

> +
> +/* SLIC EEPROM structure for Oasis */
> +struct slic_mojave_eeprom {

Comment: "for Mojave".

[...]

> +struct slic_device {
> +	struct pci_dev *pdev;
> +	struct net_device *netdev;
> +	void __iomem *regs;
> +	/* upper address setting lock */
> +	spinlock_t upper_lock;
> +	struct slic_shmem shmem;
> +	struct napi_struct napi;
> +	struct slic_rx_queue rxq;
> +	struct slic_tx_queue txq;
> +	struct slic_stat_queue stq;
> +	struct slic_stats stats;
> +	struct slic_upr_list upr_list;
> +	/* link configuration lock */
> +	spinlock_t link_lock;
> +	bool promisc;
> +	bool autoneg;
> +	int speed;
> +	int duplex;

Maybe make speed and duplex unsigned? They are assigned and compared
against unsigned values in slicoss.c, so this would get rid of some
(benign, because of the range of the values) -Wsign-compare warnings in
slic_configure_link_locked. However, in a comparison there SPEED_UNKNOWN
would need to be casted to unsigned to prevent another one popping up.

[...]

> +#endif /* _SLIC_H */
> diff --git a/drivers/net/ethernet/alacritech/slicoss.c b/drivers/net/ethernet/alacritech/slicoss.c
> new file mode 100644
> index 0000000..8cd862a
> --- /dev/null
> +++ b/drivers/net/ethernet/alacritech/slicoss.c
> @@ -0,0 +1,1867 @@

[...]

> +
> +static const struct pci_device_id slic_id_tbl[] = {
> +	{ PCI_DEVICE(PCI_VENDOR_ID_ALACRITECH,
> +		     PCI_DEVICE_ID_ALACRITECH_MOAVE) },

I missed this in slic.h, but is this a typo and "MOAVE" should be
"MOJAVE"? There are a couple similar #defines in slic.h.

[...]

> +static void slic_refill_rx_queue(struct slic_device *sdev, gfp_t gfp)
> +{
> +	const unsigned int ALIGN_MASK = SLIC_RX_BUFF_ALIGN - 1;
> +	unsigned int maplen = SLIC_RX_BUFF_SIZE;
> +	struct slic_rx_queue *rxq = &sdev->rxq;
> +	struct net_device *dev = sdev->netdev;
> +	struct slic_rx_buffer *buff;
> +	struct slic_rx_desc *desc;
> +	unsigned int misalign;
> +	unsigned int offset;
> +	struct sk_buff *skb;
> +	dma_addr_t paddr;
> +
> +	while (slic_get_free_rx_descs(rxq) > SLIC_MAX_REQ_RX_DESCS) {
> +		skb = alloc_skb(maplen + ALIGN_MASK, gfp);
> +		if (!skb)
> +			break;
> +
> +		paddr = dma_map_single(&sdev->pdev->dev, skb->data, maplen,
> +				       DMA_FROM_DEVICE);
> +		if (dma_mapping_error(&sdev->pdev->dev, paddr)) {
> +			netdev_err(dev, "mapping rx packet failed\n");
> +			/* drop skb */
> +			dev_kfree_skb_any(skb);
> +			break;
> +		}
> +		/* ensure head buffer descriptors are 256 byte aligned */
> +		offset = 0;
> +		misalign = paddr & ALIGN_MASK;
> +		if (misalign) {
> +			offset = SLIC_RX_BUFF_ALIGN - misalign;
> +			skb_reserve(skb, offset);
> +		}
> +		/* the HW expects dma chunks for descriptor + frame data */
> +		desc = (struct slic_rx_desc *)skb->data;
> +		memset(desc, 0, sizeof(*desc));
> +
> +		buff = &rxq->rxbuffs[rxq->put_idx];
> +		buff->skb = skb;
> +		dma_unmap_addr_set(buff, map_addr, paddr);
> +		dma_unmap_len_set(buff, map_len, maplen);
> +		buff->addr_offset = offset;
> +		/* head buffer descriptors are placed immediately before skb */
> +		slic_write(sdev, SLIC_REG_HBAR, lower_32_bits(paddr) +
> +						offset);

This fits nicely on one line. :-)

[...]

> +static int slic_init_tx_queue(struct slic_device *sdev)
> +{
> +	struct slic_tx_queue *txq = &sdev->txq;
> +	struct slic_tx_buffer *buff;
> +	struct slic_tx_desc *desc;
> +	int err;
> +	int i;

You could make i unsigned...

> +
> +	txq->len = SLIC_NUM_TX_DESCS;
> +	txq->put_idx = 0;
> +	txq->done_idx = 0;
> +
> +	txq->txbuffs = kcalloc(txq->len, sizeof(*buff), GFP_KERNEL);
> +	if (!txq->txbuffs)
> +		return -ENOMEM;
> +
> +	txq->dma_pool = dma_pool_create("slic_pool", &sdev->pdev->dev,
> +					sizeof(*desc), SLIC_TX_DESC_ALIGN,
> +					4096);
> +	if (!txq->dma_pool) {
> +		err = -ENOMEM;
> +		netdev_err(sdev->netdev, "failed to create dma pool\n");
> +		goto free_buffs;
> +	}
> +
> +	for (i = 0; i < txq->len; i++) {

...to fix a signed/unsigned comparison warning here, but...

> +		buff = &txq->txbuffs[i];
> +		desc = dma_pool_zalloc(txq->dma_pool, GFP_KERNEL,
> +				       &buff->desc_paddr);
> +		if (!desc) {
> +			netdev_err(sdev->netdev,
> +				   "failed to alloc pool chunk (%i)\n", i);
> +			err = -ENOMEM;
> +			goto free_descs;
> +		}
> +
> +		desc->hnd = cpu_to_le32((u32)(i + 1));
> +		desc->cmd = SLIC_CMD_XMT_REQ;
> +		desc->flags = 0;
> +		desc->type = cpu_to_le32(SLIC_CMD_TYPE_DUMB);
> +		buff->desc = desc;
> +	}
> +
> +	return 0;
> +
> +free_descs:
> +	while (i--) {

...this would require reworking this logic to prevent an endless loop,
so probably not worth bothering, considering that txq->len is well
within the positive signed range.

> +		buff = &txq->txbuffs[i];
> +		dma_pool_free(txq->dma_pool, buff->desc, buff->desc_paddr);
> +	}
> +	dma_pool_destroy(txq->dma_pool);
> +
> +free_buffs:
> +	kfree(txq->txbuffs);
> +
> +	return err;
> +}
> +
> +static void slic_free_tx_queue(struct slic_device *sdev)
> +{
> +	struct slic_tx_queue *txq = &sdev->txq;
> +	struct slic_tx_buffer *buff;
> +	int i;

Make i unsigned? One warning less, almost no work invested.

> +
> +	for (i = 0; i < txq->len; i++) {
> +		buff = &txq->txbuffs[i];
> +		dma_pool_free(txq->dma_pool, buff->desc, buff->desc_paddr);
> +		if (!buff->skb)
> +			continue;
> +
> +		dma_unmap_single(&sdev->pdev->dev,
> +				 dma_unmap_addr(buff, map_addr),
> +				 dma_unmap_len(buff, map_len), DMA_TO_DEVICE);
> +		consume_skb(buff->skb);
> +	}
> +	dma_pool_destroy(txq->dma_pool);
> +
> +	kfree(txq->txbuffs);
> +}
> +

[...]

> +static void slic_free_rx_queue(struct slic_device *sdev)
> +{
> +	struct slic_rx_queue *rxq = &sdev->rxq;
> +	struct slic_rx_buffer *buff;
> +	int i;

Unsigned?

> +
> +	/* free rx buffers */
> +	for (i = 0; i < rxq->len; i++) {
> +		buff = &rxq->rxbuffs[i];
> +
> +		if (!buff->skb)
> +			continue;
> +
> +		dma_unmap_single(&sdev->pdev->dev,
> +				 dma_unmap_addr(buff, map_addr),
> +				 dma_unmap_len(buff, map_len),
> +				 DMA_FROM_DEVICE);
> +		consume_skb(buff->skb);
> +	}
> +	kfree(rxq->rxbuffs);
> +}

[...]

> +static int slic_load_firmware(struct slic_device *sdev)
> +{
> +	u32 sectstart[SLIC_FIRMWARE_MAX_SECTIONS];
> +	u32 sectsize[SLIC_FIRMWARE_MAX_SECTIONS];
> +	const struct firmware *fw;
> +	unsigned int datalen;
> +	const char *file;
> +	int code_start;
> +	u32 numsects;
> +	int idx = 0;
> +	u32 sect;
> +	u32 instr;
> +	u32 addr;
> +	u32 base;
> +	int err;
> +	int i;

Make i unsigned?

> +
> +	file = (sdev->model == SLIC_MODEL_OASIS) ?  SLIC_FIRMWARE_OASIS :
> +						    SLIC_FIRMWARE_MOAVE;
> +	err = request_firmware(&fw, file, &sdev->pdev->dev);
> +	if (err) {
> +		dev_err(&sdev->pdev->dev, "failed to load firmware %s\n", file);
> +		return err;
> +	}
> +	/* Do an initial sanity check concerning firmware size now. A further
> +	 * check follows below.
> +	 */
> +	if (fw->size < SLIC_FIRMWARE_MIN_SIZE) {
> +		dev_err(&sdev->pdev->dev,
> +			"invalid firmware size %zu (min is %u)\n", fw->size,
> +			SLIC_FIRMWARE_MIN_SIZE);
> +		err = -EINVAL;
> +		goto release;
> +	}
> +
> +	numsects = slic_read_dword_from_firmware(fw, &idx);
> +	if (numsects == 0 || numsects > SLIC_FIRMWARE_MAX_SECTIONS) {
> +		dev_err(&sdev->pdev->dev,
> +			"invalid number of sections in firmware: %u", numsects);
> +		err = -EINVAL;
> +		goto release;
> +	}
> +
> +	datalen = numsects * 8 + 4;
> +	for (i = 0; i < numsects; i++) {
> +		sectsize[i] = slic_read_dword_from_firmware(fw, &idx);
> +		datalen += sectsize[i];
> +	}
> +
> +	/* do another sanity check against firmware size */
> +	if (datalen > fw->size) {
> +		dev_err(&sdev->pdev->dev,
> +			"invalid firmware size %zu (expected >= %u)\n",
> +			fw->size, datalen);
> +		err = -EINVAL;
> +		goto release;
> +	}
> +	/* get sections */
> +	for (i = 0; i < numsects; i++)
> +		sectstart[i] = slic_read_dword_from_firmware(fw, &idx);
> +
> +	code_start = idx;
> +	instr = slic_read_dword_from_firmware(fw, &idx);
> +
> +	for (sect = 0; sect < numsects; sect++) {
> +		unsigned int ssize = sectsize[sect] >> 3;
> +
> +		base = sectstart[sect];
> +
> +		for (addr = 0; addr < ssize; addr++) {
> +			/* write out instruction address */
> +			slic_write(sdev, SLIC_REG_WCS, base + addr);
> +			/* write out instruction to low addr */
> +			slic_write(sdev, SLIC_REG_WCS, instr);
> +			instr = slic_read_dword_from_firmware(fw, &idx);
> +			/* write out instruction to high addr */
> +			slic_write(sdev, SLIC_REG_WCS, instr);
> +			instr = slic_read_dword_from_firmware(fw, &idx);
> +		}
> +	}
> +
> +	idx = code_start;
> +
> +	for (sect = 0; sect < numsects; sect++) {
> +		unsigned int ssize = sectsize[sect] >> 3;
> +
> +		instr = slic_read_dword_from_firmware(fw, &idx);
> +		base = sectstart[sect];
> +		if (base < 0x8000)
> +			continue;
> +
> +		for (addr = 0; addr < ssize; addr++) {
> +			/* write out instruction address */
> +			slic_write(sdev, SLIC_REG_WCS,
> +				   SLIC_WCS_COMPARE | (base + addr));
> +			/* write out instruction to low addr */
> +			slic_write(sdev, SLIC_REG_WCS, instr);
> +			instr = slic_read_dword_from_firmware(fw, &idx);
> +			/* write out instruction to high addr */
> +			slic_write(sdev, SLIC_REG_WCS, instr);
> +			instr = slic_read_dword_from_firmware(fw, &idx);
> +		}
> +	}
> +	slic_flush_write(sdev);
> +	mdelay(10);
> +	/* everything OK, kick off the card */
> +	slic_write(sdev, SLIC_REG_WCS, SLIC_WCS_START);
> +	slic_flush_write(sdev);
> +	/* wait long enough for ucode to init card and reach the mainloop */
> +	mdelay(20);
> +release:
> +	release_firmware(fw);
> +
> +	return err;
> +}

[...]

> +static int slic_init_iface(struct slic_device *sdev)
> +{
> +	struct slic_shmem *sm = &sdev->shmem;
> +	int err;
> +
> +	sdev->upr_list.pending = false;
> +
> +	err = slic_init_shmem(sdev);
> +	if (err) {
> +		netdev_err(sdev->netdev, "failed to load firmware\n");

Wrong error message.

> +		return err;
> +	}

[...]

> +static netdev_tx_t slic_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct slic_device *sdev = netdev_priv(dev);
> +	struct slic_tx_queue *txq = &sdev->txq;
> +	struct slic_tx_buffer *buff;
> +	struct slic_tx_desc *desc;
> +	dma_addr_t paddr;
> +	u32 cbar_val;
> +	u32 maplen;
> +
> +	if (unlikely(slic_get_free_tx_descs(txq) < SLIC_MAX_REQ_TX_DESCS)) {
> +		netdev_err(dev, "BUG! not enought tx LEs left: %u\n",

"Enough"?

> +			   slic_get_free_tx_descs(txq));
> +		return NETDEV_TX_BUSY;
> +	}

[...]

> +static int slic_read_eeprom(struct slic_device *sdev)
> +{
> +	unsigned int devfn = PCI_FUNC(sdev->pdev->devfn);
> +	struct slic_shmem *sm = &sdev->shmem;
> +	struct slic_shmem_data *sm_data = sm->shmem_data;
> +	const unsigned int MAX_LOOPS = 5000;

Another benign -Wsign-compare warning can be fixed by either dropping
the unsigned here or making i below unsigned, too.

> +	unsigned int codesize;
> +	unsigned char *eeprom;
> +	struct slic_upr *upr;
> +	dma_addr_t paddr;
> +	int err = 0;
> +	u8 *mac[2];
> +	int i = 0;
> +
> +	eeprom = dma_zalloc_coherent(&sdev->pdev->dev, SLIC_EEPROM_SIZE,
> +				     &paddr, GFP_KERNEL);
> +	if (!eeprom)
> +		return -ENOMEM;
> +
> +	slic_write(sdev, SLIC_REG_ICR, SLIC_ICR_INT_OFF);
> +	/* setup ISP temporarily */
> +	slic_write(sdev, SLIC_REG_ISP, lower_32_bits(sm->isr_paddr));
> +
> +	err = slic_new_upr(sdev, SLIC_UPR_CONFIG, paddr);
> +	if (!err) {
> +		for (i = 0; i < MAX_LOOPS; i++) {
> +			if (le32_to_cpu(sm_data->isr) & SLIC_ISR_UPC)
> +				break;
> +			mdelay(1);
> +		}
> +		if (i == MAX_LOOPS) {
> +			dev_err(&sdev->pdev->dev,
> +				"timed out while waiting for eeprom data\n");
> +			err = -ETIMEDOUT;
> +		}
> +		upr = slic_dequeue_upr(sdev);
> +		kfree(upr);
> +	}
> +
> +	slic_write(sdev, SLIC_REG_ISP, 0);
> +	slic_write(sdev, SLIC_REG_ISR, 0);
> +	slic_flush_write(sdev);
> +
> +	if (err)
> +		goto free_eeprom;
> +
> +	if (sdev->model == SLIC_MODEL_OASIS) {
> +		struct slic_oasis_eeprom *oee;
> +
> +		oee = (struct slic_oasis_eeprom *)eeprom;
> +		mac[0] = oee->mac;
> +		mac[1] = oee->mac2;
> +		codesize = le16_to_cpu(oee->eeprom_code_size);
> +	} else {
> +		struct slic_mojave_eeprom *mee;
> +
> +		mee = (struct slic_mojave_eeprom *)eeprom;
> +		mac[0] = mee->mac;
> +		mac[1] = mee->mac2;
> +		codesize = le16_to_cpu(mee->eeprom_code_size);
> +	}
> +
> +	if (!slic_eeprom_valid(eeprom, codesize)) {
> +		dev_err(&sdev->pdev->dev, "invalid checksum in eeprom\n");
> +		err = -EINVAL;
> +		goto free_eeprom;
> +	}
> +	/* set mac address */
> +	ether_addr_copy(sdev->netdev->dev_addr, mac[devfn]);
> +free_eeprom:
> +	dma_free_coherent(&sdev->pdev->dev, SLIC_EEPROM_SIZE, eeprom, paddr);
> +
> +	return err;
> +}

[...]

> +static int slic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
> +{

[...]

> +	err = register_netdev(dev);
> +	if (err) {
> +		dev_err(&pdev->dev, "failed to register net device: %i\n",
> +			err);

Could be on one line.

Regards,
Markus
