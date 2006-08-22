From: "Indan Zupancic" <indan@nul.nu>
Subject: Get rid of /proc/sys/net/unix/max_dgram_qlen
Date: Tue, 22 Aug 2006 21:45:03 +0200 (CEST)
Message-ID: <4550.81.207.0.53.1156275903.squirrel@81.207.0.53>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from helium.samage.net ([83.149.67.129]:22203 "EHLO
	helium.samage.net") by vger.kernel.org with ESMTP id S1750801AbWHVTpJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 15:45:09 -0400
Received: from amavis by helium.samage.net with scanned-ok (Exim 3.36 #1 (Debian))
	id 1GFcBL-0004Cq-00
	for <netdev@vger.kernel.org>; Tue, 22 Aug 2006 21:45:03 +0200
Received: from helium.samage.net ([127.0.0.1])
	by localhost (helium.samage.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 15911-08 for <netdev@vger.kernel.org>;
	Tue, 22 Aug 2006 21:45:03 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Here's a patch to get rid of max_dgram_qlen proc option. All it does is
slow down unix datagram packet sending, without giving the program any
control over it.

Applying it decreases code size, simplifies the code and makes poll
behaviour more logical for connected datagram sockets in regard to
POLLOUT. With the current code poll can say the socket is writable,
because it only checks the buffers, while sendmsg will fail because too
many packets are queued up already. In practice this means that a slow
reader will cause a non-blocking sender to hog the CPU.

Either this, or it should be implemented correctly, which means poll needs
to be fixed to also check for max_dgram_qlen, and maybe an ioctl should be
added to change the variable per socket.

Greetings,

Indan


diff --git a/net/unix/Makefile b/net/unix/Makefile
--- a/net/unix/Makefile	Sun Aug 06 19:00:05 2006 +0000
+++ b/net/unix/Makefile	Tue Aug 22 21:06:09 2006 +0200
@@ -5,4 +5,3 @@ obj-$(CONFIG_UNIX)	+= unix.o
 obj-$(CONFIG_UNIX)	+= unix.o

 unix-y			:= af_unix.o garbage.o
-unix-$(CONFIG_SYSCTL)	+= sysctl_net_unix.o
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
--- a/net/unix/af_unix.c	Sun Aug 06 19:00:05 2006 +0000
+++ b/net/unix/af_unix.c	Tue Aug 22 21:05:39 2006 +0200
@@ -117,8 +117,6 @@
 #include <net/checksum.h>
 #include <linux/security.h>

-int sysctl_unix_max_dgram_qlen = 10;
-
 struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
 DEFINE_SPINLOCK(unix_table_lock);
 static atomic_t unix_nr_socks = ATOMIC_INIT(0);
@@ -586,7 +584,6 @@ static struct sock * unix_create1(struct
 				&af_unix_sk_receive_queue_lock_key);

 	sk->sk_write_space	= unix_write_space;
-	sk->sk_max_ack_backlog	= sysctl_unix_max_dgram_qlen;
 	sk->sk_destruct		= unix_sock_destructor;
 	u	  = unix_sk(sk);
 	u->dentry = NULL;
@@ -1379,23 +1376,6 @@ restart:
 			goto out_unlock;
 	}

-	if (unix_peer(other) != sk &&
-	    (skb_queue_len(&other->sk_receive_queue) >
-	     other->sk_max_ack_backlog)) {
-		if (!timeo) {
-			err = -EAGAIN;
-			goto out_unlock;
-		}
-
-		timeo = unix_wait_for_peer(other, timeo);
-
-		err = sock_intr_errno(timeo);
-		if (signal_pending(current))
-			goto out_free;
-
-		goto restart;
-	}
-
 	skb_queue_tail(&other->sk_receive_queue, skb);
 	unix_state_runlock(other);
 	other->sk_data_ready(other, len);
@@ -2076,7 +2056,6 @@ static int __init af_unix_init(void)
 #ifdef CONFIG_PROC_FS
 	proc_net_fops_create("unix", 0, &unix_seq_fops);
 #endif
-	unix_sysctl_register();
 out:
 	return rc;
 }
@@ -2084,7 +2063,6 @@ static void __exit af_unix_exit(void)
 static void __exit af_unix_exit(void)
 {
 	sock_unregister(PF_UNIX);
-	unix_sysctl_unregister();
 	proc_net_remove("unix");
 	proto_unregister(&unix_proto);
 }
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c deleted file mode 100644
--- a/net/unix/sysctl_net_unix.c	Sun Aug 06 19:00:05 2006 +0000
+++ /dev/null	Thu Jan 01 00:00:00 1970 +0000
@@ -1,60 +0,0 @@
-/*
- * NET4:	Sysctl interface to net af_unix subsystem.
- *
- * Authors:	Mike Shaver.
- *
- *		This program is free software; you can redistribute it and/or - *		modify it under the terms
of the GNU General Public License
- *		as published by the Free Software Foundation; either version
- *		2 of the License, or (at your option) any later version.
- */
-
-#include <linux/mm.h>
-#include <linux/sysctl.h>
-
-#include <net/af_unix.h>
-
-static ctl_table unix_table[] = {
-	{
-		.ctl_name	= NET_UNIX_MAX_DGRAM_QLEN,
-		.procname	= "max_dgram_qlen",
-		.data		= &sysctl_unix_max_dgram_qlen,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
-	},
-	{ .ctl_name = 0 }
-};
-
-static ctl_table unix_net_table[] = {
-	{
-		.ctl_name	= NET_UNIX,
-		.procname	= "unix",
-		.mode		= 0555,
-		.child		= unix_table
-	},
-	{ .ctl_name = 0 }
-};
-
-static ctl_table unix_root_table[] = {
-	{
-		.ctl_name	= CTL_NET,
-		.procname	= "net",
-		.mode		= 0555,
-		.child		= unix_net_table
-	},
-	{ .ctl_name = 0 }
-};
-
-static struct ctl_table_header * unix_sysctl_header;
-
-void unix_sysctl_register(void)
-{
-	unix_sysctl_header = register_sysctl_table(unix_root_table, 0);
-}
-
-void unix_sysctl_unregister(void)
-{
-	unregister_sysctl_table(unix_sysctl_header);
-}
-




