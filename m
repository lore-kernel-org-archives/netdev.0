From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 2/3] net: dsa: lan9303: Add STP ALR entry on port 0
Date: Tue, 31 Oct 2017 15:48:01 +0100
Message-ID: <20171031144802.12686-3-privat@egil-hjelmeland.no>
References: <20171031144802.12686-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171031144802.12686-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

STP BPDUs arriving on user ports must sent to CPU port only,
for processing by the SW bridge.

Add an ALR entry with STP state override to fix that.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 2 ++
 include/linux/dsa/lan9303.h    | 2 ++
 net/dsa/tag_lan9303.c          | 1 -
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 4c412bd52319..c4afc8f1a66d 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -773,6 +773,7 @@ static int lan9303_separate_ports(struct lan9303 *chip)
 {
 	int ret;
 
+	lan9303_alr_del_port(chip, eth_stp_addr, 0);
 	ret = lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_MIRROR,
 				LAN9303_SWE_PORT_MIRROR_SNIFFER_PORT0 |
 				LAN9303_SWE_PORT_MIRROR_MIRRORED_PORT1 |
@@ -797,6 +798,7 @@ static void lan9303_bridge_ports(struct lan9303 *chip)
 
 	lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_STATE,
 				 chip->swe_port_state);
+	lan9303_alr_add_port(chip, eth_stp_addr, 0, true);
 }
 
 static int lan9303_handle_reset(struct lan9303 *chip)
diff --git a/include/linux/dsa/lan9303.h b/include/linux/dsa/lan9303.h
index 05d8d136baab..b2110e69630f 100644
--- a/include/linux/dsa/lan9303.h
+++ b/include/linux/dsa/lan9303.h
@@ -34,3 +34,5 @@ struct lan9303 {
 	 **/
 	struct lan9303_alr_cache_entry alr_cache[LAN9303_NUM_ALR_RECORDS];
 };
+
+#define eth_stp_addr eth_reserved_addr_base
diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index 537ca991fafe..18f45cd9f625 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -42,7 +42,6 @@
 #define LAN9303_TAG_LEN 4
 # define LAN9303_TAG_TX_USE_ALR BIT(3)
 # define LAN9303_TAG_TX_STP_OVERRIDE BIT(4)
-#define eth_stp_addr eth_reserved_addr_base
 
 /* Decide whether to transmit using ALR lookup, or transmit directly to
  * port using tag. ALR learning is performed only when using ALR lookup.
-- 
2.11.0
