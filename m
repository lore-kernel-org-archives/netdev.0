From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] hysdn: fix to a race condition in put_log_buffer
Date: Thu, 3 Aug 2017 15:03:13 +0300
Message-ID: <a82052eb-2aec-ffa2-2cfd-c02db779d695@cogentembedded.com>
References: <2f35ddaf-88d9-e848-f83b-3001b36b2883@linux-pingi.de>
 <1501760001-22193-1-git-send-email-avolkov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org,
        khoroshilov@ispras.ru
To: Anton Volkov <avolkov@ispras.ru>, isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501760001-22193-1-git-send-email-avolkov@ispras.ru>
Content-Language: en-MW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 08/03/2017 02:33 PM, Anton Volkov wrote:

> The synchronization type that was used earlier to guard the loop that
> deletes unused log buffers may lead to a situation that prevents any
> thread from going through the loop.
> 
> The patch deletes previously used synchronization mechanism and moves
> the loop under the spin_lock so the similar cases won't be feasible in
> the future.
> 
> Found by by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Anton Volkov <avolkov@ispras.ru>
> ---
>   drivers/isdn/hysdn/hysdn_proclog.c | 27 ++++++++++++---------------
>   1 file changed, 12 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/isdn/hysdn/hysdn_proclog.c b/drivers/isdn/hysdn/hysdn_proclog.c
> index 7b5fd8f..b152c6c 100644
> --- a/drivers/isdn/hysdn/hysdn_proclog.c
> +++ b/drivers/isdn/hysdn/hysdn_proclog.c
[...]
>   	else
>   		pd->log_tail->next = ib;	/* follows existing messages */
>   	pd->log_tail = ib;	/* new tail */
> -	i = pd->del_lock++;	/* get lock state */
> -	spin_unlock_irqrestore(&card->hysdn_lock, flags);
>   
>   	/* delete old entrys */
> -	if (!i)
> -		while (pd->log_head->next) {
> -			if ((pd->log_head->usage_cnt <= 0) &&
> -			    (pd->log_head->next->usage_cnt <= 0)) {
> -				ib = pd->log_head;
> -				pd->log_head = pd->log_head->next;
> -				kfree(ib);
> -			} else
> -				break;
> -		}		/* pd->log_head->next */
> -	pd->del_lock--;		/* release lock level */
> +	while (pd->log_head->next) {
> +		if ((pd->log_head->usage_cnt <= 0) &&
> +		    (pd->log_head->next->usage_cnt <= 0)) {
> +			ib = pd->log_head;
> +			pd->log_head = pd->log_head->next;
> +			kfree(ib);
> +		} else
> +			break;
> +	}		/* pd->log_head->next */

    Need {} in the *else* branch as *if* had them.

[...]

MBR, Sergei
