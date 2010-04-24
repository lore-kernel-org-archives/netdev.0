From: Dan Carpenter <error27@gmail.com>
Subject: [patch v2] sctp: cleanup: remove duplicate assignment
Date: Sat, 24 Apr 2010 19:19:40 +0200
Message-ID: <20100424171805.GO29093@bicker>
References: <20100423115906.GE29093@bicker> <4BD1AE9D.6090807@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Chris Dischino <cdischino@sonusnet.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45704 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876Ab0DXRUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 13:20:36 -0400
Content-Disposition: inline
In-Reply-To: <4BD1AE9D.6090807@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This assignment isn't needed because we did it earlier already.

Also another reason to delete the assignment is because it triggers a
Smatch warning about checking for NULL pointers after a dereference.

Reported-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Dan Carpenter <error27@gmail.com>
---
Thanks Vlad.  I came so close to seeing that myself if only I had openned
my eyes a tiny bit more.  :P

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 17cb400..33aed1c 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -419,10 +419,17 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	if (!retval)
 		goto nomem_chunk;
 
-	/* Per the advice in RFC 2960 6.4, send this reply to
-	 * the source of the INIT packet.
+	/* RFC 2960 6.4 Multi-homed SCTP Endpoints
+	 *
+	 * An endpoint SHOULD transmit reply chunks (e.g., SACK,
+	 * HEARTBEAT ACK, * etc.) to the same destination transport
+	 * address from which it received the DATA or control chunk
+	 * to which it is replying.
+	 *
+	 * [INIT ACK back to where the INIT came from.]
 	 */
 	retval->transport = chunk->transport;
+
 	retval->subh.init_hdr =
 		sctp_addto_chunk(retval, sizeof(initack), &initack);
 	retval->param_hdr.v = sctp_addto_chunk(retval, addrs_len, addrs.v);
@@ -461,18 +468,6 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	/* We need to remove the const qualifier at this point.  */
 	retval->asoc = (struct sctp_association *) asoc;
 
-	/* RFC 2960 6.4 Multi-homed SCTP Endpoints
-	 *
-	 * An endpoint SHOULD transmit reply chunks (e.g., SACK,
-	 * HEARTBEAT ACK, * etc.) to the same destination transport
-	 * address from which it received the DATA or control chunk
-	 * to which it is replying.
-	 *
-	 * [INIT ACK back to where the INIT came from.]
-	 */
-	if (chunk)
-		retval->transport = chunk->transport;
-
 nomem_chunk:
 	kfree(cookie);
 nomem_cookie:
