From: Patrick McHardy <kaber@trash.net>
Subject: [RFC SKBUFF]: Keep track of writable header len of headerless clones
Date: Sun, 24 Jun 2007 14:53:36 +0200
Message-ID: <467E6950.4020707@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010302020609090903010406"
Cc: Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42514 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754248AbXFXMxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 08:53:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010302020609090903010406
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Currently NAT (and others) that want to modify cloned skbs copy them,
even if in the vast majority of cases its not necessary because the
skb is a clone made by TCP and the portion NAT wants to modify is
actually writable because TCP release the header reference before
cloning.

The problem is that there is no clean way for NAT to find out how
long the writable header area is, so this patch introduces skb->hdr_len
to hold this length. When a headerless skb is cloned skb->hdr_len
is set to the current headroom, for regular clones it is copied from
the original. A new function skb_clone_writable(skb, len) returns
whether the skb is writable up to len bytes from skb->data. To avoid
enlarging the skb the mac_len field is reduced to 16 bit and the
new hdr_len field is put in the remaining 16 bit.

I've done a few rough benchmarks of NAT (not with this exact patch,
but a very similar one). As expected it saves huge amounts of system
time in case of sendfile, bringing it down to basically the same
amount as without NAT, with sendmsg it only helps on loopback,
probably because of the large MTU.

Transmit a 1GB file using sendfile/sendmsg over eth0/lo with and
without NAT:

- sendfile eth0, no NAT:	sys     0m0.388s
- sendfile eth0, NAT:		sys     0m1.835s
- sendfile eth0: NAT + path:	sys     0m0.370s	(~ -80%)

- sendfile lo, no NAT:		sys     0m0.258s
- sendfile lo, NAT:		sys     0m2.609s
- sendfile lo, NAT + patch:	sys     0m0.260s	(~ -90%)

- sendmsg eth0, no NAT:		sys     0m2.508s
- sendmsg eth0, NAT:		sys     0m2.539s
- sendmsg eth0, NAT + patch:	sys     0m2.445s	(no change)

- sendmsg lo, no NAT:		sys	0m2.151s
- sendmsg lo, NAT:		sys     0m3.557s
- sendmsg lo, NAT + patch:	sys     0m2.159s	(~ -40%)


I expect other users can see a similar performance improvement,
packet mangling iptables targets, ipip and ip_gre come to mind ..

Comments welcome.

--------------010302020609090903010406
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6f0b2f7..881fe80 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -147,8 +147,8 @@ struct skb_shared_info {
 
 /* We divide dataref into two halves.  The higher 16 bits hold references
  * to the payload part of skb->data.  The lower 16 bits hold references to
- * the entire skb->data.  It is up to the users of the skb to agree on
- * where the payload starts.
+ * the entire skb->data.  A clone of a headerless skb holds the length of
+ * the header in skb->hdr_len.
  *
  * All users must obey the rule that the skb->data reference count must be
  * greater than or equal to the payload reference count.
@@ -206,6 +206,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@len: Length of actual data
  *	@data_len: Data length
  *	@mac_len: Length of link layer header
+ *	@hdr_len: writable header length of cloned skb
  *	@csum: Checksum (must include start/offset pair)
  *	@csum_start: Offset from skb->head where checksumming should start
  *	@csum_offset: Offset from csum_start where checksum should be stored
@@ -260,8 +261,9 @@ struct sk_buff {
 	char			cb[48];
 
 	unsigned int		len,
-				data_len,
-				mac_len;
+				data_len;
+	__u16			mac_len,
+				hdr_len;
 	union {
 		__wsum		csum;
 		struct {
@@ -1322,6 +1324,20 @@ static inline struct sk_buff *netdev_alloc_skb(struct net_device *dev,
 }
 
 /**
+ *	skb_clone_writable - is the header of a clone writable
+ *	@skb: buffer to check
+ *	@len: length up to which to write
+ *
+ *	Returns true if modifying the header part of the cloned buffer
+ *	does not requires the data to be copied.
+ */
+static inline int skb_clone_writable(struct sk_buff *skb, int len)
+{
+	return !skb_header_cloned(skb) &&
+	       skb_headroom(skb) + len <= skb->hdr_len;
+}
+
+/**
  *	skb_cow - copy header of skb when it is required
  *	@skb: buffer to cow
  *	@headroom: needed headroom
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7c6a34e..8d8e8fc 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -415,6 +415,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 	C(csum);
 	C(local_df);
 	n->cloned = 1;
+	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
 	n->nohdr = 0;
 	C(pkt_type);
 	C(ip_summed);
@@ -676,6 +677,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	skb->network_header   += off;
 	skb->mac_header	      += off;
 	skb->cloned   = 0;
+	skb->hdr_len  = 0;
 	skb->nohdr    = 0;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
 	return 0;
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index a84478e..3aaabec 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -203,7 +203,9 @@ int skb_make_writable(struct sk_buff **pskb, unsigned int writable_len)
 		return 0;
 
 	/* Not exclusive use of packet?  Must copy. */
-	if (skb_shared(*pskb) || skb_cloned(*pskb))
+	if (skb_cloned(*pskb) && !skb_clone_writable(*pskb, writable_len))
+		goto copy_skb;
+	if (skb_shared(*pskb))
 		goto copy_skb;
 
 	return pskb_may_pull(*pskb, writable_len);

--------------010302020609090903010406--
