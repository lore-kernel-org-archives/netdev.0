From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 2/4] fou: eliminate IPv4,v6 specific GRO functions
Date: Fri,  3 Oct 2014 15:48:08 -0700
Message-ID: <1412376490-8774-3-git-send-email-therbert@google.com>
References: <1412376490-8774-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:37535 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758075AbaJCWsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:48:47 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so2180752pad.5
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:48:46 -0700 (PDT)
In-Reply-To: <1412376490-8774-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes fou[46]_gro_receive and fou[46]_gro_complete
functions. The v4 or v6 variants were chosen for the UDP offloads
based on the address family of the socket this is not necessary
or correct. Alternatively, this patch adds is_ipv6 to napi_gro_skb.
This is set in udp6_gro_receive and unset in udp4_gro_receive. In
fou_gro_receive the value is used to select the correct inet_offloads
for the protocol of the outer IP header.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |  3 +++
 net/ipv4/fou.c            | 48 ++++++++---------------------------------------
 net/ipv4/udp_offload.c    |  1 +
 net/ipv6/udp_offload.c    |  1 +
 4 files changed, 13 insertions(+), 40 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9b7fbac..640f8d8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1886,6 +1886,9 @@ struct napi_gro_cb {
 	/* Number of checksums via CHECKSUM_UNNECESSARY */
 	u8	csum_cnt:3;
 
+	/* Used in foo-over-udp, set in udp[46]_gro_receive */
+	u8	is_ipv6:1;
+
 	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
 	__wsum	csum;
 
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index dced89f..7e2126a 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -65,14 +65,15 @@ static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
 }
 
 static struct sk_buff **fou_gro_receive(struct sk_buff **head,
-					struct sk_buff *skb,
-					const struct net_offload **offloads)
+					struct sk_buff *skb)
 {
 	const struct net_offload *ops;
 	struct sk_buff **pp = NULL;
 	u8 proto = NAPI_GRO_CB(skb)->proto;
+	const struct net_offload **offloads;
 
 	rcu_read_lock();
+	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
 	ops = rcu_dereference(offloads[proto]);
 	if (!ops || !ops->callbacks.gro_receive)
 		goto out_unlock;
@@ -85,14 +86,15 @@ out_unlock:
 	return pp;
 }
 
-static int fou_gro_complete(struct sk_buff *skb, int nhoff,
-			    const struct net_offload **offloads)
+static int fou_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	const struct net_offload *ops;
 	u8 proto = NAPI_GRO_CB(skb)->proto;
 	int err = -ENOSYS;
+	const struct net_offload **offloads;
 
 	rcu_read_lock();
+	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
 	ops = rcu_dereference(offloads[proto]);
 	if (WARN_ON(!ops || !ops->callbacks.gro_complete))
 		goto out_unlock;
@@ -105,28 +107,6 @@ out_unlock:
 	return err;
 }
 
-static struct sk_buff **fou4_gro_receive(struct sk_buff **head,
-					 struct sk_buff *skb)
-{
-	return fou_gro_receive(head, skb, inet_offloads);
-}
-
-static int fou4_gro_complete(struct sk_buff *skb, int nhoff)
-{
-	return fou_gro_complete(skb, nhoff, inet_offloads);
-}
-
-static struct sk_buff **fou6_gro_receive(struct sk_buff **head,
-					 struct sk_buff *skb)
-{
-	return fou_gro_receive(head, skb, inet6_offloads);
-}
-
-static int fou6_gro_complete(struct sk_buff *skb, int nhoff)
-{
-	return fou_gro_complete(skb, nhoff, inet6_offloads);
-}
-
 static int fou_add_to_port_list(struct fou *fou)
 {
 	struct fou *fout;
@@ -199,20 +179,8 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 
 	sk->sk_allocation = GFP_ATOMIC;
 
-	switch (cfg->udp_config.family) {
-	case AF_INET:
-		fou->udp_offloads.callbacks.gro_receive = fou4_gro_receive;
-		fou->udp_offloads.callbacks.gro_complete = fou4_gro_complete;
-		break;
-	case AF_INET6:
-		fou->udp_offloads.callbacks.gro_receive = fou6_gro_receive;
-		fou->udp_offloads.callbacks.gro_complete = fou6_gro_complete;
-		break;
-	default:
-		err = -EPFNOSUPPORT;
-		goto error;
-	}
-
+	fou->udp_offloads.callbacks.gro_receive = fou_gro_receive;
+	fou->udp_offloads.callbacks.gro_complete = fou_gro_complete;
 	fou->udp_offloads.port = cfg->udp_config.local_udp_port;
 	fou->udp_offloads.ipproto = cfg->protocol;
 
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 8c35f2c..507310e 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -334,6 +334,7 @@ static struct sk_buff **udp4_gro_receive(struct sk_buff **head,
 		skb_gro_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
 					     inet_gro_compute_pseudo);
 skip:
+	NAPI_GRO_CB(skb)->is_ipv6 = 0;
 	return udp_gro_receive(head, skb, uh);
 
 flush:
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 8f96988..6b8f543 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -140,6 +140,7 @@ static struct sk_buff **udp6_gro_receive(struct sk_buff **head,
 					     ip6_gro_compute_pseudo);
 
 skip:
+	NAPI_GRO_CB(skb)->is_ipv6 = 1;
 	return udp_gro_receive(head, skb, uh);
 
 flush:
-- 
2.1.0.rc2.206.gedb03e5
