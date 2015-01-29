From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 1/4] net: Fix vlan_get_protocol for
	stacked vlan
Date: Thu, 29 Jan 2015 20:37:07 +0900
Message-ID: <1422531430-32012-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1422531430-32012-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>, Linux NICS <linux.nics@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1422531430-32012-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

vlan_get_protocol() could not get network protocol if a skb has a 802.1ad
vlan tag or multiple vlans, which caused incorrect checksum calculation
in several drivers.

Fix vlan_get_protocol() to retrieve network protocol instead of incorrect
vlan protocol.

As the logic is the same as skb_network_protocol(), create a common helper
function __vlan_get_protocol() and call it from existing functions.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 include/linux/if_vlan.h | 60 +++++++++++++++++++++++++++++++++++++------------
 net/core/dev.c          | 31 +------------------------
 2 files changed, 47 insertions(+), 44 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 515a35e..960e666 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -472,27 +472,59 @@ static inline int vlan_get_tag(const struct sk_buff *skb, u16 *vlan_tci)
 /**
  * vlan_get_protocol - get protocol EtherType.
  * @skb: skbuff to query
+ * @type: first vlan protocol
+ * @depth: buffer to store length of eth and vlan tags in bytes
  *
  * Returns the EtherType of the packet, regardless of whether it is
  * vlan encapsulated (normal or hardware accelerated) or not.
  */
-static inline __be16 vlan_get_protocol(const struct sk_buff *skb)
+static inline __be16 __vlan_get_protocol(struct sk_buff *skb, __be16 type,
+					 int *depth)
 {
-	__be16 protocol = 0;
-
-	if (vlan_tx_tag_present(skb) ||
-	     skb->protocol != cpu_to_be16(ETH_P_8021Q))
-		protocol = skb->protocol;
-	else {
-		__be16 proto, *protop;
-		protop = skb_header_pointer(skb, offsetof(struct vlan_ethhdr,
-						h_vlan_encapsulated_proto),
-						sizeof(proto), &proto);
-		if (likely(protop))
-			protocol = *protop;
+	unsigned int vlan_depth = skb->mac_len;
+
+	/* if type is 802.1Q/AD then the header should already be
+	 * present at mac_len - VLAN_HLEN (if mac_len > 0), or at
+	 * ETH_HLEN otherwise
+	 */
+	if (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD)) {
+		if (vlan_depth) {
+			if (WARN_ON(vlan_depth < VLAN_HLEN))
+				return 0;
+			vlan_depth -= VLAN_HLEN;
+		} else {
+			vlan_depth = ETH_HLEN;
+		}
+		do {
+			struct vlan_hdr *vh;
+
+			if (unlikely(!pskb_may_pull(skb,
+						    vlan_depth + VLAN_HLEN)))
+				return 0;
+
+			vh = (struct vlan_hdr *)(skb->data + vlan_depth);
+			type = vh->h_vlan_encapsulated_proto;
+			vlan_depth += VLAN_HLEN;
+		} while (type == htons(ETH_P_8021Q) ||
+			 type == htons(ETH_P_8021AD));
 	}
 
-	return protocol;
+	if (depth)
+		*depth = vlan_depth;
+
+	return type;
+}
+
+/**
+ * vlan_get_protocol - get protocol EtherType.
+ * @skb: skbuff to query
+ *
+ * Returns the EtherType of the packet, regardless of whether it is
+ * vlan encapsulated (normal or hardware accelerated) or not.
+ */
+static inline __be16 vlan_get_protocol(struct sk_buff *skb)
+{
+	return __vlan_get_protocol(skb, skb->protocol, NULL);
 }
 
 static inline void vlan_set_encap_proto(struct sk_buff *skb,
diff --git a/net/core/dev.c b/net/core/dev.c
index 171420e..c87a226 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2352,7 +2352,6 @@ EXPORT_SYMBOL(skb_checksum_help);
 
 __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
 {
-	unsigned int vlan_depth = skb->mac_len;
 	__be16 type = skb->protocol;
 
 	/* Tunnel gso handlers can set protocol to ethernet. */
@@ -2366,35 +2365,7 @@ __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
 		type = eth->h_proto;
 	}
 
-	/* if skb->protocol is 802.1Q/AD then the header should already be
-	 * present at mac_len - VLAN_HLEN (if mac_len > 0), or at
-	 * ETH_HLEN otherwise
-	 */
-	if (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD)) {
-		if (vlan_depth) {
-			if (WARN_ON(vlan_depth < VLAN_HLEN))
-				return 0;
-			vlan_depth -= VLAN_HLEN;
-		} else {
-			vlan_depth = ETH_HLEN;
-		}
-		do {
-			struct vlan_hdr *vh;
-
-			if (unlikely(!pskb_may_pull(skb,
-						    vlan_depth + VLAN_HLEN)))
-				return 0;
-
-			vh = (struct vlan_hdr *)(skb->data + vlan_depth);
-			type = vh->h_vlan_encapsulated_proto;
-			vlan_depth += VLAN_HLEN;
-		} while (type == htons(ETH_P_8021Q) ||
-			 type == htons(ETH_P_8021AD));
-	}
-
-	*depth = vlan_depth;
-
-	return type;
+	return __vlan_get_protocol(skb, type, depth);
 }
 
 /**
-- 
1.8.1.2



------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
