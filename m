From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM][6/6] setsockopt/getsockopt cleanup
Date: Mon, 13 Oct 2003 23:47:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310140347.h9E3lIkT005624@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.4 --thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1144  -> 1.1145 
#	       net/atm/pvc.c	1.9     -> 1.10   
#	       net/atm/svc.c	1.10    -> 1.11   
#	    net/atm/common.h	1.9     -> 1.10   
#	    net/atm/common.c	1.26    -> 1.27   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/13	chas@relax.cmf.nrl.navy.mil	1.1145
# [ATM]: setsockopt/getsockopt cleanup
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Oct 13 18:41:42 2003
+++ b/net/atm/common.c	Mon Oct 13 18:41:42 2003
@@ -987,14 +987,16 @@
 	return check_tp(&qos->rxtp);
 }
 
-
-static int atm_do_setsockopt(struct socket *sock,int level,int optname,
-    void *optval,int optlen)
+int vcc_setsockopt(struct socket *sock, int level, int optname,
+		   char *optval, int optlen)
 {
 	struct atm_vcc *vcc;
 	unsigned long value;
 	int error;
 
+	if (__SO_LEVEL_MATCH(optname, level) && optlen != __SO_SIZE(optname))
+		return -EINVAL;
+
 	vcc = ATM_SD(sock);
 	switch (optname) {
 		case SO_ATMQOS:
@@ -1028,10 +1030,16 @@
 }
 
 
-static int atm_do_getsockopt(struct socket *sock,int level,int optname,
-    void *optval,int optlen)
+int vcc_getsockopt(struct socket *sock, int level, int optname,
+		   char *optval, int *optlen)
 {
 	struct atm_vcc *vcc;
+	int len;
+
+	if (get_user(len, optlen))
+		return -EFAULT;
+	if (__SO_LEVEL_MATCH(optname, level) && len != __SO_SIZE(optname))
+		return -EINVAL;
 
 	vcc = ATM_SD(sock);
 	switch (optname) {
@@ -1062,28 +1070,7 @@
 			break;
 	}
 	if (!vcc->dev || !vcc->dev->ops->getsockopt) return -EINVAL;
-	return vcc->dev->ops->getsockopt(vcc,level,optname,optval,optlen);
-}
-
-
-int atm_setsockopt(struct socket *sock,int level,int optname,char *optval,
-    int optlen)
-{
-	if (__SO_LEVEL_MATCH(optname, level) && optlen != __SO_SIZE(optname))
-		return -EINVAL;
-	return atm_do_setsockopt(sock,level,optname,optval,optlen);
-}
-
-
-int atm_getsockopt(struct socket *sock,int level,int optname,
-    char *optval,int *optlen)
-{
-	int len;
-
-	if (get_user(len,optlen)) return -EFAULT;
-	if (__SO_LEVEL_MATCH(optname, level) && len != __SO_SIZE(optname))
-		return -EINVAL;
-	return atm_do_getsockopt(sock,level,optname,optval,len);
+	return vcc->dev->ops->getsockopt(vcc, level, optname, optval, len);
 }
 
 
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Oct 13 18:41:42 2003
+++ b/net/atm/common.h	Mon Oct 13 18:41:42 2003
@@ -19,10 +19,10 @@
 		struct scm_cookie *scm);
 unsigned int atm_poll(struct file *file,struct socket *sock,poll_table *wait);
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
-int atm_setsockopt(struct socket *sock,int level,int optname,char *optval,
-    int optlen);
-int atm_getsockopt(struct socket *sock,int level,int optname,char *optval,
-    int *optlen);
+int vcc_setsockopt(struct socket *sock, int level, int optname, char *optval,
+		   int optlen);
+int vcc_getsockopt(struct socket *sock, int level, int optname, char *optval,
+		   int *optlen);
 
 void atm_shutdown_dev(struct atm_dev *dev);
 
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Mon Oct 13 18:41:42 2003
+++ b/net/atm/pvc.c	Mon Oct 13 18:41:42 2003
@@ -67,7 +67,7 @@
 	int error;
 
 	lock_sock(sk);
-	error = atm_setsockopt(sock, level, optname, optval, optlen);
+	error = vcc_setsockopt(sock, level, optname, optval, optlen);
 	release_sock(sk);
 	return error;
 }
@@ -80,7 +80,7 @@
 	int error;
 
 	lock_sock(sk);
-	error = atm_getsockopt(sock, level, optname, optval, optlen);
+	error = vcc_getsockopt(sock, level, optname, optval, optlen);
 	release_sock(sk);
 	return error;
 }
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Mon Oct 13 18:41:42 2003
+++ b/net/atm/svc.c	Mon Oct 13 18:41:42 2003
@@ -470,7 +470,7 @@
 
 	if (!__SO_LEVEL_MATCH(optname, level) || optname != SO_ATMSAP ||
 	    optlen != sizeof(struct atm_sap)) {
-		error = atm_setsockopt(sock, level, optname, optval, optlen);
+		error = vcc_setsockopt(sock, level, optname, optval, optlen);
 		goto out;
 	}
 	vcc = ATM_SD(sock);
@@ -493,7 +493,7 @@
 
 	lock_sock(sk);
 	if (!__SO_LEVEL_MATCH(optname, level) || optname != SO_ATMSAP) {
-		error = atm_getsockopt(sock, level, optname, optval, optlen);
+		error = vcc_getsockopt(sock, level, optname, optval, optlen);
 		goto out;
 	}
 	if (get_user(len, optlen)) {
