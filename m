From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 05/12] headers, net: Define struct __kernel_sockaddr,
 replacing struct sockaddr
Date: Mon, 08 Aug 2011 14:18:49 +0100
Message-ID: <1312809529.2591.1144.camel@deadeye>
References: <1312809302.2591.1139.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50062 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752183Ab1HHNSw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 09:18:52 -0400
In-Reply-To: <1312809302.2591.1139.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9c501935a3cdcf6b1d35aaee3aa11c7a7051a305 ('net: Support
inclusion of <linux/socket.h> before <sys/socket.h>') removed the
definition of struct sockaddr for userland.

But we still have several headers using struct sockaddr, and we
shouldn't make them include <sys/socket.h> as that risks recursive
inclusion in future.  Define and use an identical struct
__kernel_sockaddr instead.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/if.h     |   12 ++++++------
 include/linux/phonet.h |    3 ++-
 include/linux/socket.h |   17 +++++++++--------
 3 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/include/linux/if.h b/include/linux/if.h
index 03489ca..4ff0f95 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -20,7 +20,7 @@
 #define _LINUX_IF_H
 
 #include <linux/types.h>		/* for "__kernel_caddr_t" et al	*/
-#include <linux/socket.h>		/* for "struct sockaddr" et al	*/
+#include <linux/socket.h>		/* for "struct __kernel_sockaddr" et al	*/
 #include <linux/compiler.h>		/* for "__user" et al           */
 
 #define	IFNAMSIZ	16
@@ -175,11 +175,11 @@ struct ifreq {
 	} ifr_ifrn;
 	
 	union {
-		struct	sockaddr ifru_addr;
-		struct	sockaddr ifru_dstaddr;
-		struct	sockaddr ifru_broadaddr;
-		struct	sockaddr ifru_netmask;
-		struct  sockaddr ifru_hwaddr;
+		struct	__kernel_sockaddr ifru_addr;
+		struct	__kernel_sockaddr ifru_dstaddr;
+		struct	__kernel_sockaddr ifru_broadaddr;
+		struct	__kernel_sockaddr ifru_netmask;
+		struct  __kernel_sockaddr ifru_hwaddr;
 		short	ifru_flags;
 		int	ifru_ivalue;
 		int	ifru_mtu;
diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index f53a416..9aba9ce 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -101,7 +101,8 @@ struct sockaddr_pn {
 	__u8 spn_obj;
 	__u8 spn_dev;
 	__u8 spn_resource;
-	__u8 spn_zero[sizeof(struct sockaddr) - sizeof(__kernel_sa_family_t) - 3];
+	__u8 spn_zero[sizeof(struct __kernel_sockaddr) -
+		      sizeof(__kernel_sa_family_t) - 3];
 } __attribute__((packed));
 
 /* Well known address */
diff --git a/include/linux/socket.h b/include/linux/socket.h
index d0e77f6..f13ad7b 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -10,6 +10,14 @@
 
 typedef unsigned short __kernel_sa_family_t;
 
+/*
+ *	1003.1g requires sa_family_t and that sa_data is char.
+ */
+struct __kernel_sockaddr {
+	__kernel_sa_family_t sa_family;	/* address family, AF_xxx	*/
+	char		sa_data[14];	/* 14 bytes of protocol address	*/
+};
+
 struct __kernel_sockaddr_storage {
 	__kernel_sa_family_t	ss_family;		/* address family */
 	/* Following field(s) are implementation specific */
@@ -39,15 +47,8 @@ extern void socket_seq_show(struct seq_file *seq);
 
 typedef __kernel_sa_family_t	sa_family_t;
 
-/*
- *	1003.1g requires sa_family_t and that sa_data is char.
- */
+#define sockaddr __kernel_sockaddr
  
-struct sockaddr {
-	sa_family_t	sa_family;	/* address family, AF_xxx	*/
-	char		sa_data[14];	/* 14 bytes of protocol address	*/
-};
-
 struct linger {
 	int		l_onoff;	/* Linger active		*/
 	int		l_linger;	/* How long to linger for	*/
-- 
1.7.5.4



