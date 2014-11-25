From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/2] net: Add remcsum_adjust as common function for remote checksum offload
Date: Tue, 25 Nov 2014 11:21:19 -0800
Message-ID: <1416943280-28473-2-git-send-email-therbert@google.com>
References: <1416943280-28473-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:54712 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbaKYTVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:21:49 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so1193625ier.41
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 11:21:49 -0800 (PST)
In-Reply-To: <1416943280-28473-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function does the work to update a checksum field as part of
remote checksum offload.

remcsum_adjust does the following:

1) Subtract out the calculated checksum from the beginning of the
   packet (ptr arg) to the start offset.
2) Adjust the checksum field indicated by offset based on the modified
   checksum value from above step.
3) Return the difference in the old checksum field value and the
   new one. The caller will use this to update skb->csum and NAPI csum.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/checksum.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index 6465bae..e339a95 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -151,4 +151,20 @@ static inline void inet_proto_csum_replace2(__sum16 *sum, struct sk_buff *skb,
 				 (__force __be32)to, pseudohdr);
 }
 
+static inline __wsum remcsum_adjust(void *ptr, __wsum csum,
+				    int start, int offset)
+{
+	__sum16 *psum = (__sum16 *)(ptr + offset);
+	__wsum delta;
+
+	/* Subtract out checksum up to start */
+	csum = csum_sub(csum, csum_partial(ptr, start, 0));
+
+	/* Set derived checksum in packet */
+	delta = csum_sub(csum_fold(csum), *psum);
+	*psum = csum_fold(csum);
+
+	return delta;
+}
+
 #endif
-- 
2.1.0.rc2.206.gedb03e5
