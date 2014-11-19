From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: sctp: keep owned chunk in destructor_arg instead of skb->cb
Date: Thu, 20 Nov 2014 00:21:06 +0100
Message-ID: <1416439266-11396-1-git-send-email-dborkman@redhat.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46689 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756738AbaKSXVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 18:21:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's just silly to hold the skb destructor argument around inside
skb->cb[] as we currently do in SCTP.

Though this has been around forever, I'm inclined to say that prior
to 4c3a5bdae293 ("sctp: Don't charge for data in sndbuf again when
transmitting packet") this may well have caused issues as doing so
violates the cb[] usage accross layers; before 4c3a5bdae293-times,
we have charged twice for data, and when destructor kicks in, cb[]
could have been overwritten already by someone else.

Nowadays, we're sort of cheating on data accounting in the sense
that due to commit 4c3a5bdae293, we orphan the skb already in the
SCTP output path, and use a different destructor only to make sure
the sk doesn't vanish on skb destruction time. Thus, cb[] is still
valid here as we operate within the SCTP layer. It's actually a big
candidate for future rework, imho.

Anyhow, lets keep the chunk in destructor_arg, as this is the actual
purpose for it so that in future, we don't run into trouble.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/socket.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 2120292..85e0b65 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -162,7 +162,7 @@ static inline void sctp_set_owner_w(struct sctp_chunk *chunk)
 
 	chunk->skb->destructor = sctp_wfree;
 	/* Save the chunk pointer in skb for sctp_wfree to use later.  */
-	*((struct sctp_chunk **)(chunk->skb->cb)) = chunk;
+	skb_shinfo(chunk->skb)->destructor_arg = chunk;
 
 	asoc->sndbuf_used += SCTP_DATA_SNDSIZE(chunk) +
 				sizeof(struct sk_buff) +
@@ -6870,14 +6870,10 @@ static void sctp_wake_up_waiters(struct sock *sk,
  */
 static void sctp_wfree(struct sk_buff *skb)
 {
-	struct sctp_association *asoc;
-	struct sctp_chunk *chunk;
-	struct sock *sk;
+	struct sctp_chunk *chunk = skb_shinfo(skb)->destructor_arg;
+	struct sctp_association *asoc = chunk->asoc;
+	struct sock *sk = asoc->base.sk;
 
-	/* Get the saved chunk pointer.  */
-	chunk = *((struct sctp_chunk **)(skb->cb));
-	asoc = chunk->asoc;
-	sk = asoc->base.sk;
 	asoc->sndbuf_used -= SCTP_DATA_SNDSIZE(chunk) +
 				sizeof(struct sk_buff) +
 				sizeof(struct sctp_chunk);
-- 
1.7.11.7
