From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] ila: Fix checksum neutral mapping
Date: Tue, 14 Jun 2016 16:29:15 -0700
Message-ID: <1465946955-3088294-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <haoxuany@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51768 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752181AbcFNX3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 19:29:20 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5ENQ6la013398
	for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 16:29:20 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 23jq7q1au4-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 16:29:20 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 d09bab32328711e699a124be0595f910-60bd5b00 for <netdev@vger.kernel.org>;	Tue,
 14 Jun 2016 16:29:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The algorithm for checksum neutral mapping is incorrect. This problem
was being hidden since we were previously always performing checksum
offload on the translated addresses and only with IPv6 HW csum.
Enabling an ILA router shows the issue.

Corrected algorithm:

old_loc is the original locator in the packet, new_loc is the value
to overwrite with and is found in the lookup table. old_flag is
the old flag value (zero of CSUM_NEUTRAL_FLAG) and new_flag is
then (old_flag ^ CSUM_NEUTRAL_FLAG) & CSUM_NEUTRAL_FLAG.

Need SUM(new_id + new_flag + diff) == SUM(old_id + old_flag) for
checksum neutral translation.

Solving for diff gives:

diff = (old_id - new_id) + (old_flag - new_flag)

compute_csum_diff8(new_id, old_id) gives old_id - new_id

If old_flag is set
   old_flag - new_flag = old_flag = CSUM_NEUTRAL_FLAG
Else
   old_flag - new_flag = -new_flag = ~CSUM_NEUTRAL_FLAG

Tested:
  - Implemented a user space program that creates random addresses
    and random locators to overwrite. Compares the checksum over
    the address before and after translation (must always be equal)
  - Enabled ILA router and showed proper operation.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ila/ila_common.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ila/ila_common.c b/net/ipv6/ila/ila_common.c
index b3d00be..ec9efbc 100644
--- a/net/ipv6/ila/ila_common.c
+++ b/net/ipv6/ila/ila_common.c
@@ -34,12 +34,12 @@ static void ila_csum_do_neutral(struct ila_addr *iaddr,
 	if (p->locator_match.v64) {
 		diff = p->csum_diff;
 	} else {
-		diff = compute_csum_diff8((__be32 *)iaddr,
-					  (__be32 *)&p->locator);
+		diff = compute_csum_diff8((__be32 *)&p->locator,
+					  (__be32 *)iaddr);
 	}
 
 	fval = (__force __wsum)(ila_csum_neutral_set(iaddr->ident) ?
-			~CSUM_NEUTRAL_FLAG : CSUM_NEUTRAL_FLAG);
+			CSUM_NEUTRAL_FLAG : ~CSUM_NEUTRAL_FLAG);
 
 	diff = csum_add(diff, fval);
 
@@ -140,8 +140,8 @@ void ila_init_saved_csum(struct ila_params *p)
 		return;
 
 	p->csum_diff = compute_csum_diff8(
-				(__be32 *)&p->locator_match,
-				(__be32 *)&p->locator);
+				(__be32 *)&p->locator,
+				(__be32 *)&p->locator_match);
 }
 
 static int __init ila_init(void)
-- 
2.8.0.rc2
