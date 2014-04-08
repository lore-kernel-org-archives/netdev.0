From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: test if association is dead in sctp_wake_up_waiters
Date: Wed,  9 Apr 2014 00:23:36 +0200
Message-ID: <1396995816-25275-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41791 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757726AbaDHWXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 18:23:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function sctp_wake_up_waiters() we need to involve a test
if the association is declared dead. If so, we don't have any
reference to a possible sibling association anymore and need
to invoke sctp_write_space() instead and normally walk the
socket's associations and notify them of new wmem space. The
reason for special casing is that, otherwise, we could run
into the following issue:

sctp_association_free()
`-> list_del(&asoc->asocs)         <-- poisons list pointer
    asoc->base.dead = true
    sctp_outq_free(&asoc->outqueue)
    `-> __sctp_outq_teardown()
     `-> sctp_chunk_free()
      `-> consume_skb()
       `-> sctp_wfree()
        `-> sctp_wake_up_waiters() <-- dereferences poisoned pointers
                                       if asoc->ep->sndbuf_policy=0

Therefore, only walk the list in an 'optimized' way if we find
that the current association is still active. It's also more
clean in that context to just use list_del_init() when we call
sctp_association_free(). Stress-testing seems fine now.

Fixes: cd253f9f357d ("net: sctp: wake up all assocs if sndbuf policy is per socket")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
---
 net/sctp/associola.c | 2 +-
 net/sctp/socket.c    | 6 ++++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 4f6d6f9..0f8fa97 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -331,7 +331,7 @@ void sctp_association_free(struct sctp_association *asoc)
 	 * don't bother for if this is a temporary association.
 	 */
 	if (!asoc->temp) {
-		list_del(&asoc->asocs);
+		list_del_init(&asoc->asocs);
 
 		/* Decrement the backlog value for a TCP-style listening
 		 * socket.
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 5f83a6a..270d5bd 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6604,6 +6604,12 @@ static void sctp_wake_up_waiters(struct sock *sk,
 	if (asoc->ep->sndbuf_policy)
 		return __sctp_write_space(asoc);
 
+	/* If association goes down and is just flushing its
+	 * outq, then just normally notify others.
+	 */
+	if (asoc->base.dead)
+		return sctp_write_space(sk);
+
 	/* Accounting for the sndbuf space is per socket, so we
 	 * need to wake up others, try to be fair and in case of
 	 * other associations, let them have a go first instead
-- 
1.7.11.7
