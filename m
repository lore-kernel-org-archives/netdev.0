From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: fix a lockdep splat
Date: Thu, 23 Sep 2010 00:13:19 +0200
Message-ID: <4C9A7F7F.5010507@gmail.com>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp>	 <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp>	 <201009210651.o8L6pbkP038129@www262.sakura.ne.jp>	 <1285055760.2617.27.camel@edumazet-laptop>	 <201009210910.o8L9Anaf071504@www262.sakura.ne.jp>	 <1285061757.2617.176.camel@edumazet-laptop>	 <1285064011.2617.238.camel@edumazet-laptop>	 <201009220714.o8M7Ebps067361@www262.sakura.ne.jp>	 <1285144306.2639.90.camel@edumazet-laptop>	 <1285144471.2639.96.camel@edumazet-laptop>	 <1285144681.2639.102.camel@edumazet-laptop>	 <201009220858.o8M8w8s3094017@www262.sakura.ne.jp>	 <1285176935.2639.453.camel@edumazet-laptop> <1285184088.2380.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	David Miller <davem@davemloft.net>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1285184088.2380.18.camel@edumazet-laptop>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> [PATCH] net: fix a lockdep splat
> 
> We have for each socket :
> 
> One spinlock (sk_slock.slock)
> One rwlock (sk_callback_lock)
> 
> Possible scenarios are :
> 
> (A) (this is used in net/sunrpc/xprtsock.c)
> read_lock(&sk->sk_callback_lock) (without blocking BH)
> <BH>
> spin_lock(&sk->sk_slock.slock);
> ...
> read_lock(&sk->sk_callback_lock);
> ...
> 
> 
> (B)
> write_lock_bh(&sk->sk_callback_lock)
> stuff
> write_unlock_bh(&sk->sk_callback_lock)
> 
> 
> (C)
> spin_lock_bh(&sk->sk_slock)
> ...
> write_lock_bh(&sk->sk_callback_lock)
> stuff
> write_unlock_bh(&sk->sk_callback_lock)
> spin_unlock_bh(&sk->sk_slock)
> 
> This (C) case conflicts with (A) :
> 
> CPU1 [A]                         CPU2 [C]
> read_lock(callback_lock)
> <BH>                             spin_lock_bh(slock)
> <wait to spin_lock(slock)>
>                                  <wait to write_lock_bh(callback_lock)>
> 
> We have one problematic (C) use case in inet_csk_listen_stop() :
> 
> local_bh_disable();
> bh_lock_sock(child); // spin_lock_bh(&sk->sk_slock)
> WARN_ON(sock_owned_by_user(child));
> ...
> sock_orphan(child); // write_lock_bh(&sk->sk_callback_lock)
> 
> lockdep is not happy with this, as reported by Tetsuo Handa
> 
> This patch makes sure inet_csk_listen_stop() uses following lock order :
> 
> write_lock_bh(&sk->sk_callback_lock)
> spin_lock(&sk->sk_slock)
> ...
> spin_unlock(&sk->sk_slock)
> write_unlock_bh(&sk->sk_callback_lock)

IMHO this order conflicts with (A) too (but I'm not sure lockdep
tracks that):
 
CPU1 [A]                         CPU2 [C-reversed]
...				write_lock_bh(callback_lock)
<BH>                             
spin_lock(slock)
				<wait to spin_lock(slock)>
<wait to read_lock(callback_lock)>

My proposal is to BH protect read_lock(sk_callback_lock) everywhere (it's
done by netfilter in a few places already).

Jarek P.
