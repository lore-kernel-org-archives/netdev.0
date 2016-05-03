From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net v3 2/2] udp_offload: Set encapsulation before inner completes.
Date: Tue,  3 May 2016 16:10:21 -0700
Message-ID: <1462317021-7236-2-git-send-email-jarno@ovn.org>
References: <1462317021-7236-1-git-send-email-jarno@ovn.org>
Cc: jesse@kernel.org, jarno@ovn.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462317021-7236-1-git-send-email-jarno@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

UDP tunnel segmentation code relies on the inner offsets being set for
an UDP tunnel GSO packet, but the inner *_complete() functions will
set the inner offsets only if 'encapsulation' is set before calling
them.  Currently, udp_gro_complete() sets 'encapsulation' only after
the inner *_complete() functions are done.  This causes the inner
offsets having invalid values after udp_gro_complete() returns, which
in turn will make it impossible to properly segment the packet in case
it needs to be forwarded, which would be visible to the user either as
invalid packets being sent or as packet loss.

This patch fixes this by setting skb's 'encapsulation' in
udp_gro_complete() before calling into the inner complete functions,
and by making each possible UDP tunnel gro_complete() callback set the
inner_mac_header to the beginning of the tunnel payload.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
v3: Added setting inner_mac_header from all possible callbacks to cover
    cases where there is no inner mac header.

 drivers/net/geneve.c      | 3 +++
 drivers/net/vxlan.c       | 3 +++
 include/linux/netdevice.h | 3 +++
 net/ipv4/fou.c            | 4 ++++
 net/ipv4/udp_offload.c    | 8 +++++---
 5 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 98f1224..7b0a644 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -514,6 +514,9 @@ static int geneve_gro_complete(struct sk_buff *skb, int nhoff,
 		err = ptype->callbacks.gro_complete(skb, nhoff + gh_len);
 
 	rcu_read_unlock();
+
+	skb_set_inner_mac_header(skb, nhoff + gh_len);
+
 	return err;
 }
 
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index dd2d032..8ac261a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -616,6 +616,9 @@ out:
 static int vxlan_gro_complete(struct sk_buff *skb, int nhoff,
 			      struct udp_offload *uoff)
 {
+	/* Sets 'skb->inner_mac_header' since we are always called with
+	 * 'skb->encapsulation' set.
+	 */
 	return eth_gro_complete(skb, nhoff + sizeof(struct vxlanhdr));
 }
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b3c46b0..78181a8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2164,6 +2164,9 @@ struct packet_offload {
 
 struct udp_offload;
 
+/* 'skb->encapsulation' is set before gro_complete() is called.  gro_complete()
+ * must set 'skb->inner_mac_header' to the beginning of tunnel payload.
+ */
 struct udp_offload_callbacks {
 	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
 						 struct sk_buff *skb,
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 305d9ac..a6962cc 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -236,6 +236,8 @@ static int fou_gro_complete(struct sk_buff *skb, int nhoff,
 
 	err = ops->callbacks.gro_complete(skb, nhoff);
 
+	skb_set_inner_mac_header(skb, nhoff);
+
 out_unlock:
 	rcu_read_unlock();
 
@@ -412,6 +414,8 @@ static int gue_gro_complete(struct sk_buff *skb, int nhoff,
 
 	err = ops->callbacks.gro_complete(skb, nhoff + guehlen);
 
+	skb_set_inner_mac_header(skb, nhoff + guehlen);
+
 out_unlock:
 	rcu_read_unlock();
 	return err;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 0ed2daf..e330c0e 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -399,6 +399,11 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
 
 	uh->len = newlen;
 
+	/* Set encapsulation before calling into inner gro_complete() functions
+	 * to make them set up the inner offsets.
+	 */
+	skb->encapsulation = 1;
+
 	rcu_read_lock();
 
 	uo_priv = rcu_dereference(udp_offload_base);
@@ -421,9 +426,6 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
 	if (skb->remcsum_offload)
 		skb_shinfo(skb)->gso_type |= SKB_GSO_TUNNEL_REMCSUM;
 
-	skb->encapsulation = 1;
-	skb_set_inner_mac_header(skb, nhoff + sizeof(struct udphdr));
-
 	return err;
 }
 
-- 
2.7.4
