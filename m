From: "Kovalev, Sergey" <Sergey.Kovalev@emc.com>
Subject: [PATCH] ping: ping doesn't work correctly with -m option
Date: Mon, 18 May 2015 12:37:46 +0000
Message-ID: <7E20C7B36969D643A89BC9AE4BF0F3A422D31D95@MX102CL01.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Dion, Christopher" <Christopher.Dion@emc.com>,
	"Akopyan, Alexander" <Alexander.Akopyan@emc.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailuogwdur.emc.com ([128.221.224.79]:58830 "EHLO
	mailuogwdur.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbbERMh6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 08:37:58 -0400
Received: from maildlpprd52.lss.emc.com (maildlpprd52.lss.emc.com [10.106.48.156])
	by mailuogwprd54.lss.emc.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.0) with ESMTP id t4ICbv01013234
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 18 May 2015 08:37:57 -0400
Received: from mailusrhubprd02.lss.emc.com (mailusrhubprd02.lss.emc.com [10.253.24.20]) by maildlpprd52.lss.emc.com (RSA Interceptor) for <netdev@vger.kernel.org>; Mon, 18 May 2015 08:38:16 -0400
Received: from mxhub09.corp.emc.com (mxhub09.corp.emc.com [10.254.92.104])
	by mailusrhubprd02.lss.emc.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.0) with ESMTP id t4ICbl7B025988
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 18 May 2015 08:37:47 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "ping" or "ping6" with parameter "-m" doesn't work when "main" and "default" table are empty (or do not have any route to destination IP).
If we don't specify source IP address for the ping, the ping will try to determine the source IP automatically. To do so it creates the probe UDP socket, and try to connect to dst IP on that socket. The connect should make routing decision based on current Linux routing.  If connection succeeded it takes source IP (however it doesn't use it in future indeed). The issue is that PIGN doesn't specify fwmark for that probe socket as a result connection fails with "Network unreachable" error.

--- ./ping.c.origin     2015-05-12 09:01:16.000000000 -0400
+++ ./ping.c    		2015-05-13 07:34:06.000000000 -0400
@@ -107,6 +107,7 @@
 struct sockaddr_in source;
 char *device;
 int pmtudisc = -1;
+extern int mark;


 int
@@ -305,6 +306,12 @@
                                }
                        }
                }
+        if (options & F_MARK) {
+            if (setsockopt(probe_fd, SOL_SOCKET, SO_MARK,
+                        &mark, sizeof(mark)) == -1) {
+                fprintf(stderr, "Warning: Failed to set mark %d\n", mark);
+            }
+        }

                if (settos &&
                    setsockopt(probe_fd, IPPROTO_IP, IP_TOS, (char *)&settos, sizeof(int)) < 0)
--- ./ping6.c.origin    2015-05-12 09:01:16.000000000 -0400
+++ ./ping6.c   		2015-05-13 07:33:39.000000000 -0400
@@ -137,7 +137,7 @@
 int pmtudisc=-1;

 static int icmp_sock;
-
+extern int mark;


 static struct in6_addr in6_anyaddr;
@@ -385,6 +385,12 @@
 #endif
                        }
                }
+        if (options & F_MARK) {
+            if (setsockopt(probe_fd, SOL_SOCKET, SO_MARK,
+                        &mark, sizeof(mark)) == -1) {
+                fprintf(stderr, "Warning: Failed to set mark %d\n", mark);
+            }
+        }
                firsthop.sin6_port = htons(1025);
                if (connect(probe_fd, (struct sockaddr*)&firsthop, sizeof(firsthop)) == -1) {
                        perror("connect");
