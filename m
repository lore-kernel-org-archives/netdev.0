From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/5] netfilter: nft_nat: Fix endianness issue reported by sparse
Date: Mon,  4 Nov 2013 23:05:18 +0100
Message-ID: <1383602721-5728-3-git-send-email-pablo@netfilter.org>
References: <1383602721-5728-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1383602721-5728-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>

This patch fixes this:

CHECK   net/netfilter/nft_nat.c
net/netfilter/nft_nat.c:50:43: warning: incorrect type in assignment (different base types)
net/netfilter/nft_nat.c:50:43:    expected restricted __be32 [addressable] [usertype] ip
net/netfilter/nft_nat.c:50:43:    got unsigned int [unsigned] [usertype] <noident>
net/netfilter/nft_nat.c:51:43: warning: incorrect type in assignment (different base types)
net/netfilter/nft_nat.c:51:43:    expected restricted __be32 [addressable] [usertype] ip
net/netfilter/nft_nat.c:51:43:    got unsigned int [unsigned] [usertype] <noident>
net/netfilter/nft_nat.c:65:37: warning: incorrect type in assignment (different base types)
net/netfilter/nft_nat.c:65:37:    expected restricted __be16 [addressable] [assigned] [usertype] all
net/netfilter/nft_nat.c:65:37:    got unsigned int [unsigned] <noident>
net/netfilter/nft_nat.c:66:37: warning: incorrect type in assignment (different base types)
net/netfilter/nft_nat.c:66:37:    expected restricted __be16 [addressable] [assigned] [usertype] all
net/netfilter/nft_nat.c:66:37:    got unsigned int [unsigned] <noident>

Signed-off-by: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_nat.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nft_nat.c b/net/netfilter/nft_nat.c
index b0b87b2..d3b1ffe 100644
--- a/net/netfilter/nft_nat.c
+++ b/net/netfilter/nft_nat.c
@@ -47,8 +47,10 @@ static void nft_nat_eval(const struct nft_expr *expr,
 	memset(&range, 0, sizeof(range));
 	if (priv->sreg_addr_min) {
 		if (priv->family == AF_INET) {
-			range.min_addr.ip = data[priv->sreg_addr_min].data[0];
-			range.max_addr.ip = data[priv->sreg_addr_max].data[0];
+			range.min_addr.ip = (__force __be32)
+					data[priv->sreg_addr_min].data[0];
+			range.max_addr.ip = (__force __be32)
+					data[priv->sreg_addr_max].data[0];
 
 		} else {
 			memcpy(range.min_addr.ip6,
@@ -62,8 +64,10 @@ static void nft_nat_eval(const struct nft_expr *expr,
 	}
 
 	if (priv->sreg_proto_min) {
-		range.min_proto.all = data[priv->sreg_proto_min].data[0];
-		range.max_proto.all = data[priv->sreg_proto_max].data[0];
+		range.min_proto.all = (__force __be16)
+					data[priv->sreg_proto_min].data[0];
+		range.max_proto.all = (__force __be16)
+					data[priv->sreg_proto_max].data[0];
 		range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 
-- 
1.7.10.4

