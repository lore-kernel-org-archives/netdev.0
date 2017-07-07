From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch] mqueue: fix the retry logic for netlink_attachskb()
Date: Fri,  7 Jul 2017 11:32:15 -0700
Message-ID: <1499452335-3478-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: linux-kernel@vger.kernel.org, geneblue.mail@gmail.com,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Manfred Spraul <manfred@colorfullife.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The retry logic for netlink_attachskb() inside sys_mq_notify()
is suspicious and vulnerable:

1) The sock refcnt is already released when retry is needed
2) The fd is controllable by user-space because we already
   release the file refcnt

so we when retry and the fd has been closed during this small
window, we end up calling netlink_detachskb() on the error path
which releases the sock again and could lead to a use-after-free.

We don't need to re-get the file pointer in the retry loop, keep
it until we finally succeed.

Reported-by: GeneBlue <geneblue.mail@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 ipc/mqueue.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index e8d41ff..b894d6c 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -1237,15 +1237,15 @@ SYSCALL_DEFINE2(mq_notify, mqd_t, mqdes,
 			/* TODO: add a header? */
 			skb_put(nc, NOTIFY_COOKIE_LEN);
 			/* and attach it to the socket */
-retry:
 			f = fdget(notification.sigev_signo);
 			if (!f.file) {
 				ret = -EBADF;
 				goto out;
 			}
+retry:
 			sock = netlink_getsockbyfilp(f.file);
-			fdput(f);
 			if (IS_ERR(sock)) {
+				fdput(f);
 				ret = PTR_ERR(sock);
 				sock = NULL;
 				goto out;
@@ -1255,6 +1255,7 @@ SYSCALL_DEFINE2(mq_notify, mqd_t, mqdes,
 			ret = netlink_attachskb(sock, nc, &timeo, NULL);
 			if (ret == 1)
 				goto retry;
+			fdput(f);
 			if (ret) {
 				sock = NULL;
 				nc = NULL;
-- 
2.5.5
