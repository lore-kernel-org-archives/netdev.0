From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] filter: optimize accesses to ancillary data
Date: Thu, 16 Dec 2010 06:45:28 +0100
Message-ID: <1292478328.2603.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63657 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215Ab0LPFpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 00:45:34 -0500
Received: by wwa36 with SMTP id 36so2065884wwa.1
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 21:45:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can translate pseudo load instructions at filter check time to
dedicated instructions to speed up filtering and avoid one switch().
libpcap currently uses SKF_AD_PROTOCOL, but custom filters probably use
other ancillary accesses.

Note : I made the assertion that ancillary data was always accessed with
BPF_LD|BPF_?|BPF_ABS instructions, not with BPF_LD|BPF_?|BPF_IND ones
(offset given by K constant, not by K + X register)

On x86_64, this saves a few bytes of text :

# size net/core/filter.o.*
   text	   data	    bss	    dec	    hex	filename
   4864	      0	      0	   4864	   1300	net/core/filter.o.new
   4944	      0	      0	   4944	   1350	net/core/filter.o.old

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/filter.c |   72 ++++++++++++++++++++++++++------------------
 1 file changed, 44 insertions(+), 28 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index e8a6ac4..2b27d4e 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -85,6 +85,17 @@ enum {
 	BPF_S_JMP_JGT_X,
 	BPF_S_JMP_JSET_K,
 	BPF_S_JMP_JSET_X,
+	/* Ancillary data */
+	BPF_S_ANC_PROTOCOL,
+	BPF_S_ANC_PKTTYPE,
+	BPF_S_ANC_IFINDEX,
+	BPF_S_ANC_NLATTR,
+	BPF_S_ANC_NLATTR_NEST,
+	BPF_S_ANC_MARK,
+	BPF_S_ANC_QUEUE,
+	BPF_S_ANC_HATYPE,
+	BPF_S_ANC_RXHASH,
+	BPF_S_ANC_CPU,
 };
 
 /* No hurry in this branch */
@@ -107,11 +118,7 @@ static inline void *load_pointer(const struct sk_buff *skb, int k,
 {
 	if (k >= 0)
 		return skb_header_pointer(skb, k, size, buffer);
-	else {
-		if (k >= SKF_AD_OFF)
-			return NULL;
-		return __load_pointer(skb, k, size);
-	}
+	return __load_pointer(skb, k, size);
 }
 
 /**
@@ -269,7 +276,7 @@ load_w:
 				A = get_unaligned_be32(ptr);
 				continue;
 			}
-			break;
+			return 0;
 		case BPF_S_LD_H_ABS:
 			k = K;
 load_h:
@@ -278,7 +285,7 @@ load_h:
 				A = get_unaligned_be16(ptr);
 				continue;
 			}
-			break;
+			return 0;
 		case BPF_S_LD_B_ABS:
 			k = K;
 load_b:
@@ -287,7 +294,7 @@ load_b:
 				A = *(u8 *)ptr;
 				continue;
 			}
-			break;
+			return 0;
 		case BPF_S_LD_W_LEN:
 			A = skb->len;
 			continue;
@@ -338,45 +345,35 @@ load_b:
 		case BPF_S_STX:
 			mem[K] = X;
 			continue;
-		default:
-			WARN_ON(1);
-			return 0;
-		}
-
-		/*
-		 * Handle ancillary data, which are impossible
-		 * (or very difficult) to get parsing packet contents.
-		 */
-		switch (k-SKF_AD_OFF) {
-		case SKF_AD_PROTOCOL:
+		case BPF_S_ANC_PROTOCOL:
 			A = ntohs(skb->protocol);
 			continue;
-		case SKF_AD_PKTTYPE:
+		case BPF_S_ANC_PKTTYPE:
 			A = skb->pkt_type;
 			continue;
-		case SKF_AD_IFINDEX:
+		case BPF_S_ANC_IFINDEX:
 			if (!skb->dev)
 				return 0;
 			A = skb->dev->ifindex;
 			continue;
-		case SKF_AD_MARK:
+		case BPF_S_ANC_MARK:
 			A = skb->mark;
 			continue;
-		case SKF_AD_QUEUE:
+		case BPF_S_ANC_QUEUE:
 			A = skb->queue_mapping;
 			continue;
-		case SKF_AD_HATYPE:
+		case BPF_S_ANC_HATYPE:
 			if (!skb->dev)
 				return 0;
 			A = skb->dev->type;
 			continue;
-		case SKF_AD_RXHASH:
+		case BPF_S_ANC_RXHASH:
 			A = skb->rxhash;
 			continue;
-		case SKF_AD_CPU:
+		case BPF_S_ANC_CPU:
 			A = raw_smp_processor_id();
 			continue;
-		case SKF_AD_NLATTR: {
+		case BPF_S_ANC_NLATTR: {
 			struct nlattr *nla;
 
 			if (skb_is_nonlinear(skb))
@@ -392,7 +389,7 @@ load_b:
 				A = 0;
 			continue;
 		}
-		case SKF_AD_NLATTR_NEST: {
+		case BPF_S_ANC_NLATTR_NEST: {
 			struct nlattr *nla;
 
 			if (skb_is_nonlinear(skb))
@@ -412,6 +409,7 @@ load_b:
 			continue;
 		}
 		default:
+			WARN_ON(1);
 			return 0;
 		}
 	}
@@ -600,6 +598,24 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
 			    pc + ftest->jf + 1 >= flen)
 				return -EINVAL;
 			break;
+		case BPF_S_LD_W_ABS:
+		case BPF_S_LD_H_ABS:
+		case BPF_S_LD_B_ABS:
+#define ANCILLARY(CODE) case SKF_AD_OFF + SKF_AD_##CODE:	\
+				code = BPF_S_ANC_##CODE;	\
+				break
+			switch (ftest->k) {
+			ANCILLARY(PROTOCOL);
+			ANCILLARY(PKTTYPE);
+			ANCILLARY(IFINDEX);
+			ANCILLARY(NLATTR);
+			ANCILLARY(NLATTR_NEST);
+			ANCILLARY(MARK);
+			ANCILLARY(QUEUE);
+			ANCILLARY(HATYPE);
+			ANCILLARY(RXHASH);
+			ANCILLARY(CPU);
+			}
 		}
 		ftest->code = code;
 	}


