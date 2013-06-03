From: Rob Herring <robherring2@gmail.com>
Subject: panics in tcp_ack
Date: Sun, 02 Jun 2013 19:13:16 -0500
Message-ID: <51ABDF9C.8080009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f51.google.com ([209.85.128.51]:60967 "EHLO
	mail-qe0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755301Ab3FCANS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 20:13:18 -0400
Received: by mail-qe0-f51.google.com with SMTP id nd7so2021857qeb.10
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 17:13:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm debugging a kernel panic in the networking stack that happens with a cluster (20-40 nodes) of Calxeda highbank (ARM Cortex A9) nodes and typically only after 10-24 hours. The node are transferring files between nodes over TCP with 20 clients and servers per node. The kernel is based on ubuntu 3.5 kernel which is based on 3.5.7.11. So far testing has shown that 3.8.11 based (ubuntu raring) kernel is fixed. Attempts to bisect have not yielded results as it seems multiple problems mask the issue. Perhaps there is some new feature which has indirectly fixed the problem in 3.8.

This commit appears to fix a similar panic and seems to reduce the frequency after picking it up in the latest 3.5 stable:

commit 16fad69cfe4adbbfa813de516757b87bcae36d93
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu Mar 14 05:40:32 2013 +0000

    tcp: fix skb_availroom()
    
    Chrome OS team reported a crash on a Pixel ChromeBook in TCP stack :
    
    https://code.google.com/p/chromium/issues/detail?id=182056
    
    commit a21d45726acac (tcp: avoid order-1 allocations on wifi and tx
    path) did a poor choice adding an 'avail_size' field to skb, while
    what we really needed was a 'reserved_tailroom' one.
    
    It would have avoided commit 22b4a4f22da (tcp: fix retransmit of
    partially acked frames) and this commit.
    
    Crash occurs because skb_split() is not aware of the 'avail_size'
    management (and should not be aware)
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Reported-by: Mukesh Agrawal <quiche@chromium.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

I've searched thru 3.8 and 3.9 stable fixes looking for possibly relevant commits and applied these commits not in 3.5 stable. However, they have not helped:

net: drop dst before queueing fragments
tcp: call tcp_replace_ts_recent() from tcp_ack()
tcp: Reallocate headroom if it would overflow csum_start
tcp: incoming connections might use wrong route under synflood


The exact panic varies some, but is typically in tcp_ack. I've gotten this one several times:

<4>[17360.343983] [<c0405e08>] (tcp_fastretrans_alert+0x134/0xbec) from [<c0406e98>] (tcp_ack+0x540/0x1014)
<4>[17360.353216] [<c0406e98>] (tcp_ack+0x540/0x1014) from [<c0407cb4>] (tcp_rcv_established+0x348/0x5e0)
<4>[17360.362276] [<c0407cb4>] (tcp_rcv_established+0x348/0x5e0) from [<c040eda8>] (tcp_v4_do_rcv+0xf0/0x2cc)
<4>[17360.371679] [<c040eda8>] (tcp_v4_do_rcv+0xf0/0x2cc) from [<c04111ac>] (tcp_v4_rcv+0x814/0x8e8)
<4>[17360.380307] [<c04111ac>] (tcp_v4_rcv+0x814/0x8e8) from [<c03ef81c>] (ip_local_deliver_finish+0xe8/0x33c)
<4>[17360.389796] [<c03ef81c>] (ip_local_deliver_finish+0xe8/0x33c) from [<c03ef3b4>] (ip_rcv_finish+0x140/0x4c0)
<4>[17360.399552] [<c03ef3b4>] (ip_rcv_finish+0x140/0x4c0) from [<c03bf944>] (__netif_receive_skb+0x5e0/0x690)
<4>[17360.409045] [<c03bf944>] (__netif_receive_skb+0x5e0/0x690) from [<c03c06e8>] (netif_receive_skb+0x1c/0x90)
<4>[17360.418708] [<c03c06e8>] (netif_receive_skb+0x1c/0x90) from [<c03c2fac>] (napi_skb_finish+0x54/0x78)
<4>[17360.427855] [<c03c2fac>] (napi_skb_finish+0x54/0x78) from [<c03301e4>] (xgmac_poll+0x3ac/0x4ec)
<4>[17360.436567] [<c03301e4>] (xgmac_poll+0x3ac/0x4ec) from [<c03c2758>] (net_rx_action+0x140/0x228)
<4>[17360.445280] [<c03c2758>] (net_rx_action+0x140/0x228) from [<c002ac94>] (__do_softirq+0xb4/0x1cc)
<4>[17360.454078] [<c002ac94>] (__do_softirq+0xb4/0x1cc) from [<c002b18c>] (irq_exit+0x80/0x88)
<4>[17360.462269] [<c002b18c>] (irq_exit+0x80/0x88) from [<c000ea7c>] (handle_IRQ+0x50/0xb0)
<4>[17360.470197] [<c000ea7c>] (handle_IRQ+0x50/0xb0) from [<c00084d4>] (gic_handle_irq+0x24/0x58)
<4>[17360.478645] [<c00084d4>] (gic_handle_irq+0x24/0x58) from [<c049e1fc>] (__irq_usr+0x3c/0x60)
<4>[17360.486994] Exception stack(0xeda89fb0 to 0xeda89ff8)
<4>[17360.492042] 9fa0:                                     b6e0c1cc 0000c004 00000000 0000001c
<4>[17360.500217] 9fc0: 00000000 00000000 0000007c 0012d175 0012d174 ffffffff 0012d175 b692caf0
<4>[17360.508393] 9fe0: 001a3340 bead3758 0007bfab 0007bfb0 800f0030 ffffffff
<0>[17360.515011] Code: e595c2bc e1510000 e5960000 03a01000 (e5911038) 
<4>[17360.521207] ---[ end trace 98dabb30d5917f53 ]---

This appears to be a NULL returned from tcp_write_queue_head. I reconstructed the full stack which looks like this:

tcp_write_queue_head(sk) 
tcp_skb_timedout
tcp_head_timedout
tcp_time_to_recover
tcp_fastretrans_alert


Searching for similar panics I found this debug patch:

http://www.spinics.net/lists/mm-commits/msg49089.html

With the initial patch, I got continuous spewing of debug due to "fackets != tp->fackets_out", so I removed some of the checks and now just get these dumps. I'm not sure if there is anything relevant here and none of the warnings are triggered:

[12622.995006] P: 28 L: 7 vs 7 S: 5 vs 5 F: 12 vs 12 w: 1697479957-1697494437 (5)
[12623.002273] skb 0 def35f80
[12623.004978] skb 1 def373c0
[12623.007676] skb 2 def346c0
[12623.010374] skb 3 e1b42400
[12623.013092] skb 4 e1b40000
[12623.015794] skb 5 e1b41680
[12623.018490] skb 6 e1b418c0
[12623.021190] skb 7 e1b42f40
[12623.023908] skb 8 dec51680
[12623.026608] skb 9 dec7b600
[12623.029306] skb 10 e0505f80
[12623.032105] skb 11 dec786c0
[12623.034892] skb 12 dec7a880
[12623.037676] skb 13 dec7b840
[12623.040460] skb 14 dec78d80
[12623.043263] skb 15 e0430900
[12623.046050] skb 16 e0431440
[12623.048835] skb 17 e04321c0
[12623.051618] skb 18 e04318c0
[12623.054422] skb 19 e0433a80
[12623.057208] skb 20 e04333c0
[12623.059991] skb 21 e0432640
[12623.062792] head 22 e040df80
[12623.065667] skb 23 e0542ac0
[12623.068453] skb 24 e0431200
[12623.071239] skb 25 e040f600
[12623.074041] TCP wq(s) LLLLLLLSSSSS                <
[12623.078910] TCP wq(h) ++++++++----++++++h+-++++++-<
[12623.083792] l7 s5 f12 p28 seq: su1697479957 hs1697479957 sn1697494437

[18018.368510] P: 24 L: 10 vs 10 S: 6 vs 6 F: 13 vs 13 w: 524404136-524415720 (7)
[18018.375788] skb 0 e9742f40
[18018.378495] skb 1 e9741d40
[18018.381194] skb 2 e0473a80
[18018.383915] skb 3 e0470fc0
[18018.386621] skb 4 e0472f40
[18018.389320] skb 5 e04706c0
[18018.392035] skb 6 e0473180
[18018.394736] skb 7 e054af40
[18018.397435] skb 8 deeae400
[18018.400133] skb 9 e19e86c0
[18018.402854] skb 10 e19e98c0
[18018.405643] skb 11 e0472880
[18018.408429] skb 12 e19eaf40
[18018.411216] head 13 e19eb180
[18018.414116] skb 14 e055c000
[18018.416913] TCP wq(s) LLLLLLLSSSSSSLLL        <
[18018.421439] TCP wq(h) ++++++++-----+++h---+---<
[18018.425999] l10 s6 f13 p24 seq: su524404136 hs524404136 sn524415720

The current 3.5 tree I'm testing is available here:

git://sources.calxeda.com/linux/kernel.git 3.5-net-debug

Rob
