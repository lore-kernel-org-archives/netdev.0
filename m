From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 1/2][L2TP]: Fix possible WARN_ON from socket code when UDP socket is closed
Date: Wed, 4 Jun 2008 21:56:44 +0100
Message-ID: <200806042056.m54KuiI7003060@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:42672 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758655AbYFDU4t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 16:56:49 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <jchapman@katalix.com>)
	id 1K407Z-0001R3-3C
	for netdev@vger.kernel.org; Wed, 04 Jun 2008 16:02:13 -0500
Received: from quickie.katalix.com (localhost.localdomain [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id m54KuiTd003062
	for <netdev@vger.kernel.org>; Wed, 4 Jun 2008 21:56:44 +0100
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id m54KuiI7003060
	for netdev@vger.kernel.org; Wed, 4 Jun 2008 21:56:44 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an L2TP daemon closes a tunnel socket while packets are queued in
the tunnel's reorder queue, a kernel warning is logged because the
socket is closed while skbs are still referencing it. The fix is to
purge the queue in the socket's release handler.

WARNING: at include/net/sock.h:351 udp_lib_unhash+0x41/0x68()
Pid: 12998, comm: openl2tpd Not tainted 2.6.25 #8
 [<c0423c58>] warn_on_slowpath+0x41/0x51
 [<c05d33a7>] udp_lib_unhash+0x41/0x68
 [<c059424d>] sk_common_release+0x23/0x90
 [<c05d16be>] udp_lib_close+0x8/0xa
 [<c05d8684>] inet_release+0x42/0x48
 [<c0592599>] sock_release+0x14/0x60
 [<c059299f>] sock_close+0x29/0x30
 [<c046ef52>] __fput+0xad/0x15b
 [<c046f1d9>] fput+0x17/0x19
 [<c046c8c4>] filp_close+0x50/0x5a
 [<c046da06>] sys_close+0x69/0x9f
 [<c04048ce>] syscall_call+0x7/0xb

Signed-off-by: James Chapman <jchapman@katalix.com> 

Index: linux-2.6.25/drivers/net/pppol2tp.c
===================================================================
--- linux-2.6.25.orig/drivers/net/pppol2tp.c
+++ linux-2.6.25/drivers/net/pppol2tp.c
@@ -1318,6 +1318,7 @@ out:
 static int pppol2tp_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
+	struct pppol2tp_session *session;
 	int error;
 
 	if (!sk)
@@ -1335,9 +1336,18 @@ static int pppol2tp_release(struct socke
 	sock_orphan(sk);
 	sock->sk = NULL;
 
+	session = pppol2tp_sock_to_session(sk);
+
 	/* Purge any queued data */
 	skb_queue_purge(&sk->sk_receive_queue);
 	skb_queue_purge(&sk->sk_write_queue);
+	if (session != NULL) {
+		struct sk_buff *skb;
+		while ((skb = skb_dequeue(&session->reorder_q))) {
+			kfree_skb(skb);
+			sock_put(sk);
+		}
+	}
 
 	release_sock(sk);
 
