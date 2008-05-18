From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] NFS: Add string length argument to
	nfs_parse_server_address
Date: Sun, 18 May 2008 17:20:19 -0400
Message-ID: <20080518212018.13450.8830.stgit@ellison.1015granger.net>
References: <20080518210625.13450.71349.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:19630 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbYERVXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 17:23:32 -0400
Received: from rgmgw1.us.oracle.com (rgmgw1.us.oracle.com [138.1.186.110])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id m4ILNUsN015143
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 15:23:30 -0600
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by rgmgw1.us.oracle.com (Switch-3.2.4/Switch-3.2.4) with ESMTP id m4IHO6ZJ031795
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 15:21:04 -0600
Received: from ellison.1015granger.net (ellison.1015granger.net [127.0.0.1])
	by ellison.1015granger.net (8.14.2/8.14.2) with ESMTP id m4ILKJYW014140
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 17:20:19 -0400
In-Reply-To: <20080518210625.13450.71349.stgit@ellison.1015granger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To make nfs_parse_server_address() more generally useful, allow it to
accept input strings that are not terminated with '\0'.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   98 +++++++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 68 insertions(+), 30 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d1cccb6..970f976 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -62,6 +62,13 @@
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
+#ifndef INET_ADDRSTRLEN
+#define INET_ADDRSTRLEN		(16)
+#endif
+#ifndef INET6_ADDRSTRLEN
+#define INET6_ADDRSTRLEN	(48)
+#endif
+
 enum {
 	/* Mount options that take no arguments */
 	Opt_soft, Opt_hard,
@@ -702,38 +709,67 @@ static int nfs_verify_server_address(struct sockaddr *addr)
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
+	dfprintk(MOUNT, "NFS: parsing IPv4 address %*s\n",
+			str_len, string);
+
+	if (str_len < INET_ADDRSTRLEN) {
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
+static void nfs_parse_ipv6_address(char *string, size_t str_len,
+				   struct sockaddr *sap, size_t *addr_len)
+{
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+	u8 *addr = (u8 *)&sin6->sin6_addr.in6_u;
+
+	dfprintk(MOUNT, "NFS: parsing IPv6 address %*s\n",
+			str_len, string);
 
-		ap->sin_family = AF_INET;
-		*len = sizeof(*ap);
-		if (in4_pton(value, -1, addr, '\0', NULL))
+	if (str_len < INET6_ADDRSTRLEN) {
+		sin6->sin6_family = AF_INET6;
+		*addr_len = sizeof(*sin6);
+		if (in6_pton(string, str_len, addr, '\0', NULL))
 			return;
 	}
 
 	sap->sa_family = AF_UNSPEC;
-	*len = 0;
+	*addr_len = 0;
+}
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
+		return nfs_parse_ipv6_address(string, str_len, sap, addr_len);
+	else
+		return nfs_parse_ipv4_address(string, str_len, sap, addr_len);
 }
 
 /*
@@ -1055,9 +1091,10 @@ static int nfs_parse_mount_options(char *raw,
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
@@ -1078,9 +1115,10 @@ static int nfs_parse_mount_options(char *raw,
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
 

