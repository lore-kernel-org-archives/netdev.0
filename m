From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to entering networked mode
Date: Wed, 24 Feb 2010 13:53:40 -0500
Message-ID: <20100224185340.GB15380@hmsreliant.think-freely.org>
References: <20100219194033.GA28743@hmsreliant.think-freely.org>
 <29C1DC0826876849BDD9F1C67ABA29430705EF62@ala-mail09.corp.ad.wrs.com>
 <20100223011116.GA2021@localhost.localdomain>
 <29C1DC0826876849BDD9F1C67ABA2943070F0D92@ala-mail09.corp.ad.wrs.com>
 <20100223160936.GA16435@hmsreliant.think-freely.org>
 <29C1DC0826876849BDD9F1C67ABA2943070F0E2E@ala-mail09.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: "Stephens, Allan" <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34946 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757364Ab0BXSxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 13:53:46 -0500
Content-Disposition: inline
In-Reply-To: <29C1DC0826876849BDD9F1C67ABA2943070F0E2E@ala-mail09.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2010 at 08:21:25AM -0800, Stephens, Allan wrote:
> Neil wrote: 
> 
> > I agree that you patch fixes the exact problem that I 
> > reported here, but theres more to it than that.  A quick grep 
> > of the tipc stack reveals the following
> > symbols:
> > tipc_bearers
> > media_list
> > tipc_local_nodes
> > bcbearer
> > bclink
> > tipc_net.zones
> > 
> > All of these symbols:
> > 
> > 1) Are allocated dynamically in tipc_net_start, _after_ 
> > tipc_mode is set to TIPC_NET_MODE
> > 
> > 2) dereferenced without NULL pointer checks in either the 
> > send path or in the netlink configuration path, both of which 
> > are reachable from user space.
> > 
> > So your patch fixes the last item on your list, but what 
> > about the others?  In fact, I'll bet I can very quickly 
> > change the application to trip over a null tipc_local_nodes 
> > dereference by changing the destination address to be 
> > something within zone 0, cluster 0.
> 
> The semantics of TIPC addressing don't allow a node address of the form
> <0.0.N> where N != 0, so this kind of a send ateempt should be caught
> and handled by TIPC.  However, you've already found one missing error
> check, so it's certainly worth trying it out!
> 

So, I've tested out your patch, and it fixes the problem that was reported (no
suprisingly, it was pretty clear that it would), it also managed to fix the
access to tipc_local_nodes (I'd previously missed the chunk of the patch that
added the ? to that access), so thats all great.  Then I did this:
./tipc-config -lsr 1.1.10:eth3-1.1.17:eth2

And got this:

BUG: unable to handle kernel NULL pointer dereference at 00000000000000c4
IP: [<ffffffffa030f6a8>] tipc_bearer_find_interface+0x1f/0x66 [tipc]
PGD 11be1a067 PUD 11c721067 PMD 0 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
CPU 3 
Pid: 1284, comm: tipc-config Not tainted 2.6.33-rc8 #1 0YK962/PowerEdge SC1435
RIP: 0010:[<ffffffffa030f6a8>]  [<ffffffffa030f6a8>]
tipc_bearer_find_interface+0x1f/0x66 [tipc]
RSP: 0018:ffff88011c7b3a08  EFLAGS: 00010246
RAX: 0000000000000001 RBX: 0000000000000000 RCX: ffff88011c7b3900
RDX: 0000000000000000 RSI: ffff88011c7b39c0 RDI: ffff88011c7b3a3c
RBP: ffff88011c7b3a28 R08: 0000000000000032 R09: 000000000000000a
R10: ffffffffa03258b8 R11: 0000000000000000 R12: 0000000000000000
R13: ffff88011c7b3a3c R14: 0000000000000040 R15: ffffffff829a89b0
FS:  00007fd2d1c56700(0000) GS:ffff880082400000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000000000c4 CR3: 000000011c7aa000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process tipc-config (pid: 1284, threadinfo ffff88011c7b2000, task
ffff88011cba48a0)
Stack:
 ffff880023022260 ffff88011c7b3a38 ffff880023022260 ffff88011c7b3aa0
<0> ffff88011c7b3a88 ffffffffa031294c 336874650100100a ffff880023022200
<0> 0100101100000040 ffffff0032687465 ffff88011c7b3a88 00000000c78c4377
Call Trace:
 [<ffffffffa031294c>] link_find_link+0x40/0x9d [tipc]
 [<ffffffffa0312fce>] ? tipc_link_cmd_reset_stats+0x63/0xbb [tipc]
 [<ffffffffa0312fda>] tipc_link_cmd_reset_stats+0x6f/0xbb [tipc]
 [<ffffffffa031093d>] tipc_cfg_do_cmd+0x2ae/0x7d4 [tipc]
 [<ffffffffa031a506>] handle_cmd+0x68/0xba [tipc]
 [<ffffffff813d493f>] genl_rcv_msg+0x1c7/0x1eb
 [<ffffffff813d4778>] ? genl_rcv_msg+0x0/0x1eb
 [<ffffffff813d3895>] netlink_rcv_skb+0x43/0x94
 [<ffffffff813d4771>] genl_rcv+0x26/0x2d
 [<ffffffff813d3664>] netlink_unicast+0x125/0x18e
 [<ffffffff813d3e4e>] netlink_sendmsg+0x259/0x268
 [<ffffffff813a57d4>] __sock_sendmsg+0x5e/0x69
 [<ffffffff813a7f37>] sock_aio_write+0xc0/0xd4
 [<ffffffff8107e57f>] ? print_lock_contention_bug+0x1b/0xe0
 [<ffffffff81114f59>] do_sync_write+0xc4/0x101
 [<ffffffff811e5cd9>] ? selinux_file_permission+0xa7/0xb3
 [<ffffffff811dbdf1>] ? security_file_permission+0x16/0x18
 [<ffffffff811154e8>] vfs_write+0xc1/0x10b
 [<ffffffff8107cb35>] ? trace_hardirqs_on_caller+0x1f/0x141
 [<ffffffff811155f2>] sys_write+0x4a/0x6e
 [<ffffffff81009b82>] system_call_fastpath+0x16/0x1b
Code: 5f 5b 41 5c 41 5d 41 5e 41 5f c9 c3 55 48 89 e5 41 55 41 54 53 48 83 ec 08
0f 1f 44 00 00 48 8b 1d 86 68 01 00 45 31 e4 49 89 fd <83> bb c4 00 00 00 00 74
1e 48 8d 7b 5c be 3a 00 00 00 e8  
RIP  [<ffffffffa030f6a8>] tipc_bearer_find_interface+0x1f/0x66 [tipc]
 RSP <ffff88011c7b3a08>
CR2: 00000000000000c4
---[ end trace a14d3b6105c45243 ]---

The use of that command was arbitrary, it was just one of the paths from user
space to one of the variables that I mentioned previously.  And my patch
wouldn't have fixed this either, but its illustrative of my earlier assertion,
that theres no real synchronization between the user-space accessable paths in
tipc and the implementation state which should gate access to those paths.

Now we could continue to add NULL checks whereever these bugs pop up (and
perhaps in the above case specifically that might be valid, I'm not sure yet),
but that just feels like a loosing battle that we might never quite catch up
with, as the code evolves.  Seems to me like a better solution would be adding
common gating in the netlink and send paths to ensure that only when the system
was properly configured could you send various messages into the stack.

I'll try to put an omibus patch together shortly.

Thanks!
Neil
