From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: RFC2292(bis) checksum support
Date: Fri, 17 May 2002 01:57:14 +0900
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020517015714M.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi@linux-ipv6.org
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

According to RFC2292 and its successor RFC2292bis, kernel compute and 
store checksum for output, and verify the recieved checksum on input
(and discard it if it is in error) if the socket is for ICMPv6 IPV6_CHECKSUM
socket option is set to the raw socket.  
Linux does not support this.

Note: 

(1) RFC2292bis denies usage of this interface for ICMPv6 socket, but 
we allow it for a single case (offset is 2, which is correct value
for ICMPv6 checksum) for backward compatibility for older applications.

(2) RFC2292bis clarify that positive odd value is invalid, which cause
problems on interoperability.

<draft-ietf-ipngwg-rfc2292bis-07.txt>
3.1.  Checksums

   The kernel will calculate and insert the ICMPv6 checksum for ICMPv6
   raw sockets, since this checksum is mandatory.

   For other raw IPv6 sockets (that is, for raw IPv6 sockets created
   with a third argument other than IPPROTO_ICMPV6), the application
   must set the new IPV6_CHECKSUM socket option to have the kernel (1)
   compute and store a checksum for output, and (2) verify the received
   checksum on input, discarding the packet if the checksum is in error.
   This option prevents applications from having to perform source
   address selection on the packets they send.  The checksum will
   incorporate the IPv6 pseudo-header, defined in Section 8.1 of
   [RFC-2460].  This new socket option also specifies an integer offset
   into the user data of where the checksum is located.

       int  offset = 2;
       setsockopt(fd, IPPROTO_IPV6, IPV6_CHECKSUM, &offset, sizeof(offset));

   By default, this socket option is disabled.  Setting the offset to -1
   also disables the option.  By disabled we mean (1) the kernel will
   not calculate and store a checksum for outgoing packets, and (2) the
   kernel will not verify a checksum for received packets.

   This option assumes the use of the 16-bit one's complement of the
   one's complement sum as the checksum algorithm and that the checksum
   field is aligned on a 16-bit boundary.  Thus, specifying a positive
   odd value as offset is invalid, and setsockopt() will fail for such
   offset values.

   An attempt to set IPV6_CHECKSUM for an ICMPv6 socket will fail.
   Also, an attempt to set or get IPV6_CHECKSUM for a non-raw IPv6
   socket will fail.

   (Note: Since the checksum is always calculated by the kernel for an
   ICMPv6 socket, applications are not able to generate ICMPv6 packets
   with incorrect checksums (presumably for testing purposes) using this
   API.)
</draft-ietf-ipngwg-rfc2292bis-07.txt>

This patch is for linux-2.4.18.

Index: net/ipv6/raw.c
===================================================================
RCS file: /cvsroot/usagi/kernel/linux24/net/ipv6/raw.c,v
retrieving revision 1.1.1.10
retrieving revision 1.1.1.10.6.1
diff -u -r1.1.1.10 -r1.1.1.10.6.1
--- net/ipv6/raw.c	2001/09/24 07:07:15	1.1.1.10
+++ net/ipv6/raw.c	2002/05/16 00:25:21	1.1.1.10.6.1
@@ -11,6 +11,7 @@
  *
  *	Fixes:
  *	Hideaki YOSHIFUJI	:	sin6_scope_id support
+ * 	YOSHIFUJI,H.@USAGI	:	raw checksum (RFC2292(bis)) support
  *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
@@ -278,15 +279,34 @@
 
 static inline int rawv6_rcv_skb(struct sock * sk, struct sk_buff * skb)
 {
-	/* Charge it to the socket. */
-	if (sock_queue_rcv_skb(sk,skb)<0) {
-		IP6_INC_STATS_BH(Ip6InDiscards);
-		kfree_skb(skb);
-		return 0;
+	struct in6_addr *saddr = &skb->nh.ipv6h->saddr;
+	struct in6_addr *daddr = &skb->nh.ipv6h->daddr;
+
+	if (sk->tp_pinfo.tp_raw.checksum) {
+		if (skb->ip_summed == CHECKSUM_HW) {
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			if (csum_ipv6_magic(saddr, daddr, skb->len, sk->num,
+					    skb->csum))
+				skb->ip_summed = CHECKSUM_NONE;
+		}
+		if (skb->ip_summed == CHECKSUM_NONE) {
+			if (csum_ipv6_magic(saddr, daddr, skb->len, sk->num,
+					    skb_checksum(skb, 0, skb->len, 0)))
+				goto discard_it;
+		}
 	}
 
+	/* Charge it to the socket. */
+	if (sock_queue_rcv_skb(sk,skb)<0)
+		goto discard_it;
+
 	IP6_INC_STATS_BH(Ip6InDelivers);
 	return 0;
+
+discard_it:
+	IP6_INC_STATS_BH(Ip6InDiscards);
+	kfree_skb(skb);
+	return 0;
 }
 
 /*
@@ -415,11 +435,19 @@
 		hdr->cksum = csum_ipv6_magic(addr, daddr, hdr->len,
 					     hdr->proto, hdr->cksum);
 		
-		if (opt->offset < len) {
+		if (opt->offset + 1 < len) {
 			__u16 *csum;
 
 			csum = (__u16 *) (buff + opt->offset);
 			*csum = hdr->cksum;
+			if (*csum) {
+				/* in case cksum was not initialized */
+				__u32 sum = hdr->cksum;
+				sum += *csum;
+				*csum = hdr->cksum = (sum + (sum>>16));
+			} else {
+				*csum = hdr->cksum;
+			}
 		} else {
 			if (net_ratelimit())
 				printk(KERN_DEBUG "icmp: cksum offset too big\n");
@@ -647,6 +675,12 @@
 
 	switch (optname) {
 		case IPV6_CHECKSUM:
+			if (sk->num == IPPROTO_ICMPV6 && val != 2)
+				return(-EINVAL);
+			/* You may get strange result with a positive odd offset;
+			   RFC2292bis agrees with me. */
+			if (val > 0 && (val&1))
+				return(-EINVAL);
 			if (val < 0) {
 				opt->checksum = 0;
 			} else {
@@ -744,6 +778,11 @@
 
 static int rawv6_init_sk(struct sock *sk)
 {
+	if (sk->num == IPPROTO_ICMPV6){
+		struct raw6_opt *opt = &sk->tp_pinfo.tp_raw;
+		opt->checksum = 1;
+		opt->offset = 2;
+	}
 	return(0);
 }
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
