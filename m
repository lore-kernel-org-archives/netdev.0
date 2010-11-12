From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 8/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 20:07:19 -0500
Message-ID: <1289524039.5167.72.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Hideaki YOSHI
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:60859 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757288Ab0KLBKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:10:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 25f746d..2ca2a87 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -631,14 +631,25 @@ static int pn_sock_seq_show(struct seq_file *seq, void *v)
 		struct sock *sk = v;
 		struct pn_sock *pn = pn_sk(sk);
 
-		seq_printf(seq, "%2d %04X:%04X:%02X %02X %08X:%08X %5d %lu "
-			"%d %p %d%n",
-			sk->sk_protocol, pn->sobject, 0, pn->resource,
-			sk->sk_state,
-			sk_wmem_alloc_get(sk), sk_rmem_alloc_get(sk),
-			sock_i_uid(sk), sock_i_ino(sk),
-			atomic_read(&sk->sk_refcnt), sk,
-			atomic_read(&sk->sk_drops), &len);
+		/* Only expose kernel addresses to privileged readers */
+		if (capable(CAP_NET_ADMIN))
+			seq_printf(seq, "%2d %04X:%04X:%02X %02X %08X:%08X "
+				"%5d %lu %d %p %d%n",
+				sk->sk_protocol, pn->sobject, 0, pn->resource,
+				sk->sk_state,
+				sk_wmem_alloc_get(sk), sk_rmem_alloc_get(sk),
+				sock_i_uid(sk), sock_i_ino(sk),
+				atomic_read(&sk->sk_refcnt), sk,
+				atomic_read(&sk->sk_drops), &len);
+		else
+			seq_printf(seq, "%2d %04X:%04X:%02X %02X %08X:%08X "
+				"%5d %lu %d %d %d%n",
+				sk->sk_protocol, pn->sobject, 0, pn->resource,
+				sk->sk_state,
+				sk_wmem_alloc_get(sk), sk_rmem_alloc_get(sk),
+				sock_i_uid(sk), sock_i_ino(sk),
+				atomic_read(&sk->sk_refcnt), 0,
+				atomic_read(&sk->sk_drops), &len);
 	}
 	seq_printf(seq, "%*s\n", 127 - len, "");
 	return 0;



