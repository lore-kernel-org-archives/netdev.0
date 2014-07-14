From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: napi and softirq sticking (stuck) solution
Date: Mon, 14 Jul 2014 12:24:48 +0200
Message-ID: <1405333488.10255.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53C3A993.4050007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "p.kosyh" <p.kosyh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:63510 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbaGNKYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 06:24:55 -0400
Received: by mail-wg0-f41.google.com with SMTP id z12so3827227wgg.12
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 03:24:52 -0700 (PDT)
In-Reply-To: <53C3A993.4050007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-07-14 at 13:57 +0400, p.kosyh wrote:
> Hello!
> 
> There is one problem (well known?) we have with napi and softirq 
> sticking while irq balancing.
> We are solved this problem so may be someone will find this information 
> useful.
> 
> For example, we have some multi-queue ethernet devices. Each tx/rx-queue 
> uses own irq.
> Lets assume that at start we have not optimal irq affinity and some 
> queues irq are
> binded to the same CPU.
> 
> Then we have a heavy load traffic. So, some irqs are on (for example) 
> CPU#1. And we have
> 100% softirq on that CPU#1. Ethernet driver is working in napi mode, 
> because there are always
> a lot of packets in queues to poll.
> 
> Here, we want to make affinity better!
> 
> irq affinity in our situation is managed in realtime by irq balancer. 
> There are no many balancers.
> We found, that irqbalance and irqd sometimes do fuzzy logic, so, we have 
> developed own
> balancer that works well. Here it is: http://birq.libcode.org
> 
> But we can reproduce problem without balancer, just echo affinity in 
> smp_affinity proc entries under
> heavy load.
> 
> Anyway, under heavy load, after changing smp_affinity we stays with 100% 
> softirq at CPU#1, just
> because we are still in polling mode (irq disabled) and napi object is 
> always scheduled on same CPU#1.
> 
> So, under heavy traffic, the irq ballancing is not works at all.
> 
> To solve this problem we just break napi mode sometimes in network driver.
> For example, e1000e/netdev.c
> 
> In e1000e_poll function:
> =============
>          if (time_is_before_jiffies(adapter->napi_stamp + 
> usecs_to_jiffies(netdev_napi_limit)))
>                  work_done = 0;
> ...
>          /* If weight not fully consumed, exit the polling mode */
>                  if (work_done < weight) {
> =============
> 
> So, every 1 sec (for example) we are breaking napi mode, and softirq 
> will move on another CPU (according smp_affinity).
> 
> The bad thing is that we have to patch every network driver. But without 
> this we can not use Linux as good router.
> 
> So, i hope, this text will be useful.
> 
> Thank you.

This is a known problem and at least one driver is already trying to
address it.

Idea is to check that current cpu in napi_poll is still part of irq
affinity for the IRQ. This check can be done only when we consumed all
the budget, so that it is not done under moderate load.

Take a look at drivers/net/ethernet/mellanox/mlx4 in recent tree for
example ( commit 35f6f45368632f21bd27559c44dbb1cab51d8947 "net/mlx4_en:
Don't use irq_affinity_notifier to track changes in IRQ affinity
map") ...
