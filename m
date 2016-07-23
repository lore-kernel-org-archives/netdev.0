From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next] sctp: also point GSO head_skb to the sk when it's available
Date: Sat, 23 Jul 2016 00:33:44 -0300
Message-ID: <aa37c8d65d8d304be73f6c237202760978ec124f.1469244494.git.marcelo.leitner@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56534 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796AbcGWDeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 23:34:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The head skb for GSO packets won't travel through the inner depths of
SCTP stack as it doesn't contain any chunks on it. That means skb->sk
doesn't get set and then when sctp_recvmsg() calls
sctp_inet6_skb_msgname() on the head_skb it panics, as this last needs
to check flags at the socket (sp->v4mapped).

The fix is to initialize skb->sk for th head skb once we are able to do
it. That is, when the first chunk is processed.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/ulpevent.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index f6219b164b42c821c3e6f626731e97dd712c957c..1bc4f71aaba860776a0a6e4b664ef1c3a0f8af37 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -91,6 +91,7 @@ int sctp_ulpevent_is_notification(const struct sctp_ulpevent *event)
 static inline void sctp_ulpevent_set_owner(struct sctp_ulpevent *event,
 					   const struct sctp_association *asoc)
 {
+	struct sctp_chunk *chunk = event->chunk;
 	struct sk_buff *skb;
 
 	/* Cast away the const, as we are just wanting to
@@ -101,6 +102,8 @@ static inline void sctp_ulpevent_set_owner(struct sctp_ulpevent *event,
 	event->asoc = (struct sctp_association *)asoc;
 	atomic_add(event->rmem_len, &event->asoc->rmem_alloc);
 	sctp_skb_set_owner_r(skb, asoc->base.sk);
+	if (chunk && chunk->head_skb && !chunk->head_skb->sk)
+		chunk->head_skb->sk = asoc->base.sk;
 }
 
 /* A simple destructor to give up the reference to the association. */
-- 
2.7.4
