From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 2/2] selinux: Support for the new TUN LSM hooks
Date: Fri, 28 Aug 2009 18:12:49 -0400
Message-ID: <20090828221249.3900.87302.stgit@flek.lan>
References: <20090828220400.3900.64377.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090828220400.3900.64377.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for the new TUN LSM hooks: security_tun_dev_create(),
security_tun_dev_post_create() and security_tun_dev_attach().  This includes
the addition of a new object class, tun_socket, which represents the socks
associated with TUN devices.  The _tun_dev_create() and _tun_dev_post_create()
hooks are fairly similar to the standard socket functions but _tun_dev_attach()
is a bit special.  The _tun_dev_attach() is unique because it involves a
domain attaching to an existing TUN device and its associated tun_socket
object, an operation which does not exist with standard sockets and most
closely resembles a relabel operation.

Signed-off-by: Paul Moore <paul.moore@hp.com>
Acked-by: Eric Paris <eparis@parisplace.org>
---

 security/selinux/hooks.c                   |   60 +++++++++++++++++++++++++++-
 security/selinux/include/av_inherit.h      |    1 
 security/selinux/include/av_permissions.h  |   22 ++++++++++
 security/selinux/include/class_to_string.h |    1 
 security/selinux/include/flask.h           |    1 
 5 files changed, 83 insertions(+), 2 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 8d8b69c..8ee6b07 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -13,8 +13,8 @@
  *					   Eric Paris <eparis@redhat.com>
  *  Copyright (C) 2004-2005 Trusted Computer Solutions, Inc.
  *			    <dgoeddel@trustedcs.com>
- *  Copyright (C) 2006, 2007 Hewlett-Packard Development Company, L.P.
- *		Paul Moore <paul.moore@hp.com>
+ *  Copyright (C) 2006, 2007, 2009 Hewlett-Packard Development Company, L.P.
+ *	Paul Moore <paul.moore@hp.com>
  *  Copyright (C) 2007 Hitachi Software Engineering Co., Ltd.
  *		       Yuichi Nakamura <ynakam@hitachisoft.jp>
  *
@@ -4309,6 +4309,59 @@ static void selinux_req_classify_flow(const struct request_sock *req,
 	fl->secid = req->secid;
 }
 
+static int selinux_tun_dev_create(void)
+{
+	u32 sid = current_sid();
+
+	/* we aren't taking into account the "sockcreate" SID since the socket
+	 * that is being created here is not a socket in the traditional sense,
+	 * instead it is a private sock, accessible only to the kernel, and
+	 * representing a wide range of network traffic spanning multiple
+	 * connections unlike traditional sockets - check the TUN driver to
+	 * get a better understanding of why this socket is special */
+
+	return avc_has_perm(sid, sid, SECCLASS_TUN_SOCKET, TUN_SOCKET__CREATE,
+			    NULL);
+}
+
+static void selinux_tun_dev_post_create(struct sock *sk)
+{
+	struct sk_security_struct *sksec = sk->sk_security;
+
+	/* we don't currently perform any NetLabel based labeling here and it
+	 * isn't clear that we would want to do so anyway; while we could apply
+	 * labeling without the support of the TUN user the resulting labeled
+	 * traffic from the other end of the connection would almost certainly
+	 * cause confusion to the TUN user that had no idea network labeling
+	 * protocols were being used */
+
+	/* see the comments in selinux_tun_dev_create() about why we don't use
+	 * the sockcreate SID here */
+
+	sksec->sid = current_sid();
+	sksec->sclass = SECCLASS_TUN_SOCKET;
+}
+
+static int selinux_tun_dev_attach(struct sock *sk)
+{
+	struct sk_security_struct *sksec = sk->sk_security;
+	u32 sid = current_sid();
+	int err;
+
+	err = avc_has_perm(sid, sksec->sid, SECCLASS_TUN_SOCKET,
+			   TUN_SOCKET__RELABELFROM, NULL);
+	if (err)
+		return err;
+	err = avc_has_perm(sid, sid, SECCLASS_TUN_SOCKET,
+			   TUN_SOCKET__RELABELTO, NULL);
+	if (err)
+		return err;
+
+	sksec->sid = sid;
+
+	return 0;
+}
+
 static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
 {
 	int err = 0;
@@ -5477,6 +5530,9 @@ static struct security_operations selinux_ops = {
 	.inet_csk_clone =		selinux_inet_csk_clone,
 	.inet_conn_established =	selinux_inet_conn_established,
 	.req_classify_flow =		selinux_req_classify_flow,
+	.tun_dev_create =		selinux_tun_dev_create,
+	.tun_dev_post_create = 		selinux_tun_dev_post_create,
+	.tun_dev_attach =		selinux_tun_dev_attach,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
diff --git a/security/selinux/include/av_inherit.h b/security/selinux/include/av_inherit.h
index 8377a4b..abedcd7 100644
--- a/security/selinux/include/av_inherit.h
+++ b/security/selinux/include/av_inherit.h
@@ -15,6 +15,7 @@
    S_(SECCLASS_KEY_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_UNIX_STREAM_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_UNIX_DGRAM_SOCKET, socket, 0x00400000UL)
+   S_(SECCLASS_TUN_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_IPC, ipc, 0x00000200UL)
    S_(SECCLASS_SEM, ipc, 0x00000200UL)
    S_(SECCLASS_MSGQ, ipc, 0x00000200UL)
diff --git a/security/selinux/include/av_permissions.h b/security/selinux/include/av_permissions.h
index d645192..0b41ad5 100644
--- a/security/selinux/include/av_permissions.h
+++ b/security/selinux/include/av_permissions.h
@@ -423,6 +423,28 @@
 #define UNIX_DGRAM_SOCKET__RECV_MSG               0x00080000UL
 #define UNIX_DGRAM_SOCKET__SEND_MSG               0x00100000UL
 #define UNIX_DGRAM_SOCKET__NAME_BIND              0x00200000UL
+#define TUN_SOCKET__IOCTL                         0x00000001UL
+#define TUN_SOCKET__READ                          0x00000002UL
+#define TUN_SOCKET__WRITE                         0x00000004UL
+#define TUN_SOCKET__CREATE                        0x00000008UL
+#define TUN_SOCKET__GETATTR                       0x00000010UL
+#define TUN_SOCKET__SETATTR                       0x00000020UL
+#define TUN_SOCKET__LOCK                          0x00000040UL
+#define TUN_SOCKET__RELABELFROM                   0x00000080UL
+#define TUN_SOCKET__RELABELTO                     0x00000100UL
+#define TUN_SOCKET__APPEND                        0x00000200UL
+#define TUN_SOCKET__BIND                          0x00000400UL
+#define TUN_SOCKET__CONNECT                       0x00000800UL
+#define TUN_SOCKET__LISTEN                        0x00001000UL
+#define TUN_SOCKET__ACCEPT                        0x00002000UL
+#define TUN_SOCKET__GETOPT                        0x00004000UL
+#define TUN_SOCKET__SETOPT                        0x00008000UL
+#define TUN_SOCKET__SHUTDOWN                      0x00010000UL
+#define TUN_SOCKET__RECVFROM                      0x00020000UL
+#define TUN_SOCKET__SENDTO                        0x00040000UL
+#define TUN_SOCKET__RECV_MSG                      0x00080000UL
+#define TUN_SOCKET__SEND_MSG                      0x00100000UL
+#define TUN_SOCKET__NAME_BIND                     0x00200000UL
 #define PROCESS__FORK                             0x00000001UL
 #define PROCESS__TRANSITION                       0x00000002UL
 #define PROCESS__SIGCHLD                          0x00000004UL
diff --git a/security/selinux/include/class_to_string.h b/security/selinux/include/class_to_string.h
index 21ec786..7ab9299 100644
--- a/security/selinux/include/class_to_string.h
+++ b/security/selinux/include/class_to_string.h
@@ -77,3 +77,4 @@
     S_(NULL)
     S_(NULL)
     S_("kernel_service")
+    S_("tun_socket")
diff --git a/security/selinux/include/flask.h b/security/selinux/include/flask.h
index 882f27d..f248500 100644
--- a/security/selinux/include/flask.h
+++ b/security/selinux/include/flask.h
@@ -53,6 +53,7 @@
 #define SECCLASS_PEER                                    68
 #define SECCLASS_CAPABILITY2                             69
 #define SECCLASS_KERNEL_SERVICE                          74
+#define SECCLASS_TUN_SOCKET                              75
 
 /*
  * Security identifier indices for initial entities

