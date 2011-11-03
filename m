From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] tg3: fix error handling in tg3_open
Date: Thu, 3 Nov 2011 12:19:53 -0700
Message-ID: <20111103191953.GA11186@mcarlson.broadcom.com>
References: <1320316603-8355-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Akinobu Mita" <akinobu.mita@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1402 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933862Ab1KCTSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Nov 2011 15:18:53 -0400
In-Reply-To: <1320316603-8355-1-git-send-email-akinobu.mita@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 03, 2011 at 03:36:43AM -0700, Akinobu Mita wrote:
> If one of the request_irq calls fails in tg3_open, all interrupts
> allocated with request_irq should be freed before returning error.
> 
> But it accidentally attempts to free the same invalid IRQ repeatedly.

Hi Akinobu.  I have a similar patch under internal review at this very
minute.  The patch I have does a minor additional cleanup.  (It moves
the 'goto err_out2' inside the 'if (err)' block.)  Is it O.K.
with you to add your SOB to my patch instead?

> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Matt Carlson <mcarlson@broadcom.com>
> Cc: Michael Chan <mchan@broadcom.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 161cbbb..13c4054 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -9674,8 +9674,10 @@ static int tg3_open(struct net_device *dev)
>  		struct tg3_napi *tnapi = &tp->napi[i];
>  		err = tg3_request_irq(tp, i);
>  		if (err) {
> -			for (i--; i >= 0; i--)
> +			for (i--; i >= 0; i--) {
> +				tnapi = &tp->napi[i];
>  				free_irq(tnapi->irq_vec, tnapi);
> +			}
>  			break;
>  		}
>  	}
> -- 
> 1.7.4.4
> 
> 
