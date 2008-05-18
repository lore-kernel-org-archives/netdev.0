From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] NFS: handle interface identifiers in incoming IPv6
	addresses
Date: Sun, 18 May 2008 17:20:26 -0400
Message-ID: <20080518212026.13450.4410.stgit@ellison.1015granger.net>
References: <20080518210625.13450.71349.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:19588 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbYERVWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 17:22:51 -0400
Received: from rgmgw2.us.oracle.com (rgmgw2.us.oracle.com [138.1.186.111])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id m4ILMn6t014912
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 15:22:49 -0600
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by rgmgw2.us.oracle.com (Switch-3.2.4/Switch-3.2.4) with ESMTP id m4IHO6d2030555
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 15:22:49 -0600
Received: from ellison.1015granger.net (ellison.1015granger.net [127.0.0.1])
	by ellison.1015granger.net (8.14.2/8.14.2) with ESMTP id m4ILKQaG014158
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 17:20:26 -0400
In-Reply-To: <20080518210625.13450.71349.stgit@ellison.1015granger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support in the kernel NFS client's address parser for interface
identifiers.

IPv6 link-local addresses require an additional "interface identifier",
which is an integer that indexes the array of local network interfaces.
They are suffixed to the address with a '%'.  For example:

	fe80::215:c5ff:fe3b:e1b2%2

indicates an index of 2.  Without the interface ID, link-local addresses
are not usable for NFS.

Note these can also be expressed:

	fe80::215:c5ff:fe3b:e1b2%eth0

The mount.nfs command maps the device name to an interface index before
passing in "addr=".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 970f976..eb4a001 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -734,6 +734,7 @@ static void nfs_parse_ipv6_address(char *string, size_t str_len,
 {
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
 	u8 *addr = (u8 *)&sin6->sin6_addr.in6_u;
+	const char *delim;
 
 	dfprintk(MOUNT, "NFS: parsing IPv6 address %*s\n",
 			str_len, string);
@@ -741,8 +742,22 @@ static void nfs_parse_ipv6_address(char *string, size_t str_len,
 	if (str_len < INET6_ADDRSTRLEN) {
 		sin6->sin6_family = AF_INET6;
 		*addr_len = sizeof(*sin6);
-		if (in6_pton(string, str_len, addr, '\0', NULL))
+		if (in6_pton(string, str_len, addr, '%', &delim)) {
+			if (*delim == '%') {
+				size_t len = (string + str_len) - delim - 1;
+				char *p = kstrndup(delim + 1, len, GFP_KERNEL);
+				if (p) {
+					unsigned long id = 0;
+					/* id is set to zero on error */
+					strict_strtoul(p, 10, &id);
+					kfree(p);
+					sin6->sin6_scope_id = id;
+					dfprintk(MOUNT, "NFS: IPv6 scope "
+							"ID = %lu\n", id);
+				}
+			}
 			return;
+		}
 	}
 
 	sap->sa_family = AF_UNSPEC;

