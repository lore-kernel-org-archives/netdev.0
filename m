From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next ] mpls: In mpls_egress verify the packet length.
Date: Thu, 12 Mar 2015 18:22:59 -0500
Message-ID: <87a8zhztpo.fsf@x220.int.ebiederm.org>
References: <5500BB5E.4070909@brocade.com>
	<87385a13jz.fsf@x220.int.ebiederm.org>
	<87wq2mym03.fsf_-_@x220.int.ebiederm.org>
	<20150312.182558.447886504045770209.davem@davemloft.net>
	<87h9tpzv76.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: rshearma@brocade.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39448 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470AbbCLX0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 19:26:41 -0400
In-Reply-To: <87h9tpzv76.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 12 Mar 2015 17:50:53 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Reobert Shearman noticed that mpls_egress is failing to verify that
the bytes to be examined are in fact present in the packet before
mpls_egress reads those bytes.

As suggested by David Miller reduce this to a single pskb_may_pull
call so that we don't do unnecessary work in the fast path.

Reported-by: Robert Shearman <rshearma@brocade.com>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/mpls/af_mpls.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 0ad8f7141be2..db8a2ea6d4de 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -92,9 +92,24 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
 	 * The strange cases if we choose to support them will require
 	 * manual configuration.
 	 */
-	struct iphdr *hdr4 = ip_hdr(skb);
+	struct iphdr *hdr4;
 	bool success = true;
 
+	/* The IPv4 code below accesses through the IPv4 header
+	 * checksum, which is 12 bytes into the packet.
+	 * The IPv6 code below accesses through the IPv6 hop limit
+	 * which is 8 bytes into the packet.
+	 *
+	 * For all supported cases there should always be at least 12
+	 * bytes of packet data present.  The IPv4 header is 20 bytes
+	 * without options and the IPv6 header is always 40 bytes
+	 * long.
+	 */
+	if (!pskb_may_pull(skb, 12))
+		return false;
+
+	/* Use ip_hdr to find the ip protocol version */
+	hdr4 = ip_hdr(skb);
 	if (hdr4->version == 4) {
 		skb->protocol = htons(ETH_P_IP);
 		csum_replace2(&hdr4->check,
-- 
2.2.1
