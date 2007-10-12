From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Regression in net-2.6.24?
Date: Thu, 11 Oct 2007 20:17:16 -0700
Message-ID: <1192159036.6889.6.camel@dell>
References: <20071011.164827.64988925.davem@davemloft.net>
 <20071011165548.6545b207@freepuppy.rosehill>
 <20071011.171743.118962219.davem@davemloft.net>
 <20071011.181449.130846976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, takano@axe-inc.co.jp,
	"netdev" <netdev@vger.kernel.org>, ilpo.jarvinen@helsinki.fi
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1620 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755151AbXJLCVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 22:21:24 -0400
In-Reply-To: <20071011.181449.130846976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-10-11 at 18:14 -0700, David Miller wrote:
> +       while (1) {
> +               work_done = tg3_poll_work(tp, work_done, budget);
> +
> +               if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING))
> +                       goto tx_recovery;
> +
> +               if (unlikely(work_done >= budget))
> +                       break;
> +
> +               if (likely(!tg3_has_work(tp))) {
> +                       struct tg3_hw_status *sblk = tp->hw_status;
> +

--> new status block DMA

> +                       if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
> +                               tp->last_tag = sblk->status_tag;
> +                               rmb();
> +                       } else
> +                               sblk->status &= ~SD_STATUS_UPDATED;

We need to read the sblk->status_tag before calling tg3_has_work().  If
a new status block DMA happens in between (shown above), tp->last_tag
will get the new tag and we will end up acknowledging work that we
haven't processed.

I'll go over this some more tonight and will send a patch to refine it.
Thanks.

> +
> +                       netif_rx_complete(tp->dev, napi);
> +                       tg3_restart_ints(tp);
> +                       break;
> +               }

