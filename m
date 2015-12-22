From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: [RFC PATCH 11/17] netlabel: Prevent setsockopt() from changing the
 hop-by-hop option.
Date: Tue, 22 Dec 2015 11:46:47 +0000
Message-ID: <1450784813-18304-12-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

If a socket has a netlabel in place then don't let setsockopt() alter
the socket's IPv6 hop-by-hop option.  This is in the same spirit as
the existing check for IPv4.

Signed-off-by: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
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
1.8.0

_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
