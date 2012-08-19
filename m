From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: IPv4 BUG: held lock freed!
Date: Sun, 19 Aug 2012 23:05:42 +0800
Message-ID: <CAF1ivSZK8Y2XpjUXVpNg=m=bs7bGCYqF0ZQU2u_YpEUrmOrR-g@mail.gmail.com>
References: <20120818021918.GA6499@localhost>
	<1345380682.5158.201.camel@edumazet-glaptop>
	<CAF1ivSaU_ur9BkKG3eAsNw7d+ND5xgYbPKutemVqNec3X9m4SA@mail.gmail.com>
	<1345387532.5158.222.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	David Miller <davem@davemloft.net>,
	networking <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345387532.5158.222.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 19, 2012 at 10:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2012-08-19 at 22:15 +0800, Lin Ming wrote:
>
>> Will it still has problem if code goes here without sock_hold(sk)?
>
> Not sure of what you mean.

See my comments in the function.
Is that a potential problem?

static void tcp_write_timer(unsigned long data)
{
        struct sock *sk = (struct sock *)data;

        bh_lock_sock(sk);
        if (!sock_owned_by_user(sk)) {
                tcp_write_timer_handler(sk);

                //if we arrive here with sk_refcnt=1
                //then below sock_put(sk) will also free the sock.
        } else {
                /* deleguate our work to tcp_release_cb() */
                set_bit(TCP_WRITE_TIMER_DEFERRED, &tcp_sk(sk)->tsq_flags);
        }
        bh_unlock_sock(sk);
        sock_put(sk);
}


>
> At the time tcp_write_timer() runs, we own one reference on the socket.
> (this reference was taken in sk_reset_timer())
>
> On old kernels, if we found the socket locked by the user, we used to
> rearm the timer for a 50ms delay (and thus did sock_hold() again)
>
> Another way to avoid the bug would to make sure sk_reset_timer()
> increases refcount _before_ setting the timer, but its adding one atomic
> in fast path...

I think this is safer than your previous fix.

Thanks.

>
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 8f67ced..d1745b7 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2114,8 +2114,9 @@ EXPORT_SYMBOL(sk_send_sigurg);
>  void sk_reset_timer(struct sock *sk, struct timer_list* timer,
>                     unsigned long expires)
>  {
> -       if (!mod_timer(timer, expires))
> -               sock_hold(sk);
> +       sock_hold(sk);
> +       if (mod_timer(timer, expires))
> +               __sock_put(sk);
>  }
>  EXPORT_SYMBOL(sk_reset_timer);
>
>
>
