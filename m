From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/2] net: Add support for vrf-global TCP servers
Date: Thu, 19 Nov 2015 12:32:01 -0800
Message-ID: <1447965121-2345-2-git-send-email-dsa@cumulusnetworks.com>
References: <1447965121-2345-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36141 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030298AbbKSUcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 15:32:09 -0500
Received: by pacdm15 with SMTP id dm15so91564696pac.3
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 12:32:09 -0800 (PST)
In-Reply-To: <1447965121-2345-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow a process to have a "VRF-global" listen socket. In this case the
listen socket is not bound to a VRF device but child sockets derived
from it are bound to the VRF device the original packet was received
on. This avoids the need to replicate services or create additional
listen sockets as VRF devices are created (and the corresponding tear
down as VRFs are deleted).

Processes can learn the VRF association for the child socket using
getsockopt and the SO_BINDTODEVICE option.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/syncookies.c | 6 ++++--
 net/ipv4/tcp_input.c  | 4 +++-
 net/ipv4/tcp_ipv4.c   | 1 +
 net/ipv6/syncookies.c | 7 +++++--
 4 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 4cbe9f0a4281..85ff306a5930 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -18,6 +18,7 @@
 #include <linux/export.h>
 #include <net/tcp.h>
 #include <net/route.h>
+#include <net/l3mdev.h>
 
 extern int sysctl_tcp_syncookies;
 
@@ -351,7 +352,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	treq->snt_synack.v64	= 0;
 	treq->tfo_listener	= false;
 
-	ireq->ir_iif = sk->sk_bound_dev_if;
+	ireq->ir_iif = sk->sk_bound_dev_if ? :
+			l3mdev_master_ifindex_by_index(sock_net(sk), skb->skb_iif);
 
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
@@ -371,7 +373,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	 * hasn't changed since we received the original syn, but I see
 	 * no easy way to do this.
 	 */
-	flowi4_init_output(&fl4, sk->sk_bound_dev_if, ireq->ir_mark,
+	flowi4_init_output(&fl4, ireq->ir_iif, ireq->ir_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE, IPPROTO_TCP,
 			   inet_sk_flowi_flags(sk),
 			   opt->srr ? opt->faddr : ireq->ir_rmt_addr,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fdd88c3803a6..af884f237332 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -72,6 +72,7 @@
 #include <net/dst.h>
 #include <net/tcp.h>
 #include <net/inet_common.h>
+#include <net/l3mdev.h>
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <linux/errqueue.h>
@@ -6187,7 +6188,8 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
 
 	/* Note: tcp_v6_init_req() might override ir_iif for link locals */
-	inet_rsk(req)->ir_iif = sk->sk_bound_dev_if;
+	inet_rsk(req)->ir_iif = sk->sk_bound_dev_if ? :
+			l3mdev_master_ifindex_by_index(sock_net(sk), skb->skb_iif);
 
 	af_ops->init_req(req, sk, skb);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ba09016d1bfd..d3a10f9f763b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1275,6 +1275,7 @@ struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 	ireq		      = inet_rsk(req);
 	sk_daddr_set(newsk, ireq->ir_rmt_addr);
 	sk_rcv_saddr_set(newsk, ireq->ir_loc_addr);
+	newsk->sk_bound_dev_if = ireq->ir_iif;
 	newinet->inet_saddr	      = ireq->ir_loc_addr;
 	inet_opt	      = ireq->opt;
 	rcu_assign_pointer(newinet->inet_opt, inet_opt);
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index bb8f2fa1c7fb..d33bec50c711 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -20,6 +20,7 @@
 #include <linux/kernel.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
+#include <net/l3mdev.h>
 
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
@@ -193,7 +194,9 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		ireq->pktopts = skb;
 	}
 
-	ireq->ir_iif = sk->sk_bound_dev_if;
+	ireq->ir_iif = sk->sk_bound_dev_if ? :
+		l3mdev_master_ifindex_by_index(sock_net(sk), skb->skb_iif);
+
 	/* So that link locals have meaning */
 	if (!sk->sk_bound_dev_if &&
 	    ipv6_addr_type(&ireq->ir_v6_rmt_addr) & IPV6_ADDR_LINKLOCAL)
@@ -224,7 +227,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		fl6.daddr = ireq->ir_v6_rmt_addr;
 		final_p = fl6_update_dst(&fl6, np->opt, &final);
 		fl6.saddr = ireq->ir_v6_loc_addr;
-		fl6.flowi6_oif = sk->sk_bound_dev_if;
+		fl6.flowi6_oif = ireq->ir_iif;
 		fl6.flowi6_mark = ireq->ir_mark;
 		fl6.fl6_dport = ireq->ir_rmt_port;
 		fl6.fl6_sport = inet_sk(sk)->inet_sport;
-- 
1.9.1
