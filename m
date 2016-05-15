From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v5 net-next 03/14] ipv6: Fix nexthdr for reinjection
Date: Sun, 15 May 2016 16:42:24 -0700
Message-ID: <1463355755-3481375-4-git-send-email-tom@herbertland.com>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33879 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751871AbcEOXmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 19:42:50 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4FNfmdk020352
	for <netdev@vger.kernel.org>; Sun, 15 May 2016 16:42:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22wyb3mw56-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 15 May 2016 16:42:49 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 bb190a5a1af611e6a12624be0595f910-d34ebc50 for <netdev@vger.kernel.org>;	Sun,
 15 May 2016 16:42:48 -0700
In-Reply-To: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ip6_input_finish the nexthdr protocol is retrieved from the
next header offset that is returned in the cb of the skb.
This method does not work for UDP encapsulation that may not
even have a concept of a nexthdr field (e.g. FOU).

This patch checks for a final protocol (INET6_PROTO_FINAL) when a
protocol handler returns > 1. If the protocol is not final then
resubmission is performed on nhoff value. If the protocol is final
then the nexthdr is taken to be the return value.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_input.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index f185cbc..d35dff2 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -236,6 +236,7 @@ resubmit:
 	nhoff = IP6CB(skb)->nhoff;
 	nexthdr = skb_network_header(skb)[nhoff];
 
+resubmit_final:
 	raw = raw6_local_deliver(skb, nexthdr);
 	ipprot = rcu_dereference(inet6_protos[nexthdr]);
 	if (ipprot) {
@@ -263,10 +264,21 @@ resubmit:
 			goto discard;
 
 		ret = ipprot->handler(skb);
-		if (ret > 0)
-			goto resubmit;
-		else if (ret == 0)
+		if (ret > 0) {
+			if (ipprot->flags & INET6_PROTO_FINAL) {
+				/* Not an extension header, most likely UDP
+				 * encapsulation. Use return value as nexthdr
+				 * protocol not nhoff (which presumably is
+				 * not set by handler).
+				 */
+				nexthdr = ret;
+				goto resubmit_final;
+			} else {
+				goto resubmit;
+			}
+		} else if (ret == 0) {
 			__IP6_INC_STATS(net, idev, IPSTATS_MIB_INDELIVERS);
+		}
 	} else {
 		if (!raw) {
 			if (xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-- 
2.8.0.rc2
