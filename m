From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v5 net-next] MPLS: Use mpls_features to activate
	software MPLS GSO segmentation
Date: Wed,  4 Jun 2014 08:53:17 +0900
Message-ID: <1401839597-8961-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

If an MPLS packet requires segmentation then use mpls_features
to determine if the software implementation should be used.

As no driver advertises MPLS GSO segmentation this will always be
the case.

I had not noticed that this was necessary before as software MPLS GSO
segmentation was already being used in my test environment. I believe that
the reason for that is the skbs in question always had fragments and the
driver I used does not advertise NETIF_F_FRAGLIST (which seems to be the
case for most drivers). Thus software segmentation was activated by
skb_gso_ok().

This introduces the overhead of an extra call to skb_network_protocol()
in the case where where CONFIG_NET_MPLS_GSO is set and
skb->ip_summed == CHECKSUM_NONE.

Thanks to Jesse Gross for prompting me to investigate this.

Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Acked-by: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>

---
v5
* As suggested by Yamamoto-san
  - Remove unused tmp variable
  - Do not use unlikely() for MPLS ethertype check
* Added Ack from Yamamoto-san

v4.2
* As suggested by Eric Dumazet
  - Use htons() instead of cpu_to_be16()
  - Refactor code to pass type to net_mpls_features.

v4.1
* Following fedback from Thomas Graff and Jesse Gross
  - Use ethertype of packet to detect MPLS rather than
    relying on mac_len indicating a gap between the end of L2
    and the beginning of L3. That assumption seems to
    be broken by the GRE GSO code.
  - Move mpls_features handling into harmonize_features()
    This allows an existing call in there to skb_network_protocol()
    to be leveraged.
  - Removed acks as the patch has now changed in a material way

v4
* As suggested by YAMAMOTO Takashi
  - Correct typos in comment
* Added Ack from YAMAMOTO Takashi
v3
* As requested by David Miller
  - Do not mark net_mpls_features as inline
  - Correct alignment of parameters

v2
* Added Ack from Jesse Gross
* Removed duplicate 'Thus' from changelog
---
 net/core/dev.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0355ca5..f726bfb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2498,13 +2498,39 @@ static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
 	return 0;
 }
 
+/* If MPLS offload request, verify we are testing hardware MPLS features
+ * instead of standard features for the netdev.
+ */
+#ifdef CONFIG_NET_MPLS_GSO
+static netdev_features_t net_mpls_features(struct sk_buff *skb,
+					   netdev_features_t features,
+					   __be16 type)
+{
+	if (type == htons(ETH_P_MPLS_UC) || type == htons(ETH_P_MPLS_MC))
+		features &= skb->dev->mpls_features;
+
+	return features;
+}
+#else
+static netdev_features_t net_mpls_features(struct sk_buff *skb,
+					   netdev_features_t features,
+					   __be16 type)
+{
+	return features;
+}
+#endif
+
 static netdev_features_t harmonize_features(struct sk_buff *skb,
 	netdev_features_t features)
 {
 	int tmp;
+	__be16 type;
+
+	type = skb_network_protocol(skb, &tmp);
+	features = net_mpls_features(skb, features, type);
 
 	if (skb->ip_summed != CHECKSUM_NONE &&
-	    !can_checksum_protocol(features, skb_network_protocol(skb, &tmp))) {
+	    !can_checksum_protocol(features, type)) {
 		features &= ~NETIF_F_ALL_CSUM;
 	} else if (illegal_highdma(skb->dev, skb)) {
 		features &= ~NETIF_F_SG;
-- 
2.0.0.rc2
