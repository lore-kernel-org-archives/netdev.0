From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: sctp should release assoc when sctp_make_abort_user return NULL in sctp_close
Date: Thu, 17 Dec 2015 22:30:52 +0800
Message-ID: <48cc5cc3af81404dffc6121f075c05e6b8c5171c.1450362652.git.lucien.xin@gmail.com>
Cc: marcelo.leitner@gmail.com, vyasevic@redhat.com, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33432 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755730AbbLQOa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 09:30:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In sctp_close, sctp_make_abort_user may return NULL because of memory
allocation failure. If this happens, it will bypass any state change
and never free the assoc. The assoc has no chance to be freed and it
will be kept in memory with the state it had even after the socket is
closed by sctp_close().

So if sctp_make_abort_user fails to allocate memory, we should just
free the asoc, as there isn't much else that we can do.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/socket.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9b6cc6d..267b8f8 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1513,8 +1513,12 @@ static void sctp_close(struct sock *sk, long timeout)
 			struct sctp_chunk *chunk;
 
 			chunk = sctp_make_abort_user(asoc, NULL, 0);
-			if (chunk)
+			if (chunk) {
 				sctp_primitive_ABORT(net, asoc, chunk);
+			} else {
+				sctp_unhash_established(asoc);
+				sctp_association_free(asoc);
+			}
 		} else
 			sctp_primitive_SHUTDOWN(net, asoc, NULL);
 	}
-- 
2.1.0
