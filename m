From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 06/11] sctp: remove the typedef sctp_sack_variable_t
Date: Sun, 23 Jul 2017 09:34:31 +0800
Message-ID: <94b6f03745317ab5c57639f2155a5e1503b4dfb3.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
 <daa1cc9a380f5a1eb37b3d30fd64942d310fe81d.1500773578.git.lucien.xin@gmail.com>
 <78a33af4a9d7ef7116637943dbd0ae1403d20114.1500773578.git.lucien.xin@gmail.com>
 <54eca4d5d79aae83b386754b4613edc388521d54.1500773578.git.lucien.xin@gmail.com>
 <303fa591073b161b9434fa7f81a8d9d119954359.1500773578.git.lucien.xin@gmail.com>
 <42fb936def0c9ef0522d2e3809c9c07dccb6974f.1500773578.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:38700 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755172AbdGWBfd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 21:35:33 -0400
In-Reply-To: <42fb936def0c9ef0522d2e3809c9c07dccb6974f.1500773578.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_sack_variable_t, and
replace with union sctp_sack_variable in the places where it's
using this typedef.

It is also to fix some indents in sctp_acked().

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h |  6 +++---
 net/sctp/outqueue.c  | 10 +++++-----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 8faf74e..8df6ac5 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -368,17 +368,17 @@ struct sctp_gap_ack_block {
 	__be16 end;
 };
 
-typedef union {
+union sctp_sack_variable {
 	struct sctp_gap_ack_block gab;
 	__be32 dup;
-} sctp_sack_variable_t;
+};
 
 typedef struct sctp_sackhdr {
 	__be32 cum_tsn_ack;
 	__be32 a_rwnd;
 	__be16 num_gap_ack_blocks;
 	__be16 num_dup_tsns;
-	sctp_sack_variable_t variable[0];
+	union sctp_sack_variable variable[0];
 } sctp_sackhdr_t;
 
 typedef struct sctp_sack_chunk {
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index e876270..d2a8adf 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -1197,7 +1197,7 @@ static void sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 static void sctp_sack_update_unack_data(struct sctp_association *assoc,
 					struct sctp_sackhdr *sack)
 {
-	sctp_sack_variable_t *frags;
+	union sctp_sack_variable *frags;
 	__u16 unack_data;
 	int i;
 
@@ -1224,7 +1224,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_chunk *chunk)
 	struct sctp_transport *transport;
 	struct sctp_chunk *tchunk = NULL;
 	struct list_head *lchunk, *transport_list, *temp;
-	sctp_sack_variable_t *frags = sack->variable;
+	union sctp_sack_variable *frags = sack->variable;
 	__u32 sack_ctsn, ctsn, tsn;
 	__u32 highest_tsn, highest_new_tsn;
 	__u32 sack_a_rwnd;
@@ -1736,10 +1736,10 @@ static void sctp_mark_missing(struct sctp_outq *q,
 /* Is the given TSN acked by this packet?  */
 static int sctp_acked(struct sctp_sackhdr *sack, __u32 tsn)
 {
-	int i;
-	sctp_sack_variable_t *frags;
-	__u16 tsn_offset, blocks;
 	__u32 ctsn = ntohl(sack->cum_tsn_ack);
+	union sctp_sack_variable *frags;
+	__u16 tsn_offset, blocks;
+	int i;
 
 	if (TSN_lte(tsn, ctsn))
 		goto pass;
-- 
2.1.0
