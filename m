From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] flow_dissector: fix ipv6 dst, hop-by-hop and
 routing ext hdrs
Date: Fri, 12 Jun 2015 19:31:32 -0700
Message-ID: <1434162692.27504.111.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434124866-3881537-1-git-send-email-tom@herbertland.com>
	 <1434124866-3881537-3-git-send-email-tom@herbertland.com>
	 <20150613012752.GA9895@Alexeis-MacBook-Pro.local>
	 <1434159454.27504.101.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150613015004.GA9918@Alexeis-MacBook-Pro.local>
	 <1434161476.27504.105.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150613021534.GA9942@Alexeis-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Tom Herbert <tom@herbertland.com>,
	edumazet@google.com, netdev@vger.kernel.org,
	dan.carpenter@oracle.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35651 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818AbbFMCbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 22:31:35 -0400
Received: by pdbnf5 with SMTP id nf5so34300520pdb.2
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 19:31:34 -0700 (PDT)
In-Reply-To: <20150613021534.GA9942@Alexeis-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

__skb_header_pointer() returns a pointer that must be checked.

Fixes infinite loop reported by Alexei, and add __must_check to
catch these errors earlier.

Fixes: 6a74fcf426f5 ("flow_dissector: add support for dst, hop-by-hop and routing ext hdrs")
Reported-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Tested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h    |    9 +++++----
 net/core/flow_dissector.c |    6 ++++--
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cc612fc0a8943ec853b92e6b3516b0e5582299e2..a7acc92aa6685d7006077510697e3d9481b02588 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2743,8 +2743,9 @@ __wsum __skb_checksum(const struct sk_buff *skb, int offset, int len,
 __wsum skb_checksum(const struct sk_buff *skb, int offset, int len,
 		    __wsum csum);
 
-static inline void *__skb_header_pointer(const struct sk_buff *skb, int offset,
-					 int len, void *data, int hlen, void *buffer)
+static inline void * __must_check
+__skb_header_pointer(const struct sk_buff *skb, int offset,
+		     int len, void *data, int hlen, void *buffer)
 {
 	if (hlen - offset >= len)
 		return data + offset;
@@ -2756,8 +2757,8 @@ static inline void *__skb_header_pointer(const struct sk_buff *skb, int offset,
 	return buffer;
 }
 
-static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
-				       int len, void *buffer)
+static inline void * __must_check
+skb_header_pointer(const struct sk_buff *skb, int offset, int len, void *buffer)
 {
 	return __skb_header_pointer(skb, offset, len, skb->data,
 				    skb_headlen(skb), buffer);
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 22e4dffa0c8b3b9a20a7324eae1627313e14ce30..476e5dda59e19822dba98a931369ff2666c59c0d 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -394,9 +394,11 @@ ip_proto_again:
 
 		opthdr = __skb_header_pointer(skb, nhoff, sizeof(_opthdr),
 					      data, hlen, &_opthdr);
+		if (!opthdr)
+			return false;
 
-		ip_proto = _opthdr[0];
-		nhoff += (_opthdr[1] + 1) << 3;
+		ip_proto = opthdr[0];
+		nhoff += (opthdr[1] + 1) << 3;
 
 		goto ip_proto_again;
 	}
