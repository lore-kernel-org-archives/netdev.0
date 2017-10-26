From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/9] net: dsa: add dsa_is_unused_port helper
Date: Thu, 26 Oct 2017 11:22:51 -0400
Message-ID: <20171026152259.3123-2-vivien.didelot@savoirfairelinux.com>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As the comment above the chunk states, the b53 driver attempts to
disable the unused ports. But using ds->enabled_port_mask is misleading,
because this mask reports in fact the user ports.

To avoid confusion and fix this, this patch introduces an explicit
dsa_is_unused_port helper which ensures the corresponding bit is not
masked in any of the switch port masks.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c | 2 +-
 include/net/dsa.h                | 7 +++++++
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index b48cf0487b43..c74a50112551 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -873,7 +873,7 @@ static int b53_setup(struct dsa_switch *ds)
 	for (port = 0; port < dev->num_ports; port++) {
 		if (dsa_is_cpu_port(ds, port))
 			b53_enable_cpu_port(dev, port);
-		else if (!(BIT(port) & ds->enabled_port_mask))
+		else if (dsa_is_unused_port(ds, port))
 			b53_disable_port(ds, port, NULL);
 	}
 
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 38961ef91d3d..6b1bc1c8f7e2 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -254,6 +254,13 @@ struct dsa_switch {
 	struct dsa_port ports[];
 };
 
+static inline bool dsa_is_unused_port(struct dsa_switch *ds, int p)
+{
+	u32 m = ds->enabled_port_mask | ds->dsa_port_mask | ds->cpu_port_mask;
+
+	return !(m & BIT(p));
+}
+
 static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
 {
 	return !!(ds->cpu_port_mask & (1 << p));
-- 
2.14.3
