From: Rick Jones <rick.jones2@hp.com>
Subject: [PATCH] [RFC] allow admin/users to specify rto_min in milliseconds rather than jiffies
Date: Tue, 4 Sep 2007 13:20:47 -0700 (PDT)
Message-ID: <200709042020.NAA29612@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=X-roman8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:43585 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752310AbXIDUVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2007 16:21:14 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel12.hp.com (Postfix) with ESMTP id 6EEBD35FF8
	for <netdev@vger.kernel.org>; Tue,  4 Sep 2007 13:20:53 -0700 (PDT)
Received: (from raj@localhost)
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) id NAA29612
	for netdev@vger.kernel.org; Tue, 4 Sep 2007 13:20:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Build upon David Miller's initial patches to set the per-route rto_min
so users can specify the rto_min in the same units (milliseconds) in
which they are displayed.  This is desirable because asking users to
convert to and from jiffies themselves, when there can be different
values of HZ from system to system would be error prone.

Signed-off-by: Rick Jones <rick.jones2@hp.com>
---

*** ./lib/utils.c.orig	2007-09-04 13:11:01.000000000 -0700
--- ./lib/utils.c	2007-09-04 13:06:11.000000000 -0700
***************
*** 61,66 ****
--- 61,141 ----
  	return 0;
  }
  
+ /* liberally lifted from kernel/time.c. raj */
+ unsigned int jiffies_to_msecs(const unsigned long j)
+ {
+ 	if (__iproute2_hz_internal == 0)
+ 		__iproute2_hz_internal = __get_hz();
+  
+ 	if ((__iproute2_hz_internal <= 1000) && 
+ 		!(1000 % __iproute2_hz_internal))
+ 		return (1000 / __iproute2_hz_internal) * j;
+ 	else if (__iproute2_hz_internal > 1000 && 
+ 		!(__iproute2_hz_internal % 1000))
+ 		return (j + (__iproute2_hz_internal / 1000) - 1) /
+ 			(__iproute2_hz_internal / 1000);
+ 	else
+         	return (j * 1000) / __iproute2_hz_internal;
+ }
+ 
+ /* liberally lifted from kernel/time.c  raj */
+ unsigned long msecs_to_jiffies(const unsigned int m)
+ {
+ 
+ 	if (__iproute2_hz_internal == 0)
+ 		__iproute2_hz_internal = __get_hz();
+ 
+ 	if (__iproute2_hz_internal <= 1000 && 
+ 		!(1000 % __iproute2_hz_internal))
+         	/*
+          	 * HZ is equal to or smaller than 1000, and 1000 is a nice
+          	 * round multiple of HZ, divide with the factor between them,
+          	 * but round upwards:
+          	 */
+ 		return (m + (1000 / __iproute2_hz_internal) - 1) / 
+ 			(1000 / __iproute2_hz_internal);
+ 	else if (__iproute2_hz_internal > 1000 && 
+ 		!(__iproute2_hz_internal % 1000)) {
+         	/*
+           	 * HZ is larger than 1000, and HZ is a nice round multiple of
+          	 * 1000 - simply multiply with the factor between them.
+          	 *
+          	 * But first make sure the multiplication result cannot
+          	 * overflow:
+          	 */
+         	if (m > jiffies_to_msecs(MAX_JIFFY_OFFSET))
+                 	return MAX_JIFFY_OFFSET;
+ 
+ 		return m * (__iproute2_hz_internal / 1000);
+ 	}
+ 	else {
+         	/*
+          	 * Generic case - multiply, round and divide. But first
+          	 * check that if we are doing a net multiplication, that
+          	 * we wouldnt overflow:
+          	 */
+         	if (__iproute2_hz_internal > 1000 && 
+ 			m > jiffies_to_msecs(MAX_JIFFY_OFFSET))
+                 	return MAX_JIFFY_OFFSET;
+ 
+ 		return (m * __iproute2_hz_internal + 1000 - 1) / 1000;
+ 	}
+ }
+ 
+ int get_unsigned_ms_to_jiffies(unsigned *val, const char *arg, int base)
+ {
+ 	int ret;
+ 	unsigned myval = *val;
+ 
+ 	if (__iproute2_hz_internal == 0)
+ 		__iproute2_hz_internal = __get_hz();
+ 	ret = get_unsigned(&myval,arg,base);
+ 	if (ret == -1 || myval > (UINT_MAX / __iproute2_hz_internal))
+ 		return -1;
+ 	*val = msecs_to_jiffies(myval);
+ 	return 0;
+ }	
+ 
  int get_u64(__u64 *val, const char *arg, int base)
  {
  	unsigned long long res;
*** ./include/utils.h.orig	2007-09-04 12:56:09.000000000 -0700
--- ./include/utils.h	2007-09-04 12:55:56.000000000 -0700
***************
*** 69,74 ****
--- 69,78 ----
  	u_int8_t  ipx_node[IPX_NODE_LEN];
  };
  
+ #ifndef MAX_JIFFY_OFFSET
+ #define MAX_JIFFY_OFFSET ((LONG_MAX >> 1)-1)
+ #endif
+ 
  extern __u32 get_addr32(const char *name);
  extern int get_addr_1(inet_prefix *dst, const char *arg, int family);
  extern int get_prefix_1(inet_prefix *dst, char *arg, int family);
***************
*** 77,82 ****
--- 81,87 ----
  
  extern int get_integer(int *val, const char *arg, int base);
  extern int get_unsigned(unsigned *val, const char *arg, int base);
+ extern int get_unsigned_ms_to_jiffies(unsigned *val, const char *arg, int base);
  #define get_byte get_u8
  #define get_ushort get_u16
  #define get_short get_s16
*** ./include/linux/rtnetlink.h.orig	2007-03-13 14:50:56.000000000 -0700
--- ./include/linux/rtnetlink.h	2007-08-31 13:27:36.000000000 -0700
***************
*** 352,357 ****
--- 352,359 ----
  #define RTAX_INITCWND RTAX_INITCWND
  	RTAX_FEATURES,
  #define RTAX_FEATURES RTAX_FEATURES
+ 	RTAX_RTO_MIN,
+ #define RTAX_RTO_MIN RTAX_RTO_MIN
  	__RTAX_MAX
  };
  
*** ./ip/iproute.c.orig	2007-08-31 13:15:45.000000000 -0700
--- ./ip/iproute.c	2007-09-04 13:02:42.000000000 -0700
***************
*** 51,56 ****
--- 51,57 ----
  	[RTAX_HOPLIMIT] = "hoplimit",
  	[RTAX_INITCWND] = "initcwnd",
  	[RTAX_FEATURES] = "features",
+ 	[RTAX_RTO_MIN]	= "rto_min",
  };
  static void usage(void) __attribute__((noreturn));
  
***************
*** 74,79 ****
--- 75,81 ----
  	fprintf(stderr, "           [ rtt NUMBER ] [ rttvar NUMBER ]\n");
  	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
  	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ]\n");
+ 	fprintf(stderr, "           [ rto_min NUMBER ]\n");
  	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
  	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
  	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
***************
*** 516,522 ****
  			if (mxlock & (1<<i))
  				fprintf(fp, " lock");
  
! 			if (i != RTAX_RTT && i != RTAX_RTTVAR)
  				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
  			else {
  				unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
--- 518,525 ----
  			if (mxlock & (1<<i))
  				fprintf(fp, " lock");
  
! 			if (i != RTAX_RTT && i != RTAX_RTTVAR &&
! 			    i != RTAX_RTO_MIN)
  				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
  			else {
  				unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
***************
*** 524,530 ****
  				val *= 1000;
  				if (i == RTAX_RTT)
  					val /= 8;
! 				else
  					val /= 4;
  				if (val >= hz)
  					fprintf(fp, " %ums", val/hz);
--- 527,533 ----
  				val *= 1000;
  				if (i == RTAX_RTT)
  					val /= 8;
! 				else if (i == RTAX_RTTVAR)
  					val /= 4;
  				if (val >= hz)
  					fprintf(fp, " %ums", val/hz);
***************
*** 823,828 ****
--- 826,840 ----
  			if (get_unsigned(&rtt, *argv, 0))
  				invarg("\"rtt\" value is invalid\n", *argv);
  			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_RTT, rtt);
+ 		} else if (strcmp(*argv, "rto_min") == 0) {
+ 			unsigned rto_min;
+ 			NEXT_ARG();
+ 			mxlock |= (1<<RTAX_RTO_MIN);
+ 			if (get_unsigned_ms_to_jiffies(&rto_min, *argv, 0))
+ 				invarg("\"rto_min\" value is invalid\n",
+ 				       *argv);
+ 			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_RTO_MIN,
+ 				      rto_min);
  		} else if (matches(*argv, "window") == 0) {
  			unsigned win;
  			NEXT_ARG();
