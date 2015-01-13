From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next v2 1/2] udp: pass udp_offload struct to UDP gro callbacks
Date: Mon, 12 Jan 2015 17:00:37 -0800
Message-ID: <1421110838-5146-2-git-send-email-therbert@google.com>
References: <1421110838-5146-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:65486 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbbAMBBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 20:01:06 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so14531765igd.2
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 17:01:05 -0800 (PST)
In-Reply-To: <1421110838-5146-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces udp_offload_callbacks which has the same
GRO functions (but not a GSO function) as offload_callbacks,
except there is an argument to a udp_offload struct passed to
gro_receive and gro_complete functions. This additional argument
can be used to retrieve the per port structure of the encapsulation
for use in gro processing (mostly by doing container_of on the
structure).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c       |  7 +++++--
 include/linux/netdevice.h | 15 +++++++++++++--
 net/ipv4/fou.c            | 12 ++++++++----
 net/ipv4/geneve.c         |  6 ++++--
 net/ipv4/udp_offload.c    |  7 +++++--
 5 files changed, 35 insertions(+), 12 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3a18d8e..90e2f49 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -539,7 +539,9 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 	return 1;
 }
 
-static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff *skb)
+static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
+					  struct sk_buff *skb,
+					  struct udp_offload *uoff)
 {
 	struct sk_buff *p, **pp = NULL;
 	struct vxlanhdr *vh, *vh2;
@@ -578,7 +580,8 @@ out:
 	return pp;
 }
 
-static int vxlan_gro_complete(struct sk_buff *skb, int nhoff)
+static int vxlan_gro_complete(struct sk_buff *skb, int nhoff,
+			      struct udp_offload *uoff)
 {
 	udp_tunnel_gro_complete(skb, nhoff);
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 679e6e9..47921c2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1969,7 +1969,7 @@ struct offload_callbacks {
 	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
 						netdev_features_t features);
 	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
-					       struct sk_buff *skb);
+						 struct sk_buff *skb);
 	int			(*gro_complete)(struct sk_buff *skb, int nhoff);
 };
 
@@ -1979,10 +1979,21 @@ struct packet_offload {
 	struct list_head	 list;
 };
 
+struct udp_offload;
+
+struct udp_offload_callbacks {
+	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
+						 struct sk_buff *skb,
+						 struct udp_offload *uoff);
+	int			(*gro_complete)(struct sk_buff *skb,
+						int nhoff,
+						struct udp_offload *uoff);
+};
+
 struct udp_offload {
 	__be16			 port;
 	u8			 ipproto;
-	struct offload_callbacks callbacks;
+	struct udp_offload_callbacks callbacks;
 };
 
 /* often modified stats are per cpu, other are shared (netdev->stats) */
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 2197c36..3bc0cf0 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -174,7 +174,8 @@ drop:
 }
 
 static struct sk_buff **fou_gro_receive(struct sk_buff **head,
-					struct sk_buff *skb)
+					struct sk_buff *skb,
+					struct udp_offload *uoff)
 {
 	const struct net_offload *ops;
 	struct sk_buff **pp = NULL;
@@ -195,7 +196,8 @@ out_unlock:
 	return pp;
 }
 
-static int fou_gro_complete(struct sk_buff *skb, int nhoff)
+static int fou_gro_complete(struct sk_buff *skb, int nhoff,
+			    struct udp_offload *uoff)
 {
 	const struct net_offload *ops;
 	u8 proto = NAPI_GRO_CB(skb)->proto;
@@ -254,7 +256,8 @@ static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 }
 
 static struct sk_buff **gue_gro_receive(struct sk_buff **head,
-					struct sk_buff *skb)
+					struct sk_buff *skb,
+					struct udp_offload *uoff)
 {
 	const struct net_offload **offloads;
 	const struct net_offload *ops;
@@ -360,7 +363,8 @@ out:
 	return pp;
 }
 
-static int gue_gro_complete(struct sk_buff *skb, int nhoff)
+static int gue_gro_complete(struct sk_buff *skb, int nhoff,
+			    struct udp_offload *uoff)
 {
 	const struct net_offload **offloads;
 	struct guehdr *guehdr = (struct guehdr *)(skb->data + nhoff);
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 5b52046..31244bc 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -147,7 +147,8 @@ static int geneve_hlen(struct genevehdr *gh)
 }
 
 static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
-					   struct sk_buff *skb)
+					   struct sk_buff *skb,
+					   struct udp_offload *uoff)
 {
 	struct sk_buff *p, **pp = NULL;
 	struct genevehdr *gh, *gh2;
@@ -211,7 +212,8 @@ out:
 	return pp;
 }
 
-static int geneve_gro_complete(struct sk_buff *skb, int nhoff)
+static int geneve_gro_complete(struct sk_buff *skb, int nhoff,
+			       struct udp_offload *uoff)
 {
 	struct genevehdr *gh;
 	struct packet_offload *ptype;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index d3e537e..d10f6f4 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -339,7 +339,8 @@ unflush:
 	skb_gro_pull(skb, sizeof(struct udphdr)); /* pull encapsulating udp header */
 	skb_gro_postpull_rcsum(skb, uh, sizeof(struct udphdr));
 	NAPI_GRO_CB(skb)->proto = uo_priv->offload->ipproto;
-	pp = uo_priv->offload->callbacks.gro_receive(head, skb);
+	pp = uo_priv->offload->callbacks.gro_receive(head, skb,
+						     uo_priv->offload);
 
 out_unlock:
 	rcu_read_unlock();
@@ -395,7 +396,9 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
 
 	if (uo_priv != NULL) {
 		NAPI_GRO_CB(skb)->proto = uo_priv->offload->ipproto;
-		err = uo_priv->offload->callbacks.gro_complete(skb, nhoff + sizeof(struct udphdr));
+		err = uo_priv->offload->callbacks.gro_complete(skb,
+				nhoff + sizeof(struct udphdr),
+				uo_priv->offload);
 	}
 
 	rcu_read_unlock();
-- 
2.2.0.rc0.207.ga3a616c
