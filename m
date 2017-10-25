From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 10/12] net: Rearrange dst_entry layout to avoid useless
 padding.
Date: Wed, 25 Oct 2017 23:04:35 +0900 (KST)
Message-ID: <20171025.230435.525475057485029354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48362 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932301AbdJYOEi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:04:38 -0400
Received: from localhost (unknown [106.252.28.196])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 2B821133F06AD
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:04:36 -0700 (PDT)
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
index ca6495f237d5..403b1c02a26f 100644
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
