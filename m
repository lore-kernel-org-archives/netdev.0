From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [DST]: shrinks sizeof(struct rtable) by 64 bytes on x86_64
Date: Tue, 22 Jan 2008 11:50:06 +0100
Message-ID: <20080122115006.82dbbff4.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:34217 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755003AbYAVKuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 05:50:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On x86_64, sizeof(struct rtable) is 0x148, which is rounded up to 0x180
bytes by SLAB allocator.

We can reduce this to exactly 0x140 bytes, without alignment overhead,
and store 12 struct rtable per PAGE instead of 10.

rate_tokens is currently defined as an "unsigned long", while its content
should not exceed 6*HZ. It can safely be converted to an unsigned int.

Moving tclassid right after rate_tokens to fill the 4 bytes hole permits
to save 8 bytes on 'struct dst_entry', which finally permits to save 8
bytes on 'struct rtable'

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/include/net/dst.h b/include/net/dst.h
index c45dcc3..e3ac7d0 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -56,7 +56,11 @@ struct dst_entry
 	struct dst_entry	*path;
 
 	unsigned long		rate_last;	/* rate limiting for ICMP */
-	unsigned long		rate_tokens;
+	unsigned int		rate_tokens;
+
+#ifdef CONFIG_NET_CLS_ROUTE
+	__u32			tclassid;
+#endif
 
 	struct neighbour	*neighbour;
 	struct hh_cache		*hh;
@@ -65,10 +69,6 @@ struct dst_entry
 	int			(*input)(struct sk_buff*);
 	int			(*output)(struct sk_buff*);
 
-#ifdef CONFIG_NET_CLS_ROUTE
-	__u32			tclassid;
-#endif
-
 	struct  dst_ops	        *ops;
 		
 	unsigned long		lastuse;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 7ed8c50..1dbe89c 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -275,18 +275,19 @@ static inline void icmp_xmit_unlock(void)
 #define XRLIM_BURST_FACTOR 6
 int xrlim_allow(struct dst_entry *dst, int timeout)
 {
-	unsigned long now;
+	unsigned long now, token = dst->rate_tokens;
 	int rc = 0;
 
 	now = jiffies;
-	dst->rate_tokens += now - dst->rate_last;
+	token += now - dst->rate_last;
 	dst->rate_last = now;
-	if (dst->rate_tokens > XRLIM_BURST_FACTOR * timeout)
-		dst->rate_tokens = XRLIM_BURST_FACTOR * timeout;
-	if (dst->rate_tokens >= timeout) {
-		dst->rate_tokens -= timeout;
+	if (token > XRLIM_BURST_FACTOR * timeout)
+		token = XRLIM_BURST_FACTOR * timeout;
+	if (token >= timeout) {
+		token -= timeout;
 		rc = 1;
 	}
+	dst->rate_tokens = token;
 	return rc;
 }
 
