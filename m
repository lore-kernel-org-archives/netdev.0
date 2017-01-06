From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] dccp: fix option range in dccp_parse_options()
Date: Fri, 06 Jan 2017 08:43:29 -0800
Message-ID: <1483721009.9712.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34817 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753574AbdAFQnc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 11:43:32 -0500
Received: by mail-pg0-f68.google.com with SMTP id i5so44519275pgh.2
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 08:43:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

dccp_parse_options() improperly parses 12 or 16 bytes in excess,
because it forgets to subtract DCCP header len.

This causes various issues, since these 12/16 bytes are part of the
payload and this might not even be present in skb->head, as
dccp_invalid_packet() only pulled everything but payload.

KASAN complains since we might access uninitialized data.

Strangely enough, net/netfilter/xt_dccp.c got this right.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/options.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/dccp/options.c b/net/dccp/options.c
index 74d29c56c36709fd4e31f0e63a1f8b1aa38a32cd..41bd4bc4026f97b155e12a3a37095653836ce7fc 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -54,10 +54,9 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 	struct dccp_sock *dp = dccp_sk(sk);
 	const struct dccp_hdr *dh = dccp_hdr(skb);
 	const u8 pkt_type = DCCP_SKB_CB(skb)->dccpd_type;
-	unsigned char *options = (unsigned char *)dh + dccp_hdr_len(skb);
-	unsigned char *opt_ptr = options;
-	const unsigned char *opt_end = (unsigned char *)dh +
-					(dh->dccph_doff * 4);
+	unsigned char *opt_ptr = (unsigned char *)dh + __dccp_hdr_len(dh);
+	unsigned int optlen = dh->dccph_doff * 4 - __dccp_hdr_len(dh);
+	const unsigned char *opt_end = opt_ptr + optlen;
 	struct dccp_options_received *opt_recv = &dp->dccps_options_received;
 	unsigned char opt, len;
 	unsigned char *uninitialized_var(value);
