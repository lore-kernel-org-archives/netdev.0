From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Thu, 22 Jan 2009 22:22:42 -0600
Message-ID: <49794612.9010204@cs.wisc.edu>
References: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com> <4978F804.3060502@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080008050908040501000809"
Cc: netdev@vger.kernel.org, olaf.kirch@oracle.com, tgraf@suug.ch,
	kkeil@suse.de, herbert@gondor.apana.org.au
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:39545 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754964AbZAWEYB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 23:24:01 -0500
In-Reply-To: <4978F804.3060502@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080008050908040501000809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Mike Christie wrote:
> Brandeburg, Jesse wrote:
>>
>> skb_copy_bits is an example of the code flow that does work.
>>
>> skb_seq_read appears to only be used by iSCSI and the skb text match 
>> support in tc/netfilter (aka skb_find_text)
>>
> 
> There is no reason iscsi needs to use skb_seq_read. It used to use 
> skb_copy_bits. I can convert iscsi to use skb_copy_bits again.
> 

Attached is a patch made against the scsi maintainer's tree (I think it 
should also apply to linus's) that converts iscsi to use skb_copy_bits. 
It is lightly tested. If there is no benefit in having skb_find_text use 
skb_seq_read maybe we can just kill it, so people do not have to 
maintain two helpers that provide similar functionality.

--------------080008050908040501000809
Content-Type: text/plain;
 name="use-skb-copy-bits.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="use-skb-copy-bits.patch"

diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index 23808df..b052c57 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -74,7 +74,7 @@ static int iscsi_sw_tcp_recv(read_descriptor_t *rd_desc, struct sk_buff *skb,
 			     unsigned int offset, size_t len)
 {
 	struct iscsi_conn *conn = rd_desc->arg.data;
-	unsigned int consumed, total_consumed = 0;
+	unsigned int consumed, total_consumed = 0, in = skb->len - offset;
 	int status;
 
 	debug_tcp("in %d bytes\n", skb->len - offset);
@@ -84,7 +84,8 @@ static int iscsi_sw_tcp_recv(read_descriptor_t *rd_desc, struct sk_buff *skb,
 		consumed = iscsi_tcp_recv_skb(conn, skb, offset, 0, &status);
 		offset += consumed;
 		total_consumed += consumed;
-	} while (consumed != 0 && status != ISCSI_TCP_SKB_DONE);
+	} while (consumed != 0 && status != ISCSI_TCP_SKB_DONE &&
+		 consumed < in);
 
 	debug_tcp("read %d bytes status %d\n", skb->len - offset, status);
 	return total_consumed;
diff --git a/drivers/scsi/libiscsi_tcp.c b/drivers/scsi/libiscsi_tcp.c
index e7705d3..f91c79d 100644
--- a/drivers/scsi/libiscsi_tcp.c
+++ b/drivers/scsi/libiscsi_tcp.c
@@ -252,45 +252,6 @@ int iscsi_tcp_segment_done(struct iscsi_tcp_conn *tcp_conn,
 }
 EXPORT_SYMBOL_GPL(iscsi_tcp_segment_done);
 
-/**
- * iscsi_tcp_segment_recv - copy data to segment
- * @tcp_conn: the iSCSI TCP connection
- * @segment: the buffer to copy to
- * @ptr: data pointer
- * @len: amount of data available
- *
- * This function copies up to @len bytes to the
- * given buffer, and returns the number of bytes
- * consumed, which can actually be less than @len.
- *
- * If hash digest is enabled, the function will update the
- * hash while copying.
- * Combining these two operations doesn't buy us a lot (yet),
- * but in the future we could implement combined copy+crc,
- * just way we do for network layer checksums.
- */
-static int
-iscsi_tcp_segment_recv(struct iscsi_tcp_conn *tcp_conn,
-		       struct iscsi_segment *segment, const void *ptr,
-		       unsigned int len)
-{
-	unsigned int copy = 0, copied = 0;
-
-	while (!iscsi_tcp_segment_done(tcp_conn, segment, 1, copy)) {
-		if (copied == len) {
-			debug_tcp("iscsi_tcp_segment_recv copied %d bytes\n",
-				  len);
-			break;
-		}
-
-		copy = min(len - copied, segment->size - segment->copied);
-		debug_tcp("iscsi_tcp_segment_recv copying %d\n", copy);
-		memcpy(segment->data + segment->copied, ptr + copied, copy);
-		copied += copy;
-	}
-	return copied;
-}
-
 inline void
 iscsi_tcp_dgst_header(struct hash_desc *hash, const void *hdr, size_t hdrlen,
 		      unsigned char digest[ISCSI_DIGEST_SIZE])
@@ -850,8 +811,7 @@ int iscsi_tcp_recv_skb(struct iscsi_conn *conn, struct sk_buff *skb,
 {
 	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
 	struct iscsi_segment *segment = &tcp_conn->in.segment;
-	struct skb_seq_state seq;
-	unsigned int consumed = 0;
+	unsigned int copy = 0, copied = 0, len = skb->len - offset;
 	int rc = 0;
 
 	debug_tcp("in %d bytes\n", skb->len - offset);
@@ -867,30 +827,31 @@ int iscsi_tcp_recv_skb(struct iscsi_conn *conn, struct sk_buff *skb,
 		goto segment_done;
 	}
 
-	skb_prepare_seq_read(skb, offset, skb->len, &seq);
-	while (1) {
-		unsigned int avail;
-		const u8 *ptr;
-
-		avail = skb_seq_read(consumed, &ptr, &seq);
-		if (avail == 0) {
-			debug_tcp("no more data avail. Consumed %d\n",
-				  consumed);
+	while (!iscsi_tcp_segment_done(tcp_conn, segment, 1, copy)) {
+		if (copied == len) {
+			debug_tcp("iscsi_tcp_recv_skb finished skb "
+				  "copied %d bytes\n", len);
 			*status = ISCSI_TCP_SKB_DONE;
-			skb_abort_seq_read(&seq);
 			goto skb_done;
 		}
-		BUG_ON(segment->copied >= segment->size);
 
-		debug_tcp("skb %p ptr=%p avail=%u\n", skb, ptr, avail);
-		rc = iscsi_tcp_segment_recv(tcp_conn, segment, ptr, avail);
-		BUG_ON(rc == 0);
-		consumed += rc;
+		copy = min(len - copied, segment->size - segment->copied);
+		debug_tcp("iscsi_tcp_recv_skb copying %d (len %u copied %u "
+			  "segment size %u segment copied %u\n", copy,
+			  copied, segment->size, segment->copied);
 
-		if (segment->total_copied >= segment->total_size) {
-			skb_abort_seq_read(&seq);
-			goto segment_done;
+		rc = skb_copy_bits(skb, copied + offset,
+				   segment->data + segment->copied, copy);
+		if (rc) {
+			printk(KERN_ERR "iscsi_tcp_recv_skb bug. Could not "
+			       "copy skb data to command buffer. (len %u "
+			       "copied %u segment size %u segment copied %u)\n",
+				copy, copied, segment->size, segment->copied);
+			*status = ISCSI_TCP_CONN_ERR;
+			iscsi_conn_failure(conn, ISCSI_ERR_CONN_FAILED);
+			return 0;
 		}
+		copied += copy;
 	}
 
 segment_done:
@@ -906,8 +867,8 @@ segment_done:
 	/* The done() functions sets up the next segment. */
 
 skb_done:
-	conn->rxdata_octets += consumed;
-	return consumed;
+	conn->rxdata_octets += copied;
+	return copied;
 }
 EXPORT_SYMBOL_GPL(iscsi_tcp_recv_skb);
 

--------------080008050908040501000809--
