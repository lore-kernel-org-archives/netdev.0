From: Alexander Potapenko <glider@google.com>
Subject: [PATCH] ipv6: make sure to initialize sockc.tsflags before first use
Date: Tue, 21 Mar 2017 17:14:27 +0100
Message-ID: <20170321161427.103713-1-glider@google.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        davem@davemloft.net, soheil@google.com, kuznet@ms2.inr.ac.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the case udp_sk(sk)->pending is AF_INET6, udpv6_sendmsg() would
jump to do_append_data, skipping the initialization of sockc.tsflags.
Fix the problem by moving sockc.tsflags initialization earlier.

The bug was detected with KMSAN.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
For the record, here is the KMSAN report:

==================================================================
BUG: KMSAN: use of unitialized memory
CPU: 0 PID: 1027 Comm: udpv6_sendmsg Not tainted 4.8.0-rc6+ #2041
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 0000000000000000 ffff88010c17f1a8 ffffffff825b5098 ffff88010c17f0e8
 0000000000000000 ffffffff85bae870 0000000000000092 ffffffff85bae550
 0000000000000000 0000000000000092 0000000000000000 0000000000000002
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff825b5098>] dump_stack+0x238/0x290 lib/dump_stack.c:51
 [<ffffffff818e86f0>] kmsan_report+0x180/0x210 mm/kmsan/kmsan.c:1022
 [<ffffffff818e9dea>] __msan_warning+0x8a/0x100 mm/kmsan/kmsan_instr.c:431
 [<     inline     >] sock_tx_timestamp ./include/net/sock.h:2162
 [<ffffffff849a9680>] __ip6_append_data+0x52e0/0x6160 net/ipv6/ip6_output.c:1336
 [<ffffffff849a26c3>] ip6_append_data+0x453/0x750 net/ipv6/ip6_output.c:1599
 [<ffffffff84a68d02>] udpv6_sendmsg+0x10f2/0x47f0 net/ipv6/udp.c:1261
 [<ffffffff847d046e>] inet_sendmsg+0x64e/0x930 net/ipv4/af_inet.c:740
 [<     inline     >] sock_sendmsg_nosec net/socket.c:609
 [<     inline     >] sock_sendmsg net/socket.c:619
 [<ffffffff842c1ae0>] ___sys_sendmsg+0xe10/0x14e0 net/socket.c:1943
 [<ffffffff842c2b7c>] __sys_sendmmsg+0x4ac/0x880 net/socket.c:2033
 [<ffffffff842c30c8>] SYSC_sendmmsg+0xb8/0x130 net/socket.c:2062
 [<ffffffff842c2fe5>] SyS_sendmmsg+0x95/0xc0 net/socket.c:2057
 [<ffffffff81005688>] do_syscall_64+0x58/0x70 arch/x86/entry/common.c:292
 [<ffffffff851db97c>] entry_SYSCALL64_slow_path+0x25/0x25 arch/x86/entry/entry_64.o:?
chained origin: 00000000922009b8
 [<ffffffff810bd5e7>] save_stack_trace+0x27/0x50 arch/x86/kernel/stacktrace.c:67
 [<     inline     >] kmsan_save_stack_with_flags mm/kmsan/kmsan.c:349
 [<     inline     >] kmsan_save_stack mm/kmsan/kmsan.c:364
 [<ffffffff818e7a9e>] kmsan_internal_chain_origin+0x12e/0x1f0 mm/kmsan/kmsan.c:581
 [<ffffffff818e9cdc>] __msan_set_alloca_origin4+0xdc/0x160 mm/kmsan/kmsan_instr.c:386
 [<ffffffff84a67ef8>] udpv6_sendmsg+0x2e8/0x47f0 net/ipv6/udp.c:1014
 [<ffffffff847d046e>] inet_sendmsg+0x64e/0x930 net/ipv4/af_inet.c:740
 [<     inline     >] sock_sendmsg_nosec net/socket.c:609
 [<     inline     >] sock_sendmsg net/socket.c:619
 [<ffffffff842c1ae0>] ___sys_sendmsg+0xe10/0x14e0 net/socket.c:1943
 [<ffffffff842c2b7c>] __sys_sendmmsg+0x4ac/0x880 net/socket.c:2033
 [<ffffffff842c30c8>] SYSC_sendmmsg+0xb8/0x130 net/socket.c:2062
 [<ffffffff842c2fe5>] SyS_sendmmsg+0x95/0xc0 net/socket.c:2057
 [<ffffffff81005688>] do_syscall_64+0x58/0x70 arch/x86/entry/common.c:292
 [<ffffffff851db97c>] return_from_SYSCALL_64+0x0/0x6a arch/x86/entry/entry_64.o:?
origin description: ----sockc@udpv6_sendmsg (origin=000000009e8009b7)
==================================================================

and the reproducer that triggers it:
==================================================================
  #define _GNU_SOURCE
  #include <netinet/ip.h>
  #include <string.h>

  int main()
  {
    int sock = socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP);

    struct sockaddr_in6 addr;
    memset(&addr, 0, sizeof(struct sockaddr_in6));
    addr.sin6_family = AF_INET6;
    addr.sin6_port = htons(20000);
    inet_pton(AF_INET6, "ffff:0:400::", &addr.sin6_addr);

    struct msghdr msg;
    memset(&msg, 0, sizeof(struct msghdr));
    msg.msg_name = &addr;
    msg.msg_namelen = sizeof(struct sockaddr_in6);
    sendmsg(sock, &msg, MSG_DONTROUTE|MSG_MORE);

    struct mmsghdr mmsg;
    memset(&mmsg, 0, sizeof(struct mmsghdr));
    sendmmsg(sock, &mmsg, 1, 0);
    return 0;
  }
==================================================================

---
 net/ipv6/udp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4e4c401e3bc6..e28082f0a307 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1035,6 +1035,7 @@ int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	ipc6.hlimit = -1;
 	ipc6.tclass = -1;
 	ipc6.dontfrag = -1;
+	sockc.tsflags = sk->sk_tsflags;
 
 	/* destination address check */
 	if (sin6) {
@@ -1159,7 +1160,6 @@ int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 	fl6.flowi6_mark = sk->sk_mark;
 	fl6.flowi6_uid = sk->sk_uid;
-	sockc.tsflags = sk->sk_tsflags;
 
 	if (msg->msg_controllen) {
 		opt = &opt_space;
-- 
2.12.1.500.gab5fba24ee-goog
