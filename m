From: Florian Zumbiehl <florz@florz.de>
Subject: [RESEND][PATCH 3/3] PPPoE: move lock_sock() in pppoe_sendmsg() to the right location
Date: Sun, 29 Jul 2007 08:04:46 +0200
Message-ID: <20070729060446.GC27573@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: mostrows@earthlink.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [77.10.166.84] ([77.10.166.84]:33225 "EHLO
	rain.florz.dyndns.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1759555AbXG2GgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 02:36:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

and the last one for now: Acquire the sock lock in pppoe_sendmsg()
before accessing the sock - and in particular avoid releasing the lock
even though it hasn't been acquired.

Florian

---------------------------------------------------------------------------
Signed-off-by: Florian Zumbiehl <florz@florz.de>

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 9554924..eef8a5b 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -779,6 +779,7 @@ static int pppoe_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct net_device *dev;
 	char *start;
 
+	lock_sock(sk);
 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED)) {
 		error = -ENOTCONN;
 		goto end;
@@ -789,8 +790,6 @@ static int pppoe_sendmsg(struct kiocb *iocb, struct socket *sock,
 	hdr.code = 0;
 	hdr.sid = po->num;
 
-	lock_sock(sk);
-
 	dev = po->pppoe_dev;
 
 	error = -EMSGSIZE;
