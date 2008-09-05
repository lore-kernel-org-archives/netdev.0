From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v5 04/14] selinux: Fix missing calls to netlbl_skbuff_err()
Date: Fri, 05 Sep 2008 19:23:38 -0400
Message-ID: <20080905232338.31840.83270.stgit@flek.lan>
References: <20080905231853.31840.57880.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080905231853.31840.57880.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At some point I think I messed up and dropped the calls to netlbl_skbuff_err()
which are necessary for CIPSO to send error notifications to remote systems.
This patch re-introduces the error handling calls into the SELinux code.

Signed-off-by: Paul Moore <paul.moore@hp.com>
Acked-by: James Morris <jmorris@namei.org>
---

 include/net/netlabel.h              |    6 ++++--
 net/netlabel/netlabel_kapi.c        |    5 +++--
 security/selinux/hooks.c            |   19 +++++++++++++++----
 security/selinux/include/netlabel.h |    9 +++++++++
 security/selinux/netlabel.c         |   20 +++++++++++++++++++-
 5 files changed, 50 insertions(+), 9 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 5303749..e16db09 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -382,7 +382,7 @@ int netlbl_sock_getattr(struct sock *sk,
 int netlbl_skbuff_getattr(const struct sk_buff *skb,
 			  u16 family,
 			  struct netlbl_lsm_secattr *secattr);
-void netlbl_skbuff_err(struct sk_buff *skb, int error);
+void netlbl_skbuff_err(struct sk_buff *skb, int error, int gateway);
 
 /*
  * LSM label mapping cache operations
@@ -454,7 +454,9 @@ static inline int netlbl_skbuff_getattr(const struct sk_buff *skb,
 {
 	return -ENOSYS;
 }
-static inline void netlbl_skbuff_err(struct sk_buff *skb, int error)
+static inline void netlbl_skbuff_err(struct sk_buff *skb,
+				     int error,
+				     int gateway)
 {
 	return;
 }
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 6c211fe..22faba6 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -490,6 +490,7 @@ int netlbl_skbuff_getattr(const struct sk_buff *skb,
  * netlbl_skbuff_err - Handle a LSM error on a sk_buff
  * @skb: the packet
  * @error: the error code
+ * @gateway: true if host is acting as a gateway, false otherwise
  *
  * Description:
  * Deal with a LSM problem when handling the packet in @skb, typically this is
@@ -497,10 +498,10 @@ int netlbl_skbuff_getattr(const struct sk_buff *skb,
  * according to the packet's labeling protocol.
  *
  */
-void netlbl_skbuff_err(struct sk_buff *skb, int error)
+void netlbl_skbuff_err(struct sk_buff *skb, int error, int gateway)
 {
 	if (CIPSO_V4_OPTEXIST(skb))
-		cipso_v4_error(skb, error, 0);
+		cipso_v4_error(skb, error, gateway);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 065de8c..a09956d 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4101,6 +4101,8 @@ static int selinux_sock_rcv_skb_compat(struct sock *sk, struct sk_buff *skb,
 			return err;
 		err = avc_has_perm(sk_sid, peer_sid,
 				   SECCLASS_PEER, PEER__RECV, &ad);
+		if (err)
+			selinux_netlbl_err(skb, err, 0);
 	} else {
 		err = selinux_netlbl_sock_rcv_skb(sksec, skb, family, &ad);
 		if (err)
@@ -4156,10 +4158,14 @@ static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 			return err;
 		err = selinux_inet_sys_rcv_skb(skb->iif, addrp, family,
 					       peer_sid, &ad);
-		if (err)
+		if (err) {
+			selinux_netlbl_err(skb, err, 0);
 			return err;
+		}
 		err = avc_has_perm(sk_sid, peer_sid, SECCLASS_PEER,
 				   PEER__RECV, &ad);
+		if (err)
+			selinux_netlbl_err(skb, err, 0);
 	}
 
 	if (secmark_active) {
@@ -4384,6 +4390,7 @@ out:
 static unsigned int selinux_ip_forward(struct sk_buff *skb, int ifindex,
 				       u16 family)
 {
+	int err;
 	char *addrp;
 	u32 peer_sid;
 	struct avc_audit_data ad;
@@ -4407,10 +4414,14 @@ static unsigned int selinux_ip_forward(struct sk_buff *skb, int ifindex,
 	if (selinux_parse_skb(skb, &ad, &addrp, 1, NULL) != 0)
 		return NF_DROP;
 
-	if (peerlbl_active)
-		if (selinux_inet_sys_rcv_skb(ifindex, addrp, family,
-					     peer_sid, &ad) != 0)
+	if (peerlbl_active) {
+		err = selinux_inet_sys_rcv_skb(ifindex, addrp, family,
+					       peer_sid, &ad);
+		if (err) {
+			selinux_netlbl_err(skb, err, 1);
 			return NF_DROP;
+		}
+	}
 
 	if (secmark_active)
 		if (avc_has_perm(peer_sid, skb->secmark,
diff --git a/security/selinux/include/netlabel.h b/security/selinux/include/netlabel.h
index 487a7d8..d4e3ac8 100644
--- a/security/selinux/include/netlabel.h
+++ b/security/selinux/include/netlabel.h
@@ -39,6 +39,8 @@
 #ifdef CONFIG_NETLABEL
 void selinux_netlbl_cache_invalidate(void);
 
+void selinux_netlbl_err(struct sk_buff *skb, int error, int gateway);
+
 void selinux_netlbl_sk_security_reset(struct sk_security_struct *ssec,
 				      int family);
 
@@ -63,6 +65,13 @@ static inline void selinux_netlbl_cache_invalidate(void)
 	return;
 }
 
+static inline void selinux_netlbl_err(struct sk_buff *skb,
+				      int error,
+				      int gateway)
+{
+	return;
+}
+
 static inline void selinux_netlbl_sk_security_reset(
 					       struct sk_security_struct *ssec,
 					       int family)
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index 89b4183..0207bd2 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -106,6 +106,24 @@ void selinux_netlbl_cache_invalidate(void)
 }
 
 /**
+ * selinux_netlbl_err - Handle a NetLabel packet error
+ * @skb: the packet
+ * @error: the error code
+ * @gateway: true if host is acting as a gateway, false otherwise
+ *
+ * Description:
+ * When a packet is dropped due to a call to avc_has_perm() pass the error
+ * code to the NetLabel subsystem so any protocol specific processing can be
+ * done.  This is safe to call even if you are unsure if NetLabel labeling is
+ * present on the packet, NetLabel is smart enough to only act when it should.
+ *
+ */
+void selinux_netlbl_err(struct sk_buff *skb, int error, int gateway)
+{
+	netlbl_skbuff_err(skb, error, gateway);
+}
+
+/**
  * selinux_netlbl_sk_security_reset - Reset the NetLabel fields
  * @ssec: the sk_security_struct
  * @family: the socket family
@@ -307,7 +325,7 @@ int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
 		return 0;
 
 	if (nlbl_sid != SECINITSID_UNLABELED)
-		netlbl_skbuff_err(skb, rc);
+		netlbl_skbuff_err(skb, rc, 0);
 	return rc;
 }
 

