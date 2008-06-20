From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH] iproute2: add support for IFLA_NET_NS_PID in ip link
Date: Fri, 20 Jun 2008 11:07:35 +0200
Message-ID: <20080620090734.144305411@theryb.frec.bull.fr>
References: <20080620090725.818393362@theryb.frec.bull.fr>
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:51596 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbYFTJLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 05:11:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

I resend you this patch once more. This time I updated the documentation
too (may be that was the reason why you didn't take it before?). 

Please tell me if there are other things missing in this patch
It applies on iproute2 git tree.

Regards,
Benjamin

Description:
------------

This patch adds support for the IFLA_NET_NS_PID type. It is used to 
move network devices between network namespaces.

The syntax is: 
ip link set DEVICE netns PID

PID is the pid of a process in the target network namespace.

(Daniel Lezcano is the original author). 

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 doc/ip-cref.tex |    4 ++++
 ip/iplink.c     |    9 +++++++++
 man/man8/ip.8   |   10 +++++++++-
 3 files changed, 22 insertions(+), 1 deletion(-)

Index: iproute2/doc/ip-cref.tex
===================================================================
--- iproute2.orig/doc/ip-cref.tex
+++ iproute2/doc/ip-cref.tex
@@ -294,6 +294,10 @@ broadcast address will break networking.
 Do not use it, if you do not understand what this operation really does.
 \end{NB}
 
+\item \verb|netns PID|
+
+--- move the device to the network namespace associated with the process PID.
+
 \end{itemize}
 
 \vskip 1mm
Index: iproute2/ip/iplink.c
===================================================================
--- iproute2.orig/ip/iplink.c
+++ iproute2/ip/iplink.c
@@ -49,6 +49,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                     name NEWNAME |\n");
 	fprintf(stderr, "	                     address LLADDR | broadcast LLADDR |\n");
 	fprintf(stderr, "	                     mtu MTU }\n");
+	fprintf(stderr, "	                     netns PID }\n");
 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
 	exit(-1);
 }
@@ -156,6 +157,7 @@ int iplink_parse(int argc, char **argv, 
 	char abuf[32];
 	int qlen = -1;
 	int mtu = -1;
+	int netns = -1;
 
 	ret = argc;
 
@@ -197,6 +199,13 @@ int iplink_parse(int argc, char **argv, 
 			if (get_integer(&mtu, *argv, 0))
 				invarg("Invalid \"mtu\" value\n", *argv);
 			addattr_l(&req->n, sizeof(*req), IFLA_MTU, &mtu, 4);
+                } else if (strcmp(*argv, "netns") == 0) {
+                        NEXT_ARG();
+                        if (netns != -1)
+                                duparg("netns", *argv);
+                        if (get_integer(&netns, *argv, 0))
+                                invarg("Invalid \"netns\" value\n", *argv);
+                        addattr_l(&req->n, sizeof(*req), IFLA_NET_NS_PID, &netns, 4);
 		} else if (strcmp(*argv, "multicast") == 0) {
 			NEXT_ARG();
 			req->i.ifi_change |= IFF_MULTICAST;
Index: iproute2/man/man8/ip.8
===================================================================
--- iproute2.orig/man/man8/ip.8
+++ iproute2/man/man8/ip.8
@@ -50,7 +50,10 @@ ip \- show / manipulate routing, devices
 .IR LLADDR " |"
 .br
 .B  mtu
-.IR MTU " }"
+.IR MTU " |"
+.br
+.B  netns
+.IR PID " }"
 
 .ti -8
 .B ip link show
@@ -873,6 +876,11 @@ change the link layer broadcast address 
 the interface is
 .IR "POINTOPOINT" .
 
+.TP
+.BI netns " PID"
+move the device to the network namespace associated with the process
+.IR "PID" .
+
 .PP
 .B Warning:
 If multiple parameter changes are requested,

-- 
