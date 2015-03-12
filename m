From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next ] mpls:  In mpls_egress verify the packet length.
Date: Thu, 12 Mar 2015 15:54:52 -0500
Message-ID: <87wq2mym03.fsf_-_@x220.int.ebiederm.org>
References: <1426078702-23246-1-git-send-email-rshearma@brocade.com>
	<87sidba1ea.fsf@x220.int.ebiederm.org> <5500BB5E.4070909@brocade.com>
	<87385a13jz.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "davem\@davemloft.net" <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41519 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932089AbbCLU6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 16:58:33 -0400
In-Reply-To: <87385a13jz.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 12 Mar 2015 13:19:44 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Robert Shearman noticed that mpls_egress is failing to verify that
the bytes to be examined are in fact present in the packet before
mpls_egress reads those bytes.

Reported-by: Robert Shearman <rshearma@brocade.com>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/mpls/af_mpls.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 0ad8f7141be2..d5882c5c176b 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -92,17 +92,25 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
 	 * The strange cases if we choose to support them will require
 	 * manual configuration.
 	 */
-	struct iphdr *hdr4 = ip_hdr(skb);
+	struct iphdr *hdr4;
 	bool success = true;
 
-	if (hdr4->version == 4) {
+	/* If the packet is empty we can't do anything */
+	if (!pskb_may_pull(skb, 1))
+		return false;
+
+	/* Use ip_hdr to find the ip protocol version */
+	hdr4 = ip_hdr(skb);
+	if ((hdr4->version == 4) &&
+	    pskb_may_pull(skb, sizeof(struct iphdr))) {
 		skb->protocol = htons(ETH_P_IP);
 		csum_replace2(&hdr4->check,
 			      htons(hdr4->ttl << 8),
 			      htons(dec.ttl << 8));
 		hdr4->ttl = dec.ttl;
 	}
-	else if (hdr4->version == 6) {
+	else if ((hdr4->version == 6) &&
+		 pskb_may_pull(skb, sizeof(struct ipv6hdr))) {
 		struct ipv6hdr *hdr6 = ipv6_hdr(skb);
 		skb->protocol = htons(ETH_P_IPV6);
 		hdr6->hop_limit = dec.ttl;
-- 
2.2.1
