From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] (23/25) sk98: eliminate Pnmi scratchpad
Date: Fri, 19 Nov 2004 20:11:17 +0100
Message-ID: <20041119191117.GA13556@electric-eye.fr.zoreil.com>
References: <20041115155832.264aa86f@zqx3.pdx.osdl.net> <20041119104331.70a45312@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20041119104331.70a45312@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> diff -Nru a/drivers/net/sk98lin/skethtool.c b/drivers/net/sk98lin/skethtool.c
> --- a/drivers/net/sk98lin/skethtool.c	2004-11-19 10:38:39 -08:00
> +++ b/drivers/net/sk98lin/skethtool.c	2004-11-19 10:38:39 -08:00
> @@ -261,9 +261,26 @@
>  static void sk98_get_ethstats(struct net_device *dev,
>  			    struct ethtool_stats *stats, u64 *data)
>  {
> -	const DEV_NET	*pNet = netdev_priv(dev);
> -	const SK_AC *pAC = pNet->pAC;
> -	const SK_PNMI_STRUCT_DATA *pPnmiStruct = &pAC->PnmiStruct;
> +	DEV_NET	*pNet = netdev_priv(dev);
> +	SK_AC *pAC = pNet->pAC;
> +	unsigned long flags;
> +	unsigned int size;
> +	int err;
> +	SK_PNMI_STRUCT_DATA *pPnmiStruct;
> +
> +
> +	pPnmiStruct = kmalloc(sizeof(*pPnmiStruct), GFP_KERNEL);
> +	if (!pPnmiStruct)
> +		return;
> +
> +	memset(pPnmiStruct, 0, sizeof(*pPnmiStruct));
> +	size = sizeof(*pPnmiStruct);
> +	spin_lock_irqsave(&pAC->SlowPathLock, flags);
> +	err = SkPnmiGetStruct(pAC, pAC->IoBase, pPnmiStruct, &size, pNet->NetNr);
> +	spin_unlock_irqrestore(&pAC->SlowPathLock, flags);
> +
> +	if (err)
> +		return;

If SkPnmiGetStruct() does not frees pPnmiStruct, the code leaks
(if it does free, it is a bit ugly imho).

[...]
> --- a/drivers/net/sk98lin/skge.c	2004-11-19 10:38:39 -08:00
> +++ b/drivers/net/sk98lin/skge.c	2004-11-19 10:38:39 -08:00
> @@ -2842,27 +2842,35 @@
>  	case SK_IOCTL_PRESETMIB:
>  		if (!capable(CAP_NET_ADMIN)) return -EPERM;
>   	case SK_IOCTL_GETMIB:
> -		if(copy_from_user(&pAC->PnmiStruct, Ioctl.pData,
> -			Ioctl.Len<sizeof(pAC->PnmiStruct)?
> -			Ioctl.Len : sizeof(pAC->PnmiStruct))) {
> -			return -EFAULT;
> -		}
> -		Size = SkGeIocMib(pNet, Ioctl.Len, cmd);
> -		if(copy_to_user(Ioctl.pData, &pAC->PnmiStruct,
> -			Ioctl.Len<Size? Ioctl.Len : Size)) {
> -			return -EFAULT;
> -		}
> -		Ioctl.Len = Size;
> -		if(copy_to_user(rq->ifr_data, &Ioctl, sizeof(SK_GE_IOCTL))) {
> +	{
> +		SK_PNMI_STRUCT_DATA *pPnmiStruct;
> +
> +		pPnmiStruct = kmalloc(sizeof(*pPnmiStruct), GFP_KERNEL);
> +		if (!pPnmiStruct)
> +			return -ENOMEM;
> +
> +		memset(pPnmiStruct, 0, sizeof(*pPnmiStruct));
> +
> +		if (copy_from_user(pPnmiStruct, Ioctl.pData, 
> +				   min(sizeof(*pPnmiStruct), Ioctl.Len)))
>  			return -EFAULT;

-> leak.

So far I have not applied the whole serie of patches to check for more leaks
in this patch.

--
Ueimor
