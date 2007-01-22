From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 2.6.20-rc5 4/7] ehea: New method to determine number of available ports
Date: Mon, 22 Jan 2007 12:53:50 +0100
Message-ID: <200701221253.50709.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <roscher@de.ibm.com>,
	Stefan Roscher <ossrosch@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751769AbXAVLyD@vger.kernel.org>
Content-Disposition: inline
To: Jeff Garzik <jeff@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Count OFDT nodes to determine the number of available ports
instead of using the possibly outdated value from the hypervisor

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---


 drivers/net/ehea/ehea_main.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletion(-)


diff -Nurp -X dontdiff linux-2.6.20-rc5/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.20-rc5/drivers/net/ehea/ehea_main.c	2007-01-19 14:12:31.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-01-19 14:15:53.000000000 +0100
@@ -2269,6 +2269,8 @@ static void ehea_tx_watchdog(struct net_
 int ehea_sense_adapter_attr(struct ehea_adapter *adapter)
 {
 	struct hcp_query_ehea *cb;
+	struct device_node *lhea_dn = NULL;
+	struct device_node *eth_dn = NULL;
 	u64 hret;
 	int ret;
 
@@ -2285,7 +2287,18 @@ int ehea_sense_adapter_attr(struct ehea_
 		goto out_herr;
 	}
 
-	adapter->num_ports = cb->num_ports;
+	/* Determine the number of available logical ports
+	 * by counting the child nodes of the lhea OFDT entry
+	 */
+	adapter->num_ports = 0;
+	lhea_dn = of_find_node_by_name(lhea_dn, "lhea");
+	do {
+		eth_dn = of_get_next_child(lhea_dn, eth_dn);
+		if (eth_dn)
+			adapter->num_ports++;
+	} while ( eth_dn );
+	of_node_put(lhea_dn);
+
 	adapter->max_mc_mac = cb->max_mc_mac - 1;
 	ret = 0;
 
