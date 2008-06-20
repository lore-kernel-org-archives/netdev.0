From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH] iproute2: add support for IFLA_NET_NS_PID in ip link v2
Date: Fri, 20 Jun 2008 11:21:12 +0200
Message-ID: <20080620092109.551812772@theryb.frec.bull.fr>
References: <20080620090734.144305411@theryb.frec.bull.fr>
Cc: netdev@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:34015 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbYFTJ3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 05:29:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ah, ah, of course I forgot to refresh the patch before sending it. :)
There was still a small typo in the patch: a '}' was put instead of 
a '|' in 'ip link' usage string. 

Here is the updated patch.
Sorry for this.

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
 ip/iplink.c     |   11 ++++++++++-
 man/man8/ip.8   |   10 +++++++++-
 3 files changed, 23 insertions(+), 2 deletions(-)

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
@@ -48,7 +48,8 @@ void iplink_usage(void)
 	fprintf(stderr, "	                     txqueuelen PACKETS |\n");
 	fprintf(stderr, "	                     name NEWNAME |\n");
 	fprintf(stderr, "	                     address LLADDR | broadcast LLADDR |\n");
-	fprintf(stderr, "	                     mtu MTU }\n");
+	fprintf(stderr, "	                     mtu MTU |\n");
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
