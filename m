From: Thomas Dreibholz <dreibh@iem.uni-due.de>
Subject: [PATCH] net: SCTP NULL-pointer dereference problem description and fix
Date: Wed, 15 Sep 2010 10:03:11 +0200
Message-ID: <201009151003.17407.dreibh@iem.uni-due.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Martin Becke <martin.becke@uni-due.de>
To: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.uni-due.de ([132.252.185.19]:39596 "EHLO
	mailout.uni-due.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932Ab0IOISE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 04:18:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_assoc_update_retran_path() in net/sctp/associola.c may dereference a 
NULL-pointer when compiled with SCTP_DEBUG option: t will be NULL if there is 
no usable path for retransmission. SCTP_DEBUG_PRINTK_IPADDR() makes an access 
to t->ipaddr.v4.sin_port, without checking t before. t==NULL => oops.

The patch below against 2.6.36-rc4 (git repository) simply ensures that t is 
checked for not being set to NULL before calling SCTP_DEBUG_PRINTK_IPADDR().


Signed-off-by: Thomas Dreibholz <dreibh@iem.uni-due.de>
---
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index e41feff..b2688a4 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1321,15 +1321,15 @@ void sctp_assoc_update_retran_path(struct 
sctp_association *asoc)
 		}
 	}

-	if (t)
+	if (t) {
 		asoc->peer.retran_path = t;
-
-	SCTP_DEBUG_PRINTK_IPADDR("sctp_assoc_update_retran_path:association"
-				 " %p addr: ",
-				 " port: %d\n",
-				 asoc,
-				 (&t->ipaddr),
-				 ntohs(t->ipaddr.v4.sin_port));
+		SCTP_DEBUG_PRINTK_IPADDR("sctp_assoc_update_retran_path:association"
+					 " %p addr: ",
+					 " port: %d\n",
+					 asoc,
+					 (&t->ipaddr),
+					 ntohs(t->ipaddr.v4.sin_port));
+	}
 }

 /* Choose the transport for sending retransmit packet.  */
