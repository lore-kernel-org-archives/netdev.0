From: Ryan Hajdaj <rhajdaj@gmail.com>
Subject: [PATCH 001/001] net: Add tx_queue/rx_queue info to /proc/net/unix
Date: Sat, 28 Jan 2012 21:37:52 -0500
Message-ID: <CAB0C5qK1FGc5xhGxGzpmELbWfC6GVVxEB9Zan_nU9cC_MxMzew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38714 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab2A2Chy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 21:37:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ryan Hajdaj <rhajdaj@gmail.com>

Add tx_queue/rx_queue info to /proc/net/unix (unix_seq_show)

Signed-off-by: Ryan Hajdaj <rhajdaj@gmail.com>
Tested-by: Ryan Hajdaj <rhajdaj@gmail.com>
---
tx_queue/rx_queue info is useful in systems with multiple processes
using Unix Domain sockets to communicate, as it can be used to check
process health "at a glance".
Unit tested on Unix stream and datagram sockets.
--- linux-3.3-rc1/net/unix/af_unix.c.orig	2012-01-28 20:36:33.000000000 +0000
+++ linux-3.3-rc1/net/unix/af_unix.c	2012-01-28 19:09:18.000000000 +0000
@@ -2286,13 +2286,14 @@ static int unix_seq_show(struct seq_file

 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq, "Num       RefCount Protocol Flags    Type St "
-			 "Inode Path\n");
+			 "tx_queue rx_queue Inode Path\n");
 	else {
 		struct sock *s = v;
 		struct unix_sock *u = unix_sk(s);
 		unix_state_lock(s);

-		seq_printf(seq, "%pK: %08X %08X %08X %04X %02X %5lu",
+		seq_printf(seq,
+			"%pK: %08X %08X %08X %04X %02X %08lX %08lX %5lu",
 			s,
 			atomic_read(&s->sk_refcnt),
 			0,
@@ -2301,6 +2302,8 @@ static int unix_seq_show(struct seq_file
 			s->sk_socket ?
 			(s->sk_state == TCP_ESTABLISHED ? SS_CONNECTED : SS_UNCONNECTED) :
 			(s->sk_state == TCP_ESTABLISHED ? SS_CONNECTING : SS_DISCONNECTING),
+			unix_outq_len(s),
+			(unix_inq_len(s) < 0 ? 0 : unix_inq_len(s)),
 			sock_i_ino(s));

 		if (u->addr) {
