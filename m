From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 2/6] sctp: reorder sctp_ulpevent and shrink msg_flags
Date: Wed, 13 Jul 2016 15:08:56 -0300
Message-ID: <0d9bf4a78caa22f6c7dd84304b5ff3eed7939f1e.1468432819.git.marcelo.leitner@gmail.com>
References: <cover.1468432819.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54455 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbcGMSJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 14:09:54 -0400
In-Reply-To: <cover.1468432819.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The next patch needs 8 bytes in there. sctp_ulpevent has a hole due to
bad alignment; msg_flags is using 4 bytes while it actually uses only 2, so
we shrink it, and iif member (4 bytes) which can be easily fetched from
another place once the next patch is there, so we remove it and thus
creating space for 8 bytes.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/ulpevent.h | 10 +++++-----
 net/sctp/ulpevent.c         |  4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index cccdcfd149736b315554d64c2a556e0ad6496fc8..aa342645dbce446186d55151c3f507cf0e165b44 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -48,15 +48,15 @@
  */
 struct sctp_ulpevent {
 	struct sctp_association *asoc;
-	__u16 stream;
-	__u16 ssn;
-	__u16 flags;
+	unsigned int rmem_len;
 	__u32 ppid;
 	__u32 tsn;
 	__u32 cumtsn;
-	int msg_flags;
 	int iif;
-	unsigned int rmem_len;
+	__u16 stream;
+	__u16 ssn;
+	__u16 flags;
+	__u16 msg_flags;
 };
 
 /* Retrieve the skb this event sits inside of. */
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index d1e38308f6159c0e4da7db966c16afc6a956b554..706f5bc9f0c3083ab455ec78b963cd609a3a95b5 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -51,7 +51,7 @@ static void sctp_ulpevent_release_frag_data(struct sctp_ulpevent *event);
 
 /* Initialize an ULP event from an given skb.  */
 static void sctp_ulpevent_init(struct sctp_ulpevent *event,
-			       int msg_flags,
+			       __u16 msg_flags,
 			       unsigned int len)
 {
 	memset(event, 0, sizeof(struct sctp_ulpevent));
@@ -60,7 +60,7 @@ static void sctp_ulpevent_init(struct sctp_ulpevent *event,
 }
 
 /* Create a new sctp_ulpevent.  */
-static struct sctp_ulpevent *sctp_ulpevent_new(int size, int msg_flags,
+static struct sctp_ulpevent *sctp_ulpevent_new(int size, __u16 msg_flags,
 					       gfp_t gfp)
 {
 	struct sctp_ulpevent *event;
-- 
2.7.4
