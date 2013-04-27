From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/18] sctp: Correct type and usage of sctp_end_cksum()
Date: Sat, 27 Apr 2013 20:58:23 +0200
Message-ID: <1367089103-8394-19-git-send-email-pablo@netfilter.org>
References: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42608 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756215Ab3D0S7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 14:59:00 -0400
In-Reply-To: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

Change the type of the crc32 parameter of sctp_end_cksum()
from __be32 to __u32 to reflect that fact that it is passed
to cpu_to_le32().

There are five in-tree users of sctp_end_cksum().
The following four had warnings flagged by sparse which are
no longer present with this change.

net/netfilter/ipvs/ip_vs_proto_sctp.c:sctp_nat_csum()
net/netfilter/ipvs/ip_vs_proto_sctp.c:sctp_csum_check()
net/sctp/input.c:sctp_rcv_checksum()
net/sctp/output.c:sctp_packet_transmit()

The fifth user is net/netfilter/nf_nat_proto_sctp.c:sctp_manip_pkt().
It has been updated to pass a __u32 instead of a __be32,
the value in question was already calculated in cpu byte-order.

net/netfilter/nf_nat_proto_sctp.c:sctp_manip_pkt() has also
been updated to assign the return value of sctp_end_cksum()
directly to a variable of type __le32, matching the
type of the return value. Previously the return value
was assigned to a variable of type __be32 and then that variable
was finally assigned to another variable of type __le32.

Problems flagged by sparse.
Compile and sparse tested only.

Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/sctp/checksum.h       |    2 +-
 net/netfilter/nf_nat_proto_sctp.c |    5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
index befc8d2..5a2110d 100644
--- a/include/net/sctp/checksum.h
+++ b/include/net/sctp/checksum.h
@@ -77,7 +77,7 @@ static inline __u32 sctp_update_cksum(__u8 *buffer, __u16 length, __u32 crc32)
 	return sctp_crc32c(crc32, buffer, length);
 }
 
-static inline __le32 sctp_end_cksum(__be32 crc32)
+static inline __le32 sctp_end_cksum(__u32 crc32)
 {
 	return cpu_to_le32(~crc32);
 }
diff --git a/net/netfilter/nf_nat_proto_sctp.c b/net/netfilter/nf_nat_proto_sctp.c
index e64faa5..396e55d 100644
--- a/net/netfilter/nf_nat_proto_sctp.c
+++ b/net/netfilter/nf_nat_proto_sctp.c
@@ -36,7 +36,7 @@ sctp_manip_pkt(struct sk_buff *skb,
 {
 	struct sk_buff *frag;
 	sctp_sctphdr_t *hdr;
-	__be32 crc32;
+	__u32 crc32;
 
 	if (!skb_make_writable(skb, hdroff + sizeof(*hdr)))
 		return false;
@@ -55,8 +55,7 @@ sctp_manip_pkt(struct sk_buff *skb,
 	skb_walk_frags(skb, frag)
 		crc32 = sctp_update_cksum((u8 *)frag->data, skb_headlen(frag),
 					  crc32);
-	crc32 = sctp_end_cksum(crc32);
-	hdr->checksum = crc32;
+	hdr->checksum = sctp_end_cksum(crc32);
 
 	return true;
 }
-- 
1.7.10.4
