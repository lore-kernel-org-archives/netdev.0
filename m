From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] atl1c: fix issue of transmit queue 0 timed out
Date: Tue, 26 Jun 2012 21:23:44 +0100
Message-ID: <1340742224.2644.1.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340724786-3819-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <qca-linux-team@qualcomm.com>,
	<nic-devel@qualcomm.com>, xiong <xiong@qca.qualcomm.com>
To: "Ren, Cloud" <cjren@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56950 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751554Ab2FZUXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 16:23:51 -0400
In-Reply-To: <1340724786-3819-1-git-send-email-cjren@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 12:33 -0300, Ren, Cloud wrote:
> From: xiong <xiong@qca.qualcomm.com>
> 
> some people report atl1c could cause system hang with following
> kernel trace info:
> ---------------------------------------
> WARNING: at.../net/sched/sch_generic.c:258
> dev_watchdog+0x1db/0x1d0()
> ...
> NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
> ...
> ---------------------------------------
> This is caused by netif_stop_queue calling when cable Link is down
> but netif_wake_queue isn't called when cable Link is resume.
> 
> Signed-off-by: xiong <xiong@qca.qualcomm.com>
> Signed-off-by: Cloud Ren <cjren@qca.qualcomm.com>
> ---
>  drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> index 85717cb..c2736c4 100644
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> @@ -351,6 +351,8 @@ static void atl1c_common_task(struct work_struct *work)
>  		atl1c_irq_disable(adapter);
>  		atl1c_check_link_status(adapter);
>  		atl1c_irq_enable(adapter);
> +		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev))
> +			netif_wake_queue(netdev);
>  	}
>  }
>  

Why explicitly stop/start the queue when the link changes?  That's what
link_watch is for.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
