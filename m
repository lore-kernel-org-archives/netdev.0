From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 07/17] net: dsa: Remove dynamic allocate of routing table
Date: Fri,  3 Jun 2016 18:44:06 +0200
Message-ID: <1464972256-10408-8-git-send-email-andrew@lunn.ch>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58678 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752890AbcFCQrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2016 12:47:01 -0400
In-Reply-To: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With a maximum of four switches, the size of the routing table is the
same as the pointer to it. Removing it makes the code simpler.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c |  3 +--
 include/net/dsa.h           |  9 ++++-----
 net/dsa/dsa.c               | 12 ------------
 3 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 85332d9a245a..d622c0fb76cc 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3024,8 +3024,7 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 	for (i = 0; i < 32; i++) {
 		int nexthop = 0x1f;
 
-		if (ps->ds->cd->rtable &&
-		    i != ps->ds->index && i < ps->ds->dst->pd->nr_chips)
+		if (i != ps->ds->index && i < ps->ds->dst->pd->nr_chips)
 			nexthop = ps->ds->cd->rtable[i] & 0x1f;
 
 		err = _mv88e6xxx_reg_write(
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 8314197d028f..4e3afa9648ca 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -58,12 +58,11 @@ struct dsa_chip_data {
 	struct device_node *port_dn[DSA_MAX_PORTS];
 
 	/*
-	 * An array (with nr_chips elements) of which element [a]
-	 * indicates which port on this switch should be used to
-	 * send packets to that are destined for switch a.  Can be
-	 * NULL if there is only one switch chip.
+	 * An array of which element [a] indicates which port on this
+	 * switch should be used to send packets to that are destined
+	 * for switch a. Can be NULL if there is only one switch chip.
 	 */
-	s8		*rtable;
+	s8		rtable[DSA_MAX_SWITCHES];
 };
 
 struct dsa_platform_data {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 5907f8cd13b6..6177dd750847 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -587,17 +587,6 @@ static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
 	if (link_sw_addr >= pd->nr_chips)
 		return -EINVAL;
 
-	/* First time routing table allocation */
-	if (!cd->rtable) {
-		cd->rtable = kmalloc_array(pd->nr_chips, sizeof(s8),
-					   GFP_KERNEL);
-		if (!cd->rtable)
-			return -ENOMEM;
-
-		/* default to no valid uplink/downlink */
-		memset(cd->rtable, -1, pd->nr_chips * sizeof(s8));
-	}
-
 	cd->rtable[link_sw_addr] = port_index;
 
 	return 0;
@@ -639,7 +628,6 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 			kfree(pd->chip[i].port_names[port_index]);
 			port_index++;
 		}
-		kfree(pd->chip[i].rtable);
 
 		/* Drop our reference to the MDIO bus device */
 		if (pd->chip[i].host_dev)
-- 
2.8.1
