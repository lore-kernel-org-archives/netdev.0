From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 1/2] sctp: fix stream update when processing dupcookie
Date: Tue, 23 May 2017 13:28:54 +0800
Message-ID: <132661a3448bf87e944c07860305d979bc4d5518.1495517205.git.lucien.xin@gmail.com>
References: <cover.1495517205.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33708 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933158AbdEWF3M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 01:29:12 -0400
In-Reply-To: <cover.1495517205.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1495517205.git.lucien.xin@gmail.com>
References: <cover.1495517205.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 3dbcc105d556 ("sctp: alloc stream info when initializing
asoc"), stream and stream.out info are always alloced when creating
an asoc.

So it's not correct to check !asoc->stream before updating stream
info when processing dupcookie, but would be better to check asoc
state instead.

Fixes: 3dbcc105d556 ("sctp: alloc stream info when initializing asoc")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/associola.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index a9708da..9523828 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1176,7 +1176,9 @@ void sctp_assoc_update(struct sctp_association *asoc,
 
 		asoc->ctsn_ack_point = asoc->next_tsn - 1;
 		asoc->adv_peer_ack_point = asoc->ctsn_ack_point;
-		if (!asoc->stream) {
+
+		if (sctp_state(asoc, COOKIE_WAIT)) {
+			sctp_stream_free(asoc->stream);
 			asoc->stream = new->stream;
 			new->stream = NULL;
 		}
-- 
2.1.0
