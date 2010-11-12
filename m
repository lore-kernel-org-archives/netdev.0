From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 2/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 20:06:59 -0500
Message-ID: <1289524019.5167.66.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Hideaki YOSHI
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:60655 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755156Ab0KLBH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:07:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 08ffe9e..5960ad7 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -165,9 +165,16 @@ static int bcm_proc_show(struct seq_file *m, void *v)
 	struct bcm_sock *bo = bcm_sk(sk);
 	struct bcm_op *op;
 
-	seq_printf(m, ">>> socket %p", sk->sk_socket);
-	seq_printf(m, " / sk %p", sk);
-	seq_printf(m, " / bo %p", bo);
+	/* Only expose kernel addresses to privileged readers */
+	if (capable(CAP_NET_ADMIN))
+		seq_printf(m, ">>> socket %p", sk->sk_socket);
+		seq_printf(m, " / sk %p", sk);
+		seq_printf(m, " / bo %p", bo);
+	else
+		seq_printf(m, ">>> socket %lu", sock_i_ino(sk));
+		seq_printf(m, " / sk %d", 0);
+		seq_printf(m, " / bo %d", 0);
+
 	seq_printf(m, " / dropped %lu", bo->dropped_usr_msgs);
 	seq_printf(m, " / bound %s", bcm_proc_getifname(ifname, bo->ifindex));
 	seq_printf(m, " <<<\n");
@@ -1520,8 +1527,8 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 	bo->bound = 1;
 
 	if (proc_dir) {
-		/* unique socket address as filename */
-		sprintf(bo->procname, "%p", sock);
+		/* unique socket inode as filename */
+		sprintf(bo->procname, "%lx", sock_i_ino(sk));
 		bo->bcm_proc_read = proc_create_data(bo->procname, 0644,
 						     proc_dir,
 						     &bcm_proc_fops, sk);



