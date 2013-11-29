From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net v3] xen-netback: fix fragment detection in checksum setup
Date: Fri, 29 Nov 2013 10:52:08 +0000
Message-ID: <1385722328-32875-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:19853 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780Ab3K2KwT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Nov 2013 05:52:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code to detect fragments in checksum_setup() was missing for IPv4 and
too eager for IPv6. (It transpires that Windows seems to send IPv6 packets
with a fragment header even if they are not a fragment - i.e. offset is zero,
and M bit is not set).

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
---
v3
- Use defined values for 'fragment offset' and 'more fragments'

v2
- Added comments noting what fragment/offset masks mean


 drivers/net/xen-netback/netback.c |   31 ++++++++++++++++++++++++++++---
 include/net/ipv6.h                |    3 ++-
 2 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 64f0e0d..53419f6 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1166,15 +1166,27 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
 	struct iphdr *iph = (void *)skb->data;
 	unsigned int header_size;
 	unsigned int off;
+	bool fragment;
 	int err = -EPROTO;
 
+	fragment = false;
+
 	off = sizeof(struct iphdr);
 
 	header_size = skb->network_header + off + MAX_IPOPTLEN;
 	maybe_pull_tail(skb, header_size);
 
+	if (iph->frag_off & htons(IP_OFFSET | IP_MF))
+		fragment = true;
+
 	off = iph->ihl * 4;
 
+	if (fragment) {
+		if (net_ratelimit())
+			netdev_err(vif->dev, "Packet is a fragment!\n");
+		goto out;
+	}
+
 	switch (iph->protocol) {
 	case IPPROTO_TCP:
 		if (!skb_partial_csum_set(skb, off,
@@ -1238,6 +1250,7 @@ static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
 	bool fragment;
 	bool done;
 
+	fragment = false;
 	done = false;
 
 	off = sizeof(struct ipv6hdr);
@@ -1276,9 +1289,21 @@ static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
 			off += (hp->hdrlen+2)<<2;
 			break;
 		}
-		case IPPROTO_FRAGMENT:
-			fragment = true;
-			/* fall through */
+		case IPPROTO_FRAGMENT: {
+			struct frag_hdr *hp = (void *)(skb->data + off);
+
+			header_size = skb->network_header +
+				off +
+				sizeof(struct frag_hdr);
+			maybe_pull_tail(skb, header_size);
+
+			if (hp->frag_off & htons(IP6_OFFSET | IP6_MF))
+				fragment = true;
+
+			nexthdr = hp->nexthdr;
+			off += sizeof(struct frag_hdr);
+			break;
+		}
 		default:
 			done = true;
 			break;
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index eb198ac..488316e 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -110,7 +110,8 @@ struct frag_hdr {
 	__be32	identification;
 };
 
-#define	IP6_MF	0x0001
+#define	IP6_MF		0x0001
+#define	IP6_OFFSET	0xFFF8
 
 #include <net/sock.h>
 
-- 
1.7.10.4
