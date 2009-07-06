From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Fix a race condition in sky2_poll
Date: Mon, 6 Jul 2009 11:51:01 -0700
Message-ID: <20090706115101.68a8daaf@nehalam>
References: <392fb48f0906200101y5c83e853w170829f2ce40b274@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41620 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753206AbZGFSvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 14:51:19 -0400
In-Reply-To: <392fb48f0906200101y5c83e853w170829f2ce40b274@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Jun 2009 17:01:25 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> Clear interrupt only when the status buffer is fully drained,
> Make sure to clear interrupt when work_done == work_limit
>  and the buffer is drained.
> ---
>  drivers/net/sky2.c |   12 ++++++++----
>  1 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 7681d28..ca1e9e5 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -2524,9 +2524,6 @@ static int sky2_status_intr(struct sky2_hw *hw,
> int to_do, u16 idx)
>  		}
>  	} while (hw->st_idx != idx);
> 
> -	/* Fully processed status ring so clear irq */
> -	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
> -
>  exit_loop:
>  	sky2_rx_done(hw, 0, total_packets[0], total_bytes[0]);
>  	sky2_rx_done(hw, 1, total_packets[1], total_bytes[1]);
> @@ -2779,9 +2776,16 @@ static int sky2_poll(struct napi_struct *napi,
> int work_limit)
>  	if (status & Y2_IS_IRQ_PHY2)
>  		sky2_phy_intr(hw, 1);
> 
> -	while ((idx = sky2_read16(hw, STAT_PUT_IDX)) != hw->st_idx) {
> +	idx = sky2_read16(hw, STAT_PUT_IDX);
> +	while (idx != hw->st_idx) {
>  		work_done += sky2_status_intr(hw, work_limit - work_done, idx);
> 
> +		/* If we fully processed the status ring, clear the irq */
> +		idx = sky2_read16(hw, STAT_PUT_IDX);
> +		if (idx == hw->st_idx) {
> +			sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
> +			break;
> +		}
>  		if (work_done >= work_limit)
>  			goto done;
>  	}

Have you actually seen this race, or are you hypothesizing based
on code review?


I think the original works fine. There is a race where interrupt is cleared early,
and the poll processing runs an extra time but that is harmless.

But the patched code races the other way:

> +	while (idx != hw->st_idx) {
>  		work_done += sky2_status_intr(hw, work_limit - work_done, idx);
> 
> +		/* If we fully processed the status ring, clear the irq */
> +		idx = sky2_read16(hw, STAT_PUT_IDX);

Packet arrives right here. The variable "idx" has old value,
but chip register "put_idx" shows new packet.

> +		if (idx == hw->st_idx) {
> +			sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);

This clears level triggered status interrupt.

> +			break;
> +		}
>  		if (work_done >= work_limit)
>  			goto done;
>  	}

Now the driver misses the status interrupt.



-- 
