From: "p.kosyh" <p.kosyh@gmail.com>
Subject: napi and softirq sticking (stuck) solution
Date: Mon, 14 Jul 2014 13:57:39 +0400
Message-ID: <53C3A993.4050007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:36534 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753624AbaGNJtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 05:49:03 -0400
Received: by mail-lb0-f179.google.com with SMTP id v6so249986lbi.24
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 02:49:01 -0700 (PDT)
Received: from [192.168.33.99] ([83.220.32.68])
        by mx.google.com with ESMTPSA id n1sm15132587lbs.0.2014.07.14.02.48.59
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 02:49:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

There is one problem (well known?) we have with napi and softirq 
sticking while irq balancing.
We are solved this problem so may be someone will find this information 
useful.

For example, we have some multi-queue ethernet devices. Each tx/rx-queue 
uses own irq.
Lets assume that at start we have not optimal irq affinity and some 
queues irq are
binded to the same CPU.

Then we have a heavy load traffic. So, some irqs are on (for example) 
CPU#1. And we have
100% softirq on that CPU#1. Ethernet driver is working in napi mode, 
because there are always
a lot of packets in queues to poll.

Here, we want to make affinity better!

irq affinity in our situation is managed in realtime by irq balancer. 
There are no many balancers.
We found, that irqbalance and irqd sometimes do fuzzy logic, so, we have 
developed own
balancer that works well. Here it is: http://birq.libcode.org

But we can reproduce problem without balancer, just echo affinity in 
smp_affinity proc entries under
heavy load.

Anyway, under heavy load, after changing smp_affinity we stays with 100% 
softirq at CPU#1, just
because we are still in polling mode (irq disabled) and napi object is 
always scheduled on same CPU#1.

So, under heavy traffic, the irq ballancing is not works at all.

To solve this problem we just break napi mode sometimes in network driver.
For example, e1000e/netdev.c

In e1000e_poll function:
=============
         if (time_is_before_jiffies(adapter->napi_stamp + 
usecs_to_jiffies(netdev_napi_limit)))
                 work_done = 0;
...
         /* If weight not fully consumed, exit the polling mode */
                 if (work_done < weight) {
=============

So, every 1 sec (for example) we are breaking napi mode, and softirq 
will move on another CPU (according smp_affinity).

The bad thing is that we have to patch every network driver. But without 
this we can not use Linux as good router.

So, i hope, this text will be useful.

Thank you.
