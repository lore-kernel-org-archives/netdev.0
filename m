From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp: return sizeof tcp_dctcp_info in dctcp_get_info()
Date: Mon, 13 Jun 2016 11:20:35 -0400
Message-ID: <1465831235-29876-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:36104 "EHLO
	mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423894AbcFMP0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 11:26:21 -0400
Received: by mail-qt0-f181.google.com with SMTP id 37so35828140qtc.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 08:26:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure that dctcp_get_info() returns only the size of the
info->dctcp struct that it zeroes out and fills in. Previously it had
been returning the size of the enclosing tcp_cc_info union,
sizeof(*info).  There is no problem yet, but that union that may one
day be larger than struct tcp_dctcp_info, in which case the
TCP_CC_INFO code might accidentally copy uninitialized bytes from the
stack.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_dctcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_dctcp.c b/net/ipv4/tcp_dctcp.c
index 7e538f7..10d728b 100644
--- a/net/ipv4/tcp_dctcp.c
+++ b/net/ipv4/tcp_dctcp.c
@@ -293,7 +293,7 @@ static size_t dctcp_get_info(struct sock *sk, u32 ext, int *attr,
 	 */
 	if (ext & (1 << (INET_DIAG_DCTCPINFO - 1)) ||
 	    ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
-		memset(info, 0, sizeof(struct tcp_dctcp_info));
+		memset(&info->dctcp, 0, sizeof(info->dctcp));
 		if (inet_csk(sk)->icsk_ca_ops != &dctcp_reno) {
 			info->dctcp.dctcp_enabled = 1;
 			info->dctcp.dctcp_ce_state = (u16) ca->ce_state;
@@ -303,7 +303,7 @@ static size_t dctcp_get_info(struct sock *sk, u32 ext, int *attr,
 		}
 
 		*attr = INET_DIAG_DCTCPINFO;
-		return sizeof(*info);
+		return sizeof(info->dctcp);
 	}
 	return 0;
 }
-- 
2.8.0.rc3.226.g39d4020
