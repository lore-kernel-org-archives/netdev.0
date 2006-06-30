From: Ralf Baechle <ralf@linux-mips.org>
Subject: [ROSE] Try all routes when establishing a ROSE connections.
Date: Fri, 30 Jun 2006 14:53:16 +0100
Message-ID: <20060630135316.GA12943@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:214 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S932189AbWF3NxR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 09:53:17 -0400
Received: from localhost.localdomain ([127.0.0.1]:45032 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S3686805AbWF3NxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 14:53:16 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Jean-Paul F6FBB:

ROSE will only try to establish a route using the first route in its
routing table.  Fix to iterate through all additional routes if a
connection attempt has failed.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
 net/rose/af_rose.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

Index: linux-net/net/rose/af_rose.c
===================================================================
--- linux-net.orig/net/rose/af_rose.c	2006-06-30 14:46:33.000000000 +0100
+++ linux-net/net/rose/af_rose.c	2006-06-30 14:49:03.000000000 +0100
@@ -753,7 +753,7 @@ static int rose_connect(struct socket *s
 
 		rose_insert_socket(sk);		/* Finish the bind */
 	}
-
+rose_try_next_neigh:
 	rose->dest_addr   = addr->srose_addr;
 	rose->dest_call   = addr->srose_call;
 	rose->rand        = ((long)rose & 0xFFFF) + rose->lci;
@@ -811,6 +811,11 @@ static int rose_connect(struct socket *s
 	}
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
+	/* Try next neighbour */
+		rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause, &diagnostic);
+		if (rose->neighbour)
+			goto rose_try_next_neigh;
+	/* No more neighbour */
 		sock->state = SS_UNCONNECTED;
 		return sock_error(sk);	/* Always set at this point */
 	}
