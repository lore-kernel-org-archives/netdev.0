From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 11/14] nfp: turn NSP port entry into a union
Date: Tue,  4 Apr 2017 16:12:32 -0700
Message-ID: <20170404231235.32027-12-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:32943 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755308AbdDDXNC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:13:02 -0400
Received: by mail-pf0-f174.google.com with SMTP id s16so25016675pfs.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:13:02 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make NSP port structure a union to simplify accessing the fields
from generic macros.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   | 38 ++++++++++++++--------
 1 file changed, 25 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
index 55d8e073ccbd..ca5c041e64a4 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -49,7 +49,7 @@
 #define NSP_ETH_NBI_PORT_COUNT		24
 #define NSP_ETH_MAX_COUNT		(2 * NSP_ETH_NBI_PORT_COUNT)
 #define NSP_ETH_TABLE_SIZE		(NSP_ETH_MAX_COUNT *		\
-					 sizeof(struct eth_table_entry))
+					 sizeof(union eth_table_entry))
 
 #define NSP_ETH_PORT_LANES		GENMASK_ULL(3, 0)
 #define NSP_ETH_PORT_INDEX		GENMASK_ULL(15, 8)
@@ -71,6 +71,15 @@
 #define NSP_ETH_CTRL_TX_ENABLED		BIT_ULL(2)
 #define NSP_ETH_CTRL_RX_ENABLED		BIT_ULL(3)
 
+enum nfp_eth_raw {
+	NSP_ETH_RAW_PORT = 0,
+	NSP_ETH_RAW_STATE,
+	NSP_ETH_RAW_MAC,
+	NSP_ETH_RAW_CONTROL,
+
+	NSP_ETH_NUM_RAW
+};
+
 enum nfp_eth_rate {
 	RATE_INVALID = 0,
 	RATE_10M,
@@ -80,12 +89,15 @@ enum nfp_eth_rate {
 	RATE_25G,
 };
 
-struct eth_table_entry {
-	__le64 port;
-	__le64 state;
-	u8 mac_addr[6];
-	u8 resv[2];
-	__le64 control;
+union eth_table_entry {
+	struct {
+		__le64 port;
+		__le64 state;
+		u8 mac_addr[6];
+		u8 resv[2];
+		__le64 control;
+	};
+	__le64 raw[NSP_ETH_NUM_RAW];
 };
 
 static unsigned int nfp_eth_rate(enum nfp_eth_rate rate)
@@ -114,7 +126,7 @@ static void nfp_eth_copy_mac_reverse(u8 *dst, const u8 *src)
 }
 
 static void
-nfp_eth_port_translate(struct nfp_nsp *nsp, const struct eth_table_entry *src,
+nfp_eth_port_translate(struct nfp_nsp *nsp, const union eth_table_entry *src,
 		       unsigned int index, struct nfp_eth_table_port *dst)
 {
 	unsigned int rate;
@@ -216,7 +228,7 @@ struct nfp_eth_table *nfp_eth_read_ports(struct nfp_cpp *cpp)
 struct nfp_eth_table *
 __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp)
 {
-	struct eth_table_entry *entries;
+	union eth_table_entry *entries;
 	struct nfp_eth_table *table;
 	int i, j, ret, cnt = 0;
 
@@ -270,7 +282,7 @@ __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp)
 
 struct nfp_nsp *nfp_eth_config_start(struct nfp_cpp *cpp, unsigned int idx)
 {
-	struct eth_table_entry *entries;
+	union eth_table_entry *entries;
 	struct nfp_nsp *nsp;
 	int ret;
 
@@ -307,7 +319,7 @@ struct nfp_nsp *nfp_eth_config_start(struct nfp_cpp *cpp, unsigned int idx)
 
 void nfp_eth_config_cleanup_end(struct nfp_nsp *nsp)
 {
-	struct eth_table_entry *entries = nfp_nsp_config_entries(nsp);
+	union eth_table_entry *entries = nfp_nsp_config_entries(nsp);
 
 	nfp_nsp_config_set_modified(nsp, false);
 	nfp_nsp_config_clear_state(nsp);
@@ -331,7 +343,7 @@ void nfp_eth_config_cleanup_end(struct nfp_nsp *nsp)
  */
 int nfp_eth_config_commit_end(struct nfp_nsp *nsp)
 {
-	struct eth_table_entry *entries = nfp_nsp_config_entries(nsp);
+	union eth_table_entry *entries = nfp_nsp_config_entries(nsp);
 	int ret = 1;
 
 	if (nfp_nsp_config_modified(nsp)) {
@@ -357,7 +369,7 @@ int nfp_eth_config_commit_end(struct nfp_nsp *nsp)
  */
 int nfp_eth_set_mod_enable(struct nfp_cpp *cpp, unsigned int idx, bool enable)
 {
-	struct eth_table_entry *entries;
+	union eth_table_entry *entries;
 	struct nfp_nsp *nsp;
 	u64 reg;
 
-- 
2.11.0
