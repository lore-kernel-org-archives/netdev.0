From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/4] net: dsa: mv88e6xxx: add port private structure
Date: Fri, 12 Feb 2016 12:09:38 -0500
Message-ID: <1455296981-27998-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1455296981-27998-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455296981-27998-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a per-port mv88e6xxx_priv_port structure to store per-port related
data, instead of adding several arrays of DSA_MAX_PORTS elements in the
mv88e6xxx_priv_state structure.

It currently only contains the port STP state.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 4 ++--
 drivers/net/dsa/mv88e6xxx.h | 7 ++++++-
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 512c8c0..b0e00ed 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1131,7 +1131,7 @@ int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 	/* mv88e6xxx_port_stp_update may be called with softirqs disabled,
 	 * so we can not update the port state directly but need to schedule it.
 	 */
-	ps->port_state[port] = stp_state;
+	ps->ports[port].state = stp_state;
 	set_bit(port, &ps->port_state_update_mask);
 	schedule_work(&ps->bridge_work);
 
@@ -1925,7 +1925,7 @@ static void mv88e6xxx_bridge_work(struct work_struct *work)
 	while (ps->port_state_update_mask) {
 		port = __ffs(ps->port_state_update_mask);
 		clear_bit(port, &ps->port_state_update_mask);
-		mv88e6xxx_set_port_state(ds, port, ps->port_state[port]);
+		mv88e6xxx_set_port_state(ds, port, ps->ports[port].state);
 	}
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index ca08f91..63a6f58 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -379,6 +379,10 @@ struct mv88e6xxx_vtu_stu_entry {
 	u8	data[DSA_MAX_PORTS];
 };
 
+struct mv88e6xxx_priv_port {
+	u8 state;
+};
+
 struct mv88e6xxx_priv_state {
 	/* When using multi-chip addressing, this mutex protects
 	 * access to the indirect access registers.  (In single-chip
@@ -415,8 +419,9 @@ struct mv88e6xxx_priv_state {
 	int		id; /* switch product id */
 	int		num_ports;	/* number of switch ports */
 
+	struct mv88e6xxx_priv_port	ports[DSA_MAX_PORTS];
+
 	unsigned long port_state_update_mask;
-	u8 port_state[DSA_MAX_PORTS];
 
 	struct work_struct bridge_work;
 };
-- 
2.7.1
