From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
 take 2
Date: Fri, 31 Aug 2007 11:57:06 -0700 (PDT)
Message-ID: <20070831.115706.97292718.davem@davemloft.net>
References: <46D769C1.8090808@hp.com>
	<20070830.220911.41008322.davem@davemloft.net>
	<46D859D9.6030407@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46214
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965848AbXHaS5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 14:57:07 -0400
In-Reply-To: <46D859D9.6030407@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 31 Aug 2007 11:11:37 -0700

> At the risk of showing my ignorance (what me worry about that?-) I 
> presume this is then an interface expecting to take-in jiffies?  That 
> means the user has to know the value of HZ which can be (IIRC) one of 
> three different values?

The iproute2 changes might look something like this:

--- ./include/linux/rtnetlink.h.orig	2007-08-31 11:55:30.000000000 -0700
+++ ./include/linux/rtnetlink.h	2007-08-31 11:52:22.000000000 -0700
@@ -351,6 +351,8 @@ enum
 #define RTAX_INITCWND RTAX_INITCWND
 	RTAX_FEATURES,
 #define RTAX_FEATURES RTAX_FEATURES
+	RTAX_RTO_MIN,
+#define RTAX_RTO_MIN RTAX_RTO_MIN
 	__RTAX_MAX
 };
 
--- ./ip/iproute.c.orig	2007-08-31 11:55:30.000000000 -0700
+++ ./ip/iproute.c	2007-08-31 11:53:29.000000000 -0700
@@ -51,6 +51,7 @@ static const char *mx_names[RTAX_MAX+1] 
 	[RTAX_HOPLIMIT] = "hoplimit",
 	[RTAX_INITCWND] = "initcwnd",
 	[RTAX_FEATURES] = "features",
+	[RTAX_RTO_MIN]	= "rto_min",
 };
 static void usage(void) __attribute__((noreturn));
 
@@ -74,6 +75,7 @@ static void usage(void)
 	fprintf(stderr, "           [ rtt NUMBER ] [ rttvar NUMBER ]\n");
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ]\n");
+	fprintf(stderr, "           [ rto_min NUMBER ]\n");
 	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
@@ -520,7 +522,8 @@ int print_route(const struct sockaddr_nl
 			if (mxlock & (1<<i))
 				fprintf(fp, " lock");
 
-			if (i != RTAX_RTT && i != RTAX_RTTVAR)
+			if (i != RTAX_RTT && i != RTAX_RTTVAR &&
+			    i != RTAX_RTO_MIN)
 				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
 			else {
 				unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
@@ -528,7 +531,7 @@ int print_route(const struct sockaddr_nl
 				val *= 1000;
 				if (i == RTAX_RTT)
 					val /= 8;
-				else
+				else if (i == RTAX_RTTVAR)
 					val /= 4;
 				if (val >= hz)
 					fprintf(fp, " %ums", val/hz);
@@ -803,6 +806,15 @@ int iproute_modify(int cmd, unsigned fla
 			if (get_unsigned(&rtt, *argv, 0))
 				invarg("\"rtt\" value is invalid\n", *argv);
 			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_RTT, rtt);
+		} else if (strcmp(*argv, "rto_min") == 0) {
+			unsigned rto_min;
+			NEXT_ARG();
+			mxlock |= (1<<RTAX_RTO_MIN);
+			if (get_unsigned(&rto_min, *argv, 0))
+				invarg("\"rto_min\" value is invalid\n",
+				       *argv);
+			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_RTO_MIN,
+				      rto_min);
 		} else if (matches(*argv, "window") == 0) {
 			unsigned win;
 			NEXT_ARG();
