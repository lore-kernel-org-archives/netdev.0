From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH v3] GRE: Disable segmentation offloads w/ CSUM and we
 are encapsulated via FOU
Date: Tue, 05 Apr 2016 09:13:39 -0700
Message-ID: <20160405161249.3861.1683.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: jesse@kernel.org, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33385 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933353AbcDEQNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 12:13:44 -0400
Received: by mail-pa0-f43.google.com with SMTP id zm5so13387673pac.0
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 09:13:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes an issue I found in which we were dropping frames if we
had enabled checksums on GRE headers that were encapsulated by either FOU
or GUE.  Without this patch I was barely able to get 1 Gb/s of throughput.
With this patch applied I am now at least getting around 6 Gb/s.

The issue is due to the fact that with FOU or GUE applied we do not provide
a transport offset pointing to the GRE header, nor do we offload it in
software as the GRE header is completely skipped by GSO and treated like a
VXLAN or GENEVE type header.  As such we need to prevent the stack from
generating it and also prevent GRE from generating it via any interface we
create.

Fixes: c3483384ee511 ("gro: Allow tunnel stacking in the case of FOU/GUE")
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

v3: Basically the same patch as v1 and v2, but I am cutting it loose from
    the IPv4 ID patch as that one will likely need to be resolved in
    net-next.

 include/linux/netdevice.h |    5 ++++-
 net/core/dev.c            |    1 +
 net/ipv4/fou.c            |    6 ++++++
 net/ipv4/gre_offload.c    |    8 ++++++++
 net/ipv4/ip_gre.c         |   13 ++++++++++---
 5 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb0d5d09c2e4..8395308a2445 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2120,7 +2120,10 @@ struct napi_gro_cb {
 	/* Used in foo-over-udp, set in udp[46]_gro_receive */
 	u8	is_ipv6:1;
 
-	/* 7 bit hole */
+	/* Used in GRE, set in fou/gue_gro_receive */
+	u8	is_fou:1;
+
+	/* 6 bit hole */
 
 	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
 	__wsum	csum;
diff --git a/net/core/dev.c b/net/core/dev.c
index b9bcbe77d913..77a71cd68535 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4439,6 +4439,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 		NAPI_GRO_CB(skb)->flush = 0;
 		NAPI_GRO_CB(skb)->free = 0;
 		NAPI_GRO_CB(skb)->encap_mark = 0;
+		NAPI_GRO_CB(skb)->is_fou = 0;
 		NAPI_GRO_CB(skb)->gro_remcsum_start = 0;
 
 		/* Setup for GRO checksum validation */
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 5a94aea280d3..a39068b4a4d9 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -203,6 +203,9 @@ static struct sk_buff **fou_gro_receive(struct sk_buff **head,
 	 */
 	NAPI_GRO_CB(skb)->encap_mark = 0;
 
+	/* Flag this frame as already having an outer encap header */
+	NAPI_GRO_CB(skb)->is_fou = 1;
+
 	rcu_read_lock();
 	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
 	ops = rcu_dereference(offloads[proto]);
@@ -368,6 +371,9 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 	 */
 	NAPI_GRO_CB(skb)->encap_mark = 0;
 
+	/* Flag this frame as already having an outer encap header */
+	NAPI_GRO_CB(skb)->is_fou = 1;
+
 	rcu_read_lock();
 	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
 	ops = rcu_dereference(offloads[guehdr->proto_ctype]);
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index c47539d04b88..6a5bd4317866 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -150,6 +150,14 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 	if ((greh->flags & ~(GRE_KEY|GRE_CSUM)) != 0)
 		goto out;
 
+	/* We can only support GRE_CSUM if we can track the location of
+	 * the GRE header.  In the case of FOU/GUE we cannot because the
+	 * outer UDP header displaces the GRE header leaving us in a state
+	 * of limbo.
+	 */
+	if ((greh->flags & GRE_CSUM) && NAPI_GRO_CB(skb)->is_fou)
+		goto out;
+
 	type = greh->protocol;
 
 	rcu_read_lock();
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 31936d387cfd..af5d1f38217f 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -862,9 +862,16 @@ static void __gre_tunnel_init(struct net_device *dev)
 	dev->hw_features	|= GRE_FEATURES;
 
 	if (!(tunnel->parms.o_flags & TUNNEL_SEQ)) {
-		/* TCP offload with GRE SEQ is not supported. */
-		dev->features    |= NETIF_F_GSO_SOFTWARE;
-		dev->hw_features |= NETIF_F_GSO_SOFTWARE;
+		/* TCP offload with GRE SEQ is not supported, nor
+		 * can we support 2 levels of outer headers requiring
+		 * an update.
+		 */
+		if (!(tunnel->parms.o_flags & TUNNEL_CSUM) ||
+		    (tunnel->encap.type == TUNNEL_ENCAP_NONE)) {
+			dev->features    |= NETIF_F_GSO_SOFTWARE;
+			dev->hw_features |= NETIF_F_GSO_SOFTWARE;
+		}
+
 		/* Can use a lockless transmit, unless we generate
 		 * output sequences
 		 */
