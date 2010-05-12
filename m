From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC PATCH] bnx2: use netif_carrier_off to prevent tx
 timeout
Date: Wed, 12 May 2010 06:31:52 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B6C41FC55@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20100512130628.69bc3890@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Breno Leitao" <leitao@linux.vnet.ibm.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "'Stanislaw Gruszka'" <sgruszka@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3058 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753448Ab0ELNb7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 09:31:59 -0400
In-Reply-To: <20100512130628.69bc3890@dhcp-lab-109.englab.brq.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw Gruszka wrote:

> Touching ->trans_start make netdev watchdog timeouts only
> less probable.
> Use netif_carrier_off to prevent timeout, lately we take care
> of tuning
> carrier on.
>
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---
> Patch was not tested!
>
>  drivers/net/bnx2.c |   12 +++---------
>  1 files changed, 3 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 667f419..44fc392 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -656,17 +656,9 @@ bnx2_netif_stop(struct bnx2 *bp, bool stop_cnic)
>       if (stop_cnic)
>               bnx2_cnic_stop(bp);
>       if (netif_running(bp->dev)) {
> -             int i;
> -
>               bnx2_napi_disable(bp);
>               netif_tx_disable(bp->dev);
> -             /* prevent tx timeout */
> -             for (i = 0; i <  bp->dev->num_tx_queues; i++) {
> -                     struct netdev_queue *txq;
> -
> -                     txq = netdev_get_tx_queue(bp->dev, i);
> -                     txq->trans_start = jiffies;
> -             }
> +             netif_carrier_off(bp->dev);
>       }
>       bnx2_disable_int_sync(bp);
>  }
> @@ -6346,6 +6338,8 @@ bnx2_vlan_rx_register(struct net_device
> *dev, struct vlan_group *vlgrp)
>       if (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN)
>               bnx2_fw_sync(bp,
> BNX2_DRV_MSG_CODE_KEEP_VLAN_UPDATE, 0, 1);
>
> +     if (bp->link_up)
> +             netif_carrier_on(bp->dev);

Thanks Stanislaw, I think it is better to turn carrier on in
bnx2_netif_start().  We can use the start_cnic parameter to
decide if we need to call carrier_on().  I'll test this out.
Thanks.

>       bnx2_netif_start(bp, false);
>  }
>  #endif
> --
> 1.5.5.6
>
>
>
>

