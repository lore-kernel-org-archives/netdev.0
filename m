From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] macvtap: use set_curren_state to ensure mb
Date: Tue, 05 Jun 2012 13:05:29 +0200
Message-ID: <1338894329.2760.2318.camel@edumazet-glaptop>
References: <CAA7+ByX7Kp+Zh3ZQ2D6rSuhu6WCeqL-1MgDi9gy-0hHizVXncg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, arnd@arndb.de,
	zhiguo.hong@nsn.com, vikifang@juniper.net
To: Hong zhi guo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54322 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933617Ab2FELFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 07:05:34 -0400
Received: by bkcji2 with SMTP id ji2so4469734bkc.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 04:05:33 -0700 (PDT)
In-Reply-To: <CAA7+ByX7Kp+Zh3ZQ2D6rSuhu6WCeqL-1MgDi9gy-0hHizVXncg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-05 at 18:46 +0800, Hong zhi guo wrote:
> replace raw assignment of current->state with
> set_current_state(TASK_...) to ensure memory barrier.
> 
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
> ---
>  drivers/net/macvtap.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 2ee56de..62754f6 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -853,7 +853,7 @@ static ssize_t macvtap_do_read(struct
> macvtap_queue *q, struct kiocb *iocb,
> 
>  	add_wait_queue(sk_sleep(&q->sk), &wait);
>  	while (len) {
> -		current->state = TASK_INTERRUPTIBLE;
> +		set_current_state(TASK_INTERRUPTIBLE);
> 
>  		/* Read frames from the queue */
>  		skb = skb_dequeue(&q->sk.sk_receive_queue);
> @@ -875,7 +875,7 @@ static ssize_t macvtap_do_read(struct
> macvtap_queue *q, struct kiocb *iocb,
>  		break;
>  	}
> 
> -	current->state = TASK_RUNNING;
> +	set_current_state(TASK_RUNNING);
>  	remove_wait_queue(sk_sleep(&q->sk), &wait);
>  	return ret;
>  }


Why not using the more standard :

prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);

and

finish_wait(sk_sleep(sk), &wait);
