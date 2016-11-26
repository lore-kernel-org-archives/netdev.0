From: subashab@codeaurora.org
Subject: Crash due to mutex genl_lock called from RCU context
Date: Fri, 25 Nov 2016 19:15:56 -0700
Message-ID: <c669cd06c3e50febd95b5ed4aaa78532@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com
To: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49768 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753040AbcKZCP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 21:15:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing a crash due to gen_lock mutex being acquired in RCU 
context.
Crash is seen on a 4.4 based kernel ARM64 device. This occurred in a
regression rack, so unfortunately I don't have steps for a reproducer.

It looks like freeing socket in RCU was brought in through commit
21e4902aea80ef35afc00ee8d2abdea4f519b7f7 ("netlink: Lockless lookup with
RCU grace period in socket release").
I am not very familiar with generic netlink sockets so I am not sure
if there is any other way to fix this apart from reverting this patch.

Any pointers to debug this would be appreciated.

Here is the call stack -

BUG: sleeping function called from invalid context 
kernel/locking/mutex.c:98
in_atomic(): 1, irqs_disabled(): 0, pid: 16400, name: busybox
[<ffffff80080cad20>] ___might_sleep+0x134/0x144
[<ffffff80080cadac>] __might_sleep+0x7c/0x8c
[<ffffff8008ef09a8>] mutex_lock+0x2c/0x4c
[<ffffff8008d307f0>] genl_lock+0x1c/0x24
[<ffffff8008d30848>] genl_lock_done+0x2c/0x50
[<ffffff8008d2ccac>] netlink_sock_destruct+0x30/0x94
[<ffffff8008cdef44>] sk_destruct+0x2c/0x150
[<ffffff8008cdf104>] __sk_free+0x9c/0xc4
[<ffffff8008cdf16c>] sk_free+0x40/0x4c
[<ffffff8008d2c7fc>] deferred_put_nlk_sk+0x40/0x4c
[<ffffff800810b104>] rcu_process_callbacks+0x4d4/0x644
[<ffffff80080a6598>] __do_softirq+0x1b8/0x3c4
[<ffffff80080a6a60>] irq_exit+0x80/0xd4
[<ffffff800808e554>] handle_IPI+0x1c0/0x364
[<ffffff80080817f8>] gic_handle_irq+0x154/0x1a4
