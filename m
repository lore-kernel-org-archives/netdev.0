From: Jacob Siverskog <jacob@teenage.engineering>
Subject: [PATCH] net: Fix potential NULL pointer dereference in __skb_try_recv_datagram
Date: Tue, 29 Dec 2015 20:10:24 +0100
Message-ID: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
Cc: "David S . Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Al Viro <viro@zeniv.linux.org.uk>,
	linux-kernel@vger.kernel.org,
	Jacob Siverskog <jacob@teenage.engineering>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This should fix a NULL pointer dereference I encountered (dump
below). Since __skb_unlink is called while walking,
skb_queue_walk_safe should be used.

I investigated the oops and it seems like skb->next was NULL.

Oops:
Unable to handle kernel NULL pointer dereference at virtual address 00000004
pgd = c5a7c000
[00000004] *pgd=85ab6831, *pte=00000000, *ppte=00000000
Internal error: Oops: 817 [#1] PREEMPT ARM
Modules linked in: xt_tcpudp xt_state xt_nat wlcore_sdio wl18xx wl12xx wlcore rfcomm nf_log_arp nf_log_common iptable_nat nf_nat_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ipt_REJECT nh
CPU: 0 PID: 11902 Comm: mdnsd Not tainted 4.3.0 #2
Hardware name: Generic AM33XX (Flattened Device Tree)udpv6_recvmsg
task: c7123040 ti: c58ce000 task.ti: c58ce000
PC is at __skb_recv_datagram+0x428/0x598
LR is at udpv6_recvmsg+0x1d0/0x6d0
pc : [<c02fc0a8>]    lr : [<c0398f1c>]    psr: 60000093
sp : c58cfd98  ip : 20000013  fp : c7781040
r10: c58ce000  r9 : 00000000  r8 : c58cfe20
r7 : c58cfe1c  r6 : c06351d0  r5 : c77810ac  r4 : c583eac0
r3 : 00000000  r2 : 00000000  r1 : 00000000  r0 : 20000013
Flags: nZCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment none
Control: 10c5387d  Table: 85a7c019  DAC: 00000051
Process mdnsd (pid: 11902, stack limit = 0xc58ce208)
Stack: (0xc58cfd98 to 0xc58d0000)
fd80:                                                       00000029 00000008
fda0: c02fbc64 00000000 00000000 00000040 c778115c c03a9ed8 c58cfdc4 00000065
fdc0: 0000005d 000000ff 00000000 00000000 fb000000 00000004 00000000 c0398d4c
fde0: c7781040 c58cff6c 000022f8 be8383ec c06351d0 00000000 c06351d0 c0398f1c
fe00: c58cfe24 c58cfe70 be8383e4 00000040 00000000 c77812a8 00000000 00000000
fe20: 00000000 c58cfe2c 00000004 c0398d4c c58cff6c c6a25c00 c58cfeb8 be8383ec
fe40: be838408 00000000 00000000 c0367a2c 00000000 c58cfe5c c58cff6c 00000000
fe60: c6a25c00 c58cff6c 00000040 c02efff4 00000000 be838874 be8388c0 000022f8
fe80: c0618d78 00000000 ff14338a 9abb1afe b2b617e7 00000ab4 b2b99e16 00000ab4
fea0: c6a1fcc0 c0608374 c0608374 00000000 00000000 00000001 e914000a 00000000
fec0: 000080fe 00000000 ff14338a 9abb1afe 00000004 ffffffff 00000000 c00499ac
fee0: c77ac000 00000002 c063a848 00000000 00000000 c0049c9c 00000000 c5a74c80
ff00: c77ac018 c7123040 00002dfb 0c95f107 c58cff78 05106300 00002dfb 00000051
ff20: be83ac08 00000001 00000018 be83ac08 00000008 00000000 00000004 be8383ec
ff40: c6a25c00 00000000 00000129 c000f3a4 c58ce000 c02f0d74 00000000 be83ac08
ff60: c58cff78 00000000 fffffff7 c58cfeb8 00000000 00000000 00000000 000022f8
ff80: c58cfe78 00000001 be838408 00000400 00000000 00000000 be838890 be83883f
ffa0: ffffffff c000f1e0 be838890 be83883f 0000000e be8383ec 00000000 00000000
ffc0: be838890 be83883f ffffffff 00000129 be838848 00000000 be838844 00000000
ffe0: 0006a228 be8383c8 0000ea5c b6f39fd8 60000010 0000000e 00000000 00000000
[<c02fc0a8>] (__skb_recv_datagram) from [<c0398f1c>] (udpv6_recvmsg+0x1d0/0x6d0)
[<c0398f1c>] (udpv6_recvmsg) from [<c0367a2c>] (inet_recvmsg+0x38/0x4c)
[<c0367a2c>] (inet_recvmsg) from [<c02efff4>] (___sys_recvmsg+0x94/0x170)
[<c02efff4>] (___sys_recvmsg) from [<c02f0d74>] (__sys_recvmsg+0x3c/0x6c)
[<c02f0d74>] (__sys_recvmsg) from [<c000f1e0>] (ret_fast_syscall+0x0/0x3c)
Code: e58b3074 e894000c e5841000 e5841004 (e5823004)
---[ end trace d16f25559f81d2a9 ]---
note: mdnsd[11902] exited with preempt_count 1
Unable to handle kernel NULL pointer dereference at virtual address 00000004
pgd = c0004000
[00000004] *pgd=00000000
Internal error: Oops: 817 [#2] PREEMPT ARM
Modules linked in: xt_tcpudp xt_state xt_nat wlcore_sdio wl18xx wl12xx wlcore rfcomm nf_log_arp nf_log_common iptable_nat nf_nat_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ipt_REJECT nh
CPU: 0 PID: 11902 Comm: mdnsd Tainted: G      D         4.3.0 #2
Hardware name: Generic AM33XX (Flattened Device Tree)
task: c7123040 ti: c58ce000 task.ti: c58ce000
PC is at inet_sock_destruct+0x40/0x1d0
LR is at sk_destruct+0x18/0xe0
pc : [<c0367ac0>]    lr : [<c02f3d7c>]    psr: a0000113
sp : c58cfb28  ip : 001180f9  fp : c7123040
r10: c5941a08  r9 : 00000000  r8 : 00000008
r7 : c7051950  r6 : c77810ac  r5 : 00000000  r4 : c7781040
r3 : c583eac0  r2 : 00000000  r1 : 00000000  r0 : c583eac0
Flags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
Control: 10c5387d  Table: 858fc019  DAC: 00000051
Process mdnsd (pid: 11902, stack limit = 0xc58ce208)
Stack: (0xc58cfb28 to 0xc58d0000)
fb20:                   c7781040 c6a25c00 c6a534c8 c02f3d7c c06351d0 c7781040
fb40: c6a25c00 c0367f0c c037cfa8 c6a25c00 00000000 c02ee878 c02ee8f0 c5941a00
fb60: c6a25c20 c02ee8fc c02ee8f0 c00c2f04 00000000 00000000 c7123338 c5a8a700
fb80: c7123040 c063bd08 c5a74cb4 00000001 c06079d0 c0047600 0000007f 00000000
fba0: c06079d0 60000193 c58cfbb8 c0030308 c063be28 c0087514 c0668f2c c063a9c4
fbc0: c06079d0 c063a9c4 c06079d0 60000193 0000000b 00000001 c02fc0aa c06079d0
fbe0: c0534fa0 c00127e4 c58ce208 0000000b 00000000 00000000 00000008 c063a9c4
fc00: c58ce000 bf000000 658cfd48 33623835 20343730 34393865 63303030 38356520
fc20: 30303134 35652030 30313438 28203430 32383565 34303033 c0002029 c0087514
fc40: 00000000 00000004 00000817 c5a74c80 c58cfd48 00000004 00000000 c58ce000
fc60: c7781040 c0019aa4 00000817 c00164f8 00000000 00000000 00000000 00000000
fc80: 00000000 00000817 c0016288 00000004 c0607b14 c58cfd48 00000000 c58ce000
fca0: c7781040 c00092c0 00000000 c5957a00 c7738cf0 c7744940 c7158000 c7738cf0
fcc0: 00000000 c0321e3c c5aa287c 00000000 00000000 004c9b81 00000000 c7744940
fce0: c58ce000 00000000 00000000 c03080a8 c5957a68 00000001 c06351d0 00000000
fd00: c5941340 c5aa2800 c5aa287c c7744940 0000000e 00000000 c58ce000 00000000
fd20: c5aa287c c037e5f0 00000065 00000000 c02fc0a8 60000093 ffffffff c58cfd7c
fd40: c58cfe20 c0013120 20000013 00000000 00000000 00000000 c583eac0 c77810ac
fd60: c06351d0 c58cfe1c c58cfe20 00000000 c58ce000 c7781040 20000013 c58cfd98
fd80: c0398f1c c02fc0a8 60000093 ffffffff 00000051 00000010 00000029 00000008
fda0: c02fbc64 00000000 00000000 00000040 c778115c c03a9ed8 c58cfdc4 00000065
fdc0: 0000005d 000000ff 00000000 00000000 fb000000 00000004 00000000 c0398d4c
fde0: c7781040 c58cff6c 000022f8 be8383ec c06351d0 00000000 c06351d0 c0398f1c
fe00: c58cfe24 c58cfe70 be8383e4 00000040 00000000 c77812a8 00000000 00000000
fe20: 00000000 c58cfe2c 00000004 c0398d4c c58cff6c c6a25c00 c58cfeb8 be8383ec
fe40: be838408 00000000 00000000 c0367a2c 00000000 c58cfe5c c58cff6c 00000000
fe60: c6a25c00 c58cff6c 00000040 c02efff4 00000000 be838874 be8388c0 000022f8
fe80: c0618d78 00000000 ff14338a 9abb1afe b2b617e7 00000ab4 b2b99e16 00000ab4
fea0: c6a1fcc0 c0608374 c0608374 00000000 00000000 00000001 e914000a 00000000
fec0: 000080fe 00000000 ff14338a 9abb1afe 00000004 ffffffff 00000000 c00499ac
fee0: c77ac000 00000002 c063a848 00000000 00000000 c0049c9c 00000000 c5a74c80
ff00: c77ac018 c7123040 00002dfb 0c95f107 c58cff78 05106300 00002dfb 00000051
ff20: be83ac08 00000001 00000018 be83ac08 00000008 00000000 00000004 be8383ec
ff40: c6a25c00 00000000 00000129 c000f3a4 c58ce000 c02f0d74 00000000 be83ac08
ff60: c58cff78 00000000 fffffff7 c58cfeb8 00000000 00000000 00000000 000022f8
ff80: c58cfe78 00000001 be838408 00000400 00000000 00000000 be838890 be83883f
ffa0: ffffffff c000f1e0 be838890 be83883f 0000000e be8383ec 00000000 00000000
ffc0: be838890 be83883f ffffffff 00000129 be838848 00000000 be838844 00000000
ffe0: 0006a228 be8383c8 0000ea5c b6f39fd8 60000010 0000000e 00000000 00000000
[<c0367ac0>] (inet_sock_destruct) from [<c02f3d7c>] (sk_destruct+0x18/0xe0)
[<c02f3d7c>] (sk_destruct) from [<c0367f0c>] (inet_release+0x44/0x70)
[<c0367f0c>] (inet_release) from [<c02ee878>] (sock_release+0x20/0x98)
[<c02ee878>] (sock_release) from [<c02ee8fc>] (sock_close+0xc/0x14)
[<c02ee8fc>] (sock_close) from [<c00c2f04>] (__fput+0x80/0x1fc)
[<c00c2f04>] (__fput) from [<c0047600>] (task_work_run+0x6c/0x9c)
[<c0047600>] (task_work_run) from [<c0030308>] (do_exit+0x2ac/0x95c)
[<c0030308>] (do_exit) from [<c00127e4>] (die+0x180/0x3b0)
[<c00127e4>] (die) from [<c0019aa4>] (__do_kernel_fault.part.0+0x64/0x1e4)
[<c0019aa4>] (__do_kernel_fault.part.0) from [<c00164f8>] (do_page_fault+0x270/0x298)
[<c00164f8>] (do_page_fault) from [<c00092c0>] (do_DataAbort+0x38/0xb4)
[<c00092c0>] (do_DataAbort) from [<c0013120>] (__dabt_svc+0x40/0x60)
Exception stack(0xc58cfd48 to 0xc58cfd90)
fd40:                   20000013 00000000 00000000 00000000 c583eac0 c77810ac
fd60: c06351d0 c58cfe1c c58cfe20 00000000 c58ce000 c7781040 20000013 c58cfd98
fd80: c0398f1c c02fc0a8 60000093 ffffffff
[<c0013120>] (__dabt_svc) from [<c02fc0a8>] (__skb_recv_datagram+0x428/0x598)
[<c02fc0a8>] (__skb_recv_datagram) from [<c0398f1c>] (udpv6_recvmsg+0x1d0/0x6d0)
[<c0398f1c>] (udpv6_recvmsg) from [<c0367a2c>] (inet_recvmsg+0x38/0x4c)
[<c0367a2c>] (inet_recvmsg) from [<c02efff4>] (___sys_recvmsg+0x94/0x170)
[<c02efff4>] (___sys_recvmsg) from [<c02f0d74>] (__sys_recvmsg+0x3c/0x6c)
[<c02f0d74>] (__sys_recvmsg) from [<c000f1e0>] (ret_fast_syscall+0x0/0x3c)
Code: e5842074 e8930006 e5835000 e5835004 (e5812004)

Signed-off-by: Jacob Siverskog <jacob@teenage.engineering>
---
 net/core/datagram.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index fa9dc64..e8b3cab 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -201,7 +201,7 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 					struct sk_buff **last)
 {
 	struct sk_buff_head *queue = &sk->sk_receive_queue;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *next;
 	unsigned long cpu_flags;
 	/*
 	 * Caller is allowed not to check sk->sk_err before skb_recv_datagram()
@@ -222,7 +222,7 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 
 		*last = (struct sk_buff *)queue;
 		spin_lock_irqsave(&queue->lock, cpu_flags);
-		skb_queue_walk(queue, skb) {
+		skb_queue_walk_safe(queue, skb, next) {
 			*last = skb;
 			*peeked = skb->peeked;
 			if (flags & MSG_PEEK) {
-- 
2.6.4
