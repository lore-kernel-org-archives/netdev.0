From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [Fwd: [PATCH] [LIO-Target]: Remove extra sock_create_lite() call
	from kernel_accept() codepath]
Date: Sat, 10 Jan 2009 00:24:50 -0800
Message-ID: <1231575890.4560.1098.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ymexVyJVa7cVT5dJsZjv"
To: Linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp124.sbc.mail.sp1.yahoo.com ([69.147.64.97]:36982 "HELO
	smtp124.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751308AbZAJIZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 03:25:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ymexVyJVa7cVT5dJsZjv
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Whoops, wrong email address for netdev.

--nab

--=-ymexVyJVa7cVT5dJsZjv
Content-Disposition: inline
Content-Description: Forwarded message - [PATCH] [LIO-Target]: Remove extra
	sock_create_lite() call from kernel_accept() codepath
Content-Type: message/rfc822

Subject: [PATCH] [LIO-Target]: Remove extra sock_create_lite() call from
	kernel_accept() codepath
From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
To: "Linux-iSCSI.org Target Dev" <linux-iscsi-target-dev@googlegroups.com>
Cc: Linux-netdev <linux-netdev@vger.kernel.org>, Linux-SCTP <linux-sctp@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain
Message-Id: <1231575739.4560.1096.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
X-Mailer: Evolution 2.22.3.1 
Date: Sat, 10 Jan 2009 00:22:22 -0800
Content-Transfer-Encoding: 7bit

>From 760514837c1951258a021bf03e1111c53e4c83d7 Mon Sep 17 00:00:00 2001
From: Nicholas Bellinger <nab@linux-iscsi.org>
Date: Fri, 9 Jan 2009 23:54:22 -0800
Subject: [PATCH] [LIO-Target]: Remove extra sock_create_lite() call from kernel_accept() codepath

Recently, all v3.0 LIO-Target code using kernel socket operations was converted from
direct struct sock->ops->() function calls to use kernel_* prefixed net/socket.c wrappers.
The conversion to kernel_accept() in iscsi_target_login.c:iscsi_target_login_thread()
meant that the sock_create_lite() for *new_sock should have been removed (it was not),
and hence the *new_sock before kernel_accept() was being leaked in sock_inode_cache slab
after the kernel_* socket wrapper conversion in v3.0 code.

This patch removes the now unnecessary call to sock_create_lite() in
iscsi_target_login_thread().  Also, this patch moves the allocation of
*new_sock->file for Linux/SCTP (Stream Control Transmission Protocol) until
after kernel_accept() has succeeded.

Tested with LIO-Target/TCP and LIO-Target/SCTP on v2.6.28

Signed-off-by: Nicholas A. Bellinger <nab@linux-iscsi.org>
---
 drivers/lio-core/iscsi_target_login.c |   64 +++++++++++----------------------
 1 files changed, 21 insertions(+), 43 deletions(-)

diff --git a/drivers/lio-core/iscsi_target_login.c b/drivers/lio-core/iscsi_target_login.c
index fe1f3b9..3c429f0 100644
--- a/drivers/lio-core/iscsi_target_login.c
+++ b/drivers/lio-core/iscsi_target_login.c
@@ -933,37 +933,7 @@ get_new_sock:
 			up(&np->np_start_sem);
 		return(-1);
 	}
-	
-	if (sock_create_lite((np->np_flags & NPF_NET_IPV6) ? AF_INET6 : AF_INET,
-			sock_type, ip_proto, &new_sock) < 0) {
-		TRACE_ERROR("sock_create_lite() failed for new_sock\n");
-		if (start) {
-			up(&np->np_start_sem);
-			return(0);
-		}
-		goto get_new_sock;
-	}
-	new_sock->ops = sock->ops;
 
-	/*
-	 * The SCTP stack needs struct socket->file.
-	 */
-	if ((np->np_network_transport == ISCSI_SCTP_TCP) ||
-	    (np->np_network_transport == ISCSI_SCTP_UDP)) {
-		if (!new_sock->file) {
-			if (!(new_sock->file = kzalloc(
-					sizeof(struct file), GFP_KERNEL))) {
-				TRACE_ERROR("Unable to allocate struct file for SCTP\n");
-				if (start) {
-					up(&np->np_start_sem);
-					return(0);
-				}
-				goto get_new_sock;
-			}
-			set_sctp_conn_flag = 1;
-		}
-	}
-	
 	spin_lock_bh(&np->np_thread_lock);
 	if (np->np_thread_state == ISCSI_NP_THREAD_SHUTDOWN)
 		goto out;
@@ -987,13 +957,6 @@ get_new_sock:
 	spin_unlock_bh(&np->np_thread_lock);
 	
 	if (kernel_accept(sock, &new_sock, 0) < 0) {
-		if (new_sock) {
-			if (set_sctp_conn_flag) {
-				kfree(new_sock->file);
-				new_sock->file = NULL;
-			}
-			sock_release(new_sock);
-		}
 		if (signal_pending(current)) {
 			spin_lock_bh(&np->np_thread_lock);
 			if (np->np_thread_state == ISCSI_NP_THREAD_RESET) {
@@ -1011,6 +974,22 @@ get_new_sock:
 		}
 		goto get_new_sock;
 	}
+	/*
+	 * The SCTP stack needs struct socket->file.
+	 */
+	if ((np->np_network_transport == ISCSI_SCTP_TCP) ||
+	    (np->np_network_transport == ISCSI_SCTP_UDP)) {
+		if (!new_sock->file) {
+			printk("Allocating new_sock->file for SCTP\n");
+			if (!(new_sock->file = kzalloc(
+					sizeof(struct file), GFP_KERNEL))) {
+				TRACE_ERROR("Unable to allocate struct file for SCTP\n");
+				sock_release(new_sock);
+				goto get_new_sock;
+			}
+			set_sctp_conn_flag = 1;
+		}
+        }
 
 	iscsi_start_login_thread_timer(np);
 	
@@ -1018,13 +997,12 @@ get_new_sock:
 			sizeof(iscsi_conn_t), GFP_KERNEL))) {
 		TRACE_ERROR("Could not allocate memory for"
 			" new connection\n");
-		if (new_sock) {
-			if (set_sctp_conn_flag) {
-				kfree(new_sock->file);
-				new_sock->file = NULL;
-			}
-			sock_release(new_sock);
+		if (set_sctp_conn_flag) {
+			kfree(new_sock->file);
+			new_sock->file = NULL;
 		}
+		sock_release(new_sock);
+
 		goto get_new_sock;
 	}
 	
-- 
1.5.4.1



--=-ymexVyJVa7cVT5dJsZjv--

