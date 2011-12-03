From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3 4/6] vlan: Move vlan_set_encap_proto() to vlan
	header file
Date: Sat,  3 Dec 2011 10:38:49 -0800
Message-ID: <1322937531-8071-5-git-send-email-jesse@nicira.com>
References: <1322937531-8071-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322937531-8071-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Open vSwitch needs this function for vlan handling.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
v2/v3: Unchanged.
---
 include/linux/if_vlan.h |   34 ++++++++++++++++++++++++++++++++++
 net/8021q/vlan_core.c   |   33 ---------------------------------
 2 files changed, 34 insertions(+), 33 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 12d5543..070ac50 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -310,6 +310,40 @@ static inline __be16 vlan_get_protocol(const struct sk_buff *skb)
 
 	return protocol;
 }
+
+static inline void vlan_set_encap_proto(struct sk_buff *skb,
+					struct vlan_hdr *vhdr)
+{
+	__be16 proto;
+	unsigned char *rawp;
+
+	/*
+	 * Was a VLAN packet, grab the encapsulated protocol, which the layer
+	 * three protocols care about.
+	 */
+
+	proto = vhdr->h_vlan_encapsulated_proto;
+	if (ntohs(proto) >= 1536) {
+		skb->protocol = proto;
+		return;
+	}
+
+	rawp = skb->data;
+	if (*(unsigned short *) rawp == 0xFFFF)
+		/*
+		 * This is a magic hack to spot IPX packets. Older Novell
+		 * breaks the protocol design and runs IPX over 802.3 without
+		 * an 802.2 LLC layer. We look for FFFF which isn't a used
+		 * 802.2 SSAP/DSAP. This won't work for fault tolerant netware
+		 * but does for the rest.
+		 */
+		skb->protocol = htons(ETH_P_802_3);
+	else
+		/*
+		 * Real 802.2 LLC
+		 */
+		skb->protocol = htons(ETH_P_802_2);
+}
 #endif /* __KERNEL__ */
 
 /* VLAN IOCTLs are found in sockios.h */
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index f5ffc02..9c95e8e 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -110,39 +110,6 @@ static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
 	return skb;
 }
 
-static void vlan_set_encap_proto(struct sk_buff *skb, struct vlan_hdr *vhdr)
-{
-	__be16 proto;
-	unsigned char *rawp;
-
-	/*
-	 * Was a VLAN packet, grab the encapsulated protocol, which the layer
-	 * three protocols care about.
-	 */
-
-	proto = vhdr->h_vlan_encapsulated_proto;
-	if (ntohs(proto) >= 1536) {
-		skb->protocol = proto;
-		return;
-	}
-
-	rawp = skb->data;
-	if (*(unsigned short *) rawp == 0xFFFF)
-		/*
-		 * This is a magic hack to spot IPX packets. Older Novell
-		 * breaks the protocol design and runs IPX over 802.3 without
-		 * an 802.2 LLC layer. We look for FFFF which isn't a used
-		 * 802.2 SSAP/DSAP. This won't work for fault tolerant netware
-		 * but does for the rest.
-		 */
-		skb->protocol = htons(ETH_P_802_3);
-	else
-		/*
-		 * Real 802.2 LLC
-		 */
-		skb->protocol = htons(ETH_P_802_2);
-}
-
 struct sk_buff *vlan_untag(struct sk_buff *skb)
 {
 	struct vlan_hdr *vhdr;
-- 
1.7.5.4
