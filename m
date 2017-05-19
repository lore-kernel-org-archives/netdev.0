From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] vsock: use new wait API for vsock_stream_sendmsg()
Date: Fri, 19 May 2017 11:21:59 -0700
Message-ID: <1495218119-12358-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Jorgen Hansen <jhansen@vmware.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36510 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755505AbdESSWM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 14:22:12 -0400
Received: by mail-pf0-f196.google.com with SMTP id n23so10286846pfb.3
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 11:22:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As reported by Michal, vsock_stream_sendmsg() could still
sleep at vsock_stream_has_space() after prepare_to_wait():

  vsock_stream_has_space
    vmci_transport_stream_has_space
      vmci_qpair_produce_free_space
        qp_lock
          qp_acquire_queue_mutex
            mutex_lock

Just switch to the new wait API like we did for commit
d9dc8b0f8b4e ("net: fix sleeping for sk_wait_event()").

Reported-by: Michal Kubecek <mkubecek@suse.cz>
Cc: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Jorgen Hansen <jhansen@vmware.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/vmw_vsock/af_vsock.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 6f7f675..dfc8c51e 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1540,8 +1540,7 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 	long timeout;
 	int err;
 	struct vsock_transport_send_notify_data send_data;
-
-	DEFINE_WAIT(wait);
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 
 	sk = sock->sk;
 	vsk = vsock_sk(sk);
@@ -1584,11 +1583,10 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 	if (err < 0)
 		goto out;
 
-
 	while (total_written < len) {
 		ssize_t written;
 
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		add_wait_queue(sk_sleep(sk), &wait);
 		while (vsock_stream_has_space(vsk) == 0 &&
 		       sk->sk_err == 0 &&
 		       !(sk->sk_shutdown & SEND_SHUTDOWN) &&
@@ -1597,33 +1595,30 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 			/* Don't wait for non-blocking sockets. */
 			if (timeout == 0) {
 				err = -EAGAIN;
-				finish_wait(sk_sleep(sk), &wait);
+				remove_wait_queue(sk_sleep(sk), &wait);
 				goto out_err;
 			}
 
 			err = transport->notify_send_pre_block(vsk, &send_data);
 			if (err < 0) {
-				finish_wait(sk_sleep(sk), &wait);
+				remove_wait_queue(sk_sleep(sk), &wait);
 				goto out_err;
 			}
 
 			release_sock(sk);
-			timeout = schedule_timeout(timeout);
+			timeout = wait_woken(&wait, TASK_INTERRUPTIBLE, timeout);
 			lock_sock(sk);
 			if (signal_pending(current)) {
 				err = sock_intr_errno(timeout);
-				finish_wait(sk_sleep(sk), &wait);
+				remove_wait_queue(sk_sleep(sk), &wait);
 				goto out_err;
 			} else if (timeout == 0) {
 				err = -EAGAIN;
-				finish_wait(sk_sleep(sk), &wait);
+				remove_wait_queue(sk_sleep(sk), &wait);
 				goto out_err;
 			}
-
-			prepare_to_wait(sk_sleep(sk), &wait,
-					TASK_INTERRUPTIBLE);
 		}
-		finish_wait(sk_sleep(sk), &wait);
+		remove_wait_queue(sk_sleep(sk), &wait);
 
 		/* These checks occur both as part of and after the loop
 		 * conditional since we need to check before and after
-- 
2.5.5
