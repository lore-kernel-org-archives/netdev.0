From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2/2] [SCTP]: Remove temporary associations from backlog and
	hash
Date: Mon, 30 Oct 2006 17:38:41 -0800
Message-ID: <1162258721.22597.40.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:7635 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1422697AbWJaBin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 20:38:43 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9V1cgEu005651
	for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 20:38:42 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9V1cgEo278026
	for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 20:38:42 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9V1cgaO002638
	for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 20:38:42 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Remove temporary associations from backlog and hash.

Every time SCTP creates a temporary association, the stack hashes it,
puts it on a list of endpoint associations and increments the backlog.
However, the lifetime of a temporary association is the processing time
of a current packet and it's destroyed after that. In fact, we don't
really want anyone else finding this association. There is no reason to
do this extra work.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/associola.c   |   15 +++++++++++----
 net/sctp/endpointola.c |    7 +++++++
 net/sctp/input.c       |    6 ++++++
 3 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 27329ce..ed0445f 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -346,11 +346,18 @@ void sctp_association_free(struct sctp_a
 	struct list_head *pos, *temp;
 	int i;
 
-	list_del(&asoc->asocs);
+	/* Only real associations count against the endpoint, so
+	 * don't bother for if this is a temporary association.
+	 */
+	if (!asoc->temp) {
+		list_del(&asoc->asocs);
 
-	/* Decrement the backlog value for a TCP-style listening socket. */
-	if (sctp_style(sk, TCP) && sctp_sstate(sk, LISTENING))
-		sk->sk_ack_backlog--;
+		/* Decrement the backlog value for a TCP-style listening
+		 * socket.
+		 */
+		if (sctp_style(sk, TCP) && sctp_sstate(sk, LISTENING))
+			sk->sk_ack_backlog--;
+	}
 
 	/* Mark as dead, so other users can know this structure is
 	 * going away.
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 35c49ff..9b6b394 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -144,6 +144,13 @@ void sctp_endpoint_add_asoc(struct sctp_
 {
 	struct sock *sk = ep->base.sk;
 
+	/* If this is a temporary association, don't bother
+	 * since we'll be removing it shortly and don't
+	 * want anyone to find it anyway.
+	 */
+	if (asoc->temp)
+		return;
+
 	/* Now just add it to our list of asocs */
 	list_add_tail(&asoc->asocs, &ep->asocs);
 
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 64f6301..cd20cd0 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -768,6 +768,9 @@ static void __sctp_hash_established(stru
 /* Add an association to the hash. Local BH-safe. */
 void sctp_hash_established(struct sctp_association *asoc)
 {
+	if (asoc->temp)
+		return;
+
 	sctp_local_bh_disable();
 	__sctp_hash_established(asoc);
 	sctp_local_bh_enable();
@@ -801,6 +804,9 @@ static void __sctp_unhash_established(st
 /* Remove association from the hash table.  Local BH-safe. */
 void sctp_unhash_established(struct sctp_association *asoc)
 {
+	if (asoc->temp)
+		return;
+
 	sctp_local_bh_disable();
 	__sctp_unhash_established(asoc);
 	sctp_local_bh_enable();


