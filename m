From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: use macro for maximum payload length
Date: Tue, 24 Jun 2003 12:40:21 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030624.124021.119708603.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Use macro for maximum payload length.
Patch is against "[PATCH] [IPV6] clean-up advmss calculation" patch.

Thanks.

Index: linux-2.5/include/net/ipv6.h
===================================================================
RCS file: /home/cvs/linux-2.5/include/net/ipv6.h,v
retrieving revision 1.19
diff -u -r1.19 ipv6.h
--- linux-2.5/include/net/ipv6.h	9 Jun 2003 17:26:52 -0000	1.19
+++ linux-2.5/include/net/ipv6.h	24 Jun 2003 01:58:26 -0000
@@ -23,6 +23,8 @@
 
 #define SIN6_LEN_RFC2133	24
 
+#define IPV6_MAXPLEN		65535
+
 /*
  *	NextHeader field of IPv6 header
  */
Index: linux-2.5/net/ipv6/exthdrs.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/exthdrs.c,v
retrieving revision 1.13
diff -u -r1.13 exthdrs.c
--- linux-2.5/net/ipv6/exthdrs.c	20 May 2003 06:49:54 -0000	1.13
+++ linux-2.5/net/ipv6/exthdrs.c	24 Jun 2003 01:58:26 -0000
@@ -432,7 +432,7 @@
 	}
 
 	pkt_len = ntohl(*(u32*)(skb->nh.raw+optoff+2));
-	if (pkt_len < 0x10000) {
+	if (pkt_len <= IPV6_MAXPLEN) {
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff+2);
 		return 0;
 	}
Index: linux-2.5/net/ipv6/ip6_output.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ip6_output.c,v
retrieving revision 1.29
diff -u -r1.29 ip6_output.c
--- linux-2.5/net/ipv6/ip6_output.c	21 Jun 2003 16:20:41 -0000	1.29
+++ linux-2.5/net/ipv6/ip6_output.c	24 Jun 2003 01:58:27 -0000
@@ -621,7 +621,7 @@
 		if (opt)
 			pktlength += opt->opt_flen + opt->opt_nflen;
 
-		if (pktlength > 0xFFFF + sizeof(struct ipv6hdr)) {
+		if (pktlength > sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
 			/* Jumbo datagram.
 			   It is assumed, that in the case of hdrincl
 			   jumbo option is supplied by user.
@@ -1264,8 +1264,8 @@
 	fragheaderlen = sizeof(struct ipv6hdr) + (opt ? opt->opt_nflen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
 
-	if (mtu < 65576) {
-		if (inet->cork.length + length > 0xFFFF - fragheaderlen) {
+	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
+		if (inet->cork.length + length > IPV6_MAXPLEN - fragheaderlen) {
 			ipv6_local_error(sk, EMSGSIZE, fl, mtu-exthdrlen);
 			return -EMSGSIZE;
 		}
@@ -1461,7 +1461,7 @@
 	
 	*(u32*)hdr = fl->fl6_flowlabel | htonl(0x60000000);
 
-	if (skb->len < 65536)
+	if (skb->len <= IPV6_MAXPLEN)
 		hdr->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 	else
 		hdr->payload_len = 0;
Index: linux-2.5/net/ipv6/reassembly.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/reassembly.c,v
retrieving revision 1.16
diff -u -r1.16 reassembly.c
--- linux-2.5/net/ipv6/reassembly.c	21 Jun 2003 16:16:59 -0000	1.16
+++ linux-2.5/net/ipv6/reassembly.c	24 Jun 2003 01:58:27 -0000
@@ -425,7 +425,7 @@
 	end = offset + (ntohs(skb->nh.ipv6h->payload_len) -
 			((u8 *) (fhdr + 1) - (u8 *) (skb->nh.ipv6h + 1)));
 
-	if ((unsigned int)end >= 65536) {
+	if ((unsigned int)end > IPV6_MAXPLEN) {
  		icmpv6_param_prob(skb,ICMPV6_HDR_FIELD, (u8*)&fhdr->frag_off - skb->nh.raw);
  		return;
 	}
@@ -597,7 +597,7 @@
 
 	/* Unfragmented part is taken from the first segment. */
 	payload_len = (head->data - head->nh.raw) - sizeof(struct ipv6hdr) + fq->len - sizeof(struct frag_hdr);
-	if (payload_len > 65535)
+	if (payload_len > IPV6_MAXPLEN)
 		goto out_oversize;
 
 	/* Head of list must not be cloned. */
Index: linux-2.5/net/ipv6/route.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/route.c,v
retrieving revision 1.40
diff -u -r1.40+ route.c
--- linux-2.5/net/ipv6/route.c	Tue Jun 24 12:10:22 2003
+++ linux-2.5/net/ipv6/route.c	Tue Jun 24 12:11:23 2003
@@ -606,13 +606,13 @@
 		mtu = ip6_rt_min_advmss;
 
 	/*
-	 * Maximal non-jumbo IPv6 payload is 65535 and 
-	 * corresponding MSS is 65535 - tcp_header_size. 
-	 * 65535 is also valid and means: "any MSS, 
+	 * Maximal non-jumbo IPv6 payload is IPV6_MAXPLEN and 
+	 * corresponding MSS is IPV6_MAXPLEN - tcp_header_size. 
+	 * IPV6_MAXPLEN is also valid and means: "any MSS, 
 	 * rely only on pmtu discovery"
 	 */
-	if (mtu > 65535 - sizeof(struct tcphdr))
-		mtu = 65535;
+	if (mtu > IPV6_MAXPLEN - sizeof(struct tcphdr))
+		mtu = IPV6_MAXPLEN;
 	return mtu;
 }
 


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
