From: "Joseph S. Myers" <joseph@codesourcery.com>
Subject: Kernel header changes break glibc build
Date: Fri, 6 Oct 2006 17:20:07 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Woodhouse <dwmw2@infradead.org>, libc-alpha@sourceware.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.codesourcery.com ([65.74.133.4]:41606 "EHLO
	mail.codesourcery.com") by vger.kernel.org with ESMTP
	id S1422765AbWJFRUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 13:20:09 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel headers installed by Linux 2.6.19-rc1 "make
headers_install" do not work for building glibc, because glibc expects
<linux/rtnetlink.h> to provide various definitions, some of which have
been moved to <linux/if_addr.h> and some of which have been removed
altogether.

This kernel patch allows glibc to build again by making rtnetlink.h
include if_addr.h and adding back the removed definitions required by
glibc, but I don't know if it's the correct approach or if glibc
should change the headers it includes and add its own macro
definitions.

Signed-off-by: Joseph Myers <joseph@codesourcery.com>
---
Index: include/linux/rtnetlink.h
===================================================================
--- include/linux/rtnetlink.h
+++ include/linux/rtnetlink.h
@@ -2,6 +2,7 @@
 #define __LINUX_RTNETLINK_H
 
 #include <linux/netlink.h>
+#include <linux/if_addr.h>
 #include <linux/if_link.h>
 
 /****
Index: include/linux/if_link.h
===================================================================
--- include/linux/if_link.h
+++ include/linux/if_link.h
@@ -82,6 +82,9 @@
 
 #define IFLA_MAX (__IFLA_MAX - 1)
 
+#define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
+#define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
+
 /* ifi_flags.
 
    IFF_* flags.
Index: include/linux/if_addr.h
===================================================================
--- include/linux/if_addr.h
+++ include/linux/if_addr.h
@@ -52,4 +52,7 @@
 	__u32	tstamp; /* updated timestamp, hundredths of seconds */
 };
 
+#define IFA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifaddrmsg))))
+#define IFA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifaddrmsg))
+
 #endif



-- 
Joseph S. Myers
joseph@codesourcery.com
