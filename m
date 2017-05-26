From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 5/6] nfp: calculate total port lanes for split
Date: Fri, 26 May 2017 01:03:35 -0700
Message-ID: <20170526080336.32689-6-jakub.kicinski@netronome.com>
References: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Cc: jiri@resnulli.us, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33337 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939908AbdEZID4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 04:03:56 -0400
Received: by mail-pf0-f179.google.com with SMTP id e193so4786803pfh.0
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 01:03:56 -0700 (PDT)
In-Reply-To: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For port splitting we will need to know the total number of lanes
in a port.  Calculate that based on eth_table information.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h     |  3 +++
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c | 11 ++++++-----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
index 36b21e4dc56d..84a1d20adae1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h
@@ -96,6 +96,7 @@ enum nfp_eth_aneg {
  * @override_changed: is media reconfig pending?
  *
  * @port_type:	one of %PORT_* defines for ethtool
+ * @port_lanes:	total number of lanes on the port (sum of lanes of all subports)
  * @is_split:	is interface part of a split port
  */
 struct nfp_eth_table {
@@ -127,6 +128,8 @@ struct nfp_eth_table {
 		/* Computed fields */
 		u8 port_type;
 
+		unsigned int port_lanes;
+
 		bool is_split;
 	} ports[0];
 };
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
index 639438d8313a..b0f8785c064f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -186,17 +186,19 @@ nfp_eth_port_translate(struct nfp_nsp *nsp, const union eth_table_entry *src,
 }
 
 static void
-nfp_eth_mark_split_ports(struct nfp_cpp *cpp, struct nfp_eth_table *table)
+nfp_eth_calc_port_geometry(struct nfp_cpp *cpp, struct nfp_eth_table *table)
 {
 	unsigned int i, j;
 
 	for (i = 0; i < table->count; i++)
 		for (j = 0; j < table->count; j++) {
-			if (i == j)
-				continue;
 			if (table->ports[i].label_port !=
 			    table->ports[j].label_port)
 				continue;
+			table->ports[i].port_lanes += table->ports[j].lanes;
+
+			if (i == j)
+				continue;
 			if (table->ports[i].label_subport ==
 			    table->ports[j].label_subport)
 				nfp_warn(cpp,
@@ -205,7 +207,6 @@ nfp_eth_mark_split_ports(struct nfp_cpp *cpp, struct nfp_eth_table *table)
 					 table->ports[i].label_subport);
 
 			table->ports[i].is_split = true;
-			break;
 		}
 }
 
@@ -289,7 +290,7 @@ __nfp_eth_read_ports(struct nfp_cpp *cpp, struct nfp_nsp *nsp)
 			nfp_eth_port_translate(nsp, &entries[i], i,
 					       &table->ports[j++]);
 
-	nfp_eth_mark_split_ports(cpp, table);
+	nfp_eth_calc_port_geometry(cpp, table);
 	for (i = 0; i < table->count; i++)
 		nfp_eth_calc_port_type(cpp, &table->ports[i]);
 
-- 
2.11.0
