From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net af_key: Fix RCU splat
Date: Thu, 20 Aug 2015 09:51:02 -0700
Message-ID: <1440089462.6610.49.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440085900-8917-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:33422 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176AbbHTQvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 12:51:05 -0400
Received: by pdrh1 with SMTP id h1so16423535pdr.0
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 09:51:04 -0700 (PDT)
In-Reply-To: <1440085900-8917-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-08-20 at 08:51 -0700, David Ahern wrote:
> Hit the following splat testing VRF change for ipsec:
> 
> [  113.475692] ===============================
> [  113.476194] [ INFO: suspicious RCU usage. ]
> [  113.476667] 4.2.0-rc6-1+deb7u2+clUNRELEASED #3.2.65-1+deb7u2+clUNRELEASED Not tainted
> [  113.477545] -------------------------------
> [  113.478013] /work/monster-14/dsa/kernel.git/include/linux/rcupdate.h:568 Illegal context switch in RCU read-side critical section!
> [  113.479288]
> [  113.479288] other info that might help us debug this:
> [  113.479288]
> [  113.480207]
> [  113.480207] rcu_scheduler_active = 1, debug_locks = 1
> [  113.480931] 2 locks held by setkey/6829:
> [  113.481371]  #0:  (&net->xfrm.xfrm_cfg_mutex){+.+.+.}, at: [<ffffffff814e9887>] pfkey_sendmsg+0xfb/0x213
> [  113.482509]  #1:  (rcu_read_lock){......}, at: [<ffffffff814e767f>] rcu_read_lock+0x0/0x6e
> [  113.483509]
> [  113.483509] stack backtrace:
> [  113.484041] CPU: 0 PID: 6829 Comm: setkey Not tainted 4.2.0-rc6-1+deb7u2+clUNRELEASED #3.2.65-1+deb7u2+clUNRELEASED
> [  113.485422] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5.1-0-g8936dbb-20141113_115728-nilsson.home.kraxel.org 04/01/2014
> [  113.486845]  0000000000000001 ffff88001d4c7a98 ffffffff81518af2 ffffffff81086962
> [  113.487732]  ffff88001d538480 ffff88001d4c7ac8 ffffffff8107ae75 ffffffff8180a154
> [  113.488628]  0000000000000b30 0000000000000000 00000000000000d0 ffff88001d4c7ad8
> [  113.489525] Call Trace:
> [  113.489813]  [<ffffffff81518af2>] dump_stack+0x4c/0x65
> [  113.490389]  [<ffffffff81086962>] ? console_unlock+0x3d6/0x405
> [  113.491039]  [<ffffffff8107ae75>] lockdep_rcu_suspicious+0xfa/0x103
> [  113.491735]  [<ffffffff81064032>] rcu_preempt_sleep_check+0x45/0x47
> [  113.492442]  [<ffffffff8106404d>] ___might_sleep+0x19/0x1c8
> [  113.493077]  [<ffffffff81064268>] __might_sleep+0x6c/0x82
> [  113.493681]  [<ffffffff81133190>] cache_alloc_debugcheck_before.isra.50+0x1d/0x24
> [  113.494508]  [<ffffffff81134876>] kmem_cache_alloc+0x31/0x18f
> [  113.495149]  [<ffffffff814012b5>] skb_clone+0x64/0x80
> [  113.495712]  [<ffffffff814e6f71>] pfkey_broadcast_one+0x3d/0xff
> [  113.496380]  [<ffffffff814e7b84>] pfkey_broadcast+0xb5/0x11e
> [  113.497024]  [<ffffffff814e82d1>] pfkey_register+0x191/0x1b1
> [  113.497653]  [<ffffffff814e9770>] pfkey_process+0x162/0x17e
> [  113.498274]  [<ffffffff814e9895>] pfkey_sendmsg+0x109/0x213
> 
> In pfkey_sendmsg the net mutex is taken and then pfkey_broadcast takes
> the RCU lock. Fix by using GFP_ATOMIC for the allocation flag.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/key/af_key.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/key/af_key.c b/net/key/af_key.c
> index b397f0aa9005..73527e7dd247 100644
> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -1670,7 +1670,7 @@ static int pfkey_register(struct sock *sk, struct sk_buff *skb, const struct sad
>  		return -ENOBUFS;
>  	}
>  
> -	pfkey_broadcast(supp_skb, GFP_KERNEL, BROADCAST_REGISTERED, sk, sock_net(sk));
> +	pfkey_broadcast(supp_skb, GFP_ATOMIC, BROADCAST_REGISTERED, sk, sock_net(sk));
>  
>  	return 0;
>  }

I would rather remove the useless rcu locking from pfkey_broadcast() if
a mutex properly protects the thing.
