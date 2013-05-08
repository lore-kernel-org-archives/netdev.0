From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 5/8] qlcnic: Fix reset recovery after transmit
 timeout
Date: Wed, 08 May 2013 12:06:58 -0700 (PDT)
Message-ID: <20130508.120658.318501645917412400.davem@davemloft.net>
References: <1367956506-3290-1-git-send-email-shahed.shaikh@qlogic.com>
	<1367956506-3290-6-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	sony.chacko@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755497Ab3EHTHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 15:07:04 -0400
In-Reply-To: <1367956506-3290-6-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Tue, 7 May 2013 15:55:03 -0400

> @@ -435,10 +435,7 @@ static void qlcnic_83xx_idc_attach_driver(struct qlcnic_adapter *adapter)
>  	}
>  done:
>  	netif_device_attach(netdev);
> -	if (netif_running(netdev)) {
> -		netif_carrier_on(netdev);
> -		netif_wake_queue(netdev);
> -	}
> +	adapter->netdev->trans_start = jiffies;
>  }
>  
>  static int qlcnic_83xx_idc_enter_failed_state(struct qlcnic_adapter *adapter,

This is not right.

Multiqueue aware drivers should never access netdev->trans_start
directly, and I see several such writes in this driver.

Anything you write here will be totally ignored by the rest of the
kernel, because this value is overwritten by every call to dev_trans_start()
which is the only valid method by which to determine this value.

dev_trans_start() walks all of the transmit queues, recording the most
recent txq->trans_start timestamp in netdev->trans_start.

So if you write netdev->trans_start in your driver, it does nothing,
because even the dev_watchdog() time is going to inspect the per-queue
txq->trans_start values and ignore the netdev->trans_start value for
devices whose driver suppports multiqueue as qlcnic does.
