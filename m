From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: qdisc_alloc_handle() can be too slow
Date: Tue, 03 Jan 2012 10:58:17 +0100
Message-ID: <1325584697.2320.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:64655 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751288Ab2ACJ6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 04:58:22 -0500
Received: by lahd3 with SMTP id d3so3646454lah.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 01:58:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When trying to allocate ~32768 qdiscs using autohandle mechanism, we can
fill the space managed by kernel (handles in [8000-FFFF]:0000 range)

But O(N^2) qdisc_alloc_handle() loops 0x10000 times instead of 0x8000

time tc add qdisc add dev eth0 parent 10:7fff pfifo limit 10
RTNETLINK answers: Cannot allocate memory
real	1m54.826s
user	0m0.000s
sys	0m0.004s

INFO: rcu_sched_state detected stall on CPU 0 (t=60000 jiffies)

Half number of loops, and add a cond_resched() call.
We hold rtnl at this point.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Dave Taht <dave.taht@gmail.com>
---
Next move is using rb-tree instead of a linked list, to speedup
qdisc_lookup(). A complex qdisc setup is way too slow.

 net/sched/sch_api.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)
