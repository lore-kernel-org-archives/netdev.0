From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next] Revert "selinux: add a skb_owned_by() hook"
Date: Fri, 20 Mar 2015 17:15:19 -0700
Message-ID: <1426896919-23036-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:33574 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbbCUAPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 20:15:23 -0400
Received: by iecrl12 with SMTP id rl12so200538iec.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 17:15:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit ca10b9e9a8ca7342ee07065289cbe74ac128c169.

No longer needed after commit eb8895debe1baba41fcb62c78a16f0c63c21662a
("tcp: tcp_make_synack() should use sock_wmalloc")

When under SYNFLOOD, we build lot of SYNACK and hit false sharing
because of multiple modifications done on sk_listener->sk_wmem_alloc

Since tcp_make_synack() uses sock_wmalloc(), there is no need
to call skb_set_owner_w() again, as this adds two atomic operations.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/security.h | 8 --------
 net/ipv4/tcp_output.c    | 1 -
 security/capability.c    | 6 ------
 security/security.c      | 5 -----
 security/selinux/hooks.c | 7 -------
 5 files changed, 27 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index a1b7dbd127ff..25a079a7c3b3 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1716,7 +1716,6 @@ struct security_operations {
 	int (*tun_dev_attach_queue) (void *security);
 	int (*tun_dev_attach) (struct sock *sk, void *security);
 	int (*tun_dev_open) (void *security);
-	void (*skb_owned_by) (struct sk_buff *skb, struct sock *sk);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -2735,8 +2734,6 @@ int security_tun_dev_attach_queue(void *security);
 int security_tun_dev_attach(struct sock *sk, void *security);
 int security_tun_dev_open(void *security);
 
-void security_skb_owned_by(struct sk_buff *skb, struct sock *sk);
-
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct sock *sock,
 					       struct sock *other,
@@ -2928,11 +2925,6 @@ static inline int security_tun_dev_open(void *security)
 {
 	return 0;
 }
-
-static inline void security_skb_owned_by(struct sk_buff *skb, struct sock *sk)
-{
-}
-
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c2f0f6065cb1..18474088c3d0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2926,7 +2926,6 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	skb_reserve(skb, MAX_TCP_HEADER);
 
 	skb_dst_set(skb, dst);
-	security_skb_owned_by(skb, sk);
 
 	mss = dst_metric_advmss(dst);
 	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < mss)
diff --git a/security/capability.c b/security/capability.c
index 070dd46f62f4..58a1600c149b 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -776,11 +776,6 @@ static int cap_tun_dev_open(void *security)
 {
 	return 0;
 }
-
-static void cap_skb_owned_by(struct sk_buff *skb, struct sock *sk)
-{
-}
-
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -1134,7 +1129,6 @@ void __init security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, tun_dev_open);
 	set_to_cap_if_null(ops, tun_dev_attach_queue);
 	set_to_cap_if_null(ops, tun_dev_attach);
-	set_to_cap_if_null(ops, skb_owned_by);
 #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	set_to_cap_if_null(ops, xfrm_policy_alloc_security);
diff --git a/security/security.c b/security/security.c
index e81d5bbe7363..1f475aa53288 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1359,11 +1359,6 @@ int security_tun_dev_open(void *security)
 }
 EXPORT_SYMBOL(security_tun_dev_open);
 
-void security_skb_owned_by(struct sk_buff *skb, struct sock *sk)
-{
-	security_ops->skb_owned_by(skb, sk);
-}
-
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 4d1a54190388..edc66de39f2e 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -51,7 +51,6 @@
 #include <linux/tty.h>
 #include <net/icmp.h>
 #include <net/ip.h>		/* for local_port_range[] */
-#include <net/sock.h>
 #include <net/tcp.h>		/* struct or_callable used in sock_rcv_skb */
 #include <net/inet_connection_sock.h>
 #include <net/net_namespace.h>
@@ -4652,11 +4651,6 @@ static void selinux_inet_conn_established(struct sock *sk, struct sk_buff *skb)
 	selinux_skb_peerlbl_sid(skb, family, &sksec->peer_sid);
 }
 
-static void selinux_skb_owned_by(struct sk_buff *skb, struct sock *sk)
-{
-	skb_set_owner_w(skb, sk);
-}
-
 static int selinux_secmark_relabel_packet(u32 sid)
 {
 	const struct task_security_struct *__tsec;
@@ -6041,7 +6035,6 @@ static struct security_operations selinux_ops = {
 	.tun_dev_attach_queue =		selinux_tun_dev_attach_queue,
 	.tun_dev_attach =		selinux_tun_dev_attach,
 	.tun_dev_open =			selinux_tun_dev_open,
-	.skb_owned_by =			selinux_skb_owned_by,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
-- 
2.2.0.rc0.207.ga3a616c
