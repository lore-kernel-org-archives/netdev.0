From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] netfilter6: Skip extension headers when matching icmp6-type
Date: Thu, 30 Sep 2004 14:16:20 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040930121620.GH19083@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


This patch fixes a bug in the ip6_tables code when matching ICMP type and
code within ICMPv6 packets. The icmpv6 packet matcher expects the nexthdr
to be ICMPv6 and does not deal with hop-by-hop headers etc.

Signed-off-by: Olaf Kirch <okir@suse.de>

Index: linux-2.6.8.nf/net/ipv6/netfilter/ip6_tables.c
===================================================================
--- linux-2.6.8.nf.orig/net/ipv6/netfilter/ip6_tables.c	2004-08-26 13:22:35.000000000 +0200
+++ linux-2.6.8.nf/net/ipv6/netfilter/ip6_tables.c	2004-09-30 14:07:51.000000000 +0200
@@ -1751,10 +1751,23 @@
 	   u_int16_t datalen,
 	   int *hotdrop)
 {
-	const struct icmp6hdr *icmp = hdr;
+	struct icmp6hdr icmph;
 	const struct ip6t_icmp *icmpinfo = matchinfo;
+	int hdroff;
+	u8 nexthdr = skb->nh.ipv6h->nexthdr;
 
-	if (offset == 0 && datalen < 2) {
+	/* Must not be a fragment. */
+	if (offset)
+		return 0;
+
+	hdroff = (u8*)(skb->nh.ipv6h+1) - skb->data;
+	hdroff = ipv6_skip_exthdr(skb, hdroff, &nexthdr, skb->len - hdroff);
+	if (hdroff < 0 || hdroff > skb->len || nexthdr != IPPROTO_ICMPV6) {
+		*hotdrop = 1;
+		return 0;
+	}
+
+	if (skb_copy_bits(skb, hdroff, &icmph, sizeof(icmph)) < 0) {
 		/* We've been asked to examine this packet, and we
 		   can't.  Hence, no choice but to drop. */
 		duprintf("Dropping evil ICMP tinygram.\n");
@@ -1763,11 +1776,10 @@
 	}
 
 	/* Must not be a fragment. */
-	return !offset
-		&& icmp6_type_code_match(icmpinfo->type,
+	return icmp6_type_code_match(icmpinfo->type,
 					icmpinfo->code[0],
 					icmpinfo->code[1],
-					icmp->icmp6_type, icmp->icmp6_code,
+					icmph.icmp6_type, icmph.icmp6_code,
 					!!(icmpinfo->invflags&IP6T_ICMP_INV));
 }
 
-- 
Olaf Kirch     | Things that make Monday morning interesting, #1:
okir@suse.de   |        "I want to use NFS over AX25, can you help me?"
---------------+ 
