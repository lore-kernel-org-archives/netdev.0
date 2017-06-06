From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/5] net: dsa: add CPU and DSA ports as VLAN members
Date: Tue,  6 Jun 2017 16:56:29 -0400
Message-ID: <20170606205631.22880-4-vivien.didelot@savoirfairelinux.com>
References: <20170606205631.22880-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170606205631.22880-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In a multi-chip switch fabric, it is currently the responsibility of the
driver to add the CPU or DSA (interconnecting chips together) ports as
members of a new VLAN entry. This makes the drivers more complicated.

We want the DSA drivers to be stupid and the DSA core being the one
responsible for caring about the abstracted switch logic and topology.

Make the DSA core program the CPU and DSA ports as part of the VLAN.

This makes all chips of the data path to be aware of VIDs spanning the
the whole fabric and thus, seamlessly add support for cross-chip VLAN.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/switch.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index f235ae1e9777..f913cdfe6585 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -166,6 +166,9 @@ static int dsa_switch_vlan_add(struct dsa_switch *ds,
 	bitmap_zero(members, ds->num_ports);
 	if (ds->index == info->sw_index)
 		set_bit(info->port, members);
+	for (port = 0; port < ds->num_ports; ++port)
+		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
+			set_bit(port, members);
 
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->ops->port_vlan_prepare || !ds->ops->port_vlan_add)
-- 
2.13.0
