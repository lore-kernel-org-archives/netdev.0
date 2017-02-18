From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 2/2] sctp: add support for MSG_MORE
Date: Sun, 19 Feb 2017 01:52:46 +0800
Message-ID: <d6f2835b0bd655a563896e86648cbd9b4e01374e.1487440272.git.lucien.xin@gmail.com>
References: <cover.1487440272.git.lucien.xin@gmail.com>
 <1830885841c7bdd55510396300092f669896f2b0.1487440272.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net,
        David Laight <david.laight@aculab.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33540 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753277AbdBRR7T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 12:59:19 -0500
In-Reply-To: <1830885841c7bdd55510396300092f669896f2b0.1487440272.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1487440272.git.lucien.xin@gmail.com>
References: <cover.1487440272.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add support for MSG_MORE on sctp.

It adds force_delay in sctp_datamsg to save MSG_MORE, and sets it after
creating datamsg according to the send flag. sctp_packet_can_append_data
then uses it to decide if the chunks of this msg will be sent at once or
delay it.

Note that unlike [1], this patch saves MSG_MORE in datamsg, instead of
in assoc. As sctp enqueues the chunks first, then dequeue them one by
one. If it's saved in assoc,the current msg's send flag (MSG_MORE) may
affect other chunks' bundling.

Since last patch, sctp flush out queue once assoc state falls into
SHUTDOWN_PENDING, the close block problem mentioned in [1] has been
solved as well.

[1] https://patchwork.ozlabs.org/patch/372404/

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h | 1 +
 net/sctp/output.c          | 9 +++------
 net/sctp/socket.c          | 1 +
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 387c802..a244db5 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -497,6 +497,7 @@ struct sctp_datamsg {
 	/* Did the messenge fail to send? */
 	int send_error;
 	u8 send_failed:1,
+	   force_delay:1,
 	   can_delay;	    /* should this message be Nagle delayed */
 };
 
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 814eac0..85406d5 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -704,18 +704,15 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
 	 * unacknowledged.
 	 */
 
-	if (sctp_sk(asoc->base.sk)->nodelay)
-		/* Nagle disabled */
+	if ((sctp_sk(asoc->base.sk)->nodelay || inflight == 0) &&
+	    !chunk->msg->force_delay)
+		/* Nothing unacked */
 		return SCTP_XMIT_OK;
 
 	if (!sctp_packet_empty(packet))
 		/* Append to packet */
 		return SCTP_XMIT_OK;
 
-	if (inflight == 0)
-		/* Nothing unacked */
-		return SCTP_XMIT_OK;
-
 	if (!sctp_state(asoc, ESTABLISHED))
 		return SCTP_XMIT_OK;
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 75f35ce..b532148 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1964,6 +1964,7 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 		err = PTR_ERR(datamsg);
 		goto out_free;
 	}
+	datamsg->force_delay = !!(msg->msg_flags & MSG_MORE);
 
 	/* Now send the (possibly) fragmented message. */
 	list_for_each_entry(chunk, &datamsg->chunks, frag_list) {
-- 
2.1.0
