From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: [PATCH] Fix SELinux for removal of i_sock
Date: Fri, 01 Apr 2005 15:06:37 -0500
Message-ID: <1112385997.14481.192.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@redhat.com>,
        lkml <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
        matthew@wil.cx
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This patch against -bk eliminates the use of i_sock by SELinux as it
appears to have been removed recently, breaking the build of SELinux in
-bk.  Simply replacing the i_sock test with an S_ISSOCK test would be
unsafe in the SELinux code, as the latter will also return true for the
inodes of socket files in the filesystem, not just the actual socket
objects IIUC.  Hence this patch reworks the SELinux code to avoid the
need to apply such a test in the first place, part of which was
obsoleted anyway by earlier changes to SELinux.  Please apply.

Signed-off-by:  Stephen Smalley <sds@tycho.nsa.gov>
Signed-off-by:  James Morris <jmorris@redhat.com>

 security/selinux/hooks.c |   21 +++------------------
 1 files changed, 3 insertions(+), 18 deletions(-)

===== security/selinux/hooks.c 1.93 vs edited =====
--- 1.93/security/selinux/hooks.c	2005-03-28 17:21:19 -05:00
+++ edited/security/selinux/hooks.c	2005-04-01 15:01:58 -05:00
@@ -877,18 +877,8 @@ static int inode_doinit_with_dentry(stru
 	isec->initialized = 1;
 
 out:
-	if (inode->i_sock) {
-		struct socket *sock = SOCKET_I(inode);
-		if (sock->sk) {
-			isec->sclass = socket_type_to_security_class(sock->sk->sk_family,
-			                                             sock->sk->sk_type,
-			                                             sock->sk->sk_protocol);
-		} else {
-			isec->sclass = SECCLASS_SOCKET;
-		}
-	} else {
+	if (isec->sclass == SECCLASS_FILE)
 		isec->sclass = inode_mode_to_security_class(inode->i_mode);
-	}
 
 	if (hold_sem)
 		up(&isec->sem);
@@ -2979,18 +2969,15 @@ out:
 static void selinux_socket_post_create(struct socket *sock, int family,
 				       int type, int protocol, int kern)
 {
-	int err;
 	struct inode_security_struct *isec;
 	struct task_security_struct *tsec;
 
-	err = inode_doinit(SOCK_INODE(sock));
-	if (err < 0)
-		return;
 	isec = SOCK_INODE(sock)->i_security;
 
 	tsec = current->security;
 	isec->sclass = socket_type_to_security_class(family, type, protocol);
 	isec->sid = kern ? SECINITSID_KERNEL : tsec->sid;
+	isec->initialized = 1;
 
 	return;
 }
@@ -3158,14 +3145,12 @@ static int selinux_socket_accept(struct 
 	if (err)
 		return err;
 
-	err = inode_doinit(SOCK_INODE(newsock));
-	if (err < 0)
-		return err;
 	newisec = SOCK_INODE(newsock)->i_security;
 
 	isec = SOCK_INODE(sock)->i_security;
 	newisec->sclass = isec->sclass;
 	newisec->sid = isec->sid;
+	newisec->initialized = 1;
 
 	return 0;
 }


-- 
Stephen Smalley <sds@tycho.nsa.gov>
National Security Agency
