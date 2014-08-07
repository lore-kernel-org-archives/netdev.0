From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: Replace del_timer() with del_timer_sync()
Date: Thu, 07 Aug 2014 08:55:42 +0200
Message-ID: <1407394542.11943.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53E31A47.9000407@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Deepak <deepak_das@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53E31A47.9000407@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-08-07 at 11:48 +0530, Deepak wrote:
> on SMP system, del_timer() might return even if the timer function
>      is running on other cpu so sk_stop_timer() will execute __sock_put()
>      while timer is accessing the socket on other cpu causing 
> "use-after-free".
> 
>      This commit replaces del_timer() with del_timer_sync() in 
> sk_stop_timer().
>      del_timer_sync() will wait untill the timer function is not running in
>      any other cpu hence making sk_stop_timer() SMP safe.
> 
>      Signed-off-by: Deepak Das <deepak_das@mentor.com>
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 026e01f..491a84d 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2304,7 +2304,7 @@ EXPORT_SYMBOL(sk_reset_timer);
> 
>   void sk_stop_timer(struct sock *sk, struct timer_list* timer)
>   {
> -       if (del_timer(timer))
> +       if (del_timer_sync(timer))
>                  __sock_put(sk);
>   }
>   EXPORT_SYMBOL(sk_stop_timer);


There is a reason del_timer() and del_timer_sync() both exist, and both
are SMP safe.

Here, caller might block timer handler from making progress, you are
adding a deadlock condition.

In this case, there is no reason to use del_timer_sync(), you didn't
explain why you want this to happen in the first place.

If you hit a bug somewhere, please share it so that we can root cause
it.

Thanks
