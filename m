From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/5] llc: allow datagram recvmsg
Date: Tue, 23 May 2006 17:04:15 -0700
Message-ID: <20060524000529.852155000@localhost.localdomain>
References: <20060524000414.052569000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:8837 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932435AbWEXAFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 20:05:49 -0400
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Content-Disposition: inline; filename=llc-dgram-recv.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

LLC receive is broken for SOCK_DGRAM.
If an application does recv() on a datagram socket and there
is no data present, don't return "not connected". Instead, just
do normal datagram semantics.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
--- llc.orig/net/llc/af_llc.c
+++ llc/net/llc/af_llc.c
@@ -674,7 +674,7 @@ static int llc_ui_recvmsg(struct kiocb *
 
 	lock_sock(sk);
 	copied = -ENOTCONN;
-	if (sk->sk_state == TCP_LISTEN)
+	if (unlikely(sk->sk_type == SOCK_STREAM && sk->sk_state == TCP_LISTEN))
 		goto out;
 
 	timeo = sock_rcvtimeo(sk, nonblock);
@@ -733,7 +733,7 @@ static int llc_ui_recvmsg(struct kiocb *
 			if (sk->sk_shutdown & RCV_SHUTDOWN)
 				break;
 
-			if (sk->sk_state == TCP_CLOSE) {
+			if (sk->sk_type == SOCK_STREAM && sk->sk_state == TCP_CLOSE) {
 				if (!sock_flag(sk, SOCK_DONE)) {
 					/*
 					 * This occurs when user tries to read

--

