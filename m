From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 next-next 04/12] udp: Don't set skb->encapsulation with RCO
Date: Fri, 6 May 2016 13:04:48 -0700
Message-ID: <1462565096-4076043-5-git-send-email-tom@herbertland.com>
References: <1462565096-4076043-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:7008 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758152AbcEFUFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 16:05:31 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u46K2SLV030883
	for <netdev@vger.kernel.org>; Fri, 6 May 2016 13:05:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22rxqt0yjm-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 06 May 2016 13:05:31 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 e1f1933c13c511e6b7640002c99293a0-61c766d0 for <netdev@vger.kernel.org>;	Fri,
 06 May 2016 13:05:30 -0700
In-Reply-To: <1462565096-4076043-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When RCO is in effect we want to ensure that the outer checksum is
properly offloaded. Don't set skb->encapsulation in this case to
ensure that checksum offload is later considered for hw_features
instead of hw_enc_features.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv4/udp_offload.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index b556ef6..92a9222 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -94,11 +94,12 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	do {
 		unsigned int len;
 
-		if (remcsum)
+		if (remcsum) {
 			skb->ip_summed = CHECKSUM_NONE;
-
-		/* Set up inner headers if we are offloading inner checksum */
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			/* Set up inner headers if we are offloading inner
+			 * checksum
+			 */
 			skb_reset_inner_headers(skb);
 			skb->encapsulation = 1;
 		}
-- 
2.8.0.rc2
