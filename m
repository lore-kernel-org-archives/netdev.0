From: Dean Nelson <dnelson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 4/4] drivers: net: Add APM X-Gene SoC ethernet driver
 support.
Date: Wed, 14 May 2014 10:18:31 -0500
Message-ID: <53738947.7050204@redhat.com>
References: <1399326447-2329-1-git-send-email-isubramanian@apm.com> <1399326447-2329-5-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	patches-qTEPVZfXA3Y@public.gmane.org, Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399326447-2329-5-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/05/2014 04:47 PM, Iyappan Subramanian wrote:
> This patch adds network driver for APM X-Gene SoC ethernet.
>
> Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
> Signed-off-by: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
> Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
> ---
>   drivers/net/ethernet/Kconfig                     |    1 +
>   drivers/net/ethernet/Makefile                    |    1 +
>   drivers/net/ethernet/apm/Kconfig                 |    1 +
>   drivers/net/ethernet/apm/Makefile                |    5 +
>   drivers/net/ethernet/apm/xgene/Kconfig           |    9 +
>   drivers/net/ethernet/apm/xgene/Makefile          |    6 +
>   drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |  807 +++++++++++++++++++
>   drivers/net/ethernet/apm/xgene/xgene_enet_hw.h   |  353 ++++++++
>   drivers/net/ethernet/apm/xgene/xgene_enet_main.c |  936 ++++++++++++++++++++++
>   drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  131 +++
>   10 files changed, 2250 insertions(+)
>   create mode 100644 drivers/net/ethernet/apm/Kconfig
>   create mode 100644 drivers/net/ethernet/apm/Makefile
>   create mode 100644 drivers/net/ethernet/apm/xgene/Kconfig
>   create mode 100644 drivers/net/ethernet/apm/xgene/Makefile
>   create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
>   create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
>   create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.c
>   create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.h

Below, you'll find some comments from my review (as far as I've
gotten)...

There's an inter-related piece centered on ring->id and RING_BUFNUM(),
with comments scattered throughout. You may have to read all the
comments related to it before what I'm trying to convey makes sense.
If indeed anything of what I'm trying to say can make any sense at
all. :-) For I might be missing the obvious.

I'll continue my review as time permits, but thought it best to send
what I've seen so far for your consideration.

Dean


<snip>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> new file mode 100644
> index 0000000..421a841
> --- /dev/null
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c

<snip>
> +
> +struct xgene_enet_desc_ring *xgene_enet_setup_ring(
> +					struct xgene_enet_desc_ring *ring)
> +{
> +	u32 size = ring->size;
> +	u32 i, data;
> +	u64 *desc;
> +
> +	xgene_enet_clr_ring_state(ring);
> +	xgene_enet_set_ring_state(ring);
> +	xgene_enet_set_ring_id(ring);
> +
> +	ring->slots = IS_FP(ring->id) ? size / 16 : size / 32;
> +
> +	if (IS_FP(ring->id) || RING_OWNER(ring) != RING_OWNER_CPU)
> +		goto out;

Since we will bail out here, if (ring->id & 0x20) is true...

> +
> +	for (i = 0; i < ring->slots; i++) {
> +		desc = (u64 *)&ring->desc[i];
> +		desc[EMPTY_SLOT_INDEX] = EMPTY_SLOT;
> +	}
> +
> +	xgene_enet_ring_rd32(ring, CSR_RING_NE_INT_MODE, &data);
> +	data |= (1 << (31 - RING_BUFNUM(ring)));

Then RING_BUFNUM(ring) should always be 0 here, since I don't see
the 'bufnum' portion of ring->id being anything other than 0x20 or 0.
So why bother?


> +	xgene_enet_ring_wr32(ring, CSR_RING_NE_INT_MODE, data);
> +
> +out:
> +	return ring;
> +}
> +
> +void xgene_enet_clear_ring(struct xgene_enet_desc_ring *ring)
> +{
> +	u32 data;
> +
> +	if (IS_FP(ring->id) || RING_OWNER(ring) != RING_OWNER_CPU)
> +		goto out;

And again, since we will bail out here, if (ring->id & 0x20) is true...

> +
> +	xgene_enet_ring_rd32(ring, CSR_RING_NE_INT_MODE, &data);
> +	data &= ~(u32) (1 << (31 - RING_BUFNUM(ring)));

Then RING_BUFNUM(ring) should always be 0 here, since I don't see
the 'bufnum' portion of ring->id being anything other than 0x20 or 0.
So why bother?


> +	xgene_enet_ring_wr32(ring, CSR_RING_NE_INT_MODE, data);
> +
> +out:
> +	xgene_enet_clr_desc_ring_id(ring);
> +	xgene_enet_clr_ring_state(ring);
> +}
> +


<snip>
> +
> +static int xgene_enet_phy_connect(struct net_device *ndev)
> +{
> +	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> +	struct device_node *phy_np;
> +	struct phy_device *phy_dev;

Initialize phy_dev to NULL here, to assist the addition of a 'goto'
below.

> +	int ret = 0;
> +
> +	struct device *dev = &pdata->pdev->dev;
> +
> +	phy_np = of_parse_phandle(dev->of_node, "phy-handle", 0);
> +

Please remove the preceding blank line.


> +	if (!phy_np) {
> +		netdev_dbg(ndev, "No phy-handle found\n");
> +		ret = -ENODEV;

The following line should be added here...

                 goto out;
> +	}
> +
> +	phy_dev = of_phy_connect(ndev, phy_np, &xgene_enet_adjust_link,
> +				 0, pdata->phy_mode);
> +	if (!phy_dev) {
> +		netdev_err(ndev, "Could not connect to PHY\n");
> +		ret = -ENODEV;
> +		goto out;
> +	}
> +
> +out:
> +	pdata->phy_link = 0;
> +	pdata->phy_speed = 0;
> +	pdata->phy_dev = phy_dev;
> +
> +	return ret;
> +}
> +


<snip>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
> new file mode 100644
> index 0000000..a4c0a14
> --- /dev/null
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h

<snip>
> +
> +static inline u32 get_bits(u32 val, u32 start, u32 end)
> +{
> +	return (val & GENMASK(end, start)) >> start;
> +}
> +
> +#define CSR_RING_ID		0x00000008
> +#define OVERWRITE		BIT(31)
> +#define IS_BUFFER_POOL		BIT(20)
> +#define PREFETCH_BUF_EN		BIT(21)
> +#define CSR_RING_ID_BUF		0x0000000c
> +#define CSR_RING_NE_INT_MODE	0x0000017c
> +#define CSR_RING_CONFIG		0x0000006c
> +#define CSR_RING_WR_BASE	0x00000070
> +#define NUM_RING_CONFIG		5
> +#define BUFPOOL_MODE		3
> +#define RM3			3
> +#define INC_DEC_CMD_ADDR	0x2c
> +#define IS_FP(x) ((x & 0x0020) ? 1 : 0)

IS_FP() is only ever called with 'ring->id' as the argument 'x'.

And this macro should really be defined as...

     #define IS_FP(x)       (((x) & 0x0020) ? 1 : 0)

with a parentheses around the argument x. (And this holds true for
all your macros defined here, they should have parentheses around each
of their arguments in the body of the macro.)


> +#define UDP_HDR_SIZE		2
> +
> +#define CREATE_MASK(pos, len)		GENMASK(pos+len-1, pos)
> +#define CREATE_MASK_ULL(pos, len)	GENMASK_ULL(pos+len-1, pos)

Add parentheses around args in the above two macros.


> +
> +/* Empty slot soft signature */
> +#define EMPTY_SLOT_INDEX	1
> +#define EMPTY_SLOT		~0ULL
> +
> +#define RING_BUFNUM(q)		(q->id & 0x003F)
> +#define RING_OWNER(q)		((q->id & 0x03C0) >> 6)

Add parentheses around args...

     #define RING_BUFNUM(q)      ((q)->id & 0x003F)
     #define RING_OWNER(q)       (((q)->id & 0x3C0) >> 6)


Taking IS_FP(), together with RING_BUFNUM() and RING_OWNER(), I gather
that ring->id is...

     0x03C0        owner
     0x0020        buf_pool flag
     0x001F        bufnum

But I don't see bufnum ever being set to anything other than 0.
Wherever RING_BUFNUM() is called, either a check for 0x0020 being set
precedes it (and if true returns), or 0x0020 is subtracted from it. So
that bit can't be playing a part in what one might consider the bufnum
to be. Is this correct? Or am I missing something (perhaps the obvious)?


> +#define BUF_LEN_CODE_2K		0x5000
> +

<snip>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> new file mode 100644
> index 0000000..0feb571
> --- /dev/null
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c


<snip>
> +
> +static int xgene_enet_create_desc_rings(struct net_device *ndev)
> +{
> +	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> +	struct device *dev = &pdata->pdev->dev;
> +	struct xgene_enet_desc_ring *rx_ring, *tx_ring, *cp_ring;
> +	struct xgene_enet_desc_ring *buf_pool = NULL;
> +	u32 ring_num = 0;
> +	u32 ring_id;
> +	int ret = 0;
> +
> +	/* allocate rx descriptor ring */
> +	ring_id = (RING_OWNER_CPU << 6) | RING_BUFNUM_REGULAR;

Here we see what will become the value of ring->id being set up
RING_BUFNUM_REGULAR is 0. I don't see a non-zero bufnum being set
here (or anywhere else).

And this should be made into a macro and defined along side of
RING_BUFNUM() and RING_OWNER(). Perhaps something like...

      #define SET_RING_ID(owner, bufnum)  ((owner) << 6) | (bufnum))

or some such. And you may consider changing these to functions for
the advantage that has over macros. The compiler can inline them.


> +	rx_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
> +					      RING_CFGSIZE_16KB, ring_id);
> +	if (IS_ERR_OR_NULL(rx_ring)) {
> +		ret = PTR_ERR(rx_ring);
> +		goto err;
> +	}
> +
> +	/* allocate buffer pool for receiving packets */
> +	ring_id = (RING_OWNER_ETH0 << 6) | RING_BUFNUM_BUFPOOL;

And again here, RING_BUFNUM_BUFPOOL is 0x20. But that's just a flag
that indicates that this ring is a buf_pool. I don't see a non-zero
bufnum being set here (or anywhere else).

And a macro like 'SET_RING_ID()' as mentioned above, should be used
here.


> +	buf_pool = xgene_enet_create_desc_ring(ndev, ring_num++,
> +					       RING_CFGSIZE_2KB, ring_id);
> +	if (IS_ERR_OR_NULL(buf_pool)) {
> +		ret = PTR_ERR(buf_pool);
> +		goto err;
> +	}
> +
> +	rx_ring->nbufpool = NUM_BUFPOOL;
> +	rx_ring->buf_pool = buf_pool;
> +	rx_ring->irq = pdata->rx_irq;
> +	buf_pool->rx_skb = devm_kcalloc(dev, buf_pool->slots,
> +				     sizeof(struct sk_buff *), GFP_KERNEL);
> +	if (!buf_pool->rx_skb) {
> +		ret = -ENOMEM;
> +		goto err;
> +	}
> +
> +	buf_pool->dst_ring_num = xgene_enet_dst_ring_num(buf_pool);
> +	rx_ring->buf_pool = buf_pool;
> +	pdata->rx_ring = rx_ring;
> +
> +	/* allocate tx descriptor ring */
> +	ring_id = (RING_OWNER_ETH0 << 6) | RING_BUFNUM_REGULAR;

And again here. same story as above.


> +	tx_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
> +					      RING_CFGSIZE_16KB, ring_id);
> +	if (IS_ERR_OR_NULL(tx_ring)) {
> +		ret = PTR_ERR(tx_ring);
> +		goto err;
> +	}
> +	pdata->tx_ring = tx_ring;
> +
> +	cp_ring = pdata->rx_ring;
> +	cp_ring->cp_skb = devm_kcalloc(dev, tx_ring->slots,
> +				     sizeof(struct sk_buff *), GFP_KERNEL);
> +	if (!cp_ring->cp_skb) {
> +		ret = -ENOMEM;
> +		goto err;
> +	}
> +	pdata->tx_ring->cp_ring = cp_ring;
> +	pdata->tx_ring->dst_ring_num = xgene_enet_dst_ring_num(cp_ring);
> +
> +	pdata->tx_qcnt_hi = pdata->tx_ring->slots / 2;
> +	pdata->cp_qcnt_hi = pdata->rx_ring->slots / 2;
> +	pdata->cp_qcnt_low = pdata->cp_qcnt_hi / 2;
> +
> +	return 0;
> +
> +err:
> +	xgene_enet_delete_desc_rings(pdata);
> +	return ret;
> +}
> +

<snip>
> +
> +static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
> +{
> +	struct platform_device *pdev;
> +	struct net_device *ndev;
> +	struct device *dev;
> +	struct resource *res;
> +	void *base_addr;
> +	const char *mac;
> +	int ret = 0;
> +
> +	pdev = pdata->pdev;
> +	dev = &pdev->dev;
> +	ndev = pdata->ndev;
> +
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (!res) {
> +		dev_err(dev, "Resource IORESOURCE_MEM 0 not defined\n");
> +		ret = -ENODEV;
> +		goto out;
> +	}
> +	pdata->base_addr = devm_ioremap_resource(dev, res);
> +	if (IS_ERR(pdata->base_addr)) {
> +		dev_err(dev, "Unable to retrieve ENET Port CSR region\n");
> +		return PTR_ERR(pdata->base_addr);
> +	}
> +
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> +	if (!res) {
> +		dev_err(dev, "Resource IORESOURCE_MEM 1 not defined\n");
> +		ret = -ENODEV;
> +		goto out;
> +	}
> +	pdata->ring_csr_addr = devm_ioremap_resource(dev, res);
> +	if (IS_ERR(pdata->ring_csr_addr)) {
> +		dev_err(dev, "Unable to retrieve ENET Ring CSR region\n");
> +		return PTR_ERR(pdata->ring_csr_addr);
> +	}
> +
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
> +	if (!res) {
> +		dev_err(dev, "Resource IORESOURCE_MEM 2 not defined\n");
> +		ret = -ENODEV;
> +		goto out;
> +	}
> +	pdata->ring_cmd_addr = devm_ioremap_resource(dev, res);
> +	if (IS_ERR(pdata->ring_cmd_addr)) {
> +		dev_err(dev, "Unable to retrieve ENET Ring command region\n");
> +		return PTR_ERR(pdata->ring_cmd_addr);
> +	}
> +
> +	ret = platform_get_irq(pdev, 0);
> +	if (ret <= 0) {

If you return 0 as an error return value from this function, the caller
will have no idea anything was amiss.


> +		dev_err(dev, "Unable to get ENET Rx IRQ\n");

So you need to at least convert the 0 to a sensible error return,
leaving the others as is...

                 ret = ret ? : -ENXIO;

or just reset them all..

                 ret = -ENXIO;

You can chose the error return value that makes the most sense to you.
I've seen others use: -ENXIO, -EINVAL, and -ENODEV.


> +		goto out;
> +	}
> +	pdata->rx_irq = ret;
> +
> +	mac = of_get_mac_address(dev->of_node);
> +	if (mac)
> +		memcpy(ndev->dev_addr, mac, ndev->addr_len);
> +	else
> +		eth_hw_addr_random(ndev);
> +	memcpy(ndev->perm_addr, ndev->dev_addr, ndev->addr_len);
> +
> +	pdata->phy_mode = of_get_phy_mode(pdev->dev.of_node);
> +	if (pdata->phy_mode < 0) {
> +		dev_err(dev, "Incorrect phy-connection-type in DTS\n");
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
> +	pdata->clk = devm_clk_get(&pdev->dev, NULL);
> +	ret = IS_ERR(pdata->clk);

IS_ERR() does not yield a proper return error value. For that one needs
to use PTR_ERR(). So remove the preceding line, and change the following
line...

> +	if (ret) {

to...

         if (IS_ERR(pdata->clk)) {

> +		dev_err(&pdev->dev, "can't get clock\n");

And add the following line here...

                 ret = PTR_ERR(info->clk);
> +		goto out;
> +	}
> +
> +	base_addr = pdata->base_addr;
> +	pdata->eth_csr_addr = base_addr + BLOCK_ETH_CSR_OFFSET;
> +	pdata->eth_ring_if_addr = base_addr + BLOCK_ETH_RING_IF_OFFSET;
> +	pdata->eth_diag_csr_addr = base_addr + BLOCK_ETH_DIAG_CSR_OFFSET;
> +	pdata->mcx_mac_addr = base_addr + BLOCK_ETH_MAC_OFFSET;
> +	pdata->mcx_stats_addr = base_addr + BLOCK_ETH_STATS_OFFSET;
> +	pdata->mcx_mac_csr_addr = base_addr + BLOCK_ETH_MAC_CSR_OFFSET;
> +	pdata->rx_buff_cnt = NUM_PKT_BUF;
> +out:
> +	return ret;

The mixture of 'goto' and 'return' usage in this function is confusing.
I'd think it best if they were all the same. Because of the following,
which is stated in Documentation/CodingStyle (chapter 7)...

     The goto statement comes in handy when a function exits from multiple
     locations and some common work such as cleanup has to be done.  If 
there is no
     cleanup needed then just return directly.

And since you don't have any common work being done, my vote is with
using returns and not gotos.

I'd suggest you consider replacing gotos by returns in all functions
which simply return without having any common work to be done.


> +}
> +
> +static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
> +{
> +	struct net_device *ndev = pdata->ndev;
> +	struct xgene_enet_desc_ring *buf_pool;
> +	int ret = 0;
> +
> +	xgene_enet_reset(pdata);
> +
> +	xgene_gmac_tx_disable(pdata);
> +	xgene_gmac_rx_disable(pdata);
> +
> +	ret = xgene_enet_create_desc_rings(ndev);
> +	if (ret) {
> +		netdev_err(ndev, "Error in ring configuration\n");
> +		goto out;
> +	}
> +
> +	/* setup buffer pool */
> +	buf_pool = pdata->rx_ring->buf_pool;
> +	xgene_enet_init_bufpool(buf_pool);
> +	ret = xgene_enet_refill_bufpool(buf_pool, pdata->rx_buff_cnt);
> +	if (ret)
> +		goto out;
> +
> +	xgene_enet_cle_bypass(pdata, xgene_enet_dst_ring_num(pdata->rx_ring),
> +			      RING_BUFNUM(buf_pool) - 0x20, 0);

Subtracting an unidentified number (0x20) from RING_BUFNUM(buf_pool)
doesn't seem to me to be the best approach here. If I'm not mistaken,
it appears the 0x20 is a flag set in ring->id to indicate that this is
a buf_pool. And here you're trying to grab just the non-flag portion
of ring->id's 0x003f, which amounts to 0x001f.

So maybe given the other things I've mentioned about RING_BUFNUM() in
this review, if it is still needed, change it to be...

     #define RING_BUFNUM(q)      ((q)->id & 0x001F)

Or since the 3rd argument to xgene_enet_cle_bypass() is called fpsel,
you might create a new macro called GET_FPSEL(), and make it like the
one just mentioned.

But again, as mentioned elsewhere, the value will always be zero for
the driver as it is now. So is there a point to this?


> +	xgene_gmac_init(pdata, SPEED_1000);
> +out:
> +	return ret;
> +}

<snip>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
