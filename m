From: subashab@codeaurora.org
Subject: Re: 4.1.12 kernel crash in rtnetlink_put_metrics
Date: Mon, 07 Mar 2016 15:15:38 -0700
Message-ID: <6dc33a912af28968363ec472b69bdd5c@codeaurora.org>
References: <563A2BA7.9080202@seti.kr.ua> <563A62C8.3030901@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew <nitr0@seti.kr.ua>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56914 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099AbcCGWPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 17:15:39 -0500
In-Reply-To: <563A62C8.3030901@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On , Daniel Borkmann wrote:
> Hi Andrew,
> 
> thanks for the report!
> 
> ( Making the trace a bit more readable ... )
> 
> [41358.475254]BUG:unable to handle kernel NULL pointer dereference at 
> (null)
> [41358.475333]IP:[<c131c7d0>]rtnetlink_put_metrics+0x50/0x180
> [...]
> CallTrace:
> [41358.476522][<c1213873>]?__nla_reserve+0x23/0xe0
> [41358.476557][<c1213989>]?__nla_put+0x9/0xb0
> [41358.476595][<c138362e>]?fib_dump_info+0x15e/0x3e0
> [41358.476636][<c13bba01>]?irq_entries_start+0x639/0x678
> [41358.476671][<c1386823>]?fib_table_dump+0xf3/0x180
> [41358.476708][<c138053d>]?inet_dump_fib+0x7d/0x100
> [41358.476746][<c1337ef1>]?netlink_dump+0x121/0x270
> [41358.476781][<c1303572>]?skb_free_datagram+0x12/0x40
> [41358.476818][<c1338284>]?netlink_recvmsg+0x244/0x360
> [41358.476855][<c12f3f8d>]?sock_recvmsg+0x1d/0x30
> [41358.476890][<c12f3f70>]?sock_recvmsg_nosec+0x30/0x30
> [41358.476924][<c12f5cec>]?___sys_recvmsg+0x9c/0x120
> [41358.476958][<c12f3f70>]?sock_recvmsg_nosec+0x30/0x30
> [41358.476994][<c10740e4>]?update_cfs_rq_blocked_load+0xc4/0x130
> [41358.477030][<c1094bb4>]?hrtimer_forward+0xa4/0x1c0
> [41358.477065][<c12f4cdd>]?sockfd_lookup_light+0x1d/0x80
> [41358.477099][<c12f6c5e>]?__sys_recvmsg+0x3e/0x80
> [41358.477134][<c12f6ff1>]?SyS_socketcall+0xb1/0x2a0
> [41358.477168][<c108657c>]?handle_irq_event+0x3c/0x60
> [41358.477203][<c1088efd>]?handle_edge_irq+0x7d/0x100
> [41358.477238][<c130a2e6>]?rps_trigger_softirq+0x26/0x30
> [41358.477273][<c10a88e3>]?flush_smp_call_function_queue+0x83/0x120
> [41358.477307][<c13bb2be>]?syscall_call+0x7/0x7
> [...]
> 
> Strange that rtnetlink_put_metrics() itself is not part of the above
> call trace (it's an exported symbol).
> 
> So, your analysis suggests that metrics itself is NULL in this case?
> (Can you confirm that?)
> 
> How frequently does this trigger? Are the seen call traces all the same 
> kind?
> 
> Is there an easy way to reproduce this?
> 
> I presume you don't use any per route congestion control settings, 
> right?
> 
> Thanks,
> Daniel

Hi Daniel

I am observing a similar crash as well. This is on a 3.10 based ARM64 
kernel.
Unfortunately, the crash is occurring in a regression test rack, so I am 
not
sure of the exact test case to reproduce this crash. This seems to have
occurred twice so far with both cases having metrics as NULL.

     |  rt_=_0xFFFFFFC012DA4300 -> (
     |    dst = (
     |      callback_head = (next = 0x0, func = 0xFFFFFF800262D040),
     |      child = 0xFFFFFFC03B8BC2B0,
     |      dev = 0xFFFFFFC012DA4318,
     |      ops = 0xFFFFFFC012DA4318,
     |      _metrics = 0,
     |      expires = 0,
     |      path = 0x0,
     |      from = 0x0,
     |      xfrm = 0x0,
     |      input = 0xFFFFFFC0AD498000,
     |      output = 0x000000010401C411,
     |      flags = 0,
     |      pending_confirm = 0,
     |      error = 0,
     |      obsolete = 0,
     |      header_len = 3,
     |      trailer_len = 0,
     |      __pad2 = 4096,

168539.549000:   <6> Process ip (pid: 28473, stack limit = 
0xffffffc04b584060)
168539.549006:   <2> Call trace:
168539.549016:   <2> [<ffffffc000a95900>] 
rtnetlink_put_metrics+0x4c/0xec
168539.549027:   <2> [<ffffffc000b5e198>] 
rt6_fill_node.isra.34+0x2b8/0x3c8
168539.549035:   <2> [<ffffffc000b5e6e0>] rt6_dump_route+0x68/0x7c
168539.549043:   <2> [<ffffffc000b5edec>] fib6_dump_node+0x2c/0x74
168539.549051:   <2> [<ffffffc000b5ec24>] fib6_walk_continue+0xf8/0x1b4
168539.549059:   <2> [<ffffffc000b5f140>] fib6_walk+0x5c/0xb8
168539.549067:   <2> [<ffffffc000b5f2a0>] inet6_dump_fib+0x104/0x234
168539.549076:   <2> [<ffffffc000ab1510>] netlink_dump+0x7c/0x1cc
168539.549084:   <2> [<ffffffc000ab22f0>] 
__netlink_dump_start+0x128/0x170
168539.549093:   <2> [<ffffffc000a98ddc>] rtnetlink_rcv_msg+0x12c/0x1a0
168539.549101:   <2> [<ffffffc000ab3a80>] netlink_rcv_skb+0x64/0xc8
168539.549110:   <2> [<ffffffc000a97644>] rtnetlink_rcv+0x1c/0x2c
168539.549117:   <2> [<ffffffc000ab34cc>] netlink_unicast+0x108/0x1b8
168539.549125:   <2> [<ffffffc000ab38b8>] netlink_sendmsg+0x27c/0x2d4
168539.549134:   <2> [<ffffffc000a73f04>] sock_sendmsg+0x8c/0xb0
168539.549143:   <2> [<ffffffc000a75f04>] SyS_sendto+0xcc/0x110

I am using the following patch as a workaround now. I do not have any
per route congestion control settings enabled.
Any pointers to debug this would be greatly appreciated.

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a67310e..c63098e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -566,7 +566,7 @@ int rtnetlink_put_metrics(struct sk_buff *skb, u32 
*metrics)
         int i, valid = 0;

         mx = nla_nest_start(skb, RTA_METRICS);
-       if (mx == NULL)
+       if (mx == NULL || metrics == NULL)
                 return -ENOBUFS;

         for (i = 0; i < RTAX_MAX; i++) {
