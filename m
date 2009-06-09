From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/15]: sctp: Use frag list abstraction interfaces.
Date: Tue, 09 Jun 2009 05:02:28 -0700 (PDT)
Message-ID: <20090609.050228.260965448.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58261
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760091AbZFIMC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:02:27 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E8EFEC8C0F4
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:02:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sctp/input.c    |    4 ++--
 net/sctp/socket.c   |    6 +++---
 net/sctp/ulpevent.c |    7 +++----
 3 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index d2e9880..c0c973e 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -81,13 +81,13 @@ static void sctp_add_backlog(struct sock *sk, struct sk_buff *skb);
 /* Calculate the SCTP checksum of an SCTP packet.  */
 static inline int sctp_rcv_checksum(struct sk_buff *skb)
 {
-	struct sk_buff *list = skb_shinfo(skb)->frag_list;
 	struct sctphdr *sh = sctp_hdr(skb);
 	__le32 cmp = sh->checksum;
+	struct sk_buff *list;
 	__le32 val;
 	__u32 tmp = sctp_start_cksum((__u8 *)sh, skb_headlen(skb));
 
-	for (; list; list = list->next)
+	skb_walk_frags(skb, list)
 		tmp = sctp_update_cksum((__u8 *)list->data, skb_headlen(list),
 					tmp);
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 7c3dfd2..0f01e5d 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1881,7 +1881,7 @@ static int sctp_skb_pull(struct sk_buff *skb, int len)
 	len -= skb_len;
 	__skb_pull(skb, skb_len);
 
-	for (list = skb_shinfo(skb)->frag_list; list; list = list->next) {
+	skb_walk_frags(skb, list) {
 		rlen = sctp_skb_pull(list, len);
 		skb->len -= (len-rlen);
 		skb->data_len -= (len-rlen);
@@ -6660,7 +6660,7 @@ static void sctp_sock_rfree_frag(struct sk_buff *skb)
 		goto done;
 
 	/* Don't forget the fragments. */
-	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next)
+	skb_walk_frags(skb, frag)
 		sctp_sock_rfree_frag(frag);
 
 done:
@@ -6675,7 +6675,7 @@ static void sctp_skb_set_owner_r_frag(struct sk_buff *skb, struct sock *sk)
 		goto done;
 
 	/* Don't forget the fragments. */
-	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next)
+	skb_walk_frags(skb, frag)
 		sctp_skb_set_owner_r_frag(frag, sk);
 
 done:
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 5f186ca..8b3560f 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -976,9 +976,8 @@ static void sctp_ulpevent_receive_data(struct sctp_ulpevent *event,
 	 * In general, the skb passed from IP can have only 1 level of
 	 * fragments. But we allow multiple levels of fragments.
 	 */
-	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
+	skb_walk_frags(skb, frag)
 		sctp_ulpevent_receive_data(sctp_skb2event(frag), asoc);
-	}
 }
 
 /* Do accounting for bytes just read by user and release the references to
@@ -1003,7 +1002,7 @@ static void sctp_ulpevent_release_data(struct sctp_ulpevent *event)
 		goto done;
 
 	/* Don't forget the fragments. */
-	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
+	skb_walk_frags(skb, frag) {
 		/* NOTE:  skb_shinfos are recursive. Although IP returns
 		 * skb's with only 1 level of fragments, SCTP reassembly can
 		 * increase the levels.
@@ -1026,7 +1025,7 @@ static void sctp_ulpevent_release_frag_data(struct sctp_ulpevent *event)
 		goto done;
 
 	/* Don't forget the fragments. */
-	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next) {
+	skb_walk_frags(skb, frag) {
 		/* NOTE:  skb_shinfos are recursive. Although IP returns
 		 * skb's with only 1 level of fragments, SCTP reassembly can
 		 * increase the levels.
-- 
1.6.3.2

