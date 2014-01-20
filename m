From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH iproute2] Add IFLA_SLAVE support.
Date: Mon, 20 Jan 2014 14:25:05 -0800
Message-ID: <20140120222505.6206.85084.stgit@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:54306 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbaATWZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 17:25:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Show slave details for link when slave has IFLA_SLAVE attributes, e.g.:

ip -d link show eth4
6: eth4: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond1 state UP mode DEFAULT group default qlen 1000
    link/ether 00:02:00:00:04:03 brd ff:ff:ff:ff:ff:ff promiscuity 1
    slave state ACTIVE mii_status UP link_failure_count 0 perm_hwaddr 00:02:00:00:04:03 queue_id 0 ad_aggregator_id 1
---
 include/linux/if_link.h |   13 +++++++++
 ip/ipaddress.c          |   71 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 84 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 098be3d..7f956f6 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -144,6 +144,7 @@ enum {
 	IFLA_NUM_RX_QUEUES,
 	IFLA_CARRIER,
 	IFLA_PHYS_PORT_ID,
+	IFLA_SLAVE,
 	__IFLA_MAX
 };
 
@@ -366,6 +367,18 @@ enum {
 
 #define IFLA_BOND_AD_INFO_MAX   (__IFLA_BOND_AD_INFO_MAX - 1)
 
+enum {
+	IFLA_SLAVE_STATE,
+	IFLA_SLAVE_MII_STATUS,
+	IFLA_SLAVE_LINK_FAILURE_COUNT,
+	IFLA_SLAVE_PERM_HWADDR,
+	IFLA_SLAVE_QUEUE_ID,
+	IFLA_SLAVE_AD_AGGREGATOR_ID,
+	__IFLA_SLAVE_MAX,
+};
+
+#define IFLA_SLAVE_MAX  (__IFLA_SLAVE_MAX - 1)
+
 /* SR-IOV virtual function management section */
 
 enum {
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index d02eaaf..a0d3ab8 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -27,6 +27,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
+#include <linux/if_bonding.h>
 #include <linux/sockios.h>
 
 #include "rt_names.h"
@@ -223,6 +224,73 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 	}
 }
 
+static const char *slave_states[] = {
+	[BOND_STATE_ACTIVE] = "ACTIVE",
+	[BOND_STATE_BACKUP] = "BACKUP",
+};
+
+static void print_slave_state(FILE *f, struct rtattr *tb)
+{
+	unsigned int state = rta_getattr_u8(tb);
+
+	if (state >= sizeof(slave_states) / sizeof(slave_states[0]))
+		fprintf(f, "state %d ", state);
+	else
+		fprintf(f, "state %s ", slave_states[state]);
+}
+
+static const char *slave_mii_status[] = {
+	[BOND_LINK_UP] = "UP",
+	[BOND_LINK_FAIL] = "GOING_DOWN",
+	[BOND_LINK_DOWN] = "DOWN",
+	[BOND_LINK_BACK] = "GOING_BACK",
+};
+
+static void print_slave_mii_status(FILE *f, struct rtattr *tb)
+{
+	unsigned int status = rta_getattr_u8(tb);
+
+	if (status >= sizeof(slave_mii_status) / sizeof(slave_mii_status[0]))
+		fprintf(f, "mii_status %d ", status);
+	else
+		fprintf(f, "mii_status %s ", slave_mii_status[status]);
+}
+
+static void print_slave(FILE *fp, struct rtattr *tb)
+{
+	struct rtattr *slave[IFLA_SLAVE_MAX+1];
+	SPRINT_BUF(b1);
+
+	parse_rtattr_nested(slave, IFLA_SLAVE_MAX, tb);
+
+	if (!slave[IFLA_SLAVE_STATE])
+		return;
+
+	fprintf(fp, "%s    slave ", _SL_);
+	print_slave_state(fp, slave[IFLA_SLAVE_STATE]);
+
+	if (slave[IFLA_SLAVE_MII_STATUS])
+		print_slave_mii_status(fp, slave[IFLA_SLAVE_MII_STATUS]);
+
+	if (slave[IFLA_SLAVE_LINK_FAILURE_COUNT])
+		fprintf(fp, "link_failure_count %d ",
+			rta_getattr_u32(slave[IFLA_SLAVE_LINK_FAILURE_COUNT]));
+
+	if (slave[IFLA_SLAVE_PERM_HWADDR])
+		fprintf(fp, "perm_hwaddr %s ",
+			ll_addr_n2a(RTA_DATA(slave[IFLA_SLAVE_PERM_HWADDR]),
+				    RTA_PAYLOAD(slave[IFLA_SLAVE_PERM_HWADDR]),
+				    0, b1, sizeof(b1)));
+
+	if (slave[IFLA_SLAVE_QUEUE_ID])
+		fprintf(fp, "queue_id %d ",
+			rta_getattr_u16(slave[IFLA_SLAVE_QUEUE_ID]));
+
+	if (slave[IFLA_SLAVE_AD_AGGREGATOR_ID])
+		fprintf(fp, "ad_aggregator_id %d ",
+			rta_getattr_u16(slave[IFLA_SLAVE_AD_AGGREGATOR_ID]));
+}
+
 static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 {
 	struct ifla_vf_mac *vf_mac;
@@ -516,6 +584,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			print_vfinfo(fp, i);
 	}
 
+	if (do_link && tb[IFLA_SLAVE] && show_details)
+		print_slave(fp, tb[IFLA_SLAVE]);
+
 	fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
