From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH v2 net] api: fix compatibility of linux/in.h with
 netinet/in.h
Date: Mon, 29 Jun 2015 14:57:48 -1000
Message-ID: <20150629145748.38bac115@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34861 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124AbbF3A5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 20:57:55 -0400
Received: by iecuq6 with SMTP id uq6so2204828iec.2
        for <netdev@vger.kernel.org>; Mon, 29 Jun 2015 17:57:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

u
This fixes breakage to iproute2 build with recent kernel headers
caused by:
   commit a263653ed798216c0069922d7b5237ca49436007
   Author: Pablo Neira Ayuso <pablo@netfilter.org>
   Date:   Wed Jun 17 10:28:27 2015 -0500

   netfilter: don't pull include/linux/netfilter.h from netns headers

The issue is that definitions in linux/in.h overlap with those
in netinet/in.h. This patch solves this by introducing the same
mechanism as was used to solve the same problem with linux/in6.h

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
v2 -- fixed for iproute2, kernel
      tested on several different orders of includes

 include/uapi/linux/in.h          |   16 +++++++++++++---
 include/uapi/linux/libc-compat.h |   22 ++++++++++++++++++++++
 2 files changed, 35 insertions(+), 3 deletions(-)

--- a/include/uapi/linux/in.h	2015-06-28 16:31:45.179741978 -1000
+++ b/include/uapi/linux/in.h	2015-06-29 14:50:28.018330773 -1000
@@ -19,8 +19,10 @@
 #define _UAPI_LINUX_IN_H
 
 #include <linux/types.h>
+#include <linux/libc-compat.h>
 #include <linux/socket.h>
 
+#if __UAPI_DEF_IN_IPPROTO
 /* Standard well-defined IP protocols.  */
 enum {
   IPPROTO_IP = 0,		/* Dummy protocol for TCP		*/
@@ -75,12 +77,14 @@ enum {
 #define IPPROTO_RAW		IPPROTO_RAW
   IPPROTO_MAX
 };
+#endif
 
-
+#if __UAPI_DEF_IN_ADDR
 /* Internet address. */
 struct in_addr {
 	__be32	s_addr;
 };
+#endif
 
 #define IP_TOS		1
 #define IP_TTL		2
@@ -158,6 +162,7 @@ struct in_addr {
 
 /* Request struct for multicast socket ops */
 
+#if __UAPI_DEF_IP_MREQ
 struct ip_mreq  {
 	struct in_addr imr_multiaddr;	/* IP multicast address of group */
 	struct in_addr imr_interface;	/* local IP address of interface */
@@ -209,14 +214,18 @@ struct group_filter {
 #define GROUP_FILTER_SIZE(numsrc) \
 	(sizeof(struct group_filter) - sizeof(struct __kernel_sockaddr_storage) \
 	+ (numsrc) * sizeof(struct __kernel_sockaddr_storage))
+#endif
 
+#if __UAPI_DEF_IN_PKTINFO
 struct in_pktinfo {
 	int		ipi_ifindex;
 	struct in_addr	ipi_spec_dst;
 	struct in_addr	ipi_addr;
 };
+#endif
 
 /* Structure describing an Internet (IP) socket address. */
+#if  __UAPI_DEF_SOCKADDR_IN
 #define __SOCK_SIZE__	16		/* sizeof(struct sockaddr)	*/
 struct sockaddr_in {
   __kernel_sa_family_t	sin_family;	/* Address family		*/
@@ -228,8 +237,9 @@ struct sockaddr_in {
 			sizeof(unsigned short int) - sizeof(struct in_addr)];
 };
 #define sin_zero	__pad		/* for BSD UNIX comp. -FvK	*/
+#endif
 
-
+#if __UAPI_DEF_IN_CLASS
 /*
  * Definitions of the bits in an Internet address integer.
  * On subnets, host and network parts are found according
@@ -280,7 +290,7 @@ struct sockaddr_in {
 #define INADDR_ALLHOSTS_GROUP 	0xe0000001U	/* 224.0.0.1   */
 #define INADDR_ALLRTRS_GROUP    0xe0000002U	/* 224.0.0.2 */
 #define INADDR_MAX_LOCAL_GROUP  0xe00000ffU	/* 224.0.0.255 */
-
+#endif
 
 /* <asm/byteorder.h> contains the htonl type stuff.. */
 #include <asm/byteorder.h> 
--- a/include/uapi/linux/libc-compat.h	2015-06-28 16:31:45.179741978 -1000
+++ b/include/uapi/linux/libc-compat.h	2015-06-29 14:50:26.066347728 -1000
@@ -56,6 +56,13 @@
 
 /* GLIBC headers included first so don't define anything
  * that would already be defined. */
+#define __UAPI_DEF_IN_ADDR		0
+#define __UAPI_DEF_IN_IPPROTO		0
+#define __UAPI_DEF_IN_PKTINFO		0
+#define __UAPI_DEF_IP_MREQ		0
+#define __UAPI_DEF_SOCKADDR_IN		0
+#define __UAPI_DEF_IN_CLASS		0
+
 #define __UAPI_DEF_IN6_ADDR		0
 /* The exception is the in6_addr macros which must be defined
  * if the glibc code didn't define them. This guard matches
@@ -78,6 +85,13 @@
 /* Linux headers included first, and we must define everything
  * we need. The expectation is that glibc will check the
  * __UAPI_DEF_* defines and adjust appropriately. */
+#define __UAPI_DEF_IN_ADDR		1
+#define __UAPI_DEF_IN_IPPROTO		1
+#define __UAPI_DEF_IN_PKTINFO		1
+#define __UAPI_DEF_IP_MREQ		1
+#define __UAPI_DEF_SOCKADDR_IN		1
+#define __UAPI_DEF_IN_CLASS		1
+
 #define __UAPI_DEF_IN6_ADDR		1
 /* We unconditionally define the in6_addr macros and glibc must
  * coordinate. */
@@ -103,6 +117,14 @@
  * that we need. */
 #else /* !defined(__GLIBC__) */
 
+/* Definitions for in.h */
+#define __UAPI_DEF_IN_ADDR		1
+#define __UAPI_DEF_IN_IPPROTO		1
+#define __UAPI_DEF_IN_PKTINFO		1
+#define __UAPI_DEF_IP_MREQ		1
+#define __UAPI_DEF_SOCKADDR_IN		1
+#define __UAPI_DEF_IN_CLASS		1
+
 /* Definitions for in6.h */
 #define __UAPI_DEF_IN6_ADDR		1
 #define __UAPI_DEF_IN6_ADDR_ALT		1
