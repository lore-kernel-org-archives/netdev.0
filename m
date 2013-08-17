From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] r8169: fix invalid register dump
Date: Sat, 17 Aug 2013 12:27:38 +0200
Message-ID: <1376735258.11042.102.camel@deadeye.wl.decadent.org.uk>
References: <1376730263-9352-1-git-send-email-lekensteyn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, nic_swsd <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53059 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624Ab3HQK1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 06:27:45 -0400
In-Reply-To: <1376730263-9352-1-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-17 at 11:04 +0200, Peter Wu wrote:
> From: Peter Wu <lekensteyn@gmail.com>
> 
> For some reason, my PCIe RTL8111E onboard NIC on a GA-Z68X-UD3H-B3
> motherboard reads as FFs when reading from MMIO with a block size
> larger than 7. Therefore change to reading blocks of four bytes.
> 
> Thanks to Francois for a better implementation.
> 
> Signed-off-by: Peter Wu <lekensteyn@gmail.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index b5eb419..2943916 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -1897,12 +1897,16 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
>  			     void *p)
>  {
>  	struct rtl8169_private *tp = netdev_priv(dev);
> +	u32 __iomem *data = tp->mmio_addr;
> +	u32 *dw = p;
> +	int i;
>  
>  	if (regs->len > R8169_REGS_SIZE)
>  		regs->len = R8169_REGS_SIZE;
>  
>  	rtl_lock_work(tp);
> -	memcpy_fromio(p, tp->mmio_addr, regs->len);
> +	for (i = regs->len; i > 0; i -= 4)
> +		memcpy_fromio(dw++, data++, min(4, i));

I would be very wary of accessing registers with any width other than
the usual (32 bits).

And as I said, the kernel buffer is always large enough for all your
registers, so this could just be:

	for (i = 0; i < R8169_REGS_SIZE; i += 4)
		memcpy_fromio(dw++, data++, 4);

Ben.

>  	rtl_unlock_work(tp);
>  }
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
