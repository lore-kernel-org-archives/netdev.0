From: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Subject: [PATCH 2/2] NFS: handle IPv6 addresses in nfs ctl
Date: Mon, 22 Oct 2007 13:27:59 +0200
Message-ID: <471C893F.6000306@ext.bull.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090906080107000807060000"
Cc: netdev ML <netdev@vger.kernel.org>
To: Mailing list NFSv4 <nfsv4@linux-nfs.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090906080107000807060000
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed

Here is a second missing part of the IPv6 support in NFS server code 
concerning knfd syscall interface.
It updates write_getfd and write_getfd to accept IPv6 addresses.

I've updated it according to Brian's comments, and removed some unused code.

Applies on a kernel including ip_map cache modifications

Tests: tested with only IPv4 network and basic nfs ops (mount, file 
creation and modification)

Signed-off-by: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

diff -p -u -r -N linux-2.6.23-ipmap/fs/nfsd/nfsctl.c 
linux-2.6.23-nfsctl/fs/nfsd/nfsctl.c
--- linux-2.6.23-ipmap/fs/nfsd/nfsctl.c    2007-10-22 10:32:51.000000000 
+0200
+++ linux-2.6.23-nfsctl/fs/nfsd/nfsctl.c    2007-10-22 
11:06:13.000000000 +0200
@@ -219,7 +219,7 @@ static ssize_t write_unexport(struct fil
 static ssize_t write_getfs(struct file *file, char *buf, size_t size)
 {
     struct nfsctl_fsparm *data;
-    struct sockaddr_in *sin;
+    struct sockaddr_in6 *sin6, sin6_storage;
     struct auth_domain *clp;
     int err = 0;
     struct knfsd_fh *res;
@@ -229,9 +229,20 @@ static ssize_t write_getfs(struct file *
         return -EINVAL;
     data = (struct nfsctl_fsparm*)buf;
     err = -EPROTONOSUPPORT;
-    if (data->gd_addr.sa_family != AF_INET)
+    switch (data->gd_addr.sa_family) {
+    case AF_INET6:
+        sin6 = &sin6_storage;
+        sin6 = (struct sockaddr_in6 *)&data->gd_addr;
+        ipv6_addr_copy(&in6, &(sin6->sin6_addr));
+        break;
+    case AF_INET:
+        /* Map v4 address into v6 structure */
+        ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), (((struct 
sockaddr_in *)&data->gd_addr)->sin_addr.s_addr));
+        break;
+    default:
         goto out;
-    sin = (struct sockaddr_in *)&data->gd_addr;
+    }
+
     if (data->gd_maxlen > NFS3_FHSIZE)
         data->gd_maxlen = NFS3_FHSIZE;
 
@@ -239,10 +250,7 @@ static ssize_t write_getfs(struct file *
 
     exp_readlock();
 
-    /* IPv6 address mapping */
-        ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), (((struct 
sockaddr_in *)&data->gd_addr)->sin_addr.s_addr));
-
-        if (!(clp = auth_unix_lookup(in6)))
+    if (!(clp = auth_unix_lookup(&in6)))
         err = -EPERM;
     else {
         err = exp_rootfh(clp, data->gd_path, res, data->gd_maxlen);
@@ -258,7 +266,7 @@ static ssize_t write_getfs(struct file *
 static ssize_t write_getfd(struct file *file, char *buf, size_t size)
 {
     struct nfsctl_fdparm *data;
-    struct sockaddr_in *sin;
+    struct sockaddr_in6 *sin6, sin6_storage;
     struct auth_domain *clp;
     int err = 0;
     struct knfsd_fh fh;
@@ -269,20 +277,30 @@ static ssize_t write_getfd(struct file *
         return -EINVAL;
     data = (struct nfsctl_fdparm*)buf;
     err = -EPROTONOSUPPORT;
-    if (data->gd_addr.sa_family != AF_INET)
+    if (data->gd_addr.sa_family != AF_INET && data->gd_addr.sa_family 
!= AF_INET6)
         goto out;
     err = -EINVAL;
     if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
         goto out;
 
     res = buf;
-    sin = (struct sockaddr_in *)&data->gd_addr;
     exp_readlock();
-   
-    /* IPv6 address mapping */
-        ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), (((struct 
sockaddr_in *)&data->gd_addr)->sin_addr.s_addr));
 
-        if (!(clp = auth_unix_lookup(in6)))
+    switch (data->gd_addr.sa_family) {
+    case AF_INET:
+        /* IPv6 address mapping */
+        ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), ((struct 
sockaddr_in *)&data->gd_addr)->sin_addr.s_addr);
+        break;
+    case AF_INET6:
+        sin6 = &sin6_storage;
+        sin6 = (struct sockaddr_in6 *)&data->gd_addr;
+        ipv6_addr_copy(&in6, &(sin6->sin6_addr));
+        break;
+    default:
+        BUG();
+    }
+
+    if (!(clp = auth_unix_lookup(&in6)))
         err = -EPERM;
     else {
         err = exp_rootfh(clp, data->gd_path, &fh, NFS_FHSIZE);


-- 

********************************
       Aurelien Charbon
       Linux NFSv4 team
           Bull SAS
     Echirolles - France
http://nfsv4.bullopensource.org/
********************************


--------------090906080107000807060000
Content-Transfer-Encoding: 7bit
Content-Type: text/x-patch;
 name="linux-2.6.23-nfsctl.diff"
Content-Disposition: inline;
 filename="linux-2.6.23-nfsctl.diff"

diff -p -u -r -N linux-2.6.23-ipmap/fs/nfsd/nfsctl.c linux-2.6.23-nfsctl/fs/nfsd/nfsctl.c
--- linux-2.6.23-ipmap/fs/nfsd/nfsctl.c	2007-10-22 10:32:51.000000000 +0200
+++ linux-2.6.23-nfsctl/fs/nfsd/nfsctl.c	2007-10-22 11:06:13.000000000 +0200
@@ -219,7 +219,7 @@ static ssize_t write_unexport(struct fil
 static ssize_t write_getfs(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_fsparm *data;
-	struct sockaddr_in *sin;
+	struct sockaddr_in6 *sin6, sin6_storage;
 	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh *res;
@@ -229,9 +229,20 @@ static ssize_t write_getfs(struct file *
 		return -EINVAL;
 	data = (struct nfsctl_fsparm*)buf;
 	err = -EPROTONOSUPPORT;
-	if (data->gd_addr.sa_family != AF_INET)
+	switch (data->gd_addr.sa_family) {
+	case AF_INET6:
+		sin6 = &sin6_storage;
+		sin6 = (struct sockaddr_in6 *)&data->gd_addr;
+		ipv6_addr_copy(&in6, &(sin6->sin6_addr)); 
+		break;
+	case AF_INET:
+		/* Map v4 address into v6 structure */
+		ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), (((struct sockaddr_in *)&data->gd_addr)->sin_addr.s_addr));
+		break;
+	default:
 		goto out;
-	sin = (struct sockaddr_in *)&data->gd_addr;
+	}
+
 	if (data->gd_maxlen > NFS3_FHSIZE)
 		data->gd_maxlen = NFS3_FHSIZE;
 
@@ -239,10 +250,7 @@ static ssize_t write_getfs(struct file *
 
 	exp_readlock();
 
-	/* IPv6 address mapping */
-    	ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), (((struct sockaddr_in *)&data->gd_addr)->sin_addr.s_addr));
-
-    	if (!(clp = auth_unix_lookup(in6))) 
+	if (!(clp = auth_unix_lookup(&in6)))
 		err = -EPERM;
 	else {
 		err = exp_rootfh(clp, data->gd_path, res, data->gd_maxlen);
@@ -258,7 +266,7 @@ static ssize_t write_getfs(struct file *
 static ssize_t write_getfd(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_fdparm *data;
-	struct sockaddr_in *sin;
+	struct sockaddr_in6 *sin6, sin6_storage;
 	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh fh;
@@ -269,20 +277,30 @@ static ssize_t write_getfd(struct file *
 		return -EINVAL;
 	data = (struct nfsctl_fdparm*)buf;
 	err = -EPROTONOSUPPORT;
-	if (data->gd_addr.sa_family != AF_INET)
+	if (data->gd_addr.sa_family != AF_INET && data->gd_addr.sa_family != AF_INET6)
 		goto out;
 	err = -EINVAL;
 	if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
 		goto out;
 
 	res = buf;
-	sin = (struct sockaddr_in *)&data->gd_addr;
 	exp_readlock();
-	
-	/* IPv6 address mapping */
-    	ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), (((struct sockaddr_in *)&data->gd_addr)->sin_addr.s_addr));
 
-    	if (!(clp = auth_unix_lookup(in6))) 
+	switch (data->gd_addr.sa_family) {
+	case AF_INET:
+		/* IPv6 address mapping */
+		ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), ((struct sockaddr_in *)&data->gd_addr)->sin_addr.s_addr);
+		break;
+	case AF_INET6:
+		sin6 = &sin6_storage;
+		sin6 = (struct sockaddr_in6 *)&data->gd_addr;
+		ipv6_addr_copy(&in6, &(sin6->sin6_addr));
+		break;
+	default:
+		BUG();
+	}
+
+	if (!(clp = auth_unix_lookup(&in6)))
 		err = -EPERM;
 	else {
 		err = exp_rootfh(clp, data->gd_path, &fh, NFS_FHSIZE);

--------------090906080107000807060000
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--------------090906080107000807060000--
