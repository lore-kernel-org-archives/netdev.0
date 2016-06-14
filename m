From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 10/12] net: dsa: mv88e6xxx: iterate on compatible info
Date: Tue, 14 Jun 2016 14:31:51 -0400
Message-ID: <20160614183153.32327-11-vivien.didelot@savoirfairelinux.com>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With legacy probing, we cannot have a compatible info structure. We have
to guess it. Instead of using only the first info structure of the info
table, iterate over the compatible data.

That way, the legacy code will support new compatible chips with
different register access without requiring any code change.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 2f36d01..88c09d5 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3668,6 +3668,25 @@ mv88e6xxx_smi_detect(struct device *dev, struct mii_bus *bus, int sw_addr,
 	return ps;
 }
 
+static struct mv88e6xxx_priv_state *
+mv88e6xxx_drv_detect(struct device *dev, struct mii_bus *bus, int sw_addr)
+{
+	struct mv88e6xxx_priv_state *ps = NULL;
+	const struct mv88e6xxx_info *info;
+	const struct of_device_id *id;
+
+	/* Iterate over compatible info to detect the chip */
+	for (id = &mv88e6xxx_of_id_table[0]; id && id->data; ++id) {
+		info = (const struct mv88e6xxx_info *)id->data;
+
+		ps = mv88e6xxx_smi_detect(dev, bus, sw_addr, info);
+		if (ps)
+			break;
+	}
+
+	return ps;
+}
+
 static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 				       struct device *host_dev, int sw_addr,
 				       void **priv)
@@ -3680,7 +3699,7 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	if (!bus)
 		return NULL;
 
-	ps = mv88e6xxx_smi_detect(dsa_dev, bus, sw_addr, &mv88e6xxx_table[0]);
+	ps = mv88e6xxx_drv_detect(dsa_dev, bus, sw_addr);
 	if (!ps)
 		return NULL;
 
-- 
2.8.3
