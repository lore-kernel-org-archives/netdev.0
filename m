From: Alexander Potapenko <glider@google.com>
Subject: [PATCH] net: initialize msg.msg_flags in recvfrom
Date: Tue,  7 Mar 2017 14:58:10 +0100
Message-ID: <20170307135810.90371-1-glider@google.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:36260 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755436AbdCGOGC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 09:06:02 -0500
Received: by mail-wr0-f178.google.com with SMTP id u108so2011439wrb.3
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 06:04:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

KMSAN (KernelMemorySanitizer, a new error detection tool) reports use
of uninitialized memory in put_cmsg()):

==================================================================
BUG: KMSAN: use of unitialized memory
inter: 0
CPU: 3 PID: 1086 Comm: syz-executor0 Not tainted 4.8.0-rc6+ #1920
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 0000000000000000 ffff88008374fa48 ffffffff82576c18 ffff88008374f988
 ffffffff818c06d1 ffffffff85bab870 0000000000000092 ffffffff85bab550
 0000000000000000 0000000000000092 00000000f9600a55 0000000000000002
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff82576c18>] dump_stack+0x238/0x290 lib/dump_stack.c:51
 [<ffffffff818beef6>] kmsan_report+0x276/0x2e0 mm/kmsan/kmsan.c:1006
 [<ffffffff818c027b>] __msan_warning+0x6b/0xc0 mm/kmsan/kmsan_instr.c:425
 [<ffffffff842f01e7>] put_cmsg+0x6f7/0x850 net/core/scm.c:223
 [<     inline     >] netlink_cmsg_recv_pktinfo net/netlink/af_netlink.c:1700
 [<ffffffff844b7054>] netlink_recvmsg+0x8e4/0x1980 net/netlink/af_netlink.c:1856
 [<     inline     >] sock_recvmsg_nosec net/socket.c:711
 [<     inline     >] sock_recvmsg net/socket.c:718
 [<ffffffff8426c175>] SYSC_recvfrom+0x6e5/0xa00 net/socket.c:1695
 [<ffffffff8426ba67>] SyS_recvfrom+0xb7/0xe0 net/socket.c:1668
 [<ffffffff851840db>] entry_SYSCALL_64_fastpath+0x13/0x8f arch/x86/entry/entry_64.o:?
chained origin: 00000000f8c00a55
 [<ffffffff810bd4d7>] save_stack_trace+0x27/0x50 arch/x86/kernel/stacktrace.c:67
 [<     inline     >] kmsan_save_stack_with_flags mm/kmsan/kmsan.c:322
 [<     inline     >] kmsan_save_stack mm/kmsan/kmsan.c:337
 [<ffffffff818be2cb>] kmsan_internal_chain_origin+0x12b/0x1f0 mm/kmsan/kmsan.c:530
 [<ffffffff818bfc0f>] __kmsan_store_origin+0x9f/0x120 mm/kmsan/kmsan_instr.c:190
 [<ffffffff844b6bdd>] netlink_recvmsg+0x46d/0x1980 net/netlink/af_netlink.c:1839
 [<     inline     >] sock_recvmsg_nosec net/socket.c:711
 [<     inline     >] sock_recvmsg net/socket.c:718
 [<ffffffff8426c175>] SYSC_recvfrom+0x6e5/0xa00 net/socket.c:1695
 [<ffffffff8426ba67>] SyS_recvfrom+0xb7/0xe0 net/socket.c:1668
 [<ffffffff851840db>] entry_SYSCALL_64_fastpath+0x13/0x8f arch/x86/entry/entry_64.o:?
chained origin: 00000000b9a00a53
 [<ffffffff810bd4d7>] save_stack_trace+0x27/0x50 arch/x86/kernel/stacktrace.c:67
 [<     inline     >] kmsan_save_stack_with_flags mm/kmsan/kmsan.c:322
 [<     inline     >] kmsan_save_stack mm/kmsan/kmsan.c:337
 [<ffffffff818be2cb>] kmsan_internal_chain_origin+0x12b/0x1f0 mm/kmsan/kmsan.c:530
 [<ffffffff818c01a3>] __msan_set_alloca_origin4+0xc3/0x130 mm/kmsan/kmsan_instr.c:380
 [<ffffffff8426bc13>] SYSC_recvfrom+0x183/0xa00 net/socket.c:1671
 [<ffffffff8426ba67>] SyS_recvfrom+0xb7/0xe0 net/socket.c:1668
 [<ffffffff851840db>] entry_SYSCALL_64_fastpath+0x13/0x8f arch/x86/entry/entry_64.o:?
origin description: ----msg@SYSC_recvfrom (origin=00000000b9400a53)
==================================================================

The fields of |msg| in SYSC_recvfrom() are initialized except
for |msg.msg_flags|, which is later updated in netlink_recvmsg():

  1839                 msg->msg_flags |= MSG_TRUNC;

and then used in a condition in put_cmsg():

  223         if (MSG_CMSG_COMPAT & msg->msg_flags)

The following program has been used to reproduce the error under KMSAN:

===================================================
  #include <linux/netlink.h>
  #include <stdint.h>
  #include <stdio.h>
  #include <sys/socket.h>
  #include <sys/wait.h>

  void child()
  {
    int sock = socket(PF_NETLINK, SOCK_RAW, 16);
    uint32_t val = 0x1f;
    setsockopt(sock, 0x10e, 0x3, &val, 4);
    char obuf[31] = "\x1f\x00\x00\x00\x10\x00\x07\xff\xff\x08\x00\x00"
                    "\x00\x00\x00\x00\x03\x00\x01\x0a\x56\x67\x69\x93"
                    "\x3e\x00\x00\x01\x92\x9a\x02";
    char ibuf[31];
    write(sock, obuf, sizeof(obuf));
    struct sockaddr_nl sockaddr = {AF_NETLINK, 0, 0, 0};
    socklen_t addrlen = sizeof(sockaddr);
    recvfrom(sock, ibuf, 0, 0, &sockaddr, &addrlen);
  }

  int main()
  {
    int pid = fork();
    if (!pid) {
      child();
      return 0;
    }
    int status = 0;
    while (waitpid(pid, &status, __WALL) != pid) {}
    return 0;
  }
===================================================

Signed-off-by: Alexander Potapenko <glider@google.com>
---
 net/socket.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/socket.c b/net/socket.c
index 2c1e8677ff2d..e0757e648c0c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1731,6 +1731,7 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
 	/* We assume all kernel code knows the size of sockaddr_storage */
 	msg.msg_namelen = 0;
 	msg.msg_iocb = NULL;
+	msg.msg_flags = 0;
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
 	err = sock_recvmsg(sock, &msg, flags);
-- 
2.12.0.rc1.440.g5b76565f74-goog
