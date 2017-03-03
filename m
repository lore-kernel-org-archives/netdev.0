From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: change to save MSG_MORE flag into assoc
Date: Fri,  3 Mar 2017 14:23:55 +0800
Message-ID: <ba64767f352e56cfe694af89445fe155cd431cd0.1488522235.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        David Laight <david.laight@aculab.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33880 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751356AbdCCGYI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 01:24:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight noticed the support for MSG_MORE with datamsg->force_day
didn't really work as we expected, as the first msg with MSG_MORE set
would always block the following chunks' dequeuing.

This Patch is to rewrite it by saving the MSG_MORE flag into assoc as
Divid Laight suggested.

asoc->force_delay is used to save MSG_MORE flag before a msg is sent.
Once this msg is queued, asoc->force_delay is set back to 0, so that
it will not affect other places flushing out queue.

asoc->force_delay works as a 'local param' here as the msg sending is
under protection of sock lock.  It would make sctp's MSG_MORE work as
tcp's.

Fixes: 4ea0c32f5f42 ("sctp: add support for MSG_MORE")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h | 2 +-
 net/sctp/output.c          | 2 +-
 net/sctp/socket.c          | 3 ++-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index a244db5..3378c02 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -497,7 +497,6 @@ struct sctp_datamsg {
 	/* Did the messenge fail to send? */
 	int send_error;
 	u8 send_failed:1,
-	   force_delay:1,
 	   can_delay;	    /* should this message be Nagle delayed */
 };
 
@@ -1876,6 +1875,7 @@ struct sctp_association {
 
 	__u8 need_ecne:1,	/* Need to send an ECNE Chunk? */
 	     temp:1,		/* Is it a temporary association? */
+	     force_delay:1,
 	     prsctp_enable:1,
 	     reconf_enable:1;
 
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 85406d5..5f6acac 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -705,7 +705,7 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
 	 */
 
 	if ((sctp_sk(asoc->base.sk)->nodelay || inflight == 0) &&
-	    !chunk->msg->force_delay)
+	    !asoc->force_delay)
 		/* Nothing unacked */
 		return SCTP_XMIT_OK;
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 465a9c8..d62cf9e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1964,7 +1964,7 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 		err = PTR_ERR(datamsg);
 		goto out_free;
 	}
-	datamsg->force_delay = !!(msg->msg_flags & MSG_MORE);
+	asoc->force_delay = !!(msg->msg_flags & MSG_MORE);
 
 	/* Now send the (possibly) fragmented message. */
 	list_for_each_entry(chunk, &datamsg->chunks, frag_list) {
@@ -1982,6 +1982,7 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 	 * breaks.
 	 */
 	err = sctp_primitive_SEND(net, asoc, datamsg);
+	asoc->force_delay = 0;
 	/* Did the lower layer accept the chunk? */
 	if (err) {
 		sctp_datamsg_free(datamsg);
-- 
2.1.0
