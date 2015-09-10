From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] netlink, mmap: fix edge-case leakages in nf queue zero-copy
Date: Thu, 10 Sep 2015 02:10:57 +0200
Message-ID: <c973763474a5ecfd97f8733a111545f919949408.1441840987.git.daniel@iogearbox.net>
Cc: chamaken@gmail.com, tgraf@suug.ch, fw@strlen.de, kaber@trash.net,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53445 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbbIJALB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 20:11:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When netlink mmap on receive side is the consumer of nf queue data,
it can happen that in some edge cases, we write skb shared info into
the user space mmap buffer:

Assume a possible rx ring frame size of only 4096, and the network skb,
which is being zero-copied into the netlink skb, contains page frags
with an overall skb->len larger than the linear part of the netlink
skb.

skb_zerocopy(), which is generic and thus not aware of the fact that
shared info cannot be accessed for such skbs then tries to write and
fill frags, thus leaking kernel data/pointers and in some corner cases
possibly writing out of bounds of the mmap area (when filling the
last slot in the ring buffer this way).

I.e. the ring buffer slot is then of status NL_MMAP_STATUS_VALID, has
an advertised length larger than 4096, where the linear part is visible
at the slot beginning, and the leaked sizeof(struct skb_shared_info)
has been written to the beginning of the next slot (also corrupting
the struct nl_mmap_hdr slot header incl. status etc), since skb->end
points to skb->data + ring->frame_size - NL_MMAP_HDRLEN.

The fix adds and lets __netlink_alloc_skb() take the actual needed
linear room for the network skb + meta data into account. It's completely
irrelevant for non-mmaped netlink sockets, but in case mmap sockets
are used, it can be decided whether the available skb_tailroom() is
really large enough for the buffer, or whether it needs to internally
fallback to a normal alloc_skb().

>From nf queue side, the information whether the destination port is
an mmap RX ring is not really available without extra port-to-socket
lookup, thus it can only be determined in lower layers i.e. when
__netlink_alloc_skb() is called that checks internally for this. I
chose to add the extra ldiff parameter as mmap will then still work:
We have data_len and hlen in nfqnl_build_packet_message(), data_len
is the full length (capped at queue->copy_range) for skb_zerocopy()
and hlen some possible part of data_len that needs to be copied; the
rem_len variable indicates the needed remaining linear mmap space.

The only other workaround in nf queue internally would be after
allocation time by f.e. cap'ing the data_len to the skb_tailroom()
iff we deal with an mmap skb, but that would 1) expose the fact that
we use a mmap skb to upper layers, and 2) trim the skb where we
otherwise could just have moved the full skb into the normal receive
queue.

After the patch, in my test case the ring slot doesn't fit and therefore
shows NL_MMAP_STATUS_COPY, where a full skb carries all the data and
thus needs to be picked up via recv().

Fixes: 3ab1f683bf8b ("nfnetlink: add support for memory mapped netlink")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 [ As suggested, leaving out ovs bits for now. ]

 include/linux/netlink.h              | 13 +++++++++++--
 net/netfilter/nfnetlink_queue_core.c |  5 +++--
 net/netlink/af_netlink.c             | 18 ++++++++++++------
 3 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 9120edb..639e9b8 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -68,8 +68,17 @@ extern int netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern void __netlink_clear_multicast_users(struct sock *sk, unsigned int group);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
-extern struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
-					 u32 dst_portid, gfp_t gfp_mask);
+
+extern struct sk_buff *__netlink_alloc_skb(struct sock *ssk, unsigned int size,
+					   unsigned int ldiff, u32 dst_portid,
+					   gfp_t gfp_mask);
+static inline struct sk_buff *
+netlink_alloc_skb(struct sock *ssk, unsigned int size, u32 dst_portid,
+		  gfp_t gfp_mask)
+{
+	return __netlink_alloc_skb(ssk, size, 0, dst_portid, gfp_mask);
+}
+
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 portid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 portid,
 			     __u32 group, gfp_t allocation);
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 685cc6a..a5cd6d9 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -301,7 +301,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			   __be32 **packet_id_ptr)
 {
 	size_t size;
-	size_t data_len = 0, cap_len = 0;
+	size_t data_len = 0, cap_len = 0, rem_len = 0;
 	unsigned int hlen = 0;
 	struct sk_buff *skb;
 	struct nlattr *nla;
@@ -360,6 +360,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 		hlen = min_t(unsigned int, hlen, data_len);
 		size += sizeof(struct nlattr) + hlen;
 		cap_len = entskb->len;
+		rem_len = data_len - hlen;
 		break;
 	}
 
@@ -377,7 +378,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			size += nla_total_size(seclen);
 	}
 
-	skb = nfnetlink_alloc_skb(net, size, queue->peer_portid,
+	skb = __netlink_alloc_skb(net->nfnl, size, rem_len, queue->peer_portid,
 				  GFP_ATOMIC);
 	if (!skb) {
 		skb_tx_error(entskb);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 173817a..7f86d3b 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1844,15 +1844,16 @@ retry:
 }
 EXPORT_SYMBOL(netlink_unicast);
 
-struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
-				  u32 dst_portid, gfp_t gfp_mask)
+struct sk_buff *__netlink_alloc_skb(struct sock *ssk, unsigned int size,
+				    unsigned int ldiff, u32 dst_portid,
+				    gfp_t gfp_mask)
 {
 #ifdef CONFIG_NETLINK_MMAP
+	unsigned int maxlen, linear_size;
 	struct sock *sk = NULL;
 	struct sk_buff *skb;
 	struct netlink_ring *ring;
 	struct nl_mmap_hdr *hdr;
-	unsigned int maxlen;
 
 	sk = netlink_getsockbyportid(ssk, dst_portid);
 	if (IS_ERR(sk))
@@ -1863,7 +1864,11 @@ struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
 	if (ring->pg_vec == NULL)
 		goto out_put;
 
-	if (ring->frame_size - NL_MMAP_HDRLEN < size)
+	/* We need to account the full linear size needed as a ring
+	 * slot cannot have non-linear parts.
+	 */
+	linear_size = size + ldiff;
+	if (ring->frame_size - NL_MMAP_HDRLEN < linear_size)
 		goto out_put;
 
 	skb = alloc_skb_head(gfp_mask);
@@ -1877,13 +1882,14 @@ struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
 
 	/* check again under lock */
 	maxlen = ring->frame_size - NL_MMAP_HDRLEN;
-	if (maxlen < size)
+	if (maxlen < linear_size)
 		goto out_free;
 
 	netlink_forward_ring(ring);
 	hdr = netlink_current_frame(ring, NL_MMAP_STATUS_UNUSED);
 	if (hdr == NULL)
 		goto err2;
+
 	netlink_ring_setup_skb(skb, sk, ring, hdr);
 	netlink_set_status(hdr, NL_MMAP_STATUS_RESERVED);
 	atomic_inc(&ring->pending);
@@ -1909,7 +1915,7 @@ out:
 #endif
 	return alloc_skb(size, gfp_mask);
 }
-EXPORT_SYMBOL_GPL(netlink_alloc_skb);
+EXPORT_SYMBOL_GPL(__netlink_alloc_skb);
 
 int netlink_has_listeners(struct sock *sk, unsigned int group)
 {
-- 
1.9.3
