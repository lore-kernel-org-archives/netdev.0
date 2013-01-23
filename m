From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 1/2] decnet: use correct RCU API to deref sk_dst_cache field
Date: Wed, 23 Jan 2013 15:09:50 +0800
Message-ID: <1358924991-1602-1-git-send-email-amwang@redhat.com>
Cc: linux-decnet-user@lists.sourceforge.net,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753752Ab3AWHKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 02:10:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

sock->sk_dst_cache is protected by RCU, therefore we should
use __sk_dst_get() to deref it once we lock the sock.

This fixes several sparse warnings.

Cc: linux-decnet-user@lists.sourceforge.net
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/include/net/dn_route.h b/include/net/dn_route.h
index 4f7d6a1..2e9d317 100644
--- a/include/net/dn_route.h
+++ b/include/net/dn_route.h
@@ -16,7 +16,7 @@
 *******************************************************************************/
 
 extern struct sk_buff *dn_alloc_skb(struct sock *sk, int size, gfp_t pri);
-extern int dn_route_output_sock(struct dst_entry **pprt, struct flowidn *, struct sock *sk, int flags);
+extern int dn_route_output_sock(struct dst_entry __rcu **pprt, struct flowidn *, struct sock *sk, int flags);
 extern int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb);
 extern void dn_rt_cache_flush(int delay);
 
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 307c322..64d9843 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -909,6 +909,7 @@ static int __dn_connect(struct sock *sk, struct sockaddr_dn *addr, int addrlen,
 	struct dn_scp *scp = DN_SK(sk);
 	int err = -EISCONN;
 	struct flowidn fld;
+	struct dst_entry *dst;
 
 	if (sock->state == SS_CONNECTED)
 		goto out;
@@ -955,10 +956,11 @@ static int __dn_connect(struct sock *sk, struct sockaddr_dn *addr, int addrlen,
 	fld.flowidn_proto = DNPROTO_NSP;
 	if (dn_route_output_sock(&sk->sk_dst_cache, &fld, sk, flags) < 0)
 		goto out;
-	sk->sk_route_caps = sk->sk_dst_cache->dev->features;
+	dst = __sk_dst_get(sk);
+	sk->sk_route_caps = dst->dev->features;
 	sock->state = SS_CONNECTING;
 	scp->state = DN_CI;
-	scp->segsize_loc = dst_metric_advmss(sk->sk_dst_cache);
+	scp->segsize_loc = dst_metric_advmss(dst);
 
 	dn_nsp_send_conninit(sk, NSP_CI);
 	err = -EINPROGRESS;
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 8a96047c..1aaa51e 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -598,7 +598,7 @@ void dn_nsp_send_disc(struct sock *sk, unsigned char msgflg,
 	if (reason == 0)
 		reason = le16_to_cpu(scp->discdata_out.opt_status);
 
-	dn_nsp_do_disc(sk, msgflg, reason, gfp, sk->sk_dst_cache, ddl,
+	dn_nsp_do_disc(sk, msgflg, reason, gfp, __sk_dst_get(sk), ddl,
 		scp->discdata_out.opt_data, scp->addrrem, scp->addrloc);
 }
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index b57419c..1550028 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1282,7 +1282,7 @@ static int dn_route_output_key(struct dst_entry **pprt, struct flowidn *flp, int
 	return err;
 }
 
-int dn_route_output_sock(struct dst_entry **pprt, struct flowidn *fl, struct sock *sk, int flags)
+int dn_route_output_sock(struct dst_entry __rcu **pprt, struct flowidn *fl, struct sock *sk, int flags)
 {
 	int err;
 
