From: Huw Davies <huw@codeweavers.com>
Subject: [PATCH v4 16/19] netlabel: Pass a family parameter to netlbl_skbuff_err().
Date: Mon, 20 Jun 2016 14:36:56 +0100
Message-ID: <1466429819-12707-17-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

This makes it possible to route the error to the appropriate
labelling engine.  CALIPSO is far less verbose than CIPSO
when encountering a bogus packet, so there is no need for a
CALIPSO error handler.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 include/net/netlabel.h              |  2 +-
 net/netlabel/netlabel_kapi.c        | 11 ++++++++---
 security/selinux/hooks.c            |  6 +++---
 security/selinux/include/netlabel.h |  4 +++-
 security/selinux/netlabel.c         |  6 +++---
 security/smack/smack_lsm.c          |  2 +-
 6 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index e0e4ce8..d8a46a8 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -488,7 +488,7 @@ int netlbl_skbuff_setattr(struct sk_buff *skb,
 int netlbl_skbuff_getattr(const struct sk_buff *skb,
 			  u16 family,
 			  struct netlbl_lsm_secattr *secattr);
-void netlbl_skbuff_err(struct sk_buff *skb, int error, int gateway);
+void netlbl_skbuff_err(struct sk_buff *skb, u16 family, int error, int gateway);
 
 /*
  * LSM label mapping cache operations
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index bace474..35df8f5 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -1250,6 +1250,7 @@ int netlbl_skbuff_getattr(const struct sk_buff *skb,
 /**
  * netlbl_skbuff_err - Handle a LSM error on a sk_buff
  * @skb: the packet
+ * @family: the family
  * @error: the error code
  * @gateway: true if host is acting as a gateway, false otherwise
  *
@@ -1259,10 +1260,14 @@ int netlbl_skbuff_getattr(const struct sk_buff *skb,
  * according to the packet's labeling protocol.
  *
  */
-void netlbl_skbuff_err(struct sk_buff *skb, int error, int gateway)
+void netlbl_skbuff_err(struct sk_buff *skb, u16 family, int error, int gateway)
 {
-	if (cipso_v4_optptr(skb))
-		cipso_v4_error(skb, error, gateway);
+	switch (family) {
+	case AF_INET:
+		if (cipso_v4_optptr(skb))
+			cipso_v4_error(skb, error, gateway);
+		break;
+	}
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 93eed8f..0324493 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4539,13 +4539,13 @@ static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		err = selinux_inet_sys_rcv_skb(sock_net(sk), skb->skb_iif,
 					       addrp, family, peer_sid, &ad);
 		if (err) {
-			selinux_netlbl_err(skb, err, 0);
+			selinux_netlbl_err(skb, family, err, 0);
 			return err;
 		}
 		err = avc_has_perm(sk_sid, peer_sid, SECCLASS_PEER,
 				   PEER__RECV, &ad);
 		if (err) {
-			selinux_netlbl_err(skb, err, 0);
+			selinux_netlbl_err(skb, family, err, 0);
 			return err;
 		}
 	}
@@ -4911,7 +4911,7 @@ static unsigned int selinux_ip_forward(struct sk_buff *skb,
 		err = selinux_inet_sys_rcv_skb(dev_net(indev), indev->ifindex,
 					       addrp, family, peer_sid, &ad);
 		if (err) {
-			selinux_netlbl_err(skb, err, 1);
+			selinux_netlbl_err(skb, family, err, 1);
 			return NF_DROP;
 		}
 	}
diff --git a/security/selinux/include/netlabel.h b/security/selinux/include/netlabel.h
index 8c59b8f..75686d5 100644
--- a/security/selinux/include/netlabel.h
+++ b/security/selinux/include/netlabel.h
@@ -40,7 +40,8 @@
 #ifdef CONFIG_NETLABEL
 void selinux_netlbl_cache_invalidate(void);
 
-void selinux_netlbl_err(struct sk_buff *skb, int error, int gateway);
+void selinux_netlbl_err(struct sk_buff *skb, u16 family, int error,
+			int gateway);
 
 void selinux_netlbl_sk_security_free(struct sk_security_struct *sksec);
 void selinux_netlbl_sk_security_reset(struct sk_security_struct *sksec);
@@ -72,6 +73,7 @@ static inline void selinux_netlbl_cache_invalidate(void)
 }
 
 static inline void selinux_netlbl_err(struct sk_buff *skb,
+				      u16 family,
 				      int error,
 				      int gateway)
 {
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index ca220c3..dfca50d 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -151,9 +151,9 @@ void selinux_netlbl_cache_invalidate(void)
  * present on the packet, NetLabel is smart enough to only act when it should.
  *
  */
-void selinux_netlbl_err(struct sk_buff *skb, int error, int gateway)
+void selinux_netlbl_err(struct sk_buff *skb, u16 family, int error, int gateway)
 {
-	netlbl_skbuff_err(skb, error, gateway);
+	netlbl_skbuff_err(skb, family, error, gateway);
 }
 
 /**
@@ -405,7 +405,7 @@ int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
 		return 0;
 
 	if (nlbl_sid != SECINITSID_UNLABELED)
-		netlbl_skbuff_err(skb, rc, 0);
+		netlbl_skbuff_err(skb, family, rc, 0);
 	return rc;
 }
 
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 11f7901..292fdea 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -3992,7 +3992,7 @@ access_check:
 		rc = smk_bu_note("IPv4 delivery", skp, ssp->smk_in,
 					MAY_WRITE, rc);
 		if (rc != 0)
-			netlbl_skbuff_err(skb, rc, 0);
+			netlbl_skbuff_err(skb, sk->sk_family, rc, 0);
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case PF_INET6:
-- 
2.7.4

