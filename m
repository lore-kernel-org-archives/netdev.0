From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 2/2] sctp: set new_asoc temp when processing dupcookie
Date: Tue, 23 May 2017 13:28:55 +0800
Message-ID: <dc8c3388836508aea0d4c834fd33a1fff9085532.1495517205.git.lucien.xin@gmail.com>
References: <cover.1495517205.git.lucien.xin@gmail.com>
 <132661a3448bf87e944c07860305d979bc4d5518.1495517205.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33785 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933158AbdEWF3U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 01:29:20 -0400
In-Reply-To: <132661a3448bf87e944c07860305d979bc4d5518.1495517205.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1495517205.git.lucien.xin@gmail.com>
References: <cover.1495517205.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After sctp changed to use transport hashtable, a transport would be
added into global hashtable when adding the peer to an asoc, then
the asoc can be got by searching the transport in the hashtbale.

The problem is when processing dupcookie in sctp_sf_do_5_2_4_dupcook,
a new asoc would be created. A peer with the same addr and port as
the one in the old asoc might be added into the new asoc, but fail
to be added into the hashtable, as they also belong to the same sk.

It causes that sctp's dupcookie processing can not really work.

Since the new asoc will be freed after copying it's information to
the old asoc, it's more like a temp asoc. So this patch is to fix
it by setting it as a temp asoc to avoid adding it's any transport
into the hashtable and also avoid allocing assoc_id.

An extra thing it has to do is to also alloc stream info for any
temp asoc, as sctp dupcookie process needs it to update old asoc.
But I don't think it would hurt something, as a temp asoc would
always be freed after finishing processing cookie echo packet.

Reported-by: Jianwen Ji <jiji@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sm_make_chunk.c | 13 ++++---------
 net/sctp/sm_statefuns.c  |  3 +++
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 8a08f13..92e332e 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2454,16 +2454,11 @@ int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 	 * stream sequence number shall be set to 0.
 	 */
 
-	/* Allocate storage for the negotiated streams if it is not a temporary
-	 * association.
-	 */
-	if (!asoc->temp) {
-		if (sctp_stream_init(asoc, gfp))
-			goto clean_up;
+	if (sctp_stream_init(asoc, gfp))
+		goto clean_up;
 
-		if (sctp_assoc_set_id(asoc, gfp))
-			goto clean_up;
-	}
+	if (!asoc->temp && sctp_assoc_set_id(asoc, gfp))
+		goto clean_up;
 
 	/* ADDIP Section 4.1 ASCONF Chunk Procedures
 	 *
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 4f5e6cf..f863b55 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2088,6 +2088,9 @@ sctp_disposition_t sctp_sf_do_5_2_4_dupcook(struct net *net,
 		}
 	}
 
+	/* Set temp so that it won't be added into hashtable */
+	new_asoc->temp = 1;
+
 	/* Compare the tie_tag in cookie with the verification tag of
 	 * current association.
 	 */
-- 
2.1.0
