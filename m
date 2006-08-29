From: Zhao Yu Wang <wangzyu@cn.ibm.com>
Subject: [PATCH]ethtool.c:fix buffer overflow when devname it too long
Date: Tue, 29 Aug 2006 11:18:51 +0800
Message-ID: <OFF9058467.15705F4E-ON482571D9.0010F2FA-482571D9.0011E3AA@cn.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:31227 "EHLO
	ausmtp05.au.ibm.com") by vger.kernel.org with ESMTP id S932124AbWH2DPx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 23:15:53 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp05.au.ibm.com (8.13.6/8.13.6) with ESMTP id k7T3IMVt7979158
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 13:18:23 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7T3J8nw238038
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 13:19:14 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7T3FiOq027915
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 13:15:44 +1000
Received: from d23m0037.cn.ibm.com (d23m0037.cn.ibm.com [9.181.2.105])
	by d23av04.au.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7T3Fh6d027896
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 13:15:44 +1000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As the length of field ifr_name of struct ifreq is IFNAMSIZ(16) in header 
file /usr/include/net/if.h. It will result in buffer overflow when devname 
is too long. I modified strcpy to strncpy for only copying IFNAMSIZ bytes 
into struct ifreq. Also, by adding a section into parse_cmdline to detect 
if the length of devname is invalid.

diff -Nrup ethtool-4.orig/ethtool.c ethtool-4/ethtool.c
--- ethtool-4.orig/ethtool.c    2006-07-18 21:21:38.000000000 -0500
+++ ethtool-4/ethtool.c 2006-08-27 22:32:12.000000000 -0500
@@ -626,6 +626,9 @@ static void parse_cmdline(int argc, char
 
        if (devname == NULL) {
                show_usage(1);
+       } else if (strlen(devname) > IFNAMSIZ) {
+               fprintf(stderr, "Device name is too long. Should be less 
than %d!\n", IFNAMSIZ);
+               show_usage(1);
        }
 }
 
@@ -1139,7 +1142,7 @@ static int doit(void)
 
        /* Setup our control structures. */
        memset(&ifr, 0, sizeof(ifr));
-       strcpy(ifr.ifr_name, devname);
+       strncpy(ifr.ifr_name, devname, IFNAMSIZ);
 
        /* Open control socket. */
        fd = socket(AF_INET, SOCK_DGRAM, 0);



