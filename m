From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] xen-netback: Fix vif->disable handling
Date: Thu, 07 Aug 2014 00:31:32 +0400
Message-ID: <53E290A4.1020900@cogentembedded.com>
References: <1407353598-14185-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407353598-14185-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/06/2014 11:33 PM, Zoltan Kiss wrote:

> In the patch called "xen-netback: Turn off the carrier if the guest is not able
> to receive" new branches were introduced to this if statement, risking that a
> queue with non-zero id can reenable the disabled interface.

> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: xen-devel@lists.xenproject.org

> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index aa20933..f84516f 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -2027,7 +2027,13 @@ int xenvif_kthread_guest_rx(void *data)
>   		 */
>   		if (unlikely(queue->vif->disabled && queue->id == 0))
>   			xenvif_carrier_off(queue->vif);
> -		else if (unlikely(test_and_clear_bit(QUEUE_STATUS_RX_PURGE_EVENT,
> +		else if (unlikely(queue->vif->disabled)) {

    Perhaps it's time to fix the coding style and add {} around the first arm 
of the *if* statement?

> +			/* kthread_stop() would be called upon this thread soon,
> +			 * be a bit proactive
> +			 */
> +			skb_queue_purge(&queue->rx_queue);
> +			queue->rx_last_skb_slots = 0;
> +		} else if (unlikely(test_and_clear_bit(QUEUE_STATUS_RX_PURGE_EVENT,
>   						     &queue->status))) {
>   			xenvif_rx_purge_event(queue);
>   		} else if (!netif_carrier_ok(queue->vif->dev)) {

WBR, Sergei
