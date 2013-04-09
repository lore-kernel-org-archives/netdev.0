From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] selinux: add a skb_owned_by() hook
Date: Mon, 08 Apr 2013 20:58:11 -0700
Message-ID: <1365479891.3887.99.camel@edumazet-glaptop>
References: <20130408154519.18177.57709.stgit@localhost>
	 <3294227.D2rod7xgQB@sifl> <1365454501.3887.45.camel@edumazet-glaptop>
	 <6182509.cOVcY8B4g7@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com, linux-security-module@vger.kernel.org
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <6182509.cOVcY8B4g7@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

Commit 90ba9b1986b5ac (tcp: tcp_make_synack() can use alloc_skb())
broke certain SELinux/NetLabel configurations by no longer correctly
assigning the sock to the outgoing SYNACK packet.

Cost of atomic operations on the LISTEN socket is quite big,
and we would like it to happen only if really needed.

This patch introduces a new security_ops->skb_owned_by() method,
that is a void operation unless selinux is active.

Reported-by: Miroslav Vadkerti <mvadkert@redhat.com>
Diagnosed-by: Paul Moore <pmoore@redhat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-security-module@vger.kernel.org
---
 include/linux/security.h |    8 ++++++++
 net/ipv4/tcp_output.c    |    1 +
 security/capability.c    |    6 ++++++
 security/security.c      |    5 +++++
 security/selinux/hooks.c |    7 +++++++
 5 files changed, 27 insertions(+)

diff --git a/include/linux/security.h b/include/linux/security.h
index eee7478..6c3a78a 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1638,6 +1638,7 @@ struct security_operations {
 	int (*tun_dev_attach_queue) (void *security);
 	int (*tun_dev_attach) (struct sock *sk, void *security);
 	int (*tun_dev_open) (void *security);
+	void (*skb_owned_by) (struct sk_buff *skb, struct sock *sk);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -2588,6 +2589,8 @@ int security_tun_dev_attach_queue(void *security);
 int security_tun_dev_attach(struct sock *sk, void *security);
 int security_tun_dev_open(void *security);
 
+void security_skb_owned_by(struct sk_buff *skb, struct sock *sk);
+
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct sock *sock,
 					       struct sock *other,
@@ -2779,6 +2782,11 @@ static inline int security_tun_dev_open(void *security)
 {
 	return 0;
 }
+
+static inline void security_skb_owned_by(struct sk_buff *skb, struct sock *sk)
+{
+}
+
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5d0b438..b44cf81 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2709,6 +2709,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	skb_reserve(skb, MAX_TCP_HEADER);
 
 	skb_dst_set(skb, dst);
+	security_skb_owned_by(skb, sk);
 
 	mss = dst_metric_advmss(dst);
 	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < mss)
diff --git a/security/capability.c b/security/capability.c
index 5797750..c36cca6 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -737,6 +737,11 @@ static int cap_tun_dev_open(void *security)
 {
 	return 0;
 }
+
+static void cap_skb_owned_by(struct sk_buff *skb, struct sock *sk) 
+{
+}
+
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -1071,6 +1076,7 @@ void __init security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, tun_dev_open);
 	set_to_cap_if_null(ops, tun_dev_attach_queue);
 	set_to_cap_if_null(ops, tun_dev_attach);
+	set_to_cap_if_null(ops, skb_owned_by);
 #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	set_to_cap_if_null(ops, xfrm_policy_alloc_security);
diff --git a/security/security.c b/security/security.c
index 7b88c6a..03f248b 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1290,6 +1290,11 @@ int security_tun_dev_open(void *security)
 }
 EXPORT_SYMBOL(security_tun_dev_open);
 
+void security_skb_owned_by(struct sk_buff *skb, struct sock *sk)
+{
+	security_ops->skb_owned_by(skb, sk);
+}
+
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 2fa28c8..7171a95 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -51,6 +51,7 @@
 #include <linux/tty.h>
 #include <net/icmp.h>
 #include <net/ip.h>		/* for local_port_range[] */
+#include <net/sock.h>
 #include <net/tcp.h>		/* struct or_callable used in sock_rcv_skb */
 #include <net/net_namespace.h>
 #include <net/netlabel.h>
@@ -4363,6 +4364,11 @@ static void selinux_inet_conn_established(struct sock *sk, struct sk_buff *skb)
 	selinux_skb_peerlbl_sid(skb, family, &sksec->peer_sid);
 }
 
+static void selinux_skb_owned_by(struct sk_buff *skb, struct sock *sk)
+{
+	skb_set_owner_w(skb, sk);
+}
+
 static int selinux_secmark_relabel_packet(u32 sid)
 {
 	const struct task_security_struct *__tsec;
@@ -5664,6 +5670,7 @@ static struct security_operations selinux_ops = {
 	.tun_dev_attach_queue =		selinux_tun_dev_attach_queue,
 	.tun_dev_attach =		selinux_tun_dev_attach,
 	.tun_dev_open =			selinux_tun_dev_open,
+	.skb_owned_by =			selinux_skb_owned_by,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,


