From: <xufengzhang.main@gmail.com>
Subject: [PATCH] sctp: Make "Invalid Stream Identifier" ERROR follows SACK when bundling
Date: Thu, 19 Jul 2012 13:57:30 +0800
Message-ID: <1342677450-21810-1-git-send-email-xufengzhang.main@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <vyasevich@gmail.com>, <sri@us.ibm.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When "Invalid Stream Identifier" ERROR happens after process the
received DATA chunks, this ERROR chunk is enqueued into outqueue
before SACK chunk, so when bundling ERROR chunk with SACK chunk,
the ERROR chunk is always placed first in the packet because of
the chunk's position in the outqueue.
This violates sctp specification:
    RFC 4960 6.5. Stream Identifier and Stream Sequence Number
    ...The endpoint may bundle the ERROR chunk in the same
    packet as the SACK as long as the ERROR follows the SACK.
So we must place SACK first when bundling "Invalid Stream Identifier"
ERROR and SACK in one packet.
Although we can do that by enqueue SACK chunk into outqueue before
ERROR chunk, it will violate the side-effect interpreter processing.
It's easy to do this job when dequeue chunks from the outqueue,
by this way, we introduce a flag 'has_isi_err' which indicate
whether or not the "Invalid Stream Identifier" ERROR happens.

Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
---
 include/net/sctp/structs.h |    2 ++
 net/sctp/output.c          |   26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 88949a9..5adf4de 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -842,6 +842,8 @@ struct sctp_packet {
 	    has_sack:1,		/* This packet contains a SACK chunk. */
 	    has_auth:1,		/* This packet contains an AUTH chunk */
 	    has_data:1,		/* This packet contains at least 1 DATA chunk */
+	    has_isi_err:1,	/* This packet contains a "Invalid Stream
+				 * Identifier" ERROR chunk */
 	    ipfragok:1,		/* So let ip fragment this packet */
 	    malloced:1;		/* Is it malloced? */
 };
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 817174e..77fb1ae 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -79,6 +79,7 @@ static void sctp_packet_reset(struct sctp_packet *packet)
 	packet->has_sack = 0;
 	packet->has_data = 0;
 	packet->has_auth = 0;
+	packet->has_isi_err = 0;
 	packet->ipfragok = 0;
 	packet->auth = NULL;
 }
@@ -267,6 +268,7 @@ static sctp_xmit_t sctp_packet_bundle_sack(struct sctp_packet *pkt,
 sctp_xmit_t sctp_packet_append_chunk(struct sctp_packet *packet,
 				     struct sctp_chunk *chunk)
 {
+	struct sctp_chunk *lchunk;
 	sctp_xmit_t retval = SCTP_XMIT_OK;
 	__u16 chunk_len = WORD_ROUND(ntohs(chunk->chunk_hdr->length));
 
@@ -316,7 +318,31 @@ sctp_xmit_t sctp_packet_append_chunk(struct sctp_packet *packet,
 		packet->has_cookie_echo = 1;
 		break;
 
+	    case SCTP_CID_ERROR:
+		if (chunk->subh.err_hdr->cause & SCTP_ERROR_INV_STRM)
+			packet->has_isi_err = 1;
+		break;
+
 	    case SCTP_CID_SACK:
+		/* RFC 4960
+		 * 6.5 Stream Identifier and Stream Sequence Number
+		 * The endpoint may bundle the ERROR chunk in the same
+		 * packet as the SACK as long as the ERROR follows the SACK.
+		 */
+		if (packet->has_isi_err) {
+			if (list_is_singular(&packet->chunk_list))
+				list_add(&chunk->list, &packet->chunk_list);
+			else {
+				lchunk = list_first_entry(&packet->chunk_list,
+						struct sctp_chunk, list);
+				list_add(&chunk->list, &lchunk->list);
+			}
+			packet->size += chunk_len;
+			chunk->transport = packet->transport;
+			packet->has_sack = 1;
+			goto finish;
+		}
+
 		packet->has_sack = 1;
 		break;
 
-- 
1.7.0.2
