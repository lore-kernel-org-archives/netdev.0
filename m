From: Andrew Shewmaker <agshew@gmail.com>
Subject: [PATCH] allow dctcp alpha to drop to zero
Date: Sun, 18 Oct 2015 21:59:08 -0700
Message-ID: <20151019045908.GB11368@mininet-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Glenn Judd <glenn.judd@morganstanley.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34982 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752907AbbJSE7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 00:59:12 -0400
Received: by iofz202 with SMTP id z202so33867349iof.2
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 21:59:11 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If alpha is strictly reduced by alpha >> dctcp_shift_g and if alpha is less
than 1 << dctcp_shift_g, then alpha may never reach zero. For example,
given shift_g=4 and alpha=15, alpha >> dctcp_shift_g yields 0 and alpha
remains 15. The effect isn't noticeable in this case below cwnd=137, but
could gradually drive uncongested flows with leftover alpha down to
cwnd=137. A larger dctcp_shift_g would have a greater effect.

This change causes alpha=15 to drop to 0 instead of being decrementing by 1
as it would when alpha=16. However, it requires one less conditional to
implement since it doesn't have to guard against subtracting 1 from 0U. A
decay of 15 is not unreasonable since an equal or greater amount occurs at
alpha >= 240.

Signed-off-by: Andrew G. Shewmaker <agshew@gmail.com>
---
 net/ipv4/tcp_dctcp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_dctcp.c b/net/ipv4/tcp_dctcp.c
index 7092a61..7e538f7 100644
--- a/net/ipv4/tcp_dctcp.c
+++ b/net/ipv4/tcp_dctcp.c
@@ -209,7 +209,7 @@ static void dctcp_update_alpha(struct sock *sk, u32 flags)
 
 		/* alpha = (1 - g) * alpha + g * F */
 
-		alpha -= alpha >> dctcp_shift_g;
+		alpha -= min_not_zero(alpha, alpha >> dctcp_shift_g);
 		if (bytes_ecn) {
 			/* If dctcp_shift_g == 1, a 32bit value would overflow
 			 * after 8 Mbytes.
-- 
1.9.1
