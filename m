From: "David S. Miller" <davem@davemloft.net>
Subject: [RFC v2 PATCH 09/11] net: Rearrange dst_entry layout to avoid useless padding.
Date: Tue, 31 Oct 2017 23:10:52 +0900
Message-ID: <20171031141054.9954-10-davem@davemloft.net>
References: <20171031141054.9954-1-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [106.252.28.196] ([106.252.28.196]:51334 "EHLO davemloft.net"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753056AbdJaOUi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 10:20:38 -0400
In-Reply-To: <20171031141054.9954-1-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have padding to try and align the refcount on a separate cache
line.  But after several simplifications the padding has increased
substantially.

So now it's easy to change the layout to get rid of the padding
entirely.

We group the write-heavy __refcnt and __use with less often used
items such as the rcu_head and the error code.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h | 22 +++++-----------------
 1 file changed, 5 insertions(+), 17 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index e860c3b11322..ffd0d81f861f 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -33,7 +33,6 @@ struct sk_buff;
 
 struct dst_entry {
 	struct net_device       *dev;
-	struct rcu_head		rcu_head;
 	struct  dst_ops	        *ops;
 	unsigned long		_metrics;
 	unsigned long           expires;
@@ -55,8 +54,6 @@ struct dst_entry {
 #define DST_XFRM_QUEUE		0x0040
 #define DST_METADATA		0x0080
 
-	short			error;
-
 	/* A non-zero value of dst->obsolete forces by-hand validation
 	 * of the route entry.  Positive values are set by the generic
 	 * dst layer to indicate that the entry has been forcefully
@@ -72,21 +69,7 @@ struct dst_entry {
 #define DST_OBSOLETE_KILL	-2
 	unsigned short		header_len;	/* more space at head required */
 	unsigned short		trailer_len;	/* space to reserve at tail */
-	unsigned short		__pad3;
-
-#ifdef CONFIG_IP_ROUTE_CLASSID
-	__u32			tclassid;
-#else
-	__u32			__pad2;
-#endif
 
-#ifdef CONFIG_64BIT
-	/*
-	 * Align __refcnt to a 64 bytes alignment
-	 * (L1_CACHE_SIZE would be too much)
-	 */
-	long			__pad_to_align_refcnt[5];
-#endif
 	/*
 	 * __refcnt wants to be on a different cache line from
 	 * input/output/ops or performance tanks badly
@@ -95,6 +78,11 @@ struct dst_entry {
 	int			__use;
 	unsigned long		lastuse;
 	struct lwtunnel_state   *lwtstate;
+	struct rcu_head		rcu_head;
+	short			error;
+	short			__pad;
+	__u32			tclassid;
+
 	union {
 		struct dst_entry	*next;
 	};
-- 
2.13.6
