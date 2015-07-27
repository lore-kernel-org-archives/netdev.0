From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 11/16] net: Use VRF device index for socket lookups
Date: Mon, 27 Jul 2015 12:31:04 -0600
Message-ID: <1438021869-49186-12-git-send-email-dsa@cumulusnetworks.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37249 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628AbbG0SdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:33:10 -0400
Received: by igbpg9 with SMTP id pg9so89331604igb.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 11:33:09 -0700 (PDT)
In-Reply-To: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The intent of the VRF device is to leverage the existing SO_BINDTODEVICE
as a means of creating L3 domains. Since sockets are expected to be bound
to the VRF device the index of the master device needs to be used for
socket lookups.

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/syncookies.c |  5 ++++-
 net/ipv4/tcp_input.c  |  6 +++++-
 net/ipv4/tcp_ipv4.c   | 11 +++++++++--
 3 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index d70b1f603692..dab52fba5872 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -18,6 +18,7 @@
 #include <linux/export.h>
 #include <net/tcp.h>
 #include <net/route.h>
+#include <net/vrf.h>
 
 extern int sysctl_tcp_syncookies;
 
@@ -348,7 +349,9 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	treq->snt_synack	= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsecr : 0;
 	treq->tfo_listener	= false;
 
-	ireq->ir_iif = sk->sk_bound_dev_if;
+	ireq->ir_iif = vrf_get_master_dev_ifindex(sock_net(sk), skb->skb_iif);
+	if (!ireq->ir_iif)
+		ireq->ir_iif = sk->sk_bound_dev_if;
 
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4e4d6bcd0ca9..df82fb05c459 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -72,6 +72,7 @@
 #include <net/dst.h>
 #include <net/tcp.h>
 #include <net/inet_common.h>
+#include <net/vrf.h>
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <linux/errqueue.h>
@@ -6141,7 +6142,10 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
 
 	/* Note: tcp_v6_init_req() might override ir_iif for link locals */
-	inet_rsk(req)->ir_iif = sk->sk_bound_dev_if;
+	inet_rsk(req)->ir_iif = vrf_get_master_dev_ifindex(sock_net(sk),
+							   skb->skb_iif);
+	if (!inet_rsk(req)->ir_iif)
+		inet_rsk(req)->ir_iif = sk->sk_bound_dev_if;
 
 	af_ops->init_req(req, sk, skb);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 486ba96ae91a..d0c40f4d9058 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -75,6 +75,7 @@
 #include <net/secure_seq.h>
 #include <net/tcp_memcontrol.h>
 #include <net/busy_poll.h>
+#include <net/vrf.h>
 
 #include <linux/inet.h>
 #include <linux/ipv6.h>
@@ -682,6 +683,8 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	 */
 	if (sk)
 		arg.bound_dev_if = sk->sk_bound_dev_if;
+	if (!arg.bound_dev_if && skb->dev)
+		arg.bound_dev_if = vrf_master_dev_ifindex(skb->dev);
 
 	arg.tos = ip_hdr(skb)->tos;
 	ip_send_unicast_reply(*this_cpu_ptr(net->ipv4.tcp_sk),
@@ -766,8 +769,10 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 				      ip_hdr(skb)->saddr, /* XXX */
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
-	if (oif)
-		arg.bound_dev_if = oif;
+	arg.bound_dev_if = oif ? : vrf_master_dev_ifindex(skb_dst(skb)->dev);
+	if (!arg.bound_dev_if)
+		arg.bound_dev_if = vrf_master_dev_ifindex(skb->dev);
+
 	arg.tos = tos;
 	ip_send_unicast_reply(*this_cpu_ptr(net->ipv4.tcp_sk),
 			      skb, &TCP_SKB_CB(skb)->header.h4.opt,
@@ -1269,6 +1274,8 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	ireq		      = inet_rsk(req);
 	sk_daddr_set(newsk, ireq->ir_rmt_addr);
 	sk_rcv_saddr_set(newsk, ireq->ir_loc_addr);
+	if (netif_index_is_vrf(sock_net(newsk), ireq->ir_iif))
+		newsk->sk_bound_dev_if = ireq->ir_iif;
 	newinet->inet_saddr	      = ireq->ir_loc_addr;
 	inet_opt	      = ireq->opt;
 	rcu_assign_pointer(newinet->inet_opt, inet_opt);
-- 
2.3.2 (Apple Git-55)
