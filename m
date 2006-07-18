From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2/6][SCTP]: Unhash the endpoint in sctp_endpoint_free().
Date: Mon, 17 Jul 2006 17:25:25 -0700
Message-ID: <1153182325.4282.44.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:6329 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751263AbWGRA16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 20:27:58 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I0RvdW016762
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:27:58 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I0RvLR288188
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:27:57 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I0RvCw026691
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:27:57 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Unhash the endpoint in sctp_endpoint_free().

This prevents a race between the close of a socket and receive of an incoming
packet.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/endpointola.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 67bd530..ffda1d6 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -158,6 +158,12 @@ void sctp_endpoint_add_asoc(struct sctp_
 void sctp_endpoint_free(struct sctp_endpoint *ep)
 {
 	ep->base.dead = 1;
+
+	ep->base.sk->sk_state = SCTP_SS_CLOSED;
+
+	/* Unlink this endpoint, so we can't find it again! */
+	sctp_unhash_endpoint(ep);
+
 	sctp_endpoint_put(ep);
 }
 
@@ -166,11 +172,6 @@ static void sctp_endpoint_destroy(struct
 {
 	SCTP_ASSERT(ep->base.dead, "Endpoint is not dead", return);
 
-	ep->base.sk->sk_state = SCTP_SS_CLOSED;
-
-	/* Unlink this endpoint, so we can't find it again! */
-	sctp_unhash_endpoint(ep);
-
 	/* Free up the HMAC transform. */
 	sctp_crypto_free_tfm(sctp_sk(ep->base.sk)->hmac);
 


