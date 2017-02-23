From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/8] netfilter: xt_hashlimit: Fix integer divide round to zero.
Date: Thu, 23 Feb 2017 12:14:07 +0100
Message-ID: <1487848449-2731-7-git-send-email-pablo@netfilter.org>
References: <1487848449-2731-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54926 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751277AbdBWLOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 06:14:25 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 1E7D1A4181
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:23 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0A2B1DA849
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:23 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A797DDA85A
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:20 +0100 (CET)
In-Reply-To: <1487848449-2731-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alban Browaeys <alban.browaeys@gmail.com>

Diving the divider by the multiplier before applying to the input.
When this would "divide by zero", divide the multiplier by the divider
first then multiply the input by this value.

Currently user2creds outputs zero when input value is bigger than the
number of slices and  lower than scale.
This as then user input is applied an integer divide operation to
a number greater than itself (scale).
That rounds up to zero, then we multiply zero by the credits slice size.

  iptables -t filter -I INPUT --protocol tcp --match hashlimit
  --hashlimit 40/second --hashlimit-burst 20 --hashlimit-mode srcip
  --hashlimit-name syn-flood --jump RETURN

thus trigger the overflow detection code:

xt_hashlimit: overflow, try lower: 25000/20

(25000 as hashlimit avg and 20 the burst)

Here:
134217 slices of (HZ * CREDITS_PER_JIFFY) size.
500000 is user input value
1000000 is XT_HASHLIMIT_SCALE_v2
gives: 0 as user2creds output
Setting burst to "1" typically solve the issue ...
but setting it to "40" does too !

This is on 32bit arch calling into revision 2 of hashlimit.

Signed-off-by: Alban Browaeys <alban.browaeys@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_hashlimit.c | 25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 10063408141d..84ad5ab34558 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -463,23 +463,16 @@ static u32 xt_hashlimit_len_to_chunks(u32 len)
 /* Precision saver. */
 static u64 user2credits(u64 user, int revision)
 {
-	if (revision == 1) {
-		/* If multiplying would overflow... */
-		if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY_v1))
-			/* Divide first. */
-			return div64_u64(user, XT_HASHLIMIT_SCALE)
-				* HZ * CREDITS_PER_JIFFY_v1;
-
-		return div64_u64(user * HZ * CREDITS_PER_JIFFY_v1,
-				 XT_HASHLIMIT_SCALE);
-	} else {
-		if (user > 0xFFFFFFFFFFFFFFFFULL / (HZ*CREDITS_PER_JIFFY))
-			return div64_u64(user, XT_HASHLIMIT_SCALE_v2)
-				* HZ * CREDITS_PER_JIFFY;
+	u64 scale = (revision == 1) ?
+		XT_HASHLIMIT_SCALE : XT_HASHLIMIT_SCALE_v2;
+	u64 cpj = (revision == 1) ?
+		CREDITS_PER_JIFFY_v1 : CREDITS_PER_JIFFY;
 
-		return div64_u64(user * HZ * CREDITS_PER_JIFFY,
-				 XT_HASHLIMIT_SCALE_v2);
-	}
+	/* Avoid overflow: divide the constant operands first */
+	if (scale >= HZ * cpj)
+		return div64_u64(user, div64_u64(scale, HZ * cpj));
+
+	return user * div64_u64(HZ * cpj, scale);
 }
 
 static u32 user2credits_byte(u32 user)
-- 
2.1.4
