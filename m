From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH net-next] net: stmmac: set total length of the packet to
 be transmitted in TDES3
Date: Tue, 11 Apr 2017 07:40:28 +0200
Message-ID: <a50439b5-0e39-7d67-6034-9cf25ff947a2@st.com>
References: <20170410183329.28847-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Niklas Cassel <niklass@axis.com>
To: Niklas Cassel <niklas.cassel@axis.com>, <alexandre.torgue@st.com>,
        <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170410183329.28847-1-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Niklas

patch looks ok for me, Alex any feedback?

peppe

On 4/10/2017 8:33 PM, Niklas Cassel wrote:
> From: Niklas Cassel <niklas.cassel@axis.com>
>
> Field FL/TPL in register TDES3 is not correctly set on GMAC4.
> TX appears to be functional on GMAC 4.10a even if this field is not set,
> however, to avoid relying on undefined behavior, set the length in TDES3.
>
> The field has a different meaning depending on if the TSE bit in TDES3
> is set or not (TSO). However, regardless of the TSE bit, the field is
> not optional. The field is already set correctly when the TSE bit is set.
>
> Since there is no limit for the number of descriptors that can be
> used for a single packet, the field should be set to the sum of
> the buffers contained in:
> [<desc with First Descriptor bit set> ... <desc n> ...
> <desc with Last Descriptor bit set>], which should be equal to skb->len.
>
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/chain_mode.c   | 6 +++---
>   drivers/net/ethernet/stmicro/stmmac/common.h       | 2 +-
>   drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 3 ++-
>   drivers/net/ethernet/stmicro/stmmac/enh_desc.c     | 2 +-
>   drivers/net/ethernet/stmicro/stmmac/norm_desc.c    | 2 +-
>   drivers/net/ethernet/stmicro/stmmac/ring_mode.c    | 9 ++++++---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 5 +++--
>   7 files changed, 17 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> index 37881f81319e..e93c40b4631e 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
> @@ -52,7 +52,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>   	tx_q->tx_skbuff_dma[entry].len = bmax;
>   	/* do not close the descriptor and do not set own bit */
>   	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum, STMMAC_CHAIN_MODE,
> -					0, false);
> +					0, false, skb->len);
>   
>   	while (len != 0) {
>   		tx_q->tx_skbuff[entry] = NULL;
> @@ -70,7 +70,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>   			tx_q->tx_skbuff_dma[entry].len = bmax;
>   			priv->hw->desc->prepare_tx_desc(desc, 0, bmax, csum,
>   							STMMAC_CHAIN_MODE, 1,
> -							false);
> +							false, skb->len);
>   			len -= bmax;
>   			i++;
>   		} else {
> @@ -85,7 +85,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>   			/* last descriptor can be set now */
>   			priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
>   							STMMAC_CHAIN_MODE, 1,
> -							true);
> +							true, skb->len);
>   			len = 0;
>   		}
>   	}
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index 90d28bcad880..b7ce3fbb5375 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -373,7 +373,7 @@ struct stmmac_desc_ops {
>   	/* Invoked by the xmit function to prepare the tx descriptor */
>   	void (*prepare_tx_desc) (struct dma_desc *p, int is_fs, int len,
>   				 bool csum_flag, int mode, bool tx_own,
> -				 bool ls);
> +				 bool ls, unsigned int tot_pkt_len);
>   	void (*prepare_tso_tx_desc)(struct dma_desc *p, int is_fs, int len1,
>   				    int len2, bool tx_own, bool ls,
>   				    unsigned int tcphdrlen,
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> index 843ec69222ea..aa6476439aee 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> @@ -304,12 +304,13 @@ static void dwmac4_rd_init_tx_desc(struct dma_desc *p, int mode, int end)
>   
>   static void dwmac4_rd_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
>   				      bool csum_flag, int mode, bool tx_own,
> -				      bool ls)
> +				      bool ls, unsigned int tot_pkt_len)
>   {
>   	unsigned int tdes3 = le32_to_cpu(p->des3);
>   
>   	p->des2 |= cpu_to_le32(len & TDES2_BUFFER1_SIZE_MASK);
>   
> +	tdes3 |= tot_pkt_len & TDES3_PACKET_SIZE_MASK;
>   	if (is_fs)
>   		tdes3 |= TDES3_FIRST_DESCRIPTOR;
>   	else
> diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> index 323b59ec74a3..7546b3664113 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> @@ -315,7 +315,7 @@ static void enh_desc_release_tx_desc(struct dma_desc *p, int mode)
>   
>   static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
>   				     bool csum_flag, int mode, bool tx_own,
> -				     bool ls)
> +				     bool ls, unsigned int tot_pkt_len)
>   {
>   	unsigned int tdes0 = le32_to_cpu(p->des0);
>   
> diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> index efb818ebd55e..f817f8f36569 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> @@ -191,7 +191,7 @@ static void ndesc_release_tx_desc(struct dma_desc *p, int mode)
>   
>   static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
>   				  bool csum_flag, int mode, bool tx_own,
> -				  bool ls)
> +				  bool ls, unsigned int tot_pkt_len)
>   {
>   	unsigned int tdes1 = le32_to_cpu(p->des1);
>   
> diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
> index 31213e64513d..28e4b5d50ce6 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
> @@ -59,7 +59,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>   
>   		desc->des3 = cpu_to_le32(des2 + BUF_SIZE_4KiB);
>   		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
> -						STMMAC_RING_MODE, 0, false);
> +						STMMAC_RING_MODE, 0,
> +						false, skb->len);
>   		tx_q->tx_skbuff[entry] = NULL;
>   		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
>   
> @@ -79,7 +80,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>   
>   		desc->des3 = cpu_to_le32(des2 + BUF_SIZE_4KiB);
>   		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
> -						STMMAC_RING_MODE, 1, true);
> +						STMMAC_RING_MODE, 1,
> +						true, skb->len);
>   	} else {
>   		des2 = dma_map_single(priv->device, skb->data,
>   				      nopaged_len, DMA_TO_DEVICE);
> @@ -91,7 +93,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
>   		tx_q->tx_skbuff_dma[entry].is_jumbo = true;
>   		desc->des3 = cpu_to_le32(des2 + BUF_SIZE_4KiB);
>   		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum,
> -						STMMAC_RING_MODE, 0, true);
> +						STMMAC_RING_MODE, 0,
> +						true, skb->len);
>   	}
>   
>   	tx_q->cur_tx = entry;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index a89f76b27ea2..5c1ebc70bebd 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -3033,7 +3033,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>   
>   		/* Prepare the descriptor and set the own bit too */
>   		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
> -						priv->mode, 1, last_segment);
> +						priv->mode, 1, last_segment,
> +						skb->len);
>   	}
>   
>   	entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
> @@ -3116,7 +3117,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>   		/* Prepare the first descriptor setting the OWN bit too */
>   		priv->hw->desc->prepare_tx_desc(first, 1, nopaged_len,
>   						csum_insertion, priv->mode, 1,
> -						last_segment);
> +						last_segment, skb->len);
>   
>   		/* The own bit must be the latest setting done when prepare the
>   		 * descriptor and then barrier is needed to make sure that
