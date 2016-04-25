From: "Shi, Yang" <yang.shi@linaro.org>
Subject: Re: Warning triggered by lockdep checks for sock_owned_by_user on
 linux-next-20160420
Date: Mon, 25 Apr 2016 10:32:55 -0700
Message-ID: <571E54C7.4080503@linaro.org>
References: <571AF3C2.3010509@linaro.org>
 <1461387028.7627.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	hannes@stressinduktion.org, LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461387028.7627.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/22/2016 9:50 PM, Eric Dumazet wrote:
> On Fri, 2016-04-22 at 21:02 -0700, Shi, Yang wrote:
>> Hi David,
>>
>> When I ran some test on a nfs mounted rootfs, I got the below warning
>> with LOCKDEP enabled on linux-next-20160420:
>>
>> WARNING: CPU: 9 PID: 0 at include/net/sock.h:1408
>> udp_queue_rcv_skb+0x3d0/0x660
>> Modules linked in:
>> CPU: 9 PID: 0 Comm: swapper/9 Tainted: G      D
>> 4.6.0-rc4-next-20160420-WR7.0.0.0_standard+ #6
>> Hardware name: Intel Corporation S5520HC/S5520HC, BIOS
>> S5500.86B.01.10.0025.030220091519 03/02/2009
>>    0000000000000000 ffff88066fd03a70 ffffffff8155855f 0000000000000000
>>    0000000000000000 ffff88066fd03ab0 ffffffff81062803 0000058061318ec8
>>    ffff88065d1e39c0 ffff880661318e40 0000000000000000 ffff880661318ec8
>> Call Trace:
>>    <IRQ>  [<ffffffff8155855f>] dump_stack+0x67/0x98
>> Checking out fil [<ffffffff81062803>] __warn+0xd3/0xf0
>>    [<ffffffff810628ed>] warn_slowpath_null+0x1d/0x20
>>    [<ffffffff81aa48f0>] udp_queue_rcv_skb+0x3d0/0x660
>>    [<ffffffff81aa505c>] __udp4_lib_rcv+0x4dc/0xc00
>>    [<ffffffff81aa5b5a>] udp_rcv+0x1a/0x20
>>    [<ffffffff81a728a1>] ip_local_deliver_finish+0xd1/0x2e0
>> es:  57% (30585/ [<ffffffff81a7280f>] ? ip_local_deliver_finish+0x3f/0x2e0
>>    [<ffffffff81a73262>] ip_local_deliver+0xc2/0xd0
>>    [<ffffffff81a72c92>] ip_rcv_finish+0x1e2/0x5a0
>>    [<ffffffff81a7354c>] ip_rcv+0x2dc/0x410
>>    [<ffffffff81a20a32>] ? __pskb_pull_tail+0x82/0x400
>>    [<ffffffff81a2e188>] __netif_receive_skb_core+0x3a8/0xa80
>>    [<ffffffff81a30b9b>] ? netif_receive_skb_internal+0x1b/0xf0
>>    [<ffffffff81a30b3d>] __netif_receive_skb+0x1d/0x60
>>    [<ffffffff81a30bd5>] netif_receive_skb_internal+0x55/0xf0
>>    [<ffffffff81a30b9b>] ? netif_receive_skb_internal+0x1b/0xf0
>>    [<ffffffff81a31b52>] napi_gro_receive+0xc2/0x180
>>    [<ffffffff8187188a>] igb_poll+0x5ea/0xdf0
>>    [<ffffffff81a32b9c>] net_rx_action+0x15c/0x3d0
>>    [<ffffffff81c668c1>] __do_softirq+0x161/0x413
>>    [<ffffffff810683a1>] irq_exit+0xd1/0x110
>>    [<ffffffff81c664d2>] do_IRQ+0x62/0xf0
>>    [<ffffffff81c6474e>] common_interrupt+0x8e/0x8e
>>    <EOI>  [<ffffffff8198d9c6>] ? cpuidle_enter_state+0xc6/0x290
>>    [<ffffffff8198dbc7>] cpuidle_enter+0x17/0x20
>>    [<ffffffff810aa963>] call_cpuidle+0x33/0x50
>>    [<ffffffff810aace9>] cpu_startup_entry+0x229/0x3b0
>>    [<ffffffff810407e4>] start_secondary+0x144/0x150
>> ---[ end trace ba508c424f0d52bf ]---
>>
>>
>> The warning is triggered by commit
>> fafc4e1ea1a4c1eb13a30c9426fb799f5efacbc3 ("sock: tigthen lockdep checks
>> for sock_owned_by_user"), which checks if slock is held before locking
>> "owned".
>>
>> It looks good to lock_sock which is just called lock_sock_nested. But,
>> bh_lock_sock is different, which just calls spin_lock so it doesn't
>> touch dep_map then the check will fail even though it is locked.
>
> ?? spin_lock() definitely is lockdep friendly.

Yes, this is what I thought too. But, I didn't figure out why the 
warning was still reported even though spin_lock is called.

>
>>
>> So, I'm wondering what a right fix for it should be:
>>
>> 1. Replace bh_lock_sock to bh_lock_sock_nested in the protocols
>> implementation, but there are a lot places calling it.
>>
>> 2. Just like lock_sock, just call bh_lock_sock_nested instead of spin_lock.
>>
>> Or the both approach is wrong or not ideal?
>
> I sent a patch yesterday, I am not sure what the status is.

Thanks for the patch. I just found your original patch and the 
discussion with Valdis. I think I ran into the same problem. There is 
kernel BUG is triggered before the warning, but "lockdep is off" 
information is not printed out, although is it really off.

Just tried your patch, it works for me.

Thanks,
Yang

>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index d997ec13a643..db8301c76d50 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1350,7 +1350,8 @@ static inline bool lockdep_sock_is_held(const struct sock *csk)
>   {
>   	struct sock *sk = (struct sock *)csk;
>
> -	return lockdep_is_held(&sk->sk_lock) ||
> +	return !debug_locks ||
> +	       lockdep_is_held(&sk->sk_lock) ||
>   	       lockdep_is_held(&sk->sk_lock.slock);
>   }
>   #endif
>
>
>
>
>
