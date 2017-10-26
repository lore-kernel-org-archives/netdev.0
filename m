From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 8/9] net: dsa: use new port type in helpers
Date: Thu, 26 Oct 2017 11:22:58 -0400
Message-ID: <20171026152259.3123-9-vivien.didelot@savoirfairelinux.com>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:44354 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932338AbdJZPXP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:23:15 -0400
In-Reply-To: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that DSA exposes an enumerated type for the ports, we can use them
directly instead of checking bitmaps, which is more consistent.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 8da20c4a6552..07dfbd7f4fd5 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -261,36 +261,41 @@ struct dsa_switch {
 	struct dsa_port ports[];
 };
 
+static inline const struct dsa_port *dsa_to_port(struct dsa_switch *ds, int p)
+{
+	return &ds->ports[p];
+}
+
 static inline bool dsa_is_unused_port(struct dsa_switch *ds, int p)
 {
-	u32 m = ds->enabled_port_mask | ds->dsa_port_mask | ds->cpu_port_mask;
-
-	return !(m & BIT(p));
+	return dsa_to_port(ds, p)->type == DSA_PORT_TYPE_UNUSED;
 }
 
 static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
 {
-	return !!(ds->cpu_port_mask & (1 << p));
+	return dsa_to_port(ds, p)->type == DSA_PORT_TYPE_CPU;
 }
 
 static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
 {
-	return !!((ds->dsa_port_mask) & (1 << p));
+	return dsa_to_port(ds, p)->type == DSA_PORT_TYPE_DSA;
 }
 
 static inline bool dsa_is_user_port(struct dsa_switch *ds, int p)
 {
-	return !!(ds->enabled_port_mask & BIT(p));
+	return dsa_to_port(ds, p)->type == DSA_PORT_TYPE_USER;
 }
 
 static inline u32 dsa_user_ports(struct dsa_switch *ds)
 {
-	return ds->enabled_port_mask;
-}
+	u32 mask = 0;
+	int p;
 
-static inline const struct dsa_port *dsa_to_port(struct dsa_switch *ds, int p)
-{
-	return &ds->ports[p];
+	for (p = 0; p < ds->num_ports; p++)
+		if (dsa_is_user_port(ds, p))
+			mask |= BIT(p);
+
+	return mask;
 }
 
 static inline u8 dsa_upstream_port(struct dsa_switch *ds)
-- 
2.14.3
