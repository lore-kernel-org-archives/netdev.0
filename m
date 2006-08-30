From: wangzyu@cn.ibm.com
Subject: [PATCH]ethtool.c:fix buffer overflow when devname is too long
Date: Wed, 30 Aug 2006 18:52:44 +0800
Message-ID: <20060830105243.GA17772@ldy-gentoo.cn.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:2743 "EHLO
	ausmtp04.au.ibm.com") by vger.kernel.org with ESMTP
	id S1750840AbWH3Kww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 06:52:52 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.6/8.13.5) with ESMTP id k7UB0LAe211552
	for <netdev@vger.kernel.org>; Wed, 30 Aug 2006 21:00:21 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7UAu8r8203942
	for <netdev@vger.kernel.org>; Wed, 30 Aug 2006 20:56:13 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7UAnvt4019918
	for <netdev@vger.kernel.org>; Wed, 30 Aug 2006 20:49:58 +1000
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As the length of field ifr_name of struct ifreq is IFNAMSIZ(16) in header file /usr/include/net/if.h. 
It will result in buffer overflow when devname is too long. Modified strcpy to strncpy for only 
copying IFNAMSIZ bytes into struct ifreq. Also, by adding a section into parse_cmdline to detect 
if the length of devname is invalid.

Signed-off-by: Zhao Yu Wang <wangzyu@cn.ibm.com>
--- ethtool-4.orig/ethtool.c	2006-07-18 21:21:38.000000000 -0500
+++ ethtool-4/ethtool.c	2006-08-27 22:32:12.000000000 -0500
@@ -626,6 +626,9 @@ static void parse_cmdline(int argc, char
 
 	if (devname == NULL) {
 		show_usage(1);
+	} else if (strlen(devname) > IFNAMSIZ) {
+		fprintf(stderr, "Device name is too long. Should be less than %d!\n", IFNAMSIZ);
+		show_usage(1);
 	}
 }
 
@@ -1139,7 +1142,7 @@ static int doit(void)
 
 	/* Setup our control structures. */
 	memset(&ifr, 0, sizeof(ifr));
-	strcpy(ifr.ifr_name, devname);
+	strncpy(ifr.ifr_name, devname, IFNAMSIZ);
 
 	/* Open control socket. */
 	fd = socket(AF_INET, SOCK_DGRAM, 0);
