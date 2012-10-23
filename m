From: Duan Jiong <djduanjiong@gmail.com>
Subject: [PATCH] ipv6: fix the bug when propagating Redirect Message
Date: Tue, 23 Oct 2012 23:26:25 +0800
Message-ID: <5086B721.1090905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:52278 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757091Ab2JWP03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 11:26:29 -0400
Received: by mail-da0-f46.google.com with SMTP id n41so1974323dak.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 08:26:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Before using icmpv6_notify() to propagate redirect, change skb->data
to poing the IP packet that triggered the sending of the Redirect.

Signed-off-by: Duan Jiong <djduanjiong@gmail.com>
---
 net/ipv6/ndisc.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index ff36194..0f73303 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1334,6 +1334,11 @@ out:
 
 static void ndisc_redirect_rcv(struct sk_buff *skb)
 {
+	int opt_len;
+	int opt_offset;
+	int ndisc_head_len;
+	struct nd_opt_hdr *nd_opt;
+	
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	switch (skb->ndisc_nodetype) {
 	case NDISC_NODETYPE_HOST:
@@ -1350,6 +1355,40 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 		return;
 	}
 
+	ndisc_head_len = sizeof(struct icmp6hdr) + 2*sizeof(struct in6_addr);
+	if (!pskb_may_pull(skb, ndisc_head_len)) {
+		return;
+	}
+
+	nd_opt = (struct nd_opt_hdr *)(skb->data + ndisc_head_len);
+
+	opt_len = skb->tail - skb->transport_header - ndisc_head_len;
+	if (opt_len < 0) {
+		return;
+	}
+	while (opt_len) {
+		int l;
+	
+		if (opt_len < sizeof(struct nd_opt_hdr)) {
+			return;
+		}
+		l = nd_opt->nd_opt_len << 3;
+		if (opt_len < l || l == 0) {
+			return;
+		}
+		if (nd_opt->nd_opt_type == ND_OPT_REDIRECT_HDR) {
+			__skb_pull(skb, ndisc_head_len + opt_offset + 8);
+			break;
+		}
+		opt_len -= l;
+		nd_opt = ((void *)nd_opt) + 1;
+		opt_offset += 1;
+	}
+	
+	if (opt_len == 0) {
+		return;
+	}	
+
 	icmpv6_notify(skb, NDISC_REDIRECT, 0, 0);
 }
 
-- 
1.7.4.4
