From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next] xen-netback: Fix pull size in checksum_setup_ip*
Date: Fri, 29 Nov 2013 18:56:47 +0000
Message-ID: <1385751407-9365-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>,
	<paul.durrant@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Before checksum setup we need to make sure we have enough data in linear
buffer, so we do a pull if not. The calculation of the required data counts
with skb->network_header, which is the headroom size actually. This is not
necessary, and can cause unreasonable pulling. I've also removed
MAX_IPOPTLEN, as we only need the base header at that point.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

---
 drivers/net/xen-netback/netback.c |   24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 919b650..adadf76 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1169,8 +1169,7 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
 
 	off = sizeof(struct iphdr);
 
-	header_size = skb->network_header + off + MAX_IPOPTLEN;
-	maybe_pull_tail(skb, header_size);
+	maybe_pull_tail(skb, off);
 
 	off = iph->ihl * 4;
 
@@ -1183,8 +1182,7 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
 		if (recalculate_partial_csum) {
 			struct tcphdr *tcph = tcp_hdr(skb);
 
-			header_size = skb->network_header +
-				off +
+			header_size = off +
 				sizeof(struct tcphdr);
 			maybe_pull_tail(skb, header_size);
 
@@ -1201,8 +1199,7 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
 		if (recalculate_partial_csum) {
 			struct udphdr *udph = udp_hdr(skb);
 
-			header_size = skb->network_header +
-				off +
+			header_size = off +
 				sizeof(struct udphdr);
 			maybe_pull_tail(skb, header_size);
 
@@ -1241,8 +1238,7 @@ static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
 
 	off = sizeof(struct ipv6hdr);
 
-	header_size = skb->network_header + off;
-	maybe_pull_tail(skb, header_size);
+	maybe_pull_tail(skb, off);
 
 	nexthdr = ipv6h->nexthdr;
 
@@ -1254,8 +1250,7 @@ static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
 		case IPPROTO_ROUTING: {
 			struct ipv6_opt_hdr *hp = (void *)(skb->data + off);
 
-			header_size = skb->network_header +
-				off +
+			header_size = off +
 				sizeof(struct ipv6_opt_hdr);
 			maybe_pull_tail(skb, header_size);
 
@@ -1266,8 +1261,7 @@ static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
 		case IPPROTO_AH: {
 			struct ip_auth_hdr *hp = (void *)(skb->data + off);
 
-			header_size = skb->network_header +
-				off +
+			header_size = off +
 				sizeof(struct ip_auth_hdr);
 			maybe_pull_tail(skb, header_size);
 
@@ -1305,8 +1299,7 @@ static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
 		if (recalculate_partial_csum) {
 			struct tcphdr *tcph = tcp_hdr(skb);
 
-			header_size = skb->network_header +
-				off +
+			header_size = off +
 				sizeof(struct tcphdr);
 			maybe_pull_tail(skb, header_size);
 
@@ -1324,8 +1317,7 @@ static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
 		if (recalculate_partial_csum) {
 			struct udphdr *udph = udp_hdr(skb);
 
-			header_size = skb->network_header +
-				off +
+			header_size = off +
 				sizeof(struct udphdr);
 			maybe_pull_tail(skb, header_size);
 
