From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [RFC net-next] net: dsa: lan9303 Cpu port and ARL
Date: Mon, 23 Oct 2017 13:35:06 +0200
Message-ID: <20171023113506.13600-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:47580 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751316AbdJWLf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Oct 2017 07:35:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our proprietary lan9303 driver used .set_addr to add the master interface
MAC to the lan9303 ALR (Address Logic Resolution) table. Now that .set_addr
is gone, I found out that the lan9303 does not learn the master MAC address.
Which means that traffic to the local CPU is flooded to the other external
port as well. The problem is that when net/dsa/tag_lan9303.c use the
tagging mechanism to bypass ALR lookup, then the ALR does not learn addresses. 

We could add the static ALR entry like this:

---
diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 87f919f0e641..507586c13a60 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -791,12 +791,17 @@ static int lan9303_separate_ports(struct lan9303 *chip)
 
 static void lan9303_bridge_ports(struct lan9303 *chip)
 {
+       u8 *br_mac = dsa_to_port(chip->ds, 1)->bridge_dev->dev_addr;
+
        /* ports bridged: remove mirroring */
        lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_MIRROR,
                                 LAN9303_SWE_PORT_MIRROR_DISABLED);
 
        lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_STATE,
                                 chip->swe_port_state);
+
+       dev_info(chip->dev, "lan9303_bridge_ports: %pM\n", br_mac);
+       lan9303_alr_set_entry(chip, br_mac, BIT(0), false);
 }
 
 static int lan9303_handle_reset(struct lan9303 *chip)
--

That would cover our use case, and has the benefit of no added overhead in the
data path. 

However, if some other (virtual) interface is added to the SW bridge, we still
have the same problem. So I suspect that you want to see something like the 
following: 


---
 net/dsa/tag_lan9303.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index 57519597c6fc..1003fd91755c 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -16,6 +16,7 @@
 #include <linux/slab.h>
 
 #include "dsa_priv.h"
+#include "../../drivers/net/dsa/lan9303.h"
 
 /* To define the outgoing port and to discover the incoming port a regular
  * VLAN tag is used by the LAN9303. But its VID meaning is 'special':
@@ -39,6 +40,23 @@
  */
 
 #define LAN9303_TAG_LEN 4
+# define LAN9303_TAG_TX_USE_ALR BIT(3)
+# define LAN9303_TAG_TX_STP_OVRD BIT(4)
+#define eth_stp_addr eth_reserved_addr_base
+
+/* Decide whether to transmit using ALR lookup, or transmit directly to
+ * port using tag. ALR learning is performed only when using ALR lookup.
+ * If the two external ports are bridged and the packet is not STP BPDU,
+ * then use ALR lookup to allow ALR learning on CPU port.
+ * Otherwise transmit directly to port with STP state override.
+ * See also: lan9303_separate_ports() and lan9303.pdf 6.4.10.1
+ */
+static inline int lan9303_tx_use_arl(struct dsa_port *dp, u8 *dest_addr)
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
+	lan9303_tag[1] = lan9303_tx_use_arl(dp, skb->data) ?
+				LAN9303_TAG_TX_USE_ALR :
+				dp->index | LAN9303_TAG_TX_STP_OVRD;
+	lan9303_tag[1] = htons(lan9303_tag[1]);
 
 	return skb;
 }
-- 

Comments?

Egil Hjelmeland
