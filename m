From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 2/3] net: dsa: check out-of-range ageing time value
Date: Wed, 15 Mar 2017 15:53:49 -0400
Message-ID: <20170315195350.11059-3-vivien.didelot@savoirfairelinux.com>
References: <20170315195350.11059-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cobham <jcobham@questertangent.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40442 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753590AbdCOTzh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 15:55:37 -0400
In-Reply-To: <20170315195350.11059-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a DSA switch driver cannot program an ageing time value due to it
being out-of-range, switchdev will raise a stack trace before failing.

To fix this, add ageing_time_min and ageing_time_max members to the
dsa_switch in order for the switch drivers to optionally specify their
supported ageing time limits.

The DSA core will now check for provided ageing time limits and return
-ERANGE from the switchdev prepare phase if the value is out-of-range.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 4 ++++
 net/dsa/slave.c   | 8 ++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index bf0e42c2a6f7..e42897fd7a96 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -233,6 +233,10 @@ struct dsa_switch {
 	u32			phys_mii_mask;
 	struct mii_bus		*slave_mii_bus;
 
+	/* Ageing Time limits in msecs */
+	unsigned int ageing_time_min;
+	unsigned int ageing_time_max;
+
 	/* Dynamically allocated ports, keep last */
 	size_t num_ports;
 	struct dsa_port ports[];
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index cec47e843570..78128acfbf63 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -443,9 +443,13 @@ static int dsa_slave_ageing_time(struct net_device *dev,
 	unsigned long ageing_jiffies = clock_t_to_jiffies(attr->u.ageing_time);
 	unsigned int ageing_time = jiffies_to_msecs(ageing_jiffies);
 
-	/* bridge skips -EOPNOTSUPP, so skip the prepare phase */
-	if (switchdev_trans_ph_prepare(trans))
+	if (switchdev_trans_ph_prepare(trans)) {
+		if (ds->ageing_time_min && ageing_time < ds->ageing_time_min)
+			return -ERANGE;
+		if (ds->ageing_time_max && ageing_time > ds->ageing_time_max)
+			return -ERANGE;
 		return 0;
+	}
 
 	/* Keep the fastest ageing time in case of multiple bridges */
 	p->dp->ageing_time = ageing_time;
-- 
2.12.0
