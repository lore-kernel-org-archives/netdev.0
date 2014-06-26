From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 05/13] tipc: introduce direct iovec to buffer chain fragmentation function
Date: Wed, 25 Jun 2014 20:41:34 -0500
Message-ID: <1403746902-20408-6-git-send-email-jon.maloy@ericsson.com>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24148 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757251AbaFZBsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:48:54 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fragmentation at message sending is currently performed in two
places in link.c, depending on whether data to be transmitted
is delivered in the form of an iovec or as a big sk_buff. Those
functions are also tightly entangled with the send functions
that are using them.

We now introduce a re-entrant, standalone function, tipc_msg_build2(),
that builds a packet chain directly from an iovec. Each fragment is
sized according to the MTU value given by the caller, and is prepended
with a correctly built fragment header, when needed. The function is
independent from who is calling and where the chain will be delivered,
as long as the caller is able to indicate a correct MTU.

The function is tested, but not called by anybody yet. Since it is
incompatible with the existing tipc_msg_build(), and we cannot yet
remove that function, we have given it a temporary name.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/msg.c |  102 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/tipc/msg.h |    3 ++
 2 files changed, 105 insertions(+)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index e02afc9..4093b4c 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -144,6 +144,108 @@ out_free:
 	return 0;
 }
 
+
+/**
+ * tipc_msg_build2 - create buffer chain containing specified header and data
+ * @mhdr: Message header, to be prepended to data
+ * @iov: User data
+ * @offset: Posision in iov to start copying from
+ * @dsz: Total length of user data
+ * @pktmax: Max packet size that can be used
+ * @chain: Buffer or chain of buffers to be returned to caller
+ * Returns message data size or errno: -ENOMEM, -EFAULT
+ */
+int tipc_msg_build2(struct tipc_msg *mhdr, struct iovec const *iov,
+		    int offset, int dsz, int pktmax , struct sk_buff **chain)
+{
+	int mhsz = msg_hdr_sz(mhdr);
+	int msz = mhsz + dsz;
+	int pktno = 1;
+	int pktsz;
+	int pktrem = pktmax;
+	int drem = dsz;
+	struct tipc_msg pkthdr;
+	struct sk_buff *buf, *prev;
+	char *pktpos;
+	int rc;
+
+	msg_set_size(mhdr, msz);
+
+	/* No fragmentation needed? */
+	if (likely(msz <= pktmax)) {
+		buf = tipc_buf_acquire(msz);
+		*chain = buf;
+		if (unlikely(!buf))
+			return -ENOMEM;
+		skb_copy_to_linear_data(buf, mhdr, mhsz);
+		pktpos = buf->data + mhsz;
+		if (!dsz || !memcpy_fromiovecend(pktpos, iov, offset, dsz))
+			return dsz;
+		rc = -EFAULT;
+		goto error;
+	}
+
+	/* Prepare reusable fragment header */
+	tipc_msg_init(&pkthdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
+		      INT_H_SIZE, msg_destnode(mhdr));
+	msg_set_size(&pkthdr, pktmax);
+	msg_set_fragm_no(&pkthdr, pktno);
+
+	/* Prepare first fragment */
+	*chain = buf = tipc_buf_acquire(pktmax);
+	if (!buf)
+		return -ENOMEM;
+	pktpos = buf->data;
+	skb_copy_to_linear_data(buf, &pkthdr, INT_H_SIZE);
+	pktpos += INT_H_SIZE;
+	pktrem -= INT_H_SIZE;
+	skb_copy_to_linear_data_offset(buf, INT_H_SIZE, mhdr, mhsz);
+	pktpos += mhsz;
+	pktrem -= mhsz;
+
+	do {
+		if (drem < pktrem)
+			pktrem = drem;
+
+		if (memcpy_fromiovecend(pktpos, iov, offset, pktrem)) {
+			rc = -EFAULT;
+			goto error;
+		}
+		drem -= pktrem;
+		offset += pktrem;
+
+		if (!drem)
+			break;
+
+		/* Prepare new fragment: */
+		if (drem < (pktmax - INT_H_SIZE))
+			pktsz = drem + INT_H_SIZE;
+		else
+			pktsz = pktmax;
+		prev = buf;
+		buf = tipc_buf_acquire(pktsz);
+		if (!buf) {
+			rc = -ENOMEM;
+			goto error;
+		}
+		prev->next = buf;
+		msg_set_type(&pkthdr, FRAGMENT);
+		msg_set_size(&pkthdr, pktsz);
+		msg_set_fragm_no(&pkthdr, ++pktno);
+		skb_copy_to_linear_data(buf, &pkthdr, INT_H_SIZE);
+		pktpos = buf->data + INT_H_SIZE;
+		pktrem = pktsz - INT_H_SIZE;
+
+	} while (1);
+
+	msg_set_type(buf_msg(buf), LAST_FRAGMENT);
+	return dsz;
+error:
+	kfree_skb_list(*chain);
+	*chain = NULL;
+	return rc;
+}
+
 /**
  * tipc_msg_bundle(): Append contents of a buffer to tail of an existing one
  * @bbuf: the existing buffer ("bundle")
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 41a05fa..5e1339d 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -737,4 +737,7 @@ bool tipc_msg_bundle(struct sk_buff *bbuf, struct sk_buff *buf, u32 mtu);
 
 bool tipc_msg_make_bundle(struct sk_buff **buf, u32 mtu, u32 dnode);
 
+int tipc_msg_build2(struct tipc_msg *mhdr, struct iovec const *iov,
+		    int offset, int dsz, int mtu , struct sk_buff **chain);
+
 #endif
-- 
1.7.9.5
