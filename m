From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v9 14/16] net: core: use __ethtool_get_ksettings
Date: Wed, 24 Feb 2016 10:58:10 -0800
Message-ID: <1456340292-26003-15-git-send-email-ddecotig@gmail.com>
References: <1456340292-26003-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ed Swierk <eswierk@skyportsystems.com>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	kan.liang@intel.com, vidya@cumulusnetworks.com,
	David Decotigny <decot@googlers.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org, linux-mips@linux-mips.org,
	fcoe-devel@open-fcoe.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456340292-26003-1-git-send-email-ddecotig@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 net/core/net-sysfs.c   | 15 +++++++++------
 net/packet/af_packet.c | 11 +++++------
 2 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 4ae17c3..2b3f76f 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -198,9 +198,10 @@ static ssize_t speed_show(struct device *dev,
 		return restart_syscall();
 
 	if (netif_running(netdev)) {
-		struct ethtool_cmd cmd;
-		if (!__ethtool_get_settings(netdev, &cmd))
-			ret = sprintf(buf, fmt_dec, ethtool_cmd_speed(&cmd));
+		struct ethtool_link_ksettings cmd;
+
+		if (!__ethtool_get_link_ksettings(netdev, &cmd))
+			ret = sprintf(buf, fmt_dec, cmd.base.speed);
 	}
 	rtnl_unlock();
 	return ret;
@@ -217,10 +218,12 @@ static ssize_t duplex_show(struct device *dev,
 		return restart_syscall();
 
 	if (netif_running(netdev)) {
-		struct ethtool_cmd cmd;
-		if (!__ethtool_get_settings(netdev, &cmd)) {
+		struct ethtool_link_ksettings cmd;
+
+		if (!__ethtool_get_link_ksettings(netdev, &cmd)) {
 			const char *duplex;
-			switch (cmd.duplex) {
+
+			switch (cmd.base.duplex) {
 			case DUPLEX_HALF:
 				duplex = "half";
 				break;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b7e7851..d41b107 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -557,9 +557,8 @@ static int prb_calc_retire_blk_tmo(struct packet_sock *po,
 {
 	struct net_device *dev;
 	unsigned int mbits = 0, msec = 0, div = 0, tmo = 0;
-	struct ethtool_cmd ecmd;
+	struct ethtool_link_ksettings ecmd;
 	int err;
-	u32 speed;
 
 	rtnl_lock();
 	dev = __dev_get_by_index(sock_net(&po->sk), po->ifindex);
@@ -567,19 +566,19 @@ static int prb_calc_retire_blk_tmo(struct packet_sock *po,
 		rtnl_unlock();
 		return DEFAULT_PRB_RETIRE_TOV;
 	}
-	err = __ethtool_get_settings(dev, &ecmd);
-	speed = ethtool_cmd_speed(&ecmd);
+	err = __ethtool_get_link_ksettings(dev, &ecmd);
 	rtnl_unlock();
 	if (!err) {
 		/*
 		 * If the link speed is so slow you don't really
 		 * need to worry about perf anyways
 		 */
-		if (speed < SPEED_1000 || speed == SPEED_UNKNOWN) {
+		if (ecmd.base.speed < SPEED_1000 ||
+		    ecmd.base.speed == SPEED_UNKNOWN) {
 			return DEFAULT_PRB_RETIRE_TOV;
 		} else {
 			msec = 1;
-			div = speed / 1000;
+			div = ecmd.base.speed / 1000;
 		}
 	}
 
-- 
2.7.0.rc3.207.g0ac5344
