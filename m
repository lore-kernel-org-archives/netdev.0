From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Add Flow
	control,
Date: Mon, 15 Nov 2010 15:21:30 +0100
Message-ID: <4CE141EA.5070702@grandegger.com>
References: <4CE0EFA7.9020007@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CE0EFA7.9020007-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On 11/15/2010 09:30 AM, Tomoya MORINAGA wrote:
>  * Add Flow control
>  * Fix Data copy issue (endianness)
>  * Add Macro prefix "PCH_"
>  * Separate interface register structure
>  * Some functions are unified.
>  * Change MessageObject indication(PCH_RX_OBJ_START, etc..)
>  * Enumerate LEC macro
>  * Move MSI processing from open/close to probe/remove processing
>  * Use BIT(x)
>  * and more...
> 
> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> ---
>  drivers/net/can/pch_can.c | 1348 ++++++++++++++++++++-------------------------
>  1 files changed, 595 insertions(+), 753 deletions(-)
> 
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index 6727182..6a38593 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
...
> -	if (status & PCH_LEC_ALL) {
> +	lec = status & PCH_LEC_ALL;
> +	switch (lec) {
> +	case PCH_STUF_ERR:
> +		cf->data[2] |= CAN_ERR_PROT_STUFF;
>  		priv->can.can_stats.bus_error++;
>  		stats->rx_errors++;
> -		switch (status & PCH_LEC_ALL) {
> -		case PCH_STUF_ERR:
> -			cf->data[2] |= CAN_ERR_PROT_STUFF;
> -			break;
> -		case PCH_FORM_ERR:
> -			cf->data[2] |= CAN_ERR_PROT_FORM;
> -			break;
> -		case PCH_ACK_ERR:
> -			cf->data[2] |= CAN_ERR_PROT_LOC_ACK |
> -				       CAN_ERR_PROT_LOC_ACK_DEL;
> -			break;
> -		case PCH_BIT1_ERR:
> -		case PCH_BIT0_ERR:
> -			cf->data[2] |= CAN_ERR_PROT_BIT;
> -			break;
> -		case PCH_CRC_ERR:
> -			cf->data[2] |= CAN_ERR_PROT_LOC_CRC_SEQ |
> -				       CAN_ERR_PROT_LOC_CRC_DEL;
> -			break;
> -		default:
> -			iowrite32(status | PCH_LEC_ALL, &priv->regs->stat);
> -			break;
> -		}
> -
> +		break;
> +	case PCH_FORM_ERR:
> +		cf->data[2] |= CAN_ERR_PROT_FORM;
> +		priv->can.can_stats.bus_error++;
> +		stats->rx_errors++;
> +		break;
> +	case PCH_ACK_ERR:
> +		cf->can_id |= CAN_ERR_ACK;
> +		priv->can.can_stats.bus_error++;
> +		stats->rx_errors++;
> +		break;
> +	case PCH_BIT1_ERR:
> +	case PCH_BIT0_ERR:
> +		cf->data[2] |= CAN_ERR_PROT_BIT;
> +		priv->can.can_stats.bus_error++;
> +		stats->rx_errors++;
> +		break;
> +	case PCH_CRC_ERR:
> +		cf->data[2] |= CAN_ERR_PROT_LOC_CRC_SEQ |
> +			       CAN_ERR_PROT_LOC_CRC_DEL;
> +		priv->can.can_stats.bus_error++;
> +		stats->rx_errors++;
> +		break;
> +	case PCH_LEC_ALL: /* Written by CPU. No error status */
> +		break;
>  	}

More comments to the lec handling below.

> +	cf->data[6] = ioread32(&priv->regs->errc) & PCH_TEC;
> +	cf->data[7] = (ioread32(&priv->regs->errc) & PCH_REC) >> 8;

Could be handle with just *one* register access.

...
>  static int pch_can_rx_poll(struct napi_struct *napi, int quota)
>  {
>  	struct net_device *ndev = napi->dev;
>  	struct pch_can_priv *priv = netdev_priv(ndev);
> -	struct net_device_stats *stats = &(priv->ndev->stats);
> -	u32 dlc;
>  	u32 int_stat;
>  	int rcv_pkts = 0;
>  	u32 reg_stat;
> -	unsigned long flags;
>  
>  	int_stat = pch_can_int_pending(priv);
>  	if (!int_stat)
> -		return 0;
> +		goto end;
>  
> -INT_STAT:
> -	if (int_stat == CAN_STATUS_INT) {
> +	if ((int_stat == PCH_STATUS_INT) && (quota > 0)) {
>  		reg_stat = ioread32(&priv->regs->stat);
>  		if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) {
> -			if ((reg_stat & PCH_LEC_ALL) != PCH_LEC_ALL)
> +			if ((reg_stat & PCH_LEC_ALL) != PCH_LEC_ALL) {
>  				pch_can_error(ndev, reg_stat);
> +				quota--;
> +			}

Should be:

  		if (reg_stat & PCH_BUS_OFF ||
		    (reg_stat & PCH_LEC_ALL) != PCH_LEC_ALL) {

Your lec handling is still not correc, I believe. The driver needs to
write PCH_LEC_ALL to the "stat" register once in the initialization code
and then after each error observed (lec != PCH_LEC_ALL). I still do not
find such code. Could you show us the output of

  "# candump any,0:0,#FFFFFFFF"

when yo send CAN messages *without* a cable connected?.

Thanks,

Wolfgang.
