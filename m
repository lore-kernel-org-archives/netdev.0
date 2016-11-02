From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: tcp: check skb is non-NULL for exact match on lookups
Date: Wed,  2 Nov 2016 12:08:25 -0700
Message-ID: <1478113705-16174-1-git-send-email-dsa@cumulusnetworks.com>
Cc: andreyknvl@google.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33190 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753245AbcKBTIb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 15:08:31 -0400
Received: by mail-pf0-f170.google.com with SMTP id d2so16657010pfd.0
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 12:08:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey reported the following error report while running the syzkaller
fuzzer:

general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 648 Comm: syz-executor Not tainted 4.9.0-rc3+ #333
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff8800398c4480 task.stack: ffff88003b468000
RIP: 0010:[<ffffffff83091106>]  [<     inline     >]
inet_exact_dif_match include/net/tcp.h:808
RIP: 0010:[<ffffffff83091106>]  [<ffffffff83091106>]
__inet_lookup_listener+0xb6/0x500 net/ipv4/inet_hashtables.c:219
RSP: 0018:ffff88003b46f270  EFLAGS: 00010202
RAX: 0000000000000004 RBX: 0000000000004242 RCX: 0000000000000001
RDX: 0000000000000000 RSI: ffffc90000e3c000 RDI: 0000000000000054
RBP: ffff88003b46f2d8 R08: 0000000000004000 R09: ffffffff830910e7
R10: 0000000000000000 R11: 000000000000000a R12: ffffffff867fa0c0
R13: 0000000000004242 R14: 0000000000000003 R15: dffffc0000000000
FS:  00007fb135881700(0000) GS:ffff88003ec00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020cc3000 CR3: 000000006d56a000 CR4: 00000000000006f0
Stack:
 0000000000000000 000000000601a8c0 0000000000000000 ffffffff00004242
 424200003b9083c2 ffff88003def4041 ffffffff84e7e040 0000000000000246
 ffff88003a0911c0 0000000000000000 ffff88003a091298 ffff88003b9083ae
Call Trace:
 [<ffffffff831100f4>] tcp_v4_send_reset+0x584/0x1700 net/ipv4/tcp_ipv4.c:643
 [<ffffffff83115b1b>] tcp_v4_rcv+0x198b/0x2e50 net/ipv4/tcp_ipv4.c:1718
 [<ffffffff83069d22>] ip_local_deliver_finish+0x332/0xad0
net/ipv4/ip_input.c:216
...

MD5 has a code path that calls __inet_lookup_listener with a null skb,
so inet{6}_exact_dif_match needs to check skb against null before pulling
the flag.

Fixes: a04a480d4392 ("net: Require exact match for TCP socket lookups if
       dif is l3mdev")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
Dave: commit a04a480d4392 was queued for stable, so this needs to follow it.

 include/linux/ipv6.h | 2 +-
 include/net/tcp.h    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index ca1ad9ebbc92..a0649973ee5b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -149,7 +149,7 @@ static inline bool inet6_exact_dif_match(struct net *net, struct sk_buff *skb)
 {
 #if defined(CONFIG_NET_L3_MASTER_DEV)
 	if (!net->ipv4.sysctl_tcp_l3mdev_accept &&
-	    ipv6_l3mdev_skb(IP6CB(skb)->flags))
+	    skb && ipv6_l3mdev_skb(IP6CB(skb)->flags))
 		return true;
 #endif
 	return false;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5b82d4d94834..304a8e17bc87 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -805,7 +805,7 @@ static inline bool inet_exact_dif_match(struct net *net, struct sk_buff *skb)
 {
 #if IS_ENABLED(CONFIG_NET_L3_MASTER_DEV)
 	if (!net->ipv4.sysctl_tcp_l3mdev_accept &&
-	    ipv4_l3mdev_skb(TCP_SKB_CB(skb)->header.h4.flags))
+	    skb && ipv4_l3mdev_skb(TCP_SKB_CB(skb)->header.h4.flags))
 		return true;
 #endif
 	return false;
-- 
2.1.4
