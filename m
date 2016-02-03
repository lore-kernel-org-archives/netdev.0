From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next] hv_netvsc: Increase delay for
 RNDIS_STATUS_NETWORK_CHANGE
Date: Wed, 03 Feb 2016 14:05:54 +0100
Message-ID: <87si1ax7t9.fsf@vitty.brq.redhat.com>
References: <1454458556-10591-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
 davem@davemloft.net
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1454458556-10591-1-git-send-email-haiyangz@microsoft.com>
 (Haiyang Zhang's message of "Tue, 2 Feb 2016 16:15:56 -0800")
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Haiyang Zhang <haiyangz@microsoft.com> writes:

> We simulates a link down period for RNDIS_STATUS_NETWORK_CHANGE message to
> trigger DHCP renew. User daemons may need multiple seconds to trigger the
> link down event. (e.g. ifplugd: 5sec, network-manager: 4sec.) So update
> this link down period to 10 sec to properly trigger DHCP renew.
>

I probably don't follow: why do we need sucha a delay? If (with real
hardware) you plug network cable out and in one second you plug it in
you'll get DHCP renewed, right?

When I introduced RNDIS_STATUS_NETWORK_CHANGE handling by emulating a
pair of up/down events I put 2 second delay to make link_watch happy (as
we only handle 1 event per second there) but 10 seconds sounds to much
to me.

> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc_drv.c |   10 ++++++++--
>  1 files changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 1d3a665..6f23973 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -43,6 +43,8 @@
>
>  #define RING_SIZE_MIN 64
>  #define LINKCHANGE_INT (2 * HZ)
> +/* Extra delay for RNDIS_STATUS_NETWORK_CHANGE: */
> +#define LINKCHANGE_DELAY (8 * HZ)
>  static int ring_size = 128;
>  module_param(ring_size, int, S_IRUGO);
>  MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
> @@ -964,6 +966,7 @@ static void netvsc_link_change(struct work_struct *w)
>  		return;
>  	}
>  	ndev_ctx->last_reconfig = jiffies;
> +	delay = LINKCHANGE_INT;
>
>  	spin_lock_irqsave(&ndev_ctx->lock, flags);
>  	if (!list_empty(&ndev_ctx->reconfig_events)) {
> @@ -1009,8 +1012,11 @@ static void netvsc_link_change(struct work_struct *w)
>  			netif_tx_stop_all_queues(net);
>  			event->event = RNDIS_STATUS_MEDIA_CONNECT;
>  			spin_lock_irqsave(&ndev_ctx->lock, flags);
> -			list_add_tail(&event->list, &ndev_ctx->reconfig_events);
> +			list_add(&event->list, &ndev_ctx->reconfig_events);

Why? Adding to tail was here to not screw the order of events...

>  			spin_unlock_irqrestore(&ndev_ctx->lock, flags);
> +
> +			ndev_ctx->last_reconfig += LINKCHANGE_DELAY;
> +			delay = LINKCHANGE_INT + LINKCHANGE_DELAY;
>  			reschedule = true;
>  		}
>  		break;
> @@ -1025,7 +1031,7 @@ static void netvsc_link_change(struct work_struct *w)
>  	 * second, handle next reconfig event in 2 seconds.
>  	 */
>  	if (reschedule)
> -		schedule_delayed_work(&ndev_ctx->dwork, LINKCHANGE_INT);
> +		schedule_delayed_work(&ndev_ctx->dwork, delay);
>  }
>
>  static void netvsc_free_netdev(struct net_device *netdev)

-- 
  Vitaly
