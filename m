From: Florian Zumbiehl <florz@florz.de>
Subject: [PATCH 3/3] PPPoE: move lock_sock() in pppoe_sendmsg() to the right location
Date: Tue, 13 Mar 2007 15:52:55 +0100
Message-ID: <20070313145255.GP17712@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: mostrows@earthlink.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from odnb-d9bbf9ce.pool.mediaWays.net ([217.187.249.206]:2796 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030741AbXCMPDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 11:03:25 -0400
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
