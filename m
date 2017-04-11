From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 09/10] s390/qeth: use LINK_MODE_* to report the link characteristics
Date: Tue, 11 Apr 2017 16:11:18 +0200
Message-ID: <20170411141119.82526-10-jwi@linux.vnet.ibm.com>
References: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:41765 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753434AbdDKOLr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:11:47 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3BE91nZ047549
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:46 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29rqsdfyan-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:46 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 11 Apr 2017 15:11:44 +0100
In-Reply-To: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LINK_MODE_* replaces the u32-limited SUPPORTED_* / ENABLED_*
definitions.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 71 ++++++++++++++++++++++++++-------------
 1 file changed, 47 insertions(+), 24 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 4304bc2a6620..88f4c6cff9a4 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -6031,52 +6031,75 @@ EXPORT_SYMBOL_GPL(qeth_core_get_drvinfo);
 static void qeth_set_cmd_adv_sup(struct ethtool_link_ksettings *cmd,
 				int maxspeed, int porttype)
 {
-	u32 sup, adv;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	ethtool_link_ksettings_zero_link_mode(cmd, advertising);
+	ethtool_link_ksettings_zero_link_mode(cmd, lp_advertising);
 
-	sup = SUPPORTED_Autoneg;
-	adv = ADVERTISED_Autoneg;
+	ethtool_link_ksettings_add_link_mode(cmd, supported, Autoneg);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, Autoneg);
 
 	switch (porttype) {
 	case PORT_TP:
-		sup |= SUPPORTED_TP;
-		adv |= ADVERTISED_TP;
+		ethtool_link_ksettings_add_link_mode(cmd, supported, TP);
+		ethtool_link_ksettings_add_link_mode(cmd, advertising, TP);
 		break;
 	case PORT_FIBRE:
-		sup |= SUPPORTED_FIBRE;
-		adv |= ADVERTISED_FIBRE;
+		ethtool_link_ksettings_add_link_mode(cmd, supported, FIBRE);
+		ethtool_link_ksettings_add_link_mode(cmd, advertising, FIBRE);
 		break;
 	default:
-		sup |= SUPPORTED_TP;
-		adv |= ADVERTISED_TP;
+		ethtool_link_ksettings_add_link_mode(cmd, supported, TP);
+		ethtool_link_ksettings_add_link_mode(cmd, advertising, TP);
 		WARN_ON_ONCE(1);
 	}
 
 	/* fallthrough from high to low, to select all legal speeds: */
 	switch (maxspeed) {
 	case SPEED_10000:
-		sup |= SUPPORTED_10000baseT_Full;
-		adv |= ADVERTISED_10000baseT_Full;
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     10000baseT_Full);
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     10000baseT_Full);
 	case SPEED_1000:
-		sup |= SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full;
-		adv |= ADVERTISED_1000baseT_Half | ADVERTISED_1000baseT_Full;
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     1000baseT_Full);
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     1000baseT_Full);
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     1000baseT_Half);
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     1000baseT_Half);
 	case SPEED_100:
-		sup |= SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full;
-		adv |= ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full;
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     100baseT_Full);
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     100baseT_Full);
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     100baseT_Half);
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     100baseT_Half);
 	case SPEED_10:
-		sup |= SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full;
-		adv |= ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full;
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     10baseT_Full);
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     10baseT_Full);
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     10baseT_Half);
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     10baseT_Half);
 		/* end fallthrough */
 		break;
 	default:
-		sup |= SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full;
-		adv |= ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full;
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     10baseT_Full);
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     10baseT_Full);
+		ethtool_link_ksettings_add_link_mode(cmd, supported,
+						     10baseT_Half);
+		ethtool_link_ksettings_add_link_mode(cmd, advertising,
+						     10baseT_Half);
 		WARN_ON_ONCE(1);
 	}
-
-	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
-						sup);
-	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
-						adv);
 }
 
 int qeth_core_ethtool_get_link_ksettings(struct net_device *netdev,
-- 
2.10.2
