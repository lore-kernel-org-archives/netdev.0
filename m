From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6]: Fix suboptimal fragment sizing for last fragment
Date: Thu, 02 Sep 2004 20:36:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4137681D.3000902@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050003050700070306040006"
Cc: yoshfuji@linux-ipv6.org, Herbert Xu <herbert@debian.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050003050700070306040006
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Yoshifuji's recent fragment patch prevents unnecessary fragmentation
when the data can be kept in a single packet, but only for the first
packet. When fragmenting, all fragments are still truncated to
multiples of 8 and we might end up creating an unnecessary fragment.

This dump shows the problem (MTU 1499):

172.16.1.123.32771 > 172.16.195.3.4135: udp 2937 (frag 7066:1472@0+)
172.16.1.123 > 172.16.195.3: udp (frag 7066:1472@1472+)
172.16.1.123 > 172.16.195.3: udp (frag 7066:1@2944)

This patch always builds mtu sized fragments and truncates the previous
fragment to a multiple of 8 bytes when allocating a new one. With the
patch the dump looks like this:


172.16.1.123.32772 > 172.16.195.3.4135: udp 2937 (frag 49641:1472@0+)
172.16.1.123 > 172.16.195.3: udp (frag 49641:1473@1472)

Regards
Patrick


--------------050003050700070306040006
Content-Type: text/x-patch;
 name="frag.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="frag.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/02 17:35:32+02:00 kaber@coreworks.de 
#   [IPV4/IPV6]: Fix suboptimal fragment sizing for last fragment
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv6/ip6_output.c
#   2004/09/02 17:35:14+02:00 kaber@coreworks.de +13 -22
#   [IPV4/IPV6]: Fix suboptimal fragment sizing for last fragment
# 
# net/ipv4/ip_output.c
#   2004/09/02 17:35:14+02:00 kaber@coreworks.de +20 -49
#   [IPV4/IPV6]: Fix suboptimal fragment sizing for last fragment
# 
diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	2004-09-02 17:39:01 +02:00
+++ b/net/ipv4/ip_output.c	2004-09-02 17:39:01 +02:00
@@ -735,10 +735,10 @@
 	int hh_len;
 	int exthdrlen;
 	int mtu;
-	int copy = 0;
+	int copy;
 	int err;
 	int offset = 0;
-	unsigned int maxfraglen, fragheaderlen, fraggap = 0;
+	unsigned int maxfraglen, fragheaderlen;
 	int csummode = CHECKSUM_NONE;
 
 	if (flags&MSG_PROBE)
@@ -781,6 +781,7 @@
 	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
+	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
 
 	if (inet->cork.length + length > 0xFFFF - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu-exthdrlen);
@@ -788,26 +789,11 @@
 	}
 
 	/*
-	 * Let's try using as much space as possible to avoid generating
-	 * additional unnecessary small fragment of length 
-	 * (mtu-fragheaderlen)%8 if mtu-fragheaderlen is not 0 modulo 8.
-	 * -- yoshfuji
-	 */
-	if (fragheaderlen + inet->cork.length + length <= mtu)
-		maxfraglen = mtu;
-	else
-		maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
-
-	if (fragheaderlen + inet->cork.length <= mtu &&
-	    fragheaderlen + inet->cork.length + length > mtu)
-		fraggap = 1;
-
-	/*
 	 * transhdrlen > 0 means that this is the first fragment and we wish
 	 * it won't be fragmented in the future.
 	 */
 	if (transhdrlen &&
-	    length + fragheaderlen <= maxfraglen &&
+	    length + fragheaderlen <= mtu &&
 	    rt->u.dst.dev->features&(NETIF_F_IP_CSUM|NETIF_F_NO_CSUM|NETIF_F_HW_CSUM) &&
 	    !exthdrlen)
 		csummode = CHECKSUM_HW;
@@ -821,34 +807,33 @@
 	 * adding appropriate IP header.
 	 */
 
-	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL) {
-		fraggap = 0;
+	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL)
 		goto alloc_new_skb;
-	}
 
 	while (length > 0) {
-		if ((copy = maxfraglen - skb->len) <= 0) {
+		if ((copy = mtu - skb->len) <= 0) {
 			char *data;
 			unsigned int datalen;
 			unsigned int fraglen;
+			unsigned int fraggap;
 			unsigned int alloclen;
 			struct sk_buff *skb_prev;
-			BUG_TRAP(fraggap || copy == 0);
+			BUG_TRAP(copy == 0);
 
 alloc_new_skb:
 			skb_prev = skb;
+			fraggap = 0;
+			if (skb_prev)
+				fraggap = mtu - maxfraglen;
 
-			if (fraggap)
-				fraggap = -copy;
-
-			datalen = maxfraglen - fragheaderlen;
+			datalen = mtu - fragheaderlen;
 			if (datalen > length + fraggap)
 				datalen = length + fraggap;
 
 			fraglen = datalen + fragheaderlen;
 			if ((flags & MSG_MORE) && 
 			    !(rt->u.dst.dev->features&NETIF_F_SG))
-				alloclen = maxfraglen;
+				alloclen = mtu;
 			else
 				alloclen = datalen + fragheaderlen;
 
@@ -913,7 +898,6 @@
 			length -= datalen - fraggap;
 			transhdrlen = 0;
 			exthdrlen = 0;
-			fraggap = 0;
 			csummode = CHECKSUM_NONE;
 
 			/*
@@ -1006,7 +990,7 @@
 	int mtu;
 	int len;
 	int err;
-	unsigned int maxfraglen, fragheaderlen, fraggap = 0;
+	unsigned int maxfraglen, fragheaderlen, fraggap;
 
 	if (inet->hdrincl)
 		return -EPERM;
@@ -1028,27 +1012,13 @@
 	mtu = inet->cork.fragsize;
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
+	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
 
 	if (inet->cork.length + size > 0xFFFF - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu);
 		return -EMSGSIZE;
 	}
 
-	/*
-	 * Let's try using as much space as possible to avoid generating
-	 * additional unnecessary small fragment of length 
-	 * (mtu-fragheaderlen)%8 if mtu-fragheaderlen is not 0 modulo 8.
-	 * -- yoshfuji
-	 */
-	if (fragheaderlen + inet->cork.length + size <= mtu)
-		maxfraglen = mtu;
-	else
-		maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
-
-	if (fragheaderlen + inet->cork.length <= mtu &&
-	    fragheaderlen + inet->cork.length + size > mtu)
-		fraggap = 1;
-
 	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL)
 		return -EINVAL;
 
@@ -1056,17 +1026,18 @@
 
 	while (size > 0) {
 		int i;
-		if ((len = maxfraglen - skb->len) <= 0) {
+		if ((len = mtu - skb->len) <= 0) {
 			struct sk_buff *skb_prev;
 			char *data;
 			struct iphdr *iph;
 			int alloclen;
 
-			BUG_TRAP(fraggap || len == 0);
+			BUG_TRAP(len == 0);
 
 			skb_prev = skb;
-			if (fraggap)
-				fraggap = -len;
+			fraggap = 0;
+			if (skb_prev)
+				fraggap = mtu - maxfraglen;
 
 			alloclen = fragheaderlen + hh_len + fraggap + 15;
 			skb = sock_wmalloc(sk, alloclen, 1, sk->sk_allocation);
diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	2004-09-02 17:39:01 +02:00
+++ b/net/ipv6/ip6_output.c	2004-09-02 17:39:01 +02:00
@@ -814,11 +814,11 @@
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff *skb;
-	unsigned int maxfraglen, fragheaderlen, fraggap = 0;
+	unsigned int maxfraglen, fragheaderlen;
 	int exthdrlen;
 	int hh_len;
 	int mtu;
-	int copy = 0;
+	int copy;
 	int err;
 	int offset = 0;
 	int csummode = CHECKSUM_NONE;
@@ -867,6 +867,7 @@
 	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
 
 	fragheaderlen = sizeof(struct ipv6hdr) + (opt ? opt->opt_nflen : 0);
+	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
 
 	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
 		if (inet->cork.length + length > sizeof(struct ipv6hdr) + IPV6_MAXPLEN - fragheaderlen) {
@@ -883,46 +884,37 @@
 	 *
 	 * Note that we may need to "move" the data from the tail of
 	 * of the buffer to the new fragment when we split 
-	 * the message at the first time.
+	 * the message.
 	 *
 	 * FIXME: It may be fragmented into multiple chunks 
 	 *        at once if non-fragmentable extension headers
 	 *        are too large.
 	 * --yoshfuji 
 	 */
-	if (fragheaderlen + inet->cork.length + length <= mtu)
-		maxfraglen = mtu;
-	else
-		maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen 
-			     - sizeof(struct frag_hdr);
-
-	if (fragheaderlen + inet->cork.length <= mtu &&
-	    fragheaderlen + inet->cork.length + length > mtu)
-		fraggap = 1;
 
 	inet->cork.length += length;
 
-	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL) {
-		fraggap = 0;
+	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL)
 		goto alloc_new_skb;
-	}
 
 	while (length > 0) {
-		if ((copy = maxfraglen - skb->len) <= 0) {
+		if ((copy = mtu - skb->len) <= 0) {
 			char *data;
 			unsigned int datalen;
 			unsigned int fraglen;
+			unsigned int fraggap;
 			unsigned int alloclen;
 			struct sk_buff *skb_prev;
-			BUG_TRAP(fraggap || copy == 0);
+			BUG_TRAP(copy == 0);
 alloc_new_skb:
 			skb_prev = skb;
 
 			/* There's no room in the current skb */
-			if (fraggap)
-				fraggap = -copy;
+			fraggap = 0;
+			if (skb_prev)
+				fraggap = mtu - maxfraglen;
 
-			datalen = maxfraglen - fragheaderlen;
+			datalen = mtu - fragheaderlen;
 
 			if (datalen > length + fraggap)
 				datalen = length + fraggap;
@@ -930,7 +922,7 @@
 			fraglen = datalen + fragheaderlen;
 			if ((flags & MSG_MORE) &&
 			    !(rt->u.dst.dev->features&NETIF_F_SG))
-				alloclen = maxfraglen;
+				alloclen = mtu;
 			else
 				alloclen = datalen + fragheaderlen;
 
@@ -1005,7 +997,6 @@
 			length -= datalen - fraggap;
 			transhdrlen = 0;
 			exthdrlen = 0;
-			fraggap = 0;
 			csummode = CHECKSUM_NONE;
 
 			/*

--------------050003050700070306040006--
