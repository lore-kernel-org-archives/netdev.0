From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Add string length argument to nfs_parse_server_address
Date: Thu, 19 Jun 2008 15:03:35 -0400
Message-ID: <20080619190151.29360.22489.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:46043 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975AbYFSTF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 15:05:57 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m5JJ5s3Q015471
	for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 14:05:54 -0500
Received: from acsmt355.oracle.com (acsmt355.oracle.com [141.146.40.155])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m5JIFmGO022748
	for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 13:05:54 -0600
Received: from ellison.1015granger.net (ellison.1015granger.net [127.0.0.1])
	by ellison.1015granger.net (8.14.2/8.14.2) with ESMTP id m5JJ3ZbM029463
	for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 15:03:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To make nfs_parse_server_address() more generally useful, allow it to
accept input strings that are not terminated with '\0'.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

As part of a series of patches adding support for IPv6 addresses to the NFS
mount option parser, I'm considering this change, which includes an addition
to include/linux/inet.h.  Comments?

 fs/nfs/super.c       |  100 +++++++++++++++++++++++++++++++++++---------------
 include/linux/inet.h |    7 ++++
 2 files changed, 77 insertions(+), 30 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 98c8110..225b14c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -702,38 +702,76 @@ static int nfs_verify_server_address(struct sockaddr *addr)
 	return 0;
 }
 
-/*
- * Parse string addresses passed in via a mount option,
- * and construct a sockaddr based on the result.
- *
- * If address parsing fails, set the sockaddr's address
- * family to AF_UNSPEC to force nfs_verify_server_address()
- * to punt the mount.
- */
-static void nfs_parse_server_address(char *value,
-				     struct sockaddr *sap,
-				     size_t *len)
+static void nfs_parse_ipv4_address(char *string, size_t str_len,
+				   struct sockaddr *sap, size_t *addr_len)
 {
-	if (strchr(value, ':')) {
-		struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
-		u8 *addr = (u8 *)&ap->sin6_addr.in6_u;
+	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	u8 *addr = (u8 *)&sin->sin_addr.s_addr;
 
-		ap->sin6_family = AF_INET6;
-		*len = sizeof(*ap);
-		if (in6_pton(value, -1, addr, '\0', NULL))
+	if (str_len <= INET_ADDRSTRLEN) {
+		dfprintk(MOUNT, "NFS: parsing IPv4 address %*s\n",
+				(int)str_len, string);
+
+		sin->sin_family = AF_INET;
+		*addr_len = sizeof(*sin);
+		if (in4_pton(string, str_len, addr, '\0', NULL))
 			return;
-	} else {
-		struct sockaddr_in *ap = (struct sockaddr_in *)sap;
-		u8 *addr = (u8 *)&ap->sin_addr.s_addr;
+	}
+
+	sap->sa_family = AF_UNSPEC;
+	*addr_len = 0;
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static void nfs_parse_ipv6_address(char *string, size_t str_len,
+				   struct sockaddr *sap, size_t *addr_len)
+{
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+	u8 *addr = (u8 *)&sin6->sin6_addr.in6_u;
+
+	if (str_len <= INET6_ADDRSTRLEN) {
+		dfprintk(MOUNT, "NFS: parsing IPv6 address %*s\n",
+				(int)str_len, string);
 
-		ap->sin_family = AF_INET;
-		*len = sizeof(*ap);
-		if (in4_pton(value, -1, addr, '\0', NULL))
+		sin6->sin6_family = AF_INET6;
+		*addr_len = sizeof(*sin6);
+		if (in6_pton(string, str_len, addr, '\0', NULL))
 			return;
 	}
 
 	sap->sa_family = AF_UNSPEC;
-	*len = 0;
+	*addr_len = 0;
+}
+#else
+static void nfs_parse_ipv6_address(char *string, size_t str_len,
+				   struct sockaddr *sap, size_t *addr_len)
+{
+	sap->sa_family = AF_UNSPEC;
+	*addr_len = 0;
+}
+#endif
+
+/*
+ * Construct a sockaddr based on the contents of a string that contains
+ * an IP address in presentation format.
+ *
+ * If there is a problem constructing the new sockaddr, set the address
+ * family to AF_UNSPEC.
+ */
+static void nfs_parse_ip_address(char *string, size_t str_len,
+				 struct sockaddr *sap, size_t *addr_len)
+{
+	unsigned int i, colons;
+
+	colons = 0;
+	for (i = 0; i < str_len; i++)
+		if (string[i] == ':')
+			colons++;
+
+	if (colons >= 2)
+		nfs_parse_ipv6_address(string, str_len, sap, addr_len);
+	else
+		nfs_parse_ipv4_address(string, str_len, sap, addr_len);
 }
 
 /*
@@ -1093,9 +1131,10 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			nfs_parse_server_address(string, (struct sockaddr *)
-						 &mnt->nfs_server.address,
-						 &mnt->nfs_server.addrlen);
+			nfs_parse_ip_address(string, strlen(string),
+					     (struct sockaddr *)
+						&mnt->nfs_server.address,
+					     &mnt->nfs_server.addrlen);
 			kfree(string);
 			break;
 		case Opt_clientaddr:
@@ -1116,9 +1155,10 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			nfs_parse_server_address(string, (struct sockaddr *)
-						 &mnt->mount_server.address,
-						 &mnt->mount_server.addrlen);
+			nfs_parse_ip_address(string, strlen(string),
+					     (struct sockaddr *)
+						&mnt->mount_server.address,
+					     &mnt->mount_server.addrlen);
 			kfree(string);
 			break;
 
diff --git a/include/linux/inet.h b/include/linux/inet.h
index 1354080..4cca05c 100644
--- a/include/linux/inet.h
+++ b/include/linux/inet.h
@@ -44,6 +44,13 @@
 
 #include <linux/types.h>
 
+/*
+ * These mimic similar macros defined in user-space for inet_ntop(3).
+ * See /usr/include/netinet/in.h .
+ */
+#define INET_ADDRSTRLEN		(16)
+#define INET6_ADDRSTRLEN	(48)
+
 extern __be32 in_aton(const char *str);
 extern int in4_pton(const char *src, int srclen, u8 *dst, int delim, const char **end);
 extern int in6_pton(const char *src, int srclen, u8 *dst, int delim, const char **end);

