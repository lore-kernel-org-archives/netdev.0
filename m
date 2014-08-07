From: "Das, Deepak" <Deepak_Das@mentor.com>
Subject: RE: [RFC] net: Replace del_timer() with del_timer_sync()
Date: Thu, 7 Aug 2014 15:15:07 +0000
Message-ID: <38E11AEFEB035045A1BA4C1177FBFC424A89BEBE@EU-MBX-03.mgc.mentorg.com>
References: <53E31A47.9000407@mentor.com>,<1407394542.11943.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407394542.11943.21.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I apologies for not explaining the scenario previously.

sk_stop_timer() is used to stop the tcp timers with expiry callback
tcp_write_timer(), tcp_delack_timer(), tcp_keepalive_timer(), ...
del_timer() is used to stop the the timer in sk_stop_timer(), which
might return a non-zero result even if one of these timer handler functions
(tcp_write_timer(), tcp_delack_timer(), tcp_keepalive_timer(), ...)
is already executing on another processor.

Following is the possible scenario :-
on CPU #0: sk_stop_timer() decrements the sk->sk_refcnt if del_timer(timer)
returns non-zero.

on CPU #1: If a timer handler callback runs then it also calls sock_put(sk)
which decrements sk->sk_refcnt and if the sk_refcnt becomes zero it frees the
structure sock pointed to by sk.

if the sk->sk_refcnt decrements twice then that will cause a mismatch in the
number of "puts" and "holds" resulting in a malfunction of the sk->sk_refcnt mechanism.

The solution is to use del_timer_sync() instead of del_timer()
because del_timer_sync() will wait for timer handler functions to
complete execution.

yes, we are facing some memory corruption issues due to access of already released
struct sock in our environment. Our memory corruption issue looks like memory locations
being decremented which could be consistent with a rogue decrement of a reference counter.

similar suggestion is also made by Dean Jenkins in rfcomm_dlc_clear_timer() and accepted by Marcel.
http://www.spinics.net/lists/linux-bluetooth/msg51132.html

with warm regards,
Deepak Das 
________________________________________
From: Eric Dumazet [eric.dumazet@gmail.com]
Sent: Thursday, August 07, 2014 12:25 PM
To: Das, Deepak
Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: [RFC] net: Replace del_timer() with del_timer_sync()

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
