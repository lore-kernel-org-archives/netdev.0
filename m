From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6]: Fix suboptimal fragment sizing for last fragment
Date: Fri, 03 Sep 2004 10:40:50 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040903.104050.29603454.yoshfuji@linux-ipv6.org>
References: <4137681D.3000902@trash.net>
	<20040902144436.2c8c1337.davem@redhat.com>
	<20040902220343.GA3250@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, herbert@gondor.apana.org.au
In-Reply-To: <20040902220343.GA3250@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040902220343.GA3250@gondor.apana.org.au> (at Fri, 3 Sep 2004 08:03:44 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> Another thing we can do is to not always fill up the frags in the middle
> and then move bytes off them.  As it is if you do a send that spans
> multiple packets each fragment will be filled up to the full and then
> chopped off when the next one is started.

I think I had similar impression when I saw the Patrick's patch.

Here's the optimization: if we know the remaining data exceeds the
mtu, we do not need to fill up full of it.

skb_prev:
                mtu
+----------+--+-+
|          |  | |
+----------+--+-+
           ^  ^
skb_prev->len |
              maxfraglen

appending data:
           +--------+
           |        |
           +--------+
           --------->
                  length

In this case, we know we need more fragment(s).
So, let's fill up to maxfraglen (instead of mtu) 
to avoid needless copy in the next loop.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv4/ip_output.c 1.67 vs edited =====
--- 1.67/net/ipv4/ip_output.c	2004-09-03 06:50:20 +09:00
+++ edited/net/ipv4/ip_output.c	2004-09-03 10:15:53 +09:00
@@ -811,26 +811,33 @@
 		goto alloc_new_skb;
 
 	while (length > 0) {
-		if ((copy = mtu - skb->len) <= 0) {
+		/* Check if the remaining data fits into current packet. */
+		copy = mtu - skb->len;
+		if (copy < length)
+			copy = maxfraglen - skb->len;
+		if (copy <= 0) {
 			char *data;
 			unsigned int datalen;
 			unsigned int fraglen;
 			unsigned int fraggap;
 			unsigned int alloclen;
 			struct sk_buff *skb_prev;
-			BUG_TRAP(copy == 0);
-
 alloc_new_skb:
 			skb_prev = skb;
-			fraggap = 0;
 			if (skb_prev)
-				fraggap = mtu - maxfraglen;
-
-			datalen = mtu - fragheaderlen;
-			if (datalen > length + fraggap)
-				datalen = length + fraggap;
+				fraggap = skb_prev->len - maxfraglen;
+			else
+				fraggap = 0;
 
+			/*
+			 * If remaining data exceeds the mtu,
+			 * we know we need more fragment(s).
+			 */
+			datalen = length + fraggap;
+			if (datalen > mtu - fragheaderlen)
+				datalen = maxfraglen - fragheaderlen;
 			fraglen = datalen + fragheaderlen;
+
 			if ((flags & MSG_MORE) && 
 			    !(rt->u.dst.dev->features&NETIF_F_SG))
 				alloclen = mtu;
@@ -1026,18 +1033,22 @@
 
 	while (size > 0) {
 		int i;
-		if ((len = mtu - skb->len) <= 0) {
+
+		/* Check if the remaining data fits into current packet. */
+		len = mtu - skb->len;
+		if (len > size)
+			len = maxfraglen - skb->len;
+		if (len <= 0) {
 			struct sk_buff *skb_prev;
 			char *data;
 			struct iphdr *iph;
 			int alloclen;
 
-			BUG_TRAP(len == 0);
-
 			skb_prev = skb;
-			fraggap = 0;
 			if (skb_prev)
-				fraggap = mtu - maxfraglen;
+				fraggap = skb_prev->len - maxfraglen;
+			else
+				fraggap = 0;
 
 			alloclen = fragheaderlen + hh_len + fraggap + 15;
 			skb = sock_wmalloc(sk, alloclen, 1, sk->sk_allocation);
===== net/ipv6/ip6_output.c 1.72 vs edited =====
--- 1.72/net/ipv6/ip6_output.c	2004-09-03 06:50:20 +09:00
+++ edited/net/ipv6/ip6_output.c	2004-09-03 10:24:57 +09:00
@@ -898,26 +898,34 @@
 		goto alloc_new_skb;
 
 	while (length > 0) {
-		if ((copy = mtu - skb->len) <= 0) {
+		/* Check if the remaining data fits into current packet. */
+		copy = mtu - skb->len;
+		if (copy < length)
+			copy = maxfraglen - skb->len;
+
+		if (copy <= 0) {
 			char *data;
 			unsigned int datalen;
 			unsigned int fraglen;
 			unsigned int fraggap;
 			unsigned int alloclen;
 			struct sk_buff *skb_prev;
-			BUG_TRAP(copy == 0);
 alloc_new_skb:
 			skb_prev = skb;
 
 			/* There's no room in the current skb */
-			fraggap = 0;
 			if (skb_prev)
-				fraggap = mtu - maxfraglen;
-
-			datalen = mtu - fragheaderlen;
+				fraggap = skb_prev->len - maxfraglen;
+			else
+				fraggap = 0;
 
-			if (datalen > length + fraggap)
-				datalen = length + fraggap;
+			/*
+			 * If remaining data exceeds the mtu,
+			 * we know we need more fragment(s).
+			 */
+			datalen = length + fraggap;
+			if (datalen > mtu - fragheaderlen)
+				datalen = maxfraglen - fragheaderlen;
 
 			fraglen = datalen + fragheaderlen;
 			if ((flags & MSG_MORE) &&

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
