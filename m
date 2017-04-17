From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: unmap DMA buffers when freeing rings
Date: Mon, 17 Apr 2017 11:57:27 +0300
Message-ID: <ef4b905e-15fa-d257-72b3-bb5ed7f55b80@cogentembedded.com>
References: <20170416200157.111095876@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170416200157.111095876@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 4/16/2017 11:01 PM, Sergei Shtylyov wrote:

> The DMA API debugging (when enabled) causes:
>
> WARNING: CPU: 0 PID: 1445 at lib/dma-debug.c:519 add_dma_entry+0xe0/0x12c
> DMA-API: exceeded 7 overlapping mappings of cacheline 0x01b2974d
>
> to be  printed after repeated initialization of the Ether device, e.g.
> suspend/resume or 'ifconfig' up/down. This is because DMA buffers mapped
> using dma_map_single() in sh_eth_ring_format() and sh_eth_start_xmit() are
> never unmapped. Resolve this problem by unmapping the buffers when freeing
> the descriptor  rings;  in order  to do it right, we'd have to add an extra
> parameter to sh_eth_txfree() (we rename this function to sh_eth_tx_free(),
> while at it).
>
> Based on the commit a47b70ea86bd ("ravb: unmap descriptors when freeing
> rings").
>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
> ---
>  drivers/net/ethernet/renesas/sh_eth.c |  122 ++++++++++++++++++----------------
>  1 file changed, 67 insertions(+), 55 deletions(-)
>
> Index: net/drivers/net/ethernet/renesas/sh_eth.c
> ===================================================================
> --- net.orig/drivers/net/ethernet/renesas/sh_eth.c
> +++ net/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1127,12 +1127,70 @@ static struct mdiobb_ops bb_ops = {
>  	.get_mdio_data = sh_get_mdio,
>  };
>
> +/* free Tx skb function */
> +static int sh_eth_tx_free(struct net_device *ndev, bool sent_only)
> +{
> +	struct sh_eth_private *mdp = netdev_priv(ndev);
> +	struct sh_eth_txdesc *txdesc;
> +	int free_num = 0;
> +	int entry;
> +	bool sent;
> +
> +	for (; mdp->cur_tx - mdp->dirty_tx > 0; mdp->dirty_tx++) {
> +		entry = mdp->dirty_tx % mdp->num_tx_ring;
> +		txdesc = &mdp->tx_ring[entry];
> +		sent = txdesc->status & cpu_to_le32(TD_TACT);

    Oops, forgot to reverse the condition here. Which means I haven't goved in 
enough testing... :-/

> +		if (sent_only && !sent)
> +			break;
[...]

MBR, Sergei
