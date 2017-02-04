From: Alban Browaeys <alban.browaeys@gmail.com>
Subject: [PATCH] netfilter: xt_hashlimit: Fix integer divide round to zero.
Date: Sat,  4 Feb 2017 23:47:31 +0100
Message-ID: <20170204224731.3222-1-alban.browaeys@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Alban Browaeys <alban.browaeys@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Diving the divider by the multiplier before applying to the input.
When this would "divide by zero", divide the multiplier by the divider
first then multiply the input by this value.

Currently user2creds outputs zero when input value is bigger than the
number of slices and  lower than scale.
This as then user input is applied an integer divide operation to
a number greater than itself (scale).
That rounds up to zero, then we mulitply zero by the credits slice size.
  iptables -t filter -I INPUT --protocol tcp --match hashlimit
  --hashlimit 40/second --hashlimit-burst 20 --hashlimit-mode srcip
  --hashlimit-name syn-flood --jump RETURN
thus trigger the overflow detection code:
xt_hashlimit: overflow, try lower: 25000/20
(25000 as hashlimit avd and 20 the burst)
Here:
134217 slices of (HZ * CREDITS_PER_JIFFY) size.
500000 is user input value
1000000 is XT_HASHLIMIT_SCALE_v2
gives: 0 as user2creds output
Setting burst to "1" typically solve the issue ...
but setting it to "40" does too !

This is on 32bit arch calling into revision 2 of hashlimit.

Signed-off-by: Alban Browaeys <alban.browaeys@gmail.com>
---
 net/netfilter/xt_hashlimit.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 10063408141d..df75ad643eef 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -463,21 +463,19 @@ static u32 xt_hashlimit_len_to_chunks(u32 len)
 /* Precision saver. */
 static u64 user2credits(u64 user, int revision)
 {
+	/* Avoid overflow: divide the constant operands first */
 	if (revision == 1) {
-		/* If multiplying would overflow... */
-		if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY_v1))
-			/* Divide first. */
-			return div64_u64(user, XT_HASHLIMIT_SCALE)
-				* HZ * CREDITS_PER_JIFFY_v1;
+		return div64_u64(user, div64_u64(XT_HASHLIMIT_SCALE,
+			HZ * CREDITS_PER_JIFFY_v1));
 
-		return div64_u64(user * HZ * CREDITS_PER_JIFFY_v1,
+		return user * div64_u64(HZ * CREDITS_PER_JIFFY_v1,
 				 XT_HASHLIMIT_SCALE);
 	} else {
-		if (user > 0xFFFFFFFFFFFFFFFFULL / (HZ*CREDITS_PER_JIFFY))
-			return div64_u64(user, XT_HASHLIMIT_SCALE_v2)
-				* HZ * CREDITS_PER_JIFFY;
+		if (XT_HASHLIMIT_SCALE_v2 >= HZ * CREDITS_PER_JIFFY)
+			return div64_u64(user, div64_u64(XT_HASHLIMIT_SCALE_v2,
+				HZ * CREDITS_PER_JIFFY));
 
-		return div64_u64(user * HZ * CREDITS_PER_JIFFY,
+		return user * div64_u64(HZ * CREDITS_PER_JIFFY,
 				 XT_HASHLIMIT_SCALE_v2);
 	}
 }
-- 
2.11.0

