From: Eric Sesterhenn / Snakebyte <snakebyte@gmx.de>
Subject: BUG with ipv6 jumbo frames over loopback
Date: Tue, 1 May 2007 13:22:30 +0200
Message-ID: <20070501112230.GA6360@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:54094 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1031680AbXEALXJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 07:23:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

with the double skb_free() issue fixed, I ran some more ip6sic
tests, after a while i hit the following:

[  346.941000] Oops: 0000 [#1]
[  346.941000] PREEMPT 
[  346.941000] Modules linked in:
[  346.941000] CPU:    0
[  346.941000] EIP:    0060:[<c05ce396>]    Not tainted VLI
[  346.941000] EFLAGS: 00010246   (2.6.21-g40caf5ea #3)
[  346.941000] EIP is at ipv6_hop_jumbo+0x26/0x180
[  346.941000] eax: 00000000   ebx: c93ce978   ecx: 00000001   edx:
00000103
[  346.941000] esi: c8ca2126   edi: 0000008c   ebp: c0816f14   esp:
c0816f04
[  346.941000] ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
[  346.941000] Process ip6sic (pid: 4959, ti=c0816000 task=c9ea4aa0
task.ti=c8c2e000)
[  346.941000] Stack: c945a400 c0816f34 c07bf33c 0000002a c0816f3c
c05cdb9f c0816f6c c07bf334 
[  346.941000]        c93ce978 c8ca20fc 00000496 c93ce978 c0816f6c
c93ce9b4 c0816f4c c05ce6f1 
[  346.941000]        00000000 cf8cfd84 c0816f7c c05ada2e 00000001
00000514 c07a3be0 00000506 
[  346.941000] Call Trace:
[  346.941000]  [<c010490a>] show_trace_log_lvl+0x1a/0x30
[  346.941000]  [<c01049c9>] show_stack_log_lvl+0xa9/0xd0
[  346.941000]  [<c0104c0c>] show_registers+0x21c/0x3a0
[  346.941000]  [<c0104e94>] die+0x104/0x260
[  346.941000]  [<c0116087>] do_page_fault+0x277/0x610
[  346.941000]  [<c062a75c>] error_code+0x74/0x7c
[  346.941000]  [<c05cdb9f>] ip6_parse_tlv+0xef/0x130
[  346.941000]  [<c05ce6f1>] ipv6_parse_hopopts+0x41/0xb0
[  346.941000]  [<c05ada2e>] ipv6_rcv+0x1be/0x370
[  346.941000]  [<c053978b>] netif_receive_skb+0x21b/0x2b0
[  346.941000]  [<c053b6e2>] process_backlog+0x82/0xf0
[  346.941000]  [<c053b97b>] net_rx_action+0xab/0x1c0
[  346.941000]  [<c01209a2>] __do_softirq+0x62/0xc0
[  346.941000]  [<c010632a>] do_softirq+0x8a/0xf0
[  346.941000]  [<c0120c96>] local_bh_enable+0xa6/0x160
[  346.941000]  [<c053bb28>] dev_queue_xmit+0x98/0x330
[  346.941000]  [<c05dfe38>] packet_sendmsg+0x208/0x260
[  346.941000]  [<c052eb05>] sock_sendmsg+0xc5/0xf0
[  346.941000]  [<c052ee0f>] sys_sendto+0xbf/0xe0
[  346.941000]  [<c052fd37>] sys_socketcall+0x187/0x260
[  346.941000]  [<c0104194>] sysenter_past_esp+0x5d/0x99
[  346.941000]  =======================
[  346.941000] Code: 90 8d 74 26 00 55 89 e5 56 53 83 ec 08 8b 18 8b 4b
78 8d 34 11 80 7e 01 04 74 3b a1 30 7c 7c c0 85 c0 0f 85 7d 00 00 00 8b
43 1c <8b> 80 8c 00 00 00 85 c0 74 09 8b 80 38 01 00 00 ff 40 08 a1 04 
[  346.941000] EIP: [<c05ce396>] ipv6_hop_jumbo+0x26/0x180 SS:ESP
0068:c0816f04
[  346.953000] Kernel panic - not syncing: Fatal exception in interrupt


It looks like packets coming via the loopback interface dont have
skb->dst set, therefore we crash in ipv6_hop_jumbo() in exthdrs.c
doing:

IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);

the ip6_dst_idev() call dereferences skb->dst which is not set, causing
the oops and hardlocking the box.

The obvious fix would be to make ip6_dst_idev() return NULL if the
parameter is NULL, since IP6_INC_STATS_BH() can handle a NULL argument,
but not sure if this would be correct.

To reproduce use: ip6sic -i lo -d ::1 -p 100000 -r 4959
it should crash at 92.4%, i was unable to capture the stuff, since the
box locks up hard, if i find a faster testcase I'll let you know.

Greetings, Eric

-- 
 www.cobra-basket.de -- just my stuff
