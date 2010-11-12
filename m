From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 10/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 20:07:25 -0500
Message-ID: <1289524045.5167.74.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Hideaki YOSHI
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:60919 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755068Ab0KLBLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:11:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 3c95304..ba7cf7c 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2198,16 +2198,33 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 		struct unix_sock *u = unix_sk(s);
 		unix_state_lock(s);
 
-		seq_printf(seq, "%p: %08X %08X %08X %04X %02X %5lu",
-			s,
-			atomic_read(&s->sk_refcnt),
-			0,
-			s->sk_state == TCP_LISTEN ? __SO_ACCEPTCON : 0,
-			s->sk_type,
-			s->sk_socket ?
-			(s->sk_state == TCP_ESTABLISHED ? SS_CONNECTED : SS_UNCONNECTED) :
-			(s->sk_state == TCP_ESTABLISHED ? SS_CONNECTING : SS_DISCONNECTING),
-			sock_i_ino(s));
+		/* Only expose kernel addresses to privileged readers */
+		if (capable(CAP_NET_ADMIN))
+			seq_printf(seq, "%p: %08X %08X %08X %04X %02X %5lu",
+				s,
+				atomic_read(&s->sk_refcnt),
+				0,
+				s->sk_state == TCP_LISTEN ? __SO_ACCEPTCON : 0,
+				s->sk_type,
+				s->sk_socket ?
+				(s->sk_state == TCP_ESTABLISHED ?
+				SS_CONNECTED : SS_UNCONNECTED) :
+				(s->sk_state == TCP_ESTABLISHED ?
+				SS_CONNECTING : SS_DISCONNECTING),
+				sock_i_ino(s));
+		else
+			seq_printf(seq, "%d: %08X %08X %08X %04X %02X %5lu",
+				0,
+				atomic_read(&s->sk_refcnt),
+				0,
+				s->sk_state == TCP_LISTEN ? __SO_ACCEPTCON : 0,
+				s->sk_type,
+				s->sk_socket ?
+				(s->sk_state == TCP_ESTABLISHED ?
+				SS_CONNECTED : SS_UNCONNECTED) :
+				(s->sk_state == TCP_ESTABLISHED ?
+				SS_CONNECTING : SS_DISCONNECTING),
+				sock_i_ino(s));
 
 		if (u->addr) {
 			int i, len;



