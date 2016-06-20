From: Huw Davies <huw@codeweavers.com>
Subject: [PATCH v4 11/19] netlabel: Prevent setsockopt() from changing the hop-by-hop option.
Date: Mon, 20 Jun 2016 14:36:51 +0100
Message-ID: <1466429819-12707-12-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a socket has a netlabel in place then don't let setsockopt() alter
the socket's IPv6 hop-by-hop option.  This is in the same spirit as
the existing check for IPv4.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 security/selinux/netlabel.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index 5470f32..2477a75 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -410,6 +410,21 @@ int selinux_netlbl_sock_rcv_skb(struct sk_security_struct *sksec,
 }
 
 /**
+ * selinux_netlbl_option - Is this a NetLabel option
+ * @level: the socket level or protocol
+ * @optname: the socket option name
+ *
+ * Description:
+ * Returns true if @level and @optname refer to a NetLabel option.
+ * Helper for selinux_netlbl_socket_setsockopt().
+ */
+static inline int selinux_netlbl_option(int level, int optname)
+{
+	return (level == IPPROTO_IP && optname == IP_OPTIONS) ||
+		(level == IPPROTO_IPV6 && optname == IPV6_HOPOPTS);
+}
+
+/**
  * selinux_netlbl_socket_setsockopt - Do not allow users to remove a NetLabel
  * @sock: the socket
  * @level: the socket level or protocol
@@ -431,7 +446,7 @@ int selinux_netlbl_socket_setsockopt(struct socket *sock,
 	struct sk_security_struct *sksec = sk->sk_security;
 	struct netlbl_lsm_secattr secattr;
 
-	if (level == IPPROTO_IP && optname == IP_OPTIONS &&
+	if (selinux_netlbl_option(level, optname) &&
 	    (sksec->nlbl_state == NLBL_LABELED ||
 	     sksec->nlbl_state == NLBL_CONNLABELED)) {
 		netlbl_secattr_init(&secattr);
-- 
2.7.4

