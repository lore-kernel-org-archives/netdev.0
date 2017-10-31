From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 1/3] net: dsa: lan9303: Transmit using ALR when unicast
Date: Tue, 31 Oct 2017 15:48:00 +0100
Message-ID: <20171031144802.12686-2-privat@egil-hjelmeland.no>
References: <20171031144802.12686-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171031144802.12686-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

lan9303_xmit_use_arl() introduced in previous patch set is wrong.
The chip flood broadcast and unknown multicast frames. The effect is that
broadcasts and multicasts are duplicated on egress. It is not possible to
configure the chip to direct unknown multicasts to CPU port only.

This means that only unicast frames can be transmitted using ALR lookup.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 net/dsa/tag_lan9303.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index 64092325aac3..537ca991fafe 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -46,7 +46,7 @@
 
 /* Decide whether to transmit using ALR lookup, or transmit directly to
  * port using tag. ALR learning is performed only when using ALR lookup.
- * If the two external ports are bridged and the packet is not STP BPDU,
+ * If the two external ports are bridged and the frame is unicast,
  * then use ALR lookup to allow ALR learning on CPU port.
  * Otherwise transmit directly to port with STP state override.
  * See also: lan9303_separate_ports() and lan9303.pdf 6.4.10.1
@@ -55,7 +55,7 @@ static int lan9303_xmit_use_arl(struct dsa_port *dp, u8 *dest_addr)
 {
 	struct lan9303 *chip = dp->ds->priv;
 
-	return chip->is_bridged && !ether_addr_equal(dest_addr, eth_stp_addr);
+	return chip->is_bridged && !is_multicast_ether_addr(dest_addr);
 }
 
 static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device *dev)
-- 
2.11.0
