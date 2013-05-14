From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH 2/2] mrf24j40: Keep the interrupt
 line enabled
Date: Mon, 13 May 2013 23:55:48 -0400
Message-ID: <5191B5C4.2020609@signal11.us>
References: <1368112788-25701-1-git-send-email-david@hauweele.net>
	<1368112788-25701-2-git-send-email-david@hauweele.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: David Hauweele <david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1368112788-25701-2-git-send-email-david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On 5/9/13 11:19 AM, David Hauweele wrote:
> Disabling the interrupt line could miss an IRQ and leave the line into a
> low state hence locking the driver.
>

Have you observed this? My understanding is that the interrupt won't be 
lost but instead delayed until enable_irq() is called.

I got this pattern from the other 802.15.4 drivers. Perhaps my 
understanding is wrong.


> Signed-off-by: David Hauweele <david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>
> ---
>   drivers/net/ieee802154/mrf24j40.c |    7 +------
>   1 file changed, 1 insertion(+), 6 deletions(-)
>
> diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
> index 1e3ddf3..6ef32f7 100644
> --- a/drivers/net/ieee802154/mrf24j40.c
> +++ b/drivers/net/ieee802154/mrf24j40.c
> @@ -603,8 +603,6 @@ static irqreturn_t mrf24j40_isr(int irq, void *data)
>   {
>   	struct mrf24j40 *devrec = data;
>
> -	disable_irq_nosync(irq);
> -
>   	schedule_work(&devrec->irqwork);
>
>   	return IRQ_HANDLED;
> @@ -619,7 +617,7 @@ static void mrf24j40_isrwork(struct work_struct *work)
>   	/* Read the interrupt status */
>   	ret = read_short_reg(devrec, REG_INTSTAT, &intstat);
>   	if (ret)
> -		goto out;
> +		return;
>
>   	/* Check for TX complete */
>   	if (intstat & 0x1)
> @@ -628,9 +626,6 @@ static void mrf24j40_isrwork(struct work_struct *work)
>   	/* Check for Rx */
>   	if (intstat & 0x8)
>   		schedule_work(&devrec->rxwork);
> -
> -out:
> -	enable_irq(devrec->spi->irq);
>   }
>
>   static void mrf24j40_rxwork(struct work_struct *work)
>


------------------------------------------------------------------------------
AlienVault Unified Security Management (USM) platform delivers complete
security visibility with the essential security capabilities. Easily and
efficiently configure, manage, and operate all of your security controls
from a single console and one unified framework. Download a free trial.
http://p.sf.net/sfu/alienvault_d2d
