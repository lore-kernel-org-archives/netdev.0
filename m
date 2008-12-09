From: Benedikt Gollatz <ben@differentialschokolade.org>
Subject: Minor bug in "ip addr" output
Date: Wed, 10 Dec 2008 00:33:28 +0100
Message-ID: <200812100033.28850.ben@differentialschokolade.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213-239-195-174.clients.your-server.de ([213.239.195.174]:49768
	"EHLO mail.g4b.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbYLJABB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 19:01:01 -0500
Received: from laforge-linux.localnet (unknown [IPv6:2001:6f8:11b2:1:221:e9ff:fedb:8691])
	by mail.g4b.org (Postfix) with ESMTP id F17CB1D742AA
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 00:33:30 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a minor problem in iproute2 regarding the output of "ip -6 addr". 
Preferred lifetimes of IPv6 prefixes are printed as unsigned integers even 
though they may become negative (for deprecated prefixes).

As I've argued in <http://bugzilla.kernel.org/show_bug.cgi?id=10880>, I think 
this is partly because of an inconsistency in the kernel APIs, but since 
nobody seemed interested, I guess it has to be dealt with by application 
developers.

The following patch fixes the problem.

--- a/ip/ipaddress.c	2008-07-25 22:46:07.000000000 +0200
+++ b/ip/ipaddress.c	2008-12-08 03:29:27.000000000 +0100
@@ -360,4 +360,5 @@
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
+	int deprecated = 0;
 	struct rtattr * rta_tb[IFA_MAX+1];
 	char abuf[256];
@@ -489,4 +490,5 @@
 	if (ifa->ifa_flags&IFA_F_DEPRECATED) {
 		ifa->ifa_flags &= ~IFA_F_DEPRECATED;
+		deprecated = 1;
 		fprintf(fp, "deprecated ");
 	}
@@ -517,7 +519,12 @@
 		if (ci->ifa_prefered == INFINITY_LIFE_TIME)
 			sprintf(buf+strlen(buf), " preferred_lft forever");
-		else
-			sprintf(buf+strlen(buf), " preferred_lft %usec",
-				ci->ifa_prefered);
+		else {
+			if (deprecated)
+				sprintf(buf+strlen(buf), " preferred_lft %dsec",
+					ci->ifa_prefered);
+			else
+				sprintf(buf+strlen(buf), " preferred_lft %usec",
+					ci->ifa_prefered);
+		}
 		fprintf(fp, "       %s", buf);
 	}


