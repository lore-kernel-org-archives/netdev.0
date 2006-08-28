From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 1/1][SCTP]: Fix sctp_primitive_ABORT() call in sctp_close()
Date: Mon, 28 Aug 2006 12:11:36 -0700
Message-ID: <1156792296.11959.20.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:11917 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751347AbWH1TLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 15:11:39 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7SJBcVI021696
	for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 15:11:38 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7SJBcHE240238
	for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 15:11:38 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7SJBbvQ012759
	for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 15:11:38 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

The recent SCTP CVE fix that went into 2.6.18 changed 
sctp_primitive_ABORT() callers to create an ABORT chunk
and pass it as an arg instead of struct msghdr.
While submitting this fix, i missed the other location in
sctp_close() where this is called.

Please apply this patch to 2.6.18 and it should also go
into the stable series.

Thanks
Sridhar

[SCTP]: Fix sctp_primitive_ABORT() call in sctp_close().

With the recent fix, the callers of sctp_primitive_ABORT()
need to create an ABORT chunk and pass it as an argument rather
than msghdr that was passed earlier.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index fde3f55..dab1594 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1289,9 +1289,13 @@ SCTP_STATIC void sctp_close(struct sock 
 			}
 		}
 
-		if (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime)
-			sctp_primitive_ABORT(asoc, NULL);
-		else
+		if (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime) {
+			struct sctp_chunk *chunk;
+
+			chunk = sctp_make_abort_user(asoc, NULL, 0);
+			if (chunk)
+				sctp_primitive_ABORT(asoc, chunk);
+		} else
 			sctp_primitive_SHUTDOWN(asoc, NULL);
 	}
 

