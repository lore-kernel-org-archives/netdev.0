From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 1/1] [SK_BUFF]: Don't apply the offset of two allocations to the layer headers
Date: Sun, 18 Mar 2007 00:12:24 -0300
Message-ID: <20070318031224.GA17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:6069 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987AbXCRDMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2007 23:12:30 -0400
Received: by wx-out-0506.google.com with SMTP id h31so912984wxd
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2007 20:12:30 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi David,

	Here is the bugger, it wasn't because {transport,network,mac}_header
is unsigned after all :-)

	Please consider pulling from the usual place:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22

	Please lemme know how longer it takes to crash your workstation, I hope
not before next century 8-)

- Arnaldo

---
In pskb_expand_head and copy_skb_header (used in p?skb_copy(expand)?) the
difference of two allocations were being applied to
->(transport|network|mac)_header, when this is not only not needed but causes
problems, as those headers are now just offsets from ->head.

This fixes the problem with xfrm (skb_copy_checksum was the first place this
bug would crash the machine, on the first packet being xfrm'ed), so reenable
the offset code on 64bit arches.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/skbuff.h |    4 +---
 net/core/skbuff.c      |   18 ++++++++++++++----
 2 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 673ca0c..3e4a2bd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -180,9 +180,7 @@ enum {
 	SKB_GSO_TCPV6 = 1 << 4,
 };
 
-/* #if BITS_PER_LONG > 32 */
-#if 0
-/* Disabled for now till the ipsec problem is fixed -acme */
+#if BITS_PER_LONG > 32
 #define NET_SKBUFF_DATA_USES_OFFSET 1
 #endif
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5db345a..ea03cbf 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -502,11 +502,12 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 
 static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 {
+#ifndef NET_SKBUFF_DATA_USES_OFFSET
 	/*
 	 *	Shift between the two data areas in bytes
 	 */
 	unsigned long offset = new->data - old->data;
-
+#endif
 	new->sk		= NULL;
 	new->dev	= old->dev;
 	new->priority	= old->priority;
@@ -515,9 +516,15 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #ifdef CONFIG_INET
 	new->sp		= secpath_get(old->sp);
 #endif
-	new->transport_header = old->transport_header + offset;
-	new->network_header   = old->network_header + offset;
-	new->mac_header	      = old->mac_header + offset;
+	new->transport_header = old->transport_header;
+	new->network_header   = old->network_header;
+	new->mac_header	      = old->mac_header;
+#ifndef NET_SKBUFF_DATA_USES_OFFSET
+	/* {transport,network,mac}_header are relative to skb->head */
+	new->transport_header += offset;
+	new->network_header   += offset;
+	new->mac_header	      += offset;
+#endif
 	memcpy(new->cb, old->cb, sizeof(old->cb));
 	new->local_df	= old->local_df;
 	new->fclone	= SKB_FCLONE_UNAVAILABLE;
@@ -693,9 +700,12 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	skb->end      = data + size;
 	skb->data    += off;
 	skb->tail    += off;
+#ifndef NET_SKBUFF_DATA_USES_OFFSET
+	/* {transport,network,mac}_header are relative to skb->head */
 	skb->transport_header += off;
 	skb->network_header   += off;
 	skb->mac_header	      += off;
+#endif
 	skb->cloned   = 0;
 	skb->nohdr    = 0;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
-- 
1.5.0.3

