From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v3 net-next 08/11] ipv6: Change "final" protocol processing for encapsulation
Date: Fri, 6 May 2016 15:12:03 -0700
Message-ID: <1462572726-566137-9-git-send-email-tom@herbertland.com>
References: <1462572726-566137-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47959 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758994AbcEFWMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 18:12:25 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u46MBCDp009798
	for <netdev@vger.kernel.org>; Fri, 6 May 2016 15:12:24 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 22s3a984k5-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 06 May 2016 15:12:24 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 9b375b2c13d711e6ae7d0002c9521c9e-807fcc50 for <netdev@vger.kernel.org>;	Fri,
 06 May 2016 15:12:22 -0700
In-Reply-To: <1462572726-566137-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When performing foo-over-UDP, UDP are receveived processed by the
encapsulation header which returns another protocol to process.
This may result in processing two (or more) protocols in the
loop that are marked as INET6_PROTO_FINAL. The actions taken
for hitting a final protocol, in particular the skb_postpull_rcsum
can only be performed.

This patch set adds a check of a final protocol has been seen. The
rules are:
  - If the final protocol has not been seen any protocol is processed
    (final and non-final). In the case of a final protocol, the final
    actions are taken (like the skb_postpull_rcsum)
  - If a final protocol has been seen (e.g. an encapsulating UDP
    header) then no further non-final protocols are allowed
    (e.g. extension headers). For more final protocols the
    final actions are not taken (e.g. skb_postpull_rcsum).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_input.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 2a0258a..7d98d01 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -216,6 +216,7 @@ static int ip6_input_finish(struct net *net, struct sock *sk, struct sk_buff *sk
 	unsigned int nhoff;
 	int nexthdr;
 	bool raw;
+	bool have_final = false;
 
 	/*
 	 *	Parse extension headers
@@ -235,9 +236,21 @@ resubmit:
 	if (ipprot) {
 		int ret;
 
-		if (ipprot->flags & INET6_PROTO_FINAL) {
+		if (have_final) {
+			if (!(ipprot->flags & INET6_PROTO_FINAL)) {
+				/* Once we've seen a final protocol don't
+				 * allow encapsulation on any non-final
+				 * ones. This allows foo in UDP encapsulation
+				 * to work.
+				 */
+				goto discard;
+			}
+		} else if (ipprot->flags & INET6_PROTO_FINAL) {
 			const struct ipv6hdr *hdr;
 
+			/* Only do this once for first final protocol */
+			have_final = true;
+
 			/* Free reference early: we don't need it any more,
 			   and it may hold ip_conntrack module loaded
 			   indefinitely. */
-- 
2.8.0.rc2
