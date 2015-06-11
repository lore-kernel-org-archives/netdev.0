From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: tcp: dctcp_update_alpha() fixes.
Date: Wed, 10 Jun 2015 22:11:17 -0700
Message-ID: <1433999477.27504.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f193.google.com ([209.85.223.193]:33736 "EHLO
	mail-ie0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbbFKFLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 01:11:20 -0400
Received: by ierx19 with SMTP id x19so963971ier.0
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 22:11:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

dctcp_alpha can be read by from dctcp_get_info() without
synchro, so use WRITE_ONCE() to prevent compiler from using
dctcp_alpha as a temporary variable.

Also, playing with small dctcp_shift_g (like 1), can expose
an overflow with 32bit values shifted 9 times before divide.

Use an u64 field to avoid this problem, and perform the divide
only if acked_bytes_ecn is not zero.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_dctcp.c |   26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_dctcp.c b/net/ipv4/tcp_dctcp.c
index 4c41c1287197eb4748198ae9532d1f6233aa7f6a..7092a61c4dc8465fcf17ff71b289cf25bbb8b559 100644
--- a/net/ipv4/tcp_dctcp.c
+++ b/net/ipv4/tcp_dctcp.c
@@ -204,20 +204,26 @@ static void dctcp_update_alpha(struct sock *sk, u32 flags)
 
 	/* Expired RTT */
 	if (!before(tp->snd_una, ca->next_seq)) {
-		/* For avoiding denominator == 1. */
-		if (ca->acked_bytes_total == 0)
-			ca->acked_bytes_total = 1;
+		u64 bytes_ecn = ca->acked_bytes_ecn;
+		u32 alpha = ca->dctcp_alpha;
 
 		/* alpha = (1 - g) * alpha + g * F */
-		ca->dctcp_alpha = ca->dctcp_alpha -
-				  (ca->dctcp_alpha >> dctcp_shift_g) +
-				  (ca->acked_bytes_ecn << (10U - dctcp_shift_g)) /
-				  ca->acked_bytes_total;
 
-		if (ca->dctcp_alpha > DCTCP_MAX_ALPHA)
-			/* Clamp dctcp_alpha to max. */
-			ca->dctcp_alpha = DCTCP_MAX_ALPHA;
+		alpha -= alpha >> dctcp_shift_g;
+		if (bytes_ecn) {
+			/* If dctcp_shift_g == 1, a 32bit value would overflow
+			 * after 8 Mbytes.
+			 */
+			bytes_ecn <<= (10 - dctcp_shift_g);
+			do_div(bytes_ecn, max(1U, ca->acked_bytes_total));
 
+			alpha = min(alpha + (u32)bytes_ecn, DCTCP_MAX_ALPHA);
+		}
+		/* dctcp_alpha can be read from dctcp_get_info() without
+		 * synchro, so we ask compiler to not use dctcp_alpha
+		 * as a temporary variable in prior operations.
+		 */
+		WRITE_ONCE(ca->dctcp_alpha, alpha);
 		dctcp_reset(tp, ca);
 	}
 }
