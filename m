From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 03/14] udp: Don't set skb->encapsulation with RCO
Date: Wed, 4 May 2016 18:02:33 -0700
Message-ID: <1462410164-1953217-4-git-send-email-tom@herbertland.com>
References: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58602 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755348AbcEEBC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 21:02:57 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u450xWB8027375
	for <netdev@vger.kernel.org>; Wed, 4 May 2016 18:02:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 22qh8mkqwt-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 04 May 2016 18:02:56 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1919f238125d11e6b1ad0002c9dfb610-b2eeac50 for <netdev@vger.kernel.org>;	Wed,
 04 May 2016 18:02:54 -0700
In-Reply-To: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When RCO is in effect we want to ensure that the outer checksum is
properly offloaded. Don't set skb->encapsulation in this case to
ensure that checksum offload is later considered for hw_features
instead of hw_enc_features.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv4/udp_offload.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index b556ef6..4eedec6 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -94,11 +94,13 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	do {
 		unsigned int len;
 
-		if (remcsum)
+		if (remcsum) {
 			skb->ip_summed = CHECKSUM_NONE;
-
-		/* Set up inner headers if we are offloading inner checksum */
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			skb->encapsulation = 0;
+		} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			/* Set up inner headers if we are offloading inner
+			 * checksum
+			 */
 			skb_reset_inner_headers(skb);
 			skb->encapsulation = 1;
 		}
-- 
2.8.0.rc2
