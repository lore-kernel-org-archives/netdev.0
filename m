From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: fix calculation of option len in ip6_append_data
Date: Sun, 11 May 2014 23:01:13 +0200
Message-ID: <1399842073-1072-1-git-send-email-hannes@stressinduktion.org>
Cc: preobr@google.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from new2-smtp.messagingengine.com ([66.111.4.224]:43702 "EHLO
	new2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756516AbaEKVBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 17:01:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tot_len does specify the size of struct ipv6_txoptions. We need opt_flen +
opt_nflen to calculate the overall length of additional ipv6 extensions.

I found this while auditing the ipv6 output path for a memory corruption
reported by Alexey Preobrazhensky while he fuzzed an instrumented
AddressSanitizer kernel with trinity. This may or may not be the cause
of the original bug.

Fixes: 4df98e76cde7c6 ("ipv6: pmtudisc setting not respected with UFO/CORK")
Reported-by: Alexey Preobrazhensky <preobr@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
Also material for stable, thanks!

 net/ipv6/ip6_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 31a38bd..fbf1156 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1229,7 +1229,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		unsigned int maxnonfragsize, headersize;
 
 		headersize = sizeof(struct ipv6hdr) +
-			     (opt ? opt->tot_len : 0) +
+			     (opt ? opt->opt_flen + opt->opt_nflen : 0) +
 			     (dst_allfrag(&rt->dst) ?
 			      sizeof(struct frag_hdr) : 0) +
 			     rt->rt6i_nfheader_len;
-- 
1.9.0
