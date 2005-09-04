From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel 2.6.13 breaks libpcap (and tcpdump).
Date: Sun, 04 Sep 2005 18:21:09 +1000
Message-ID: <E1EBpkT-0001RP-00@gondolin.me.apana.org.au>
References: <20050902172719.4eaaa6db.akpm@osdl.org>
Cc: jmcgowan@inch.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751291AbVIDIVZ@vger.kernel.org>
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20050902172719.4eaaa6db.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> 
>>  Filter incoming data, looking for ICMP messages:
>>  
>>   tcpdump -f "ip proto \icmp"
>>  
>> Well, that catches nothing.

We aren't handling the reading of specific fields like the IP protocol
field correctly.  This patch should make it work again.

I tried to move this logic into the new load_pointer function but it
all came out messy so I simply rolled it back.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/filter.c b/net/core/filter.c
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -36,7 +36,7 @@
 #include <linux/filter.h>
 
 /* No hurry in this branch */
-static void *__load_pointer(struct sk_buff *skb, int k)
+static void *load_pointer(struct sk_buff *skb, int k)
 {
 	u8 *ptr = NULL;
 
@@ -50,18 +50,6 @@ static void *__load_pointer(struct sk_bu
 	return NULL;
 }
 
-static inline void *load_pointer(struct sk_buff *skb, int k,
-                                 unsigned int size, void *buffer)
-{
-	if (k >= 0)
-		return skb_header_pointer(skb, k, size, buffer);
-	else {
-		if (k >= SKF_AD_OFF)
-			return NULL;
-		return __load_pointer(skb, k);
-	}
-}
-
 /**
  *	sk_run_filter	- 	run a filter on a socket
  *	@skb: buffer to run the filter on
@@ -177,7 +165,13 @@ int sk_run_filter(struct sk_buff *skb, s
 		case BPF_LD|BPF_W|BPF_ABS:
 			k = fentry->k;
  load_w:
-			ptr = load_pointer(skb, k, 4, &tmp);
+			if (k >= 0)
+				ptr = skb_header_pointer(skb, k, 4, &tmp);
+			else if (k < SKF_AD_OFF)
+				ptr = load_pointer(skb, k);
+			else
+				break;
+
 			if (ptr != NULL) {
 				A = ntohl(*(u32 *)ptr);
 				continue;
@@ -186,7 +180,13 @@ int sk_run_filter(struct sk_buff *skb, s
 		case BPF_LD|BPF_H|BPF_ABS:
 			k = fentry->k;
  load_h:
-			ptr = load_pointer(skb, k, 2, &tmp);
+			if (k >= 0)
+				ptr = skb_header_pointer(skb, k, 2, &tmp);
+			else if (k < SKF_AD_OFF)
+				ptr = load_pointer(skb, k);
+			else
+				break;
+
 			if (ptr != NULL) {
 				A = ntohs(*(u16 *)ptr);
 				continue;
@@ -195,7 +195,13 @@ int sk_run_filter(struct sk_buff *skb, s
 		case BPF_LD|BPF_B|BPF_ABS:
 			k = fentry->k;
 load_b:
-			ptr = load_pointer(skb, k, 1, &tmp);
+			if (k >= 0)
+				ptr = skb_header_pointer(skb, k, 1, &tmp);
+			else if (k < SKF_AD_OFF)
+				ptr = load_pointer(skb, k);
+			else
+				break;
+
 			if (ptr != NULL) {
 				A = *(u8 *)ptr;
 				continue;
@@ -217,7 +223,9 @@ load_b:
 			k = X + fentry->k;
 			goto load_b;
 		case BPF_LDX|BPF_B|BPF_MSH:
-			ptr = load_pointer(skb, fentry->k, 1, &tmp);
+			if (fentry->k < 0)
+				return 0;
+			ptr = skb_header_pointer(skb, fentry->k, 1, &tmp);
 			if (ptr != NULL) {
 				X = (*(u8 *)ptr & 0xf) << 2;
 				continue;
