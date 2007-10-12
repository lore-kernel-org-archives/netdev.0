From: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Subject: [PATCH 2/2] NFS: handle IPv6 addresses in nfs ctl
Date: Fri, 12 Oct 2007 11:14:33 +0200
Message-ID: <470F3AF9.4050705@ext.bull.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030702020902020108010108"
To: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:59870 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932470AbXJLJLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 05:11:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030702020902020108010108
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed

Here is a second missing part of the IPv6 support in NFS server code 
concerning knfd syscall interface.
It updates write_getfd and write_getfd to accept IPv6 addresses.

Applies on a kernel including ip_map cache modifications

Tests: tested with only IPv4 network and basic nfs ops (mount, file creation and modification) 


Signed-off-by: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 nfsctl.c |   41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

diff -p -u -r -N linux-2.6.23-ipmap-cache/fs/nfsd/nfsctl.c 
linux-2.6.23-nfsctl/fs/nfsd/nfsctl.c
--- linux-2.6.23-ipmap-cache/fs/nfsd/nfsctl.c    2007-10-11 
15:23:07.000000000 +0200
+++ linux-2.6.23-nfsctl/fs/nfsd/nfsctl.c    2007-10-12 
10:49:31.000000000 +0200
@@ -219,7 +219,7 @@ static ssize_t write_unexport(struct fil
 static ssize_t write_getfs(struct file *file, char *buf, size_t size)
 {
     struct nfsctl_fsparm *data;
-    struct sockaddr_in *sin;
+    struct sockaddr_in6 *sin, sin6_storage;
     struct auth_domain *clp;
     int err = 0;
     struct knfsd_fh *res;
@@ -228,9 +228,20 @@ static ssize_t write_getfs(struct file *
         return -EINVAL;
     data = (struct nfsctl_fsparm*)buf;
     err = -EPROTONOSUPPORT;
-    if (data->gd_addr.sa_family != AF_INET)
+    sin = &sin6_storage;
+    switch (data->gd_addr.sa_family) {
+    case AF_INET6:
+        sin = (struct sockaddr_in6 *)&data->gd_addr;
+        in6 = sin->sin6_addr;
+        break;
+    case AF_INET:
+        /* Map v4 address into v6 structure */
+        ipv6_addr_v4map(((struct sockaddr_in 
*)&data->gd_addr)->sin_addr, in6);
+        break;
+    default:
         goto out;
-    sin = (struct sockaddr_in *)&data->gd_addr;
+    }
+
     if (data->gd_maxlen > NFS3_FHSIZE)
         data->gd_maxlen = NFS3_FHSIZE;
 
@@ -238,9 +249,6 @@ static ssize_t write_getfs(struct file *
 
     exp_readlock();
 
-    /* IPv6 address mapping */
-    ipv6_addr_v4map(sin->sin_addr, in6);
-
     if (!(clp = auth_unix_lookup(in6)))
         err = -EPERM;
     else {
@@ -257,7 +265,7 @@ static ssize_t write_getfs(struct file *
 static ssize_t write_getfd(struct file *file, char *buf, size_t size)
 {
     struct nfsctl_fdparm *data;
-    struct sockaddr_in *sin;
+    struct sockaddr_in6 *sin, sin6_storage;
     struct in6_addr in6;
     struct auth_domain *clp;
     int err = 0;
@@ -268,18 +276,29 @@ static ssize_t write_getfd(struct file *
         return -EINVAL;
     data = (struct nfsctl_fdparm*)buf;
     err = -EPROTONOSUPPORT;
-    if (data->gd_addr.sa_family != AF_INET)
+    if (data->gd_addr.sa_family != AF_INET &&
+        data->gd_addr.sa_family != AF_INET6)
         goto out;
     err = -EINVAL;
     if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
         goto out;
 
     res = buf;
-    sin = (struct sockaddr_in *)&data->gd_addr;
+    sin = &sin6_storage;
     exp_readlock();
 
-    /* IPv6 address mapping */
-    ipv6_addr_v4map(sin->sin_addr, in6);
+    switch (data->gd_addr.sa_family) {
+    case AF_INET:
+        /* IPv6 address mapping */
+        ipv6_addr_v4map(((struct sockaddr_in 
*)&data->gd_addr)->sin_addr, in6);
+        break;
+    case AF_INET6:
+        sin = (struct sockaddr_in6 *)&data->gd_addr;
+        in6 = sin->sin6_addr;
+        break;
+    default:
+        BUG();
+    }
 
     if (!(clp = auth_unix_lookup(in6)))
         err = -EPERM;
diff -p -u -r -N linux-2.6.23-ipmap-cache/net/sunrpc/svcauth_unix.c 
linux-2.6.23-nfsctl/net/sunrpc/svcauth_unix.c
--- linux-2.6.23-ipmap-cache/net/sunrpc/svcauth_unix.c    2007-10-12 
10:47:27.000000000 +0200
+++ linux-2.6.23-nfsctl/net/sunrpc/svcauth_unix.c    2007-10-12 
10:03:56.000000000 +0200
@@ -677,7 +677,7 @@ svcauth_unix_set_client(struct svc_rqst
     case AF_INET:
         sin = svc_addr_in(rqstp);
         sin6 = &sin6_storage;
-        ipv6_addr_set(&sin6->sin6_addr, 0, 0,
+        ipv6_addr_set(&sin6->sin6_addr, 0, 0,
                 htonl(0x0000FFFF), sin->sin_addr.s_addr);
         break;
     case AF_INET6:

-- 

********************************
       Aurelien Charbon
           Bull SAS
     Echirolles - France
 http://www.bullopensource.org/
********************************


--------------030702020902020108010108
Content-Transfer-Encoding: 7bit
Content-Type: text/x-patch;
 name="linux-2.6.23-nfsctl.diff"
Content-Disposition: inline;
 filename="linux-2.6.23-nfsctl.diff"

diff -p -u -r -N linux-2.6.23-ipmap-cache/fs/nfsd/nfsctl.c linux-2.6.23-nfsctl/fs/nfsd/nfsctl.c
--- linux-2.6.23-ipmap-cache/fs/nfsd/nfsctl.c	2007-10-11 15:23:07.000000000 +0200
+++ linux-2.6.23-nfsctl/fs/nfsd/nfsctl.c	2007-10-12 10:49:31.000000000 +0200
@@ -219,7 +219,7 @@ static ssize_t write_unexport(struct fil
 static ssize_t write_getfs(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_fsparm *data;
-	struct sockaddr_in *sin;
+	struct sockaddr_in6 *sin, sin6_storage;
 	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh *res;
@@ -228,9 +228,20 @@ static ssize_t write_getfs(struct file *
 		return -EINVAL;
 	data = (struct nfsctl_fsparm*)buf;
 	err = -EPROTONOSUPPORT;
-	if (data->gd_addr.sa_family != AF_INET)
+	sin = &sin6_storage;
+	switch (data->gd_addr.sa_family) {
+	case AF_INET6:
+		sin = (struct sockaddr_in6 *)&data->gd_addr;
+		in6 = sin->sin6_addr;
+		break;
+	case AF_INET:
+		/* Map v4 address into v6 structure */
+		ipv6_addr_v4map(((struct sockaddr_in *)&data->gd_addr)->sin_addr, in6);
+		break;
+	default:
 		goto out;
-	sin = (struct sockaddr_in *)&data->gd_addr;
+	}
+
 	if (data->gd_maxlen > NFS3_FHSIZE)
 		data->gd_maxlen = NFS3_FHSIZE;
 
@@ -238,9 +249,6 @@ static ssize_t write_getfs(struct file *
 
 	exp_readlock();
 
-	/* IPv6 address mapping */
-	ipv6_addr_v4map(sin->sin_addr, in6);
-
 	if (!(clp = auth_unix_lookup(in6)))
 		err = -EPERM;
 	else {
@@ -257,7 +265,7 @@ static ssize_t write_getfs(struct file *
 static ssize_t write_getfd(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_fdparm *data;
-	struct sockaddr_in *sin;
+	struct sockaddr_in6 *sin, sin6_storage;
 	struct in6_addr in6;
 	struct auth_domain *clp;
 	int err = 0;
@@ -268,18 +276,29 @@ static ssize_t write_getfd(struct file *
 		return -EINVAL;
 	data = (struct nfsctl_fdparm*)buf;
 	err = -EPROTONOSUPPORT;
-	if (data->gd_addr.sa_family != AF_INET)
+	if (data->gd_addr.sa_family != AF_INET && 
+		data->gd_addr.sa_family != AF_INET6)
 		goto out;
 	err = -EINVAL;
 	if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
 		goto out;
 
 	res = buf;
-	sin = (struct sockaddr_in *)&data->gd_addr;
+	sin = &sin6_storage;
 	exp_readlock();
 
-	/* IPv6 address mapping */
-	ipv6_addr_v4map(sin->sin_addr, in6);
+	switch (data->gd_addr.sa_family) {
+	case AF_INET:
+		/* IPv6 address mapping */
+		ipv6_addr_v4map(((struct sockaddr_in *)&data->gd_addr)->sin_addr, in6);
+		break;
+	case AF_INET6:
+		sin = (struct sockaddr_in6 *)&data->gd_addr;
+		in6 = sin->sin6_addr;
+		break;
+	default:
+		BUG();
+	}
 
 	if (!(clp = auth_unix_lookup(in6)))
 		err = -EPERM;


--------------030702020902020108010108--
