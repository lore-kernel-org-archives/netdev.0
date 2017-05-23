From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: support cross-chip ageing time
Date: Tue, 23 May 2017 15:20:59 -0400
Message-ID: <20170523192059.1720-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the switchdev bridge ageing time attribute is propagated to all
switch chips of the fabric, each switch can check if the requested value
is valid and program itself, so that the whole fabric shares a common
ageing time setting.

This is especially needed for switch chips in between others, containing
no bridge port members but evidently used in the data path.

To achieve that, remove the condition which skips the other switches. We
also don't need to identify the target switch anymore, thus remove the
sw_index member of the dsa_notifier_ageing_time_info notifier structure.

On ZII Dev Rev B (with two 88E6352 and one 88E6185) and ZII Dev Rev C
(with two 88E6390X), we have the following hardware configuration:

    # ip link add name br0 type bridge
    # ip link set master br0 dev lan6
    br0: port 1(lan6) entered blocking state
    br0: port 1(lan6) entered disabled state
    # echo 2000 > /sys/class/net/br0/bridge/ageing_time

Before this patch:

    zii-rev-b# cat /sys/kernel/debug/mv88e6xxx/sw*/age_time
    300000
    300000
    15000

    zii-rev-c# cat /sys/kernel/debug/mv88e6xxx/sw*/age_time
    300000
    18750

After this patch:

    zii-rev-b# cat /sys/kernel/debug/mv88e6xxx/sw*/age_time
    15000
    15000
    15000

    zii-rev-c# cat /sys/kernel/debug/mv88e6xxx/sw*/age_time
    18750
    18750

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h | 1 -
 net/dsa/port.c     | 1 -
 net/dsa/switch.c   | 4 ----
 3 files changed, 6 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 1d52f9051d0e..c1d4180651af 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -32,7 +32,6 @@ enum {
 struct dsa_notifier_ageing_time_info {
 	struct switchdev_trans *trans;
 	unsigned int ageing_time;
-	int sw_index;
 };
 
 /* DSA_NOTIFIER_BRIDGE_* */
diff --git a/net/dsa/port.c b/net/dsa/port.c
index c88c0cec8454..efc3bce3a89d 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -135,7 +135,6 @@ int dsa_port_ageing_time(struct dsa_port *dp, clock_t ageing_clock,
 	unsigned int ageing_time = jiffies_to_msecs(ageing_jiffies);
 	struct dsa_notifier_ageing_time_info info = {
 		.ageing_time = ageing_time,
-		.sw_index = dp->ds->index,
 		.trans = trans,
 	};
 
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index c1e4b2d5a3ae..d8e5c311ee7c 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -37,10 +37,6 @@ static int dsa_switch_ageing_time(struct dsa_switch *ds,
 	unsigned int ageing_time = info->ageing_time;
 	struct switchdev_trans *trans = info->trans;
 
-	/* Do not care yet about other switch chips of the fabric */
-	if (ds->index != info->sw_index)
-		return 0;
-
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (ds->ageing_time_min && ageing_time < ds->ageing_time_min)
 			return -ERANGE;
-- 
2.13.0
