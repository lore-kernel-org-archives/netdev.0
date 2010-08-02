From: kaber@trash.net
Subject: [PATCH 27/28] netfilter: nf_nat: don't check if the tuple is unique when there isn't any other choice
Date: Mon,  2 Aug 2010 21:57:44 +0200
Message-ID: <1280779065-9333-28-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

The tuple got from unique_tuple() doesn't need to be really unique, so the
check for the unique tuple isn't necessary, when there isn't any other
choice. Eliminating the unnecessary nf_nat_used_tuple() can save some CPU
cycles too.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_proto_common.c |    4 ++--
 net/ipv4/netfilter/nf_nat_proto_gre.c    |    4 ++--
 net/ipv4/netfilter/nf_nat_proto_icmp.c   |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_proto_common.c b/net/ipv4/netfilter/nf_nat_proto_common.c
index 2844a03..3e61faf 100644
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
index 89933ab..bc8d83a 100644
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
index 97003fe..5744c3e 100644
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
-- 
1.7.1

