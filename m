From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net] af_unix: don't poll dead peers
Date: Wed,  4 Mar 2015 21:07:09 +0100
Message-ID: <1425499629-15223-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Olivier Mauras <olivier@mauras.ch>,
	Mathias Krause <minipli@googlemail.com>,
	Rainer Weikusat <rweikusat@mssgmbh.com>,
	PaX Team <pageexec@freemail.hu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:37060 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752765AbbCDUHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 15:07:42 -0500
Received: by wesx3 with SMTP id x3so2086379wes.4
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 12:07:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to test if the peer is still alive, before actually calling
poll_wait() on its wait queue, as we may race with unix_release_sock()
which may lead to a use-after-free in the epoll code, ending up in
uninterruptable lockups in the epoll code or other badnesses.

The following program triggers the condition. The visible effects may
take some time to materialize.

,---[ ep.c ]---
| /* gcc -O2 -pthread -o ep ep.c */
| #include <sys/socket.h>
| #include <sys/epoll.h>
| #include <pthread.h>
| #include <unistd.h>
| #include <stdlib.h>
| #include <string.h>
| #include <stdio.h>
| #include <errno.h>
|
| static long fd_max;
| static int ep = -1;
|
| static int get_fd(void) {
|     int fd;
|
|     for (;;) {
|         fd = rand() % fd_max;
|
|         if (fd > 2 && fd != ep)
|             break;
|     }
|
|     return fd;
| }
|
|
| static void *opener(void *ptr) {
|     sleep(1);
|
|     for (;;) {
|         switch (rand() % 3) {
|             int fd[2];
|
|             case 0:
|                 socketpair(AF_UNIX, SOCK_DGRAM, 0, fd);
|                 break;
|
|             case 1:
|                 dup(get_fd());
|                 break;
|
|             case 2:
|                 write(get_fd(), ".", 1);
|                 break;
|         }
|
|         /* take a short nap when there are no more fds left */
|         if (errno == EMFILE || errno == ENFILE)
|             usleep(10);
|     }
|
|     return ptr;
| }
|
|
| static void *closer(void *ptr) {
|     int miss = 0;
|
|     sleep(1);
|
|     for (;;) {
|         switch (rand() % 5) {
|             default:
|                 close(get_fd());
|                 break;
|
|             case 4:
|                 usleep(1);
|                 break;
|         }
|
|         /* take a short nap when we're not hitting valid fds 10 times in
|          * a row so opener() can catch up */
|         if (errno == EBADF && ++miss >= 10) {
|             usleep(10);
|             miss = 0;
|         } else if (errno == 0) {
|             miss = 0;
|         }
|     }
|
|     return ptr;
| }
|
|
| static void *ep_add(void *ptr) {
|     sleep(1);
|
|     for (;;) {
|         int fd = get_fd();
|         struct epoll_event ev = {
|             .events = EPOLLIN | EPOLLOUT,
|             .data.fd = fd,
|         };
|
|         if (epoll_ctl(ep, EPOLL_CTL_ADD, fd, &ev) < 0 && errno == ENOSPC)
|             usleep(1);
|     }
|
|     return ptr;
| }
|
|
| static void *ep_del(void *ptr) {
|     sleep(1);
|
|     for (;;)
|         epoll_ctl(ep, EPOLL_CTL_DEL, get_fd(), NULL);
|
|     return ptr;
| }
|
|
| int main(void) {
|     pthread_t thread[4];
|     int i;
|
|     /* use epoll_create() to support older kernels */
|     ep = epoll_create(42);
|     if (ep < 0) {
|         fprintf(stderr, "err: epoll_create1() failed (%s)\n",
|                 strerror(errno));
|
|         return 1;
|     }
|
|     fd_max = sysconf(_SC_OPEN_MAX);
|     if (pthread_create(&thread[0], NULL, opener, NULL) ||
|         pthread_create(&thread[1], NULL, closer, NULL) ||
|         pthread_create(&thread[2], NULL, ep_add, NULL) ||
|         pthread_create(&thread[3], NULL, ep_del, NULL))
|     {
|         fprintf(stderr, "err: failed to start all threads!\n");
|
|         return 1;
|     }
|
|     /* XXX: pthread_cancel() all threads on termination request */
|
|     for (i = 0; i < 4; i++)
|         pthread_join(thread[i], NULL);
|
|     return 0;
| }
`-----

On a kernel with CONFIG_DEBUG_LIST and CONFIG_SLUB_DEBUG_ON set the
above program triggers the below splats within seconds:

[   10.660952] ------------[ cut here ]------------
[   10.664035] WARNING: CPU: 0 PID: 113 at /home/minipli/src/linux/lib/list_debug.c:59 __list_del_entry+0xa1/0xd0()
[   10.664035] list_del corruption. prev->next should be ffff88001fb98990, but was ffff88001f43fcd8
[   10.664035] Modules linked in:
[   10.664035] CPU: 0 PID: 113 Comm: ep Not tainted 4.0.0-rc2 #197
[   10.664035] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   10.664035]  ffffffff814ebce0 ffff88001fb3fd48 ffffffff813ca3be 0000000000000000
[   10.683504]  ffff88001fb3fd98 ffff88001fb3fd88 ffffffff81044b1d ffff880000000000
[   10.683504]  ffff88001fb98990 ffff88001fb98978 0000000000000292 ffff88001f436e00
[   10.683504] Call Trace:
[   10.683504]  [<ffffffff813ca3be>] dump_stack+0x45/0x57
[   10.683504]  [<ffffffff81044b1d>] warn_slowpath_common+0x8d/0xd0
[   10.683504]  [<ffffffff81044c01>] warn_slowpath_fmt+0x41/0x50
[   10.683504]  [<ffffffff811c44e1>] __list_del_entry+0xa1/0xd0
[   10.683504]  [<ffffffff811c4521>] list_del+0x11/0x40
[   10.683504]  [<ffffffff8107279c>] remove_wait_queue+0x2c/0x50
[   10.683504]  [<ffffffff81133bba>] ep_unregister_pollwait.isra.12+0x3a/0x60
[   10.683504]  [<ffffffff81133c0a>] ep_remove+0x2a/0xd0
[   10.683504]  [<ffffffff81134f5e>] SyS_epoll_ctl+0x46e/0xcf0
[   10.683504]  [<ffffffff813cfd89>] ? _raw_spin_unlock_irq+0x9/0x10
[   10.683504]  [<ffffffff813d0192>] system_call_fastpath+0x12/0x17
[   10.683504] ---[ end trace 2a55662f515a4628 ]---
[   10.789959] BUG: spinlock bad magic on CPU#0, ep/113
[   10.792014] general protection fault: 0000 [#1] SMP
[   10.792014] Modules linked in:
[   10.792014] CPU: 0 PID: 113 Comm: ep Tainted: G        W       4.0.0-rc2 #197
[   10.792014] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   10.792014] task: ffff88001f977500 ti: ffff88001fb3c000 task.ti: ffff88001fb3c000
[   10.792014] RIP: 0010:[<ffffffff813c8682>]  [<ffffffff813c8682>] spin_dump+0x55/0x90
[   10.792014] RSP: 0018:ffff88001fb3fd98  EFLAGS: 00010002
[   10.792014] RAX: 0000000000000028 RBX: 6b6b6b6b6b6b6b6b RCX: 0000000000000000
[   10.792014] RDX: 0000000000000001 RSI: ffff88001f00d1a8 RDI: ffff88001f00d1a8
[   10.792014] RBP: ffff88001fb3fda8 R08: 0000000000000000 R09: 000000006b6b6b6b
[   10.792014] R10: ffffffff81437e80 R11: 0000000000000000 R12: ffff88001fbe99c0
[   10.792014] R13: ffff88001fb48c40 R14: ffff88001fb48c00 R15: fffffffffffffffe
[   10.792014] FS:  00007f62532af700(0000) GS:ffff88001f000000(0000) knlGS:0000000000000000
[   10.792014] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   10.792014] CR2: ffffffffff600400 CR3: 000000001f989000 CR4: 00000000000006f0
[   10.792014] Stack:
[   10.792014]  ffff88001fbe99c0 ffffffff814da8cb ffff88001fb3fdc8 ffffffff813c86de
[   10.792014]  ffff88001fbe99c0 ffff88001fb6eb08 ffff88001fb3fdf8 ffffffff810777f7
[   10.792014]  0000000000000292 ffff88001fb6eb08 ffff88001fb48c40 ffff88001fb48c00
[   10.792014] Call Trace:
[   10.792014]  [<ffffffff813c86de>] spin_bug+0x21/0x26
[   10.792014]  [<ffffffff810777f7>] do_raw_spin_lock+0x157/0x170
[   10.792014]  [<ffffffff813cfdd1>] _raw_spin_lock_irqsave+0x11/0x20
[   10.792014]  [<ffffffff8107278f>] remove_wait_queue+0x1f/0x50
[   10.792014]  [<ffffffff81133bba>] ep_unregister_pollwait.isra.12+0x3a/0x60
[   10.792014]  [<ffffffff81133c0a>] ep_remove+0x2a/0xd0
[   10.792014]  [<ffffffff81134f5e>] SyS_epoll_ctl+0x46e/0xcf0
[   10.792014]  [<ffffffff813cfd89>] ? _raw_spin_unlock_irq+0x9/0x10
[   10.792014]  [<ffffffff813d0192>] system_call_fastpath+0x12/0x17
[   10.792014] Code: 25 00 aa 00 00 44 8b 80 00 03 00 00 48 8d 88 a0 04 00 00 31 c0 65 8b 15 95 1a c4 7e e8 bd 00 00 00 48 85 db 45 8b 4c 24 08 74 10 <44> 8b 83 00 03 00 00 48 8d 8b a0 04 00 00 eb 0b 41 83 c8 ff 48
[   10.792014] RIP  [<ffffffff813c8682>] spin_dump+0x55/0x90
[   10.792014]  RSP <ffff88001fb3fd98>
[   10.792014] ---[ end trace 2a55662f515a462a ]---

Those look similar to [1] and [2] so might be the cause of these as
well.

[1] https://lkml.org/lkml/2013/10/14/353
[2] https://lkml.org/lkml/2014/5/15/532

The backtraces are misleading, as the bug is, in fact, not in the epoll
code but in af_unix. A 'git bisect' run confirmed that and identified
commit 3c73419c09a5 ("af_unix: fix 'poll for write'/ connected DGRAM
sockets") as the root cause.

This bug has been found by the PaX memory sanitize feature, reported
here: https://forums.grsecurity.net/viewtopic.php?f=3&t=4150

Fixes: 3c73419c09a5 "af_unix: fix 'poll for write'/ connected DGRAM..."
Signed-off-by: Mathias Krause <minipli@googlemail.com>
Reported-by: Olivier Mauras <olivier@mauras.ch>
Cc: Rainer Weikusat <rweikusat@mssgmbh.com>
Cc: PaX Team <pageexec@freemail.hu>
---
 net/unix/af_unix.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 526b6edab018..0da9d7eeed17 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2233,10 +2233,14 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	writable = unix_writable(sk);
 	other = unix_peer_get(sk);
 	if (other) {
-		if (unix_peer(other) != sk) {
+		unix_state_lock(other);
+		if (!sock_flag(other, SOCK_DEAD) && unix_peer(other) != sk) {
+			unix_state_unlock(other);
 			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
 			if (unix_recvq_full(other))
 				writable = 0;
+		} else {
+			unix_state_unlock(other);
 		}
 		sock_put(other);
 	}
-- 
1.7.10.4
