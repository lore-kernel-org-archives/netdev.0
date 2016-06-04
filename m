From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 08/17] net: dsa: Copy the routing table into the switch structure
Date: Sat,  4 Jun 2016 21:17:00 +0200
Message-ID: <1465067829-1875-11-git-send-email-andrew@lunn.ch>
References: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Shawn Guo <shawnguo@kernel.org>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59490 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751255AbcFDTSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 15:18:53 -0400
In-Reply-To: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new binding will not have a chip data structure, it will place the
routing directly into the switch structure. To enable backwards
compatibility, copy the routing from the chip data into the switch
structure.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
v2 - Reformat rtable comment.
---
 drivers/net/dsa/mv88e6xxx.c | 4 ++--
 include/net/dsa.h           | 9 ++++++++-
 net/dsa/dsa.c               | 2 ++
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index d622c0fb76cc..492801a6398c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3024,8 +3024,8 @@ static int mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 	for (i = 0; i < 32; i++) {
 		int nexthop = 0x1f;
 
-		if (i != ps->ds->index && i < ps->ds->dst->pd->nr_chips)
-			nexthop = ps->ds->cd->rtable[i] & 0x1f;
+		if (i != ds->index && i < DSA_MAX_SWITCHES)
+			nexthop = ds->rtable[i] & 0x1f;
 
 		err = _mv88e6xxx_reg_write(
 			ps, REG_GLOBAL2,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 4e3afa9648ca..b666f27b3daa 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -148,6 +148,13 @@ struct dsa_switch {
 	 */
 	struct dsa_switch_driver	*drv;
 
+	/*
+	 * An array of which element [a] indicates which port on this
+	 * switch should be used to send packets to that are destined
+	 * for switch a. Can be NULL if there is only one switch chip.
+	 */
+	s8		rtable[DSA_MAX_SWITCHES];
+
 #ifdef CONFIG_NET_DSA_HWMON
 	/*
 	 * Hardware monitoring information
@@ -194,7 +201,7 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 	if (dst->cpu_switch == ds->index)
 		return dst->cpu_port;
 	else
-		return ds->cd->rtable[dst->cpu_switch];
+		return ds->rtable[dst->cpu_switch];
 }
 
 struct switchdev_trans;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 6177dd750847..bfe1d03d4730 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -297,6 +297,8 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		dst->tag_protocol = drv->tag_protocol;
 	}
 
+	memcpy(ds->rtable, cd->rtable, sizeof(ds->rtable));
+
 	/*
 	 * Do basic register setup.
 	 */
-- 
2.8.1
