From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v1 2/2] selinux: Support for the new TUN LSM hooks
Date: Tue, 04 Aug 2009 17:22:04 -0400
Message-ID: <20090804212204.10798.53727.stgit@flek.lan>
References: <20090804211304.10798.65601.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090804211304.10798.65601.stgit@flek.lan>
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

This patch also includes a new policy capability, tun_perms, to ensure that
the new access controls do not affect older SELinux policies.

--

NOTE: This relies on some changes to the policy to add the new object class
      and its associated permissions, I will ensure that the policy is sorted
      and merged before pushing this patch upstream.  Also, you will notice
      that the new tun_socket object class simply inherits the base socket
      object class, thoughts?
---

 security/selinux/hooks.c                   |   76 +++++++++++++++++++++++++++-
 security/selinux/include/av_inherit.h      |    1 
 security/selinux/include/av_permissions.h  |   22 ++++++++
 security/selinux/include/class_to_string.h |    1 
 security/selinux/include/flask.h           |    1 
 security/selinux/include/security.h        |    2 +
 security/selinux/selinuxfs.c               |    3 +
 security/selinux/ss/services.c             |    3 +
 8 files changed, 106 insertions(+), 3 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 15c2a08..6ba99c2 100644
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
@@ -4296,6 +4296,75 @@ static void selinux_req_classify_flow(const struct request_sock *req,
 	fl->secid = req->secid;
 }
 
+static int selinux_tun_dev_create(void)
+{
+	u32 sid;
+	int err;
+
+	err = cap_tun_dev_create();
+	if (err)
+		return err;
+
+	if (!selinux_policycap_tunperm)
+		return 0;
+
+	/* we aren't taking into account the "sockcreate" SID since the socket
+	 * that is being created here is not a socket in the traditional sense,
+	 * instead it is a private sock, accessible only to the kernel, and
+	 * representing a wide range of network traffic spanning multiple
+	 * connections unlike traditional sockets - check the TUN driver to
+	 * get a better understand of why this socket is special */
+
+	sid = current_sid();
+	return avc_has_perm(sid, sid, SECCLASS_TUN_SOCKET, TUN_SOCKET__CREATE,
+			    NULL);
+}
+
+static void selinux_tun_dev_post_create(struct sock *tun_sk)
+{
+	struct sk_security_struct *sksec = tun_sk->sk_security;
+
+	/* see the comments in _tun_dev_create() about why we don't use the
+	 * sockcreate SID here */
+
+	/* we don't currently perform any NetLabel based labeling here and it
+	 * isn't clear that we would want to do so anyway: while we could apply
+	 * labeling without the support of the TUN user the resulting labeled
+	 * traffic from the other end of the connection would almost certainly
+	 * cause confusion to the TUN user that had no idea network labeling
+	 * protocols were being used */
+
+	sksec->sid = current_sid();
+	sksec->sclass = SECCLASS_TUN_SOCKET;
+}
+
+static int selinux_tun_dev_attach(struct sock *tun_sk)
+{
+	struct sk_security_struct *tun_sksec = tun_sk->sk_security;
+	u32 sid;
+	int err;
+
+	err = cap_tun_dev_attach();
+	if (err)
+		return err;
+
+	if (!selinux_policycap_tunperm)
+		return 0;
+
+	sid = current_sid();
+	err = avc_has_perm(sid, tun_sksec->sid, SECCLASS_TUN_SOCKET,
+			   TUN_SOCKET__RELABELFROM, NULL);
+	if (err)
+		return err;
+	err = avc_has_perm(sid, sid, SECCLASS_RAWIP_SOCKET,
+			   TUN_SOCKET__RELABELTO, NULL);
+	if (err)
+		return err;
+	tun_sksec->sid = sid;
+
+	return 0;
+}
+
 static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
 {
 	int err = 0;
@@ -5464,6 +5533,9 @@ static struct security_operations selinux_ops = {
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
diff --git a/security/selinux/include/security.h b/security/selinux/include/security.h
index ca83579..188af8d 100644
--- a/security/selinux/include/security.h
+++ b/security/selinux/include/security.h
@@ -63,12 +63,14 @@ extern int selinux_mls_enabled;
 enum {
 	POLICYDB_CAPABILITY_NETPEER,
 	POLICYDB_CAPABILITY_OPENPERM,
+	POLICYDB_CAPABILITY_TUNPERM,
 	__POLICYDB_CAPABILITY_MAX
 };
 #define POLICYDB_CAPABILITY_MAX (__POLICYDB_CAPABILITY_MAX - 1)
 
 extern int selinux_policycap_netpeer;
 extern int selinux_policycap_openperm;
+extern int selinux_policycap_tunperm;
 
 /*
  * type_datum properties
diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index b4fc506..770e059 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -42,7 +42,8 @@
 /* Policy capability filenames */
 static char *policycap_names[] = {
 	"network_peer_controls",
-	"open_perms"
+	"open_perms",
+	"tun_perms"
 };
 
 unsigned int selinux_checkreqprot = CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE;
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index 500e6f7..adbe6d5 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -64,6 +64,7 @@ unsigned int policydb_loaded_version;
 
 int selinux_policycap_netpeer;
 int selinux_policycap_openperm;
+int selinux_policycap_tunperm;
 
 /*
  * This is declared in avc.c
@@ -1593,6 +1594,8 @@ static void security_load_policycaps(void)
 						  POLICYDB_CAPABILITY_NETPEER);
 	selinux_policycap_openperm = ebitmap_get_bit(&policydb.policycaps,
 						  POLICYDB_CAPABILITY_OPENPERM);
+	selinux_policycap_tunperm = ebitmap_get_bit(&policydb.policycaps,
+						   POLICYDB_CAPABILITY_TUNPERM);
 }
 
 extern void selinux_complete_init(void);

