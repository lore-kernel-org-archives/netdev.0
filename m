From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2 2/2] nf_nat: don't check if the tuple is unique when there isn't any other choice
Date: Sat, 31 Jul 2010 15:09:24 +0800
Message-ID: <1280560164-30783-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the tuple got from unique_tuple() doesn't need to be really unique, so the
check for the unique tuple isn't necessary, when there isn't any other
choice. Eliminating the unnecessary nf_nat_used_tuple() can save some CPU
cycles too.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ipv4/netfilter/nf_nat_proto_common.c |    4 ++--
 net/ipv4/netfilter/nf_nat_proto_gre.c    |    4 ++--
 net/ipv4/netfilter/nf_nat_proto_icmp.c   |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)
diff --git a/net/ipv4/netfilter/nf_nat_proto_common.c b/net/ipv4/netfilter/nf_nat_proto_common.c
index 2844a03..95aa286 100644
--- a/net/ipv4/netfilter/nf_nat_proto_common.c
+++ b/net/ipv4/netfilter/nf_nat_proto_common.c
@@ -81,9 +81,9 @@ void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
 	else
 		off = *rover;
 
-	for (i = 0; i < range_size; i++, off++) {
+	for (i = 0; ; ++off) {
 		*portptr = htons(min + off % range_size);
-		if (nf_nat_used_tuple(tuple, ct))
+		if (++i != range_size && nf_nat_used_tuple(tuple, ct))
 			continue;
 		if (!(range->flags & IP_NAT_RANGE_PROTO_RANDOM))
 			*rover = off;
diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
index 89933ab..1669be6 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -68,9 +68,9 @@ gre_unique_tuple(struct nf_conntrack_tuple *tuple,
 
 	pr_debug("min = %u, range_size = %u\n", min, range_size);
 
-	for (i = 0; i < range_size; i++, key++) {
+	for (i = 0; ; ++key) {
 		*keyptr = htons(min + key % range_size);
-		if (!nf_nat_used_tuple(tuple, ct))
+		if (++i == range_size || !nf_nat_used_tuple(tuple, ct))
 			return;
 	}
 
diff --git a/net/ipv4/netfilter/nf_nat_proto_icmp.c b/net/ipv4/netfilter/nf_nat_proto_icmp.c
index 97003fe..f6b07c9 100644
--- a/net/ipv4/netfilter/nf_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_icmp.c
@@ -42,10 +42,10 @@ icmp_unique_tuple(struct nf_conntrack_tuple *tuple,
 	if (!(range->flags & IP_NAT_RANGE_PROTO_SPECIFIED))
 		range_size = 0xFFFF;
 
-	for (i = 0; i < range_size; i++, id++) {
+	for (i = 0; ; ++id) {
 		tuple->src.u.icmp.id = htons(ntohs(range->min.icmp.id) +
 					     (id % range_size));
-		if (!nf_nat_used_tuple(tuple, ct))
+		if (++i == range_size || !nf_nat_used_tuple(tuple, ct))
 			return;
 	}
 	return;
