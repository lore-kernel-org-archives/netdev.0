From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/12] netfilter: nf_nat: add full port randomization support
Date: Mon,  6 Jan 2014 00:13:00 +0100
Message-ID: <1388963586-5049-7-git-send-email-pablo@netfilter.org>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56241 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752085AbaAEXNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 18:13:24 -0500
In-Reply-To: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

We currently use prandom_u32() for allocation of ports in tcp bind(0)
and udp code. In case of plain SNAT we try to keep the ports as is
or increment on collision.

SNAT --random mode does use per-destination incrementing port
allocation. As a recent paper pointed out in [1] that this mode of
port allocation makes it possible to an attacker to find the randomly
allocated ports through a timing side-channel in a socket overloading
attack conducted through an off-path attacker.

So, NF_NAT_RANGE_PROTO_RANDOM actually weakens the port randomization
in regard to the attack described in this paper. As we need to keep
compatibility, add another flag called NF_NAT_RANGE_PROTO_RANDOM_FULLY
that would replace the NF_NAT_RANGE_PROTO_RANDOM hash-based port
selection algorithm with a simple prandom_u32() in order to mitigate
this attack vector. Note that the lfsr113's internal state is
periodically reseeded by the kernel through a local secure entropy
source.

More details can be found in [1], the basic idea is to send bursts
of packets to a socket to overflow its receive queue and measure
the latency to detect a possible retransmit when the port is found.
Because of increasing ports to given destination and port, further
allocations can be predicted. This information could then be used by
an attacker for e.g. for cache-poisoning, NS pinning, and degradation
of service attacks against DNS servers [1]:

  The best defense against the poisoning attacks is to properly
  deploy and validate DNSSEC; DNSSEC provides security not only
  against off-path attacker but even against MitM attacker. We hope
  that our results will help motivate administrators to adopt DNSSEC.
  However, full DNSSEC deployment make take significant time, and
  until that happens, we recommend short-term, non-cryptographic
  defenses. We recommend to support full port randomisation,
  according to practices recommended in [2], and to avoid
  per-destination sequential port allocation, which we show may be
  vulnerable to derandomisation attacks.

Joint work between Hannes Frederic Sowa and Daniel Borkmann.

 [1] https://sites.google.com/site/hayashulman/files/NIC-derandomisation.pdf
 [2] http://arxiv.org/pdf/1205.5190v1.pdf

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_nat.h |   12 ++++++++----
 net/netfilter/nf_nat_core.c           |    4 ++--
 net/netfilter/nf_nat_proto_common.c   |   10 ++++++----
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_nat.h b/include/uapi/linux/netfilter/nf_nat.h
index bf0cc37..1ad3659 100644
--- a/include/uapi/linux/netfilter/nf_nat.h
+++ b/include/uapi/linux/netfilter/nf_nat.h
@@ -4,10 +4,14 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/nf_conntrack_tuple_common.h>
 
-#define NF_NAT_RANGE_MAP_IPS		1
-#define NF_NAT_RANGE_PROTO_SPECIFIED	2
-#define NF_NAT_RANGE_PROTO_RANDOM	4
-#define NF_NAT_RANGE_PERSISTENT		8
+#define NF_NAT_RANGE_MAP_IPS			(1 << 0)
+#define NF_NAT_RANGE_PROTO_SPECIFIED		(1 << 1)
+#define NF_NAT_RANGE_PROTO_RANDOM		(1 << 2)
+#define NF_NAT_RANGE_PERSISTENT			(1 << 3)
+#define NF_NAT_RANGE_PROTO_RANDOM_FULLY		(1 << 4)
+
+#define NF_NAT_RANGE_PROTO_RANDOM_ALL		\
+	(NF_NAT_RANGE_PROTO_RANDOM | NF_NAT_RANGE_PROTO_RANDOM_FULLY)
 
 struct nf_nat_ipv4_range {
 	unsigned int			flags;
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 63a8154..d3f5cd6 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -315,7 +315,7 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 	 * manips not an issue.
 	 */
 	if (maniptype == NF_NAT_MANIP_SRC &&
-	    !(range->flags & NF_NAT_RANGE_PROTO_RANDOM)) {
+	    !(range->flags & NF_NAT_RANGE_PROTO_RANDOM_ALL)) {
 		/* try the original tuple first */
 		if (in_range(l3proto, l4proto, orig_tuple, range)) {
 			if (!nf_nat_used_tuple(orig_tuple, ct)) {
@@ -339,7 +339,7 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 	 */
 
 	/* Only bother mapping if it's not already in range and unique */
-	if (!(range->flags & NF_NAT_RANGE_PROTO_RANDOM)) {
+	if (!(range->flags & NF_NAT_RANGE_PROTO_RANDOM_ALL)) {
 		if (range->flags & NF_NAT_RANGE_PROTO_SPECIFIED) {
 			if (l4proto->in_range(tuple, maniptype,
 					      &range->min_proto,
diff --git a/net/netfilter/nf_nat_proto_common.c b/net/netfilter/nf_nat_proto_common.c
index 9baaf73..83a72a2 100644
--- a/net/netfilter/nf_nat_proto_common.c
+++ b/net/netfilter/nf_nat_proto_common.c
@@ -74,22 +74,24 @@ void nf_nat_l4proto_unique_tuple(const struct nf_nat_l3proto *l3proto,
 		range_size = ntohs(range->max_proto.all) - min + 1;
 	}
 
-	if (range->flags & NF_NAT_RANGE_PROTO_RANDOM)
+	if (range->flags & NF_NAT_RANGE_PROTO_RANDOM) {
 		off = l3proto->secure_port(tuple, maniptype == NF_NAT_MANIP_SRC
 						  ? tuple->dst.u.all
 						  : tuple->src.u.all);
-	else
+	} else if (range->flags & NF_NAT_RANGE_PROTO_RANDOM_FULLY) {
+		off = prandom_u32();
+	} else {
 		off = *rover;
+	}
 
 	for (i = 0; ; ++off) {
 		*portptr = htons(min + off % range_size);
 		if (++i != range_size && nf_nat_used_tuple(tuple, ct))
 			continue;
-		if (!(range->flags & NF_NAT_RANGE_PROTO_RANDOM))
+		if (!(range->flags & NF_NAT_RANGE_PROTO_RANDOM_ALL))
 			*rover = off;
 		return;
 	}
-	return;
 }
 EXPORT_SYMBOL_GPL(nf_nat_l4proto_unique_tuple);
 
-- 
1.7.10.4
