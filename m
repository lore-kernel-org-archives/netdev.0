From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: pkt_sched: gen_estimator: more fuel for Jarek and Changli
Date: Wed, 09 Jun 2010 08:13:17 +0200
Message-ID: <1276063997.2439.650.camel@edumazet-laptop>
References: <20100608121546.GA9392@ff.dom.local>
	 <1276000052.2475.307.camel@edumazet-laptop>
	 <20100608124052.GB9392@ff.dom.local> <4C0E9A2E.9080109@gmail.com>
	 <1276026329.2439.2.camel@edumazet-laptop>
	 <20100608202405.GA3496@del.dom.local>
	 <1276030354.2439.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40078 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407Ab0FIGNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 02:13:24 -0400
Received: by wyf28 with SMTP id 28so642584wyf.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 23:13:22 -0700 (PDT)
In-Reply-To: <1276030354.2439.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With un-modified kernel, I ran following scripts on my machine

taskset 01 sh -c "while :;do iptables  -I INPUT -i eth0 -j RATEEST --rateest-name eth0 --rateest-interval 250ms --rateest-ewmalog 1000ms; done" &
taskset 02 sh -c "while :;do iptables  -F INPUT; done" &
taskset 02 sh -c "while :;do tc qdisc del dev eth0 root 2>/dev/null;done" &
taskset 08 sh -c "while :;do tc qdisc add dev eth0 root handle 1: est 250msec 1sec cbq avpkt 1000 rate 1000Mbit bandwidth 1000Mbit 2>/dev/null;done" &


I got following oops in about 10 seconds, and my machine had to be
rebooted, rtnl being locked forever, so many commands block hard in
rtnl_lock()

root      6016  0.0  0.0  2040  536 pts/0    D    07:14   0:00 tc qdisc del dev eth0 root
root      6021  0.0  0.0  2040  676 pts/0    D    07:14   0:00 tc qdisc add dev eth0 root handle 1: est 250msec 1sec cbq avpkt 1000 rate 1
root     19358  0.0  0.0  1752  252 ?        D    07:45   0:00 ip -o link ls dev eth0

[  753.892107] BUG: unable to handle kernel NULL pointer dereference at (null)
[  753.892132] IP: [<c116b6c8>] rb_insert_color+0xc6/0xd0
[  753.892156] *pdpt = 0000000032827001 *pde = 0000000000000000 
[  753.892177] Oops: 0002 [#1] PREEMPT SMP 
[  753.892196] last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:01:04.6/class
[  753.892218] Modules linked in: xt_RATEEST iptable_filter ip_tables x_tables ipmi_devintf ipmi_si ipmi_msghandler ipv6 dm_mod button battery ac ehci_hcd uhci_hcd tg3 libphy bnx2x crc32c libcrc32c mdio [last unloaded: x_tables]
[  753.892314] 
[  753.892321] Pid: 5951, comm: tc Not tainted 2.6.35-rc1-00208-g50e3a9a #68 /ProLiant BL460c G6
[  753.892341] EIP: 0060:[<c116b6c8>] EFLAGS: 00010202 CPU: 3
[  753.892356] EIP is at rb_insert_color+0xc6/0xd0
[  753.892368] EAX: 00000000 EBX: f34c1750 ECX: f34c1750 EDX: c1b5a1bc
[  753.892384] ESI: 00000001 EDI: f34c1ae0 EBP: f34a0c0c ESP: f34a0bf8
[  753.892399]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[  753.892413] Process tc (pid: 5951, ti=f34a0000 task=f43f2ac0 task.ti=f34a0000)
[  753.892430] Stack:
[  753.892465]  c1292899 c1b5a1bc f34c1aa8 f3ae47f4 f36baf78 f34a0c34 c1292a66 f36baf5c
[  753.892524] <0> 00000098 d8d43110 f36baf2c 00000000 f36baf00 f34a0ca0 00000000 f34a0c6c
[  753.892598] <0> c12aa80c d8d4310c c16ba5a0 00000000 f4160000 c1561fa0 f43f2a00 00000000
[  753.892681] Call Trace:
[  753.892707]  [<c1292899>] ? gen_new_estimator+0x55/0x247
[  753.892736]  [<c1292a66>] ? gen_new_estimator+0x222/0x247
[  753.892765]  [<c12aa80c>] ? qdisc_create+0x1e4/0x273
[  753.892793]  [<c12aabd8>] ? tc_modify_qdisc+0x33d/0x3be
[  753.892822]  [<c12aa89b>] ? tc_modify_qdisc+0x0/0x3be
[  753.892850]  [<c12a1c10>] ? rtnetlink_rcv_msg+0x197/0x1a6
[  753.892880]  [<c132d454>] ? mutex_lock_nested+0x26e/0x288
[  753.892909]  [<c12a1a79>] ? rtnetlink_rcv_msg+0x0/0x1a6
[  753.892938]  [<c12c74ec>] ? netlink_rcv_skb+0x32/0x73
[  753.892966]  [<c12a1a00>] ? rtnetlink_rcv+0x1b/0x22
[  753.892993]  [<c12c7045>] ? netlink_unicast+0x1b3/0x214
[  753.893021]  [<c12c72dc>] ? netlink_sendmsg+0x236/0x243
[  753.893050]  [<c1288262>] ? sock_sendmsg+0xc0/0xdb
[  753.893080]  [<c109f15a>] ? might_fault+0x36/0x70
[  753.893107]  [<c109f15a>] ? might_fault+0x36/0x70
[  753.893134]  [<c109f15a>] ? might_fault+0x36/0x70
[  753.893161]  [<c116f330>] ? _copy_from_user+0x39/0x4d
[  753.893189]  [<c1290a91>] ? verify_iovec+0x3e/0x6d
[  753.893217]  [<c1289b89>] ? sys_sendmsg+0x13f/0x18c
[  753.893244]  [<c12882cd>] ? sockfd_lookup_light+0x19/0x4b
[  753.893274]  [<c1094dea>] ? __lru_cache_add+0x64/0x7b
[  753.893302]  [<c102a200>] ? get_parent_ip+0x9/0x31
[  753.893332]  [<c105a62b>] ? lock_release_non_nested+0x88/0x245
[  753.893362]  [<c109f15a>] ? might_fault+0x36/0x70
[  753.893389]  [<c109f15a>] ? might_fault+0x36/0x70
[  753.893415]  [<c109f15a>] ? might_fault+0x36/0x70
[  753.893443]  [<c1289f62>] ? sys_socketcall+0x163/0x1a3
[  753.893472]  [<c116edd0>] ? trace_hardirqs_on_thunk+0xc/0x10
[  753.893501]  [<c100278c>] ? sysenter_do_call+0x12/0x32
[  753.893537] Code: cb 83 0b 01 89 f0 83 26 fe 8b 55 f0 e8 8e fe ff ff 8b 1f 83 e3 fc 74 0e 8b 33 f7 c6 01 00 00 00 0f 84 61 ff ff ff 8b 55 f0 8b 02 <83> 08 01 58 5a 5b 5e 5f 5d c3 55 89 e5 57 56 89 d6 53 89 c3 83 
[  753.893763] EIP: [<c116b6c8>] rb_insert_color+0xc6/0xd0 SS:ESP 0068:f34a0bf8
[  753.893799] CR2: 0000000000000000
[  753.894062] ---[ end trace da6bae989b9be023 ]---



Triggering the other bug is more difficult :

est_timer() should be interrupted 
(by hard irqs for example), right before spin_lock(e->stats_lock);

Then a caller of gen_kill_estimator() might freed stats_lock and 
est_timer() reference a freed spinlock.

This can be simulated with following patch, to inject a 100 ms delay.

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index cf8e703..55ba060 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -120,6 +120,8 @@ static void est_timer(unsigned long arg)
                u32 npackets;
                u32 rate;
 
+               for (rate = 0; rate < 100; rate++)
+                       udelay(1000);
                spin_lock(e->stats_lock);
                read_lock(&est_lock);
                if (e->bstats == NULL)

My machine crash almost instantly in spin_lock(e->stats_lock)

I'll post v3 of the patch, with updated Changelog


