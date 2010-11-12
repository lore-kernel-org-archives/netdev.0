From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 9/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 20:07:22 -0500
Message-ID: <1289524042.5167.73.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Hideaki YOSHI
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:60889 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755357Ab0KLBKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:10:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 61aacfb..9d28702 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -212,10 +212,20 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
 	sctp_for_each_hentry(epb, node, &head->chain) {
 		ep = sctp_ep(epb);
 		sk = epb->sk;
-		seq_printf(seq, "%8p %8p %-3d %-3d %-4d %-5d %5d %5lu ", ep, sk,
-			   sctp_sk(sk)->type, sk->sk_state, hash,
-			   epb->bind_addr.port,
-			   sock_i_uid(sk), sock_i_ino(sk));
+
+		/* Only expose kernel addresses to privileged readers */
+		if (capable(CAP_NET_ADMIN))
+			seq_printf(seq, "%8p %8p %-3d %-3d %-4d %-5d %5d %5lu ",
+				   ep, sk,
+				   sctp_sk(sk)->type, sk->sk_state, hash,
+				   epb->bind_addr.port,
+				   sock_i_uid(sk), sock_i_ino(sk));
+		else
+			seq_printf(seq, "%d %d %-3d %-3d %-4d %-5d %5d %5lu ",
+				   0, 0,
+				   sctp_sk(sk)->type, sk->sk_state, hash,
+				   epb->bind_addr.port,
+				   sock_i_uid(sk), sock_i_ino(sk));
 
 		sctp_seq_dump_local_addrs(seq, epb);
 		seq_printf(seq, "\n");
@@ -315,17 +325,33 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 	sctp_for_each_hentry(epb, node, &head->chain) {
 		assoc = sctp_assoc(epb);
 		sk = epb->sk;
-		seq_printf(seq,
-			   "%8p %8p %-3d %-3d %-2d %-4d "
-			   "%4d %8d %8d %7d %5lu %-5d %5d ",
-			   assoc, sk, sctp_sk(sk)->type, sk->sk_state,
-			   assoc->state, hash,
-			   assoc->assoc_id,
-			   assoc->sndbuf_used,
-			   atomic_read(&assoc->rmem_alloc),
-			   sock_i_uid(sk), sock_i_ino(sk),
-			   epb->bind_addr.port,
-			   assoc->peer.port);
+
+		/* Only expose kernel addresses to privileged readers */
+		if (capable(CAP_NET_ADMIN))
+			seq_printf(seq,
+				   "%8p %8p %-3d %-3d %-2d %-4d "
+				   "%4d %8d %8d %7d %5lu %-5d %5d ",
+				   assoc, sk, sctp_sk(sk)->type, sk->sk_state,
+				   assoc->state, hash,
+				   assoc->assoc_id,
+				   assoc->sndbuf_used,
+				   atomic_read(&assoc->rmem_alloc),
+				   sock_i_uid(sk), sock_i_ino(sk),
+				   epb->bind_addr.port,
+				   assoc->peer.port);
+		else
+			seq_printf(seq,
+				   "%d %d %-3d %-3d %-2d %-4d "
+				   "%4d %8d %8d %7d %5lu %-5d %5d ",
+				   0, 0, sctp_sk(sk)->type, sk->sk_state,
+				   assoc->state, hash,
+				   assoc->assoc_id,
+				   assoc->sndbuf_used,
+				   atomic_read(&assoc->rmem_alloc),
+				   sock_i_uid(sk), sock_i_ino(sk),
+				   epb->bind_addr.port,
+				   assoc->peer.port);
+
 		seq_printf(seq, " ");
 		sctp_seq_dump_local_addrs(seq, epb);
 		seq_printf(seq, "<-> ");



