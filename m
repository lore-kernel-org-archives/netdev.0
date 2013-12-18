From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Wed, 18 Dec 2013 18:02:33 +0800
Message-ID: <52B172B9.7030609@huawei.com>
References: <1386138457.30495.86.camel@edumazet-glaptop2.roam.corp.google.com> <529EF30A.4050609@huawei.com> <1386170645.30495.108.camel@edumazet-glaptop2.roam.corp.google.com> <529FC980.8020101@cn.fujitsu.com> <529FF066.1070307@huawei.com> <52B142AF.8070708@huawei.com> <20131218075131.GD27460@order.stressinduktion.org> <52B15A9F.6030301@huawei.com> <20131218084106.GF27460@order.stressinduktion.org> <52B1635D.7020205@huawei.com> <20131218092815.GA3505@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, <yoshfuji@linux-ipv6.org>,
	<joe@perches.com>, <vfalico@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:43341 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab3LRKDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 05:03:54 -0500
In-Reply-To: <20131218092815.GA3505@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/18 17:28, Hannes Frederic Sowa wrote:
> On Wed, Dec 18, 2013 at 04:57:01PM +0800, Ding Tianhong wrote:
>> On 2013/12/18 16:41, Hannes Frederic Sowa wrote:
>>> On Wed, Dec 18, 2013 at 04:19:43PM +0800, Ding Tianhong wrote:
>>>> 0xffffffff812f8e29 <neigh_timer_handler+265>:   mov    0xe8(%rbx),%rax
>>>> 0xffffffff812f8e30 <neigh_timer_handler+272>:   mov    %rbp,%rsi
>>>> 0xffffffff812f8e33 <neigh_timer_handler+275>:   mov    %rbx,%rdi
>>>> 0xffffffff812f8e36 <neigh_timer_handler+278>:   callq  *0x8(%rax)						<-----crash
>>>> /usr/src/linux/net/core/neighbour.c: 877
>>>> 0xffffffff812f8e39 <neigh_timer_handler+281>:   lea    0x3c(%rbx),%rax
>>>
>>> For me it looks like this:
>>>
>>> %rax is neigh->ops and the function pointer solicit is NULL and causes the the
>>> page fault.
>>>
>>>
>> yes, it is. So I was trying to find the situation that may free the neighbour when
>> the timer is running, but I could not yet.
> 
> Hm. Ok. It is actually ops which is NULL, not the function pointer, may bad.
> 
> Could you try to follow param or table links and check if this is an arp or
> ndisc one? Maybe some interactions with arp.c or ndisc.c causes this bug?
> 
> 

David and Eric has said that someone may called neigh_release in a wrong place, I agree with that,
and review the code which calling the function in the kernel, I could not find any obvious problem,
and doubt with the situation:

CPU0					  CPU1					  CPU2
      --------		      			--------                		---------
neigh_timer_handler				
write_lock(n->lock);		
	...
write_unlock(n->lock);
n->ref_cnt = 2 or 3(if mode_time)				
	...					neigh_flush_dev
						write_lock(n->lock);
						n->ref_cnt = 2;
						n->nud_state = NUD_NONE;
						write_unlock(n->lock);
						neigh_release()
						n->ref_cnt = 1;
						...					neigh_periodic_work
											write_lock(n->lock);
											write_unlock(n->lock);
											neigh_release();
											kfree(n)
n->ops->solicit()									...
...


.

Regards
Ding


> 
