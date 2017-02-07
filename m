From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] kcm: fix 0-length case for kcm_sendmsg()
Date: Tue,  7 Feb 2017 12:59:47 -0800
Message-ID: <1486501187-12869-2-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, dvyukov@google.com,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36084 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932379AbdBGVAA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 16:00:00 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so13040439pgf.3
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 12:59:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry reported a kernel warning:

 WARNING: CPU: 3 PID: 2936 at net/kcm/kcmsock.c:627
 kcm_write_msgs+0x12e3/0x1b90 net/kcm/kcmsock.c:627
 CPU: 3 PID: 2936 Comm: a.out Not tainted 4.10.0-rc6+ #209
 Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 Call Trace:
  __dump_stack lib/dump_stack.c:15 [inline]
  dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
  panic+0x1fb/0x412 kernel/panic.c:179
  __warn+0x1c4/0x1e0 kernel/panic.c:539
  warn_slowpath_null+0x2c/0x40 kernel/panic.c:582
  kcm_write_msgs+0x12e3/0x1b90 net/kcm/kcmsock.c:627
  kcm_sendmsg+0x163a/0x2200 net/kcm/kcmsock.c:1029
  sock_sendmsg_nosec net/socket.c:635 [inline]
  sock_sendmsg+0xca/0x110 net/socket.c:645
  sock_write_iter+0x326/0x600 net/socket.c:848
  new_sync_write fs/read_write.c:499 [inline]
  __vfs_write+0x483/0x740 fs/read_write.c:512
  vfs_write+0x187/0x530 fs/read_write.c:560
  SYSC_write fs/read_write.c:607 [inline]
  SyS_write+0xfb/0x230 fs/read_write.c:599
  entry_SYSCALL_64_fastpath+0x1f/0xc2

when calling syscall(__NR_write, sock2, 0x208aaf27ul, 0x0ul) on a KCM
seqpacket socket. It appears that kcm_sendmsg() does not handle len==0
case correctly, which causes an empty skb is allocated and queued.
Fix this by skipping the skb allocation for len==0 case.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/kcm/kcmsock.c | 40 ++++++++++++++++++++++------------------
 1 file changed, 22 insertions(+), 18 deletions(-)

diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index 7e08a4d..64f0e85 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -929,23 +929,25 @@ static int kcm_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 			goto out_error;
 	}
 
-	/* New message, alloc head skb */
-	head = alloc_skb(0, sk->sk_allocation);
-	while (!head) {
-		kcm_push(kcm);
-		err = sk_stream_wait_memory(sk, &timeo);
-		if (err)
-			goto out_error;
-
+	if (msg_data_left(msg)) {
+		/* New message, alloc head skb */
 		head = alloc_skb(0, sk->sk_allocation);
-	}
+		while (!head) {
+			kcm_push(kcm);
+			err = sk_stream_wait_memory(sk, &timeo);
+			if (err)
+				goto out_error;
 
-	skb = head;
+			head = alloc_skb(0, sk->sk_allocation);
+		}
 
-	/* Set ip_summed to CHECKSUM_UNNECESSARY to avoid calling
-	 * csum_and_copy_from_iter from skb_do_copy_data_nocache.
-	 */
-	skb->ip_summed = CHECKSUM_UNNECESSARY;
+		skb = head;
+
+		/* Set ip_summed to CHECKSUM_UNNECESSARY to avoid calling
+		 * csum_and_copy_from_iter from skb_do_copy_data_nocache.
+		 */
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
 
 start:
 	while (msg_data_left(msg)) {
@@ -1018,10 +1020,12 @@ static int kcm_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	if (eor) {
 		bool not_busy = skb_queue_empty(&sk->sk_write_queue);
 
-		/* Message complete, queue it on send buffer */
-		__skb_queue_tail(&sk->sk_write_queue, head);
-		kcm->seq_skb = NULL;
-		KCM_STATS_INCR(kcm->stats.tx_msgs);
+		if (head) {
+			/* Message complete, queue it on send buffer */
+			__skb_queue_tail(&sk->sk_write_queue, head);
+			kcm->seq_skb = NULL;
+			KCM_STATS_INCR(kcm->stats.tx_msgs);
+		}
 
 		if (msg->msg_flags & MSG_BATCH) {
 			kcm->tx_wait_more = true;
-- 
2.5.5
