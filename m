From: David Howells <dhowells@redhat.com>
Subject: [PATCH 10/13] rxrpc: rxkad: The version number in the response
 should be net byte order
Date: Fri, 04 Mar 2016 16:38:15 +0000
Message-ID: <20160304163815.31057.23078.stgit@warthog.procyon.org.uk>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38907 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932859AbcCDQiR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 11:38:17 -0500
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The version number rxkad places in the response should be network byte
order.

Whilst we're at it, rearrange the code to be more readable.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/rxkad.c |   17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 0f27524536bd..ca746f382517 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -787,10 +787,15 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	/* build the response packet */
 	memset(&resp, 0, sizeof(resp));
 
-	resp.version = RXKAD_VERSION;
-	resp.encrypted.epoch = htonl(conn->epoch);
-	resp.encrypted.cid = htonl(conn->cid);
-	resp.encrypted.securityIndex = htonl(conn->security_ix);
+	resp.version			= htonl(RXKAD_VERSION);
+	resp.encrypted.epoch		= htonl(conn->epoch);
+	resp.encrypted.cid		= htonl(conn->cid);
+	resp.encrypted.securityIndex	= htonl(conn->security_ix);
+	resp.encrypted.inc_nonce	= htonl(nonce + 1);
+	resp.encrypted.level		= htonl(conn->security_level);
+	resp.kvno			= htonl(token->kad->kvno);
+	resp.ticket_len			= htonl(token->kad->ticket_len);
+
 	resp.encrypted.call_id[0] =
 		htonl(conn->channels[0] ? conn->channels[0]->call_id : 0);
 	resp.encrypted.call_id[1] =
@@ -799,10 +804,6 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 		htonl(conn->channels[2] ? conn->channels[2]->call_id : 0);
 	resp.encrypted.call_id[3] =
 		htonl(conn->channels[3] ? conn->channels[3]->call_id : 0);
-	resp.encrypted.inc_nonce = htonl(nonce + 1);
-	resp.encrypted.level = htonl(conn->security_level);
-	resp.kvno = htonl(token->kad->kvno);
-	resp.ticket_len = htonl(token->kad->ticket_len);
 
 	/* calculate the response checksum and then do the encryption */
 	rxkad_calc_response_checksum(&resp);
