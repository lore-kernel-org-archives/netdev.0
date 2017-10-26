From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v2 net-next 2/2] net: dsa: lan9303: Learn addresses on CPU port when bridged
Date: Thu, 26 Oct 2017 11:00:49 +0200
Message-ID: <20171026090049.1647-3-privat@egil-hjelmeland.no>
References: <20171026090049.1647-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:39278 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752061AbdJZJBT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 05:01:19 -0400
In-Reply-To: <20171026090049.1647-1-privat@egil-hjelmeland.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CPU transmit directly to port using tag, the LAN9303 does not
learn MAC addresses received on the CPU port into the ALR.
ALR learning is performed only when transmitting using ALR lookup.

Solution:
If the two external ports are bridged and the packet is not STP BPDU,
then use ALR lookup to allow ALR learning on CPU port.
Otherwise transmit directly to port with STP state override.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 net/dsa/tag_lan9303.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index 57519597c6fc..64092325aac3 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -11,6 +11,7 @@
  * GNU General Public License for more details.
  *
  */
+#include <linux/dsa/lan9303.h>
 #include <linux/etherdevice.h>
 #include <linux/list.h>
 #include <linux/slab.h>
@@ -39,6 +40,23 @@
  */
 
 #define LAN9303_TAG_LEN 4
+# define LAN9303_TAG_TX_USE_ALR BIT(3)
+# define LAN9303_TAG_TX_STP_OVERRIDE BIT(4)
+#define eth_stp_addr eth_reserved_addr_base
+
+/* Decide whether to transmit using ALR lookup, or transmit directly to
+ * port using tag. ALR learning is performed only when using ALR lookup.
+ * If the two external ports are bridged and the packet is not STP BPDU,
+ * then use ALR lookup to allow ALR learning on CPU port.
+ * Otherwise transmit directly to port with STP state override.
+ * See also: lan9303_separate_ports() and lan9303.pdf 6.4.10.1
+ */
+static int lan9303_xmit_use_arl(struct dsa_port *dp, u8 *dest_addr)
+{
+	struct lan9303 *chip = dp->ds->priv;
+
+	return chip->is_bridged && !ether_addr_equal(dest_addr, eth_stp_addr);
+}
 
 static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -62,7 +80,10 @@ static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	lan9303_tag = (u16 *)(skb->data + 2 * ETH_ALEN);
 	lan9303_tag[0] = htons(ETH_P_8021Q);
-	lan9303_tag[1] = htons(dp->index | BIT(4));
+	lan9303_tag[1] = lan9303_xmit_use_arl(dp, skb->data) ?
+				LAN9303_TAG_TX_USE_ALR :
+				dp->index | LAN9303_TAG_TX_STP_OVERRIDE;
+	lan9303_tag[1] = htons(lan9303_tag[1]);
 
 	return skb;
 }
-- 
2.11.0
