From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] Zero-length write() does not generate a datagram on connected
 socket
Date: Mon, 24 Sep 2007 15:34:35 -0700
Message-ID: <20070924153435.14249225@freepuppy.rosehill>
References: <bug-5731-100@http.bugzilla.kernel.org/>
	<20070922094432.E9BEA108010@picon.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33378 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754511AbXIXWfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 18:35:12 -0400
Received: from freepuppy.rosehill (069-064-229-129.pdx.net [69.64.229.129])
	(authenticated bits=0)
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l8OMYt4D016528
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 24 Sep 2007 15:35:07 -0700
In-Reply-To: <20070922094432.E9BEA108010@picon.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bug http://bugzilla.kernel.org/show_bug.cgi?id=5731
describes an issue where write() can't be used to generate a zero-length
datagram (but send, and sendto do work).

I think the following is needed:

--- a/net/socket.c	2007-08-20 09:54:28.000000000 -0700
+++ b/net/socket.c	2007-09-24 15:31:25.000000000 -0700
@@ -777,8 +777,11 @@ static ssize_t sock_aio_write(struct kio
 	if (pos != 0)
 		return -ESPIPE;
 
-	if (iocb->ki_left == 0)	/* Match SYS5 behaviour */
-		return 0;
+	if (unlikely(iocb->ki_left == 0)) {
+		struct socket *sock = iocb->ki_filp->private_data;
+		if (sock->type == SOCK_STREAM)
+			return 0;
+	}
 
 	x = alloc_sock_iocb(iocb, &siocb);
 	if (!x)
