From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH v3] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check
Date: Fri, 10 Jun 2011 18:56:58 +0200
Message-ID: <20110610165656.GA25677@minipsycho.redhat.com>
References: <m11uzcidvq.fsf_-_@fess.ebiederm.org>
 <BANLkTikjdz+LkavRiuqdDNS6+djAer-a0A@mail.gmail.com>
 <BANLkTikM1TuO_S9LuJv30uV9oGgLjE09Xw@mail.gmail.com>
 <20110605.141446.1838641439880246155.davem@davemloft.net>
 <20110610083539.GB17568@minipsycho.redhat.com>
 <BANLkTinqikKoeW6mbjMV9nPii0Nzp4vSdQ@mail.gmail.com>
 <20110610093413.GC17568@minipsycho.redhat.com>
 <BANLkTimHi7V3YwbPepLyW7=pTS7hQVxEBQ@mail.gmail.com>
 <20110610103503.GD17568@minipsycho.redhat.com>
 <BANLkTinctdoyYJo+sU9qUWV8uZV8yGNdnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pratnakarlx@gmail.com,
	ebiederm@xmission.com, shemminger@linux-foundation.org,
	greearb@candelatech.com, nicolas.2p.debian@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52897 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324Ab1FJQ5N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 12:57:13 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTinctdoyYJo+sU9qUWV8uZV8yGNdnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This time heavily based on Eric's V2. mac_len is reset at appropriate
places. Also skb->data is adjusted to point to beginning of mac header
before calling vlan_insert_tag.

Please review (fingers crossed).

Subject: [patch net-2.6 v2.1] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check

Testing of VLAN_FLAG_REORDER_HDR does not belong in vlan_untag
but rather in vlan_do_receive.  Otherwise the vlan header
will not be properly put on the packet in the case of
vlan header accelleration.

As we remove the check from vlan_check_reorder_header
rename it vlan_reorder_header to keep the naming clean.

Fix up the skb->pkt_type early so we don't look at the packet
after adding the vlan tag, which guarantees we don't goof
and look at the wrong field.

Use a simple if statement instead of a complicated switch
statement to decided that we need to increment rx_stats
for a multicast packet.

Hopefully at somepoint we will just declare the case where
VLAN_FLAG_REORDER_HDR is cleared as unsupported and remove
the code.  Until then this keeps it working correctly.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if_vlan.h |   25 +++++++++++++++++--
 include/linux/skbuff.h  |    5 ++++
 net/8021q/vlan_core.c   |   60 +++++++++++++++++++++++++---------------------
 net/core/dev.c          |    2 +-
 4 files changed, 61 insertions(+), 31 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index dc01681..affa273 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -225,7 +225,7 @@ static inline int vlan_hwaccel_receive_skb(struct sk_buff *skb,
 }
 
 /**
- * __vlan_put_tag - regular VLAN tag inserting
+ * vlan_insert_tag - regular VLAN tag inserting
  * @skb: skbuff to tag
  * @vlan_tci: VLAN TCI to insert
  *
@@ -234,8 +234,10 @@ static inline int vlan_hwaccel_receive_skb(struct sk_buff *skb,
  *
  * Following the skb_unshare() example, in case of error, the calling function
  * doesn't have to worry about freeing the original skb.
+ *
+ * Does not change skb->protocol so this function can be used during receive.
  */
-static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
+static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb, u16 vlan_tci)
 {
 	struct vlan_ethhdr *veth;
 
@@ -255,8 +257,25 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
 	/* now, the TCI */
 	veth->h_vlan_TCI = htons(vlan_tci);
 
-	skb->protocol = htons(ETH_P_8021Q);
+	return skb;
+}
 
+/**
+ * __vlan_put_tag - regular VLAN tag inserting
+ * @skb: skbuff to tag
+ * @vlan_tci: VLAN TCI to insert
+ *
+ * Inserts the VLAN tag into @skb as part of the payload
+ * Returns a VLAN tagged skb. If a new skb is created, @skb is freed.
+ *
+ * Following the skb_unshare() example, in case of error, the calling function
+ * doesn't have to worry about freeing the original skb.
+ */
+static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
+{
+	skb = vlan_insert_tag(skb, vlan_tci);
+	if (skb)
+		skb->protocol = htons(ETH_P_8021Q);
 	return skb;
 }
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e8b78ce..c0a4f3a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1256,6 +1256,11 @@ static inline void skb_reserve(struct sk_buff *skb, int len)
 	skb->tail += len;
 }
 
+static inline void skb_reset_mac_len(struct sk_buff *skb)
+{
+	skb->mac_len = skb->network_header - skb->mac_header;
+}
+
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
 {
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 41495dc..fcc6846 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -23,6 +23,31 @@ bool vlan_do_receive(struct sk_buff **skbp)
 		return false;
 
 	skb->dev = vlan_dev;
+	if (skb->pkt_type == PACKET_OTHERHOST) {
+		/* Our lower layer thinks this is not local, let's make sure.
+		 * This allows the VLAN to have a different MAC than the
+		 * underlying device, and still route correctly. */
+		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
+					vlan_dev->dev_addr))
+			skb->pkt_type = PACKET_HOST;
+	}
+
+	if (!(vlan_dev_info(vlan_dev)->flags & VLAN_FLAG_REORDER_HDR)) {
+		unsigned int offset = skb->data - skb_mac_header(skb);
+
+		/*
+		 * vlan_insert_tag expect skb->data pointing to mac header.
+		 * So change skb->data before calling it and change back to
+		 * original position later
+		 */
+		skb_push(skb, offset);
+		skb = *skbp = vlan_insert_tag(skb, skb->vlan_tci);
+		if (!skb)
+			return false;
+		skb_pull(skb, offset + VLAN_HLEN);
+		skb_reset_mac_len(skb);
+	}
+
 	skb->priority = vlan_get_ingress_priority(vlan_dev, skb->vlan_tci);
 	skb->vlan_tci = 0;
 
@@ -31,22 +56,8 @@ bool vlan_do_receive(struct sk_buff **skbp)
 	u64_stats_update_begin(&rx_stats->syncp);
 	rx_stats->rx_packets++;
 	rx_stats->rx_bytes += skb->len;
-
-	switch (skb->pkt_type) {
-	case PACKET_BROADCAST:
-		break;
-	case PACKET_MULTICAST:
+	if (skb->pkt_type == PACKET_MULTICAST)
 		rx_stats->rx_multicast++;
-		break;
-	case PACKET_OTHERHOST:
-		/* Our lower layer thinks this is not local, let's make sure.
-		 * This allows the VLAN to have a different MAC than the
-		 * underlying device, and still route correctly. */
-		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
-					vlan_dev->dev_addr))
-			skb->pkt_type = PACKET_HOST;
-		break;
-	}
 	u64_stats_update_end(&rx_stats->syncp);
 
 	return true;
@@ -89,18 +100,13 @@ gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 }
 EXPORT_SYMBOL(vlan_gro_frags);
 
-static struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
+static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
 {
-	if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
-		if (skb_cow(skb, skb_headroom(skb)) < 0)
-			skb = NULL;
-		if (skb) {
-			/* Lifted from Gleb's VLAN code... */
-			memmove(skb->data - ETH_HLEN,
-				skb->data - VLAN_ETH_HLEN, 12);
-			skb->mac_header += VLAN_HLEN;
-		}
-	}
+	if (skb_cow(skb, skb_headroom(skb)) < 0)
+		return NULL;
+	memmove(skb->data - ETH_HLEN, skb->data - VLAN_ETH_HLEN, 2 * ETH_ALEN);
+	skb->mac_header += VLAN_HLEN;
+	skb_reset_mac_len(skb);
 	return skb;
 }
 
@@ -161,7 +167,7 @@ struct sk_buff *vlan_untag(struct sk_buff *skb)
 	skb_pull_rcsum(skb, VLAN_HLEN);
 	vlan_set_encap_proto(skb, vhdr);
 
-	skb = vlan_check_reorder_header(skb);
+	skb = vlan_reorder_header(skb);
 	if (unlikely(!skb))
 		goto err_free;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index a54c9f8..9c58c1e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3114,7 +3114,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
-	skb->mac_len = skb->network_header - skb->mac_header;
+	skb_reset_mac_len(skb);
 
 	pt_prev = NULL;
 
-- 
1.7.5.2

