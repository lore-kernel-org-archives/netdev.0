From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 13/20] net: dsa: list switches in tree
Date: Wed, 27 Apr 2016 18:30:10 -0400
Message-ID: <1461796217-18893-14-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

List the registered dsa_switch structures in a "ds" member of the
dsa_switch_tree structure. This allows the drivers to easily iterate on
the DSA switch structures of their related DSA tree.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 9 +++++++++
 net/dsa/dsa.c     | 3 +++
 2 files changed, 12 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 389227d..85fac8a 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -32,11 +32,16 @@ enum dsa_tag_protocol {
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
 
+
+#define dsa_tree_for_each_switch(_dst, _ds)		\
+	list_for_each_entry(_ds, &_dst->ds, list)
+
 #define dsa_switch_for_each_port(_ds, _dp, _num_ports)			\
 	for (_dp = list_first_entry(&_ds->dp, typeof(*_dp), list);	\
 	     &_dp->list != (&_ds->dp) && _dp->port < _num_ports;	\
 	     _dp = list_next_entry(_dp, list))
 
+
 struct dsa_chip_data {
 	/*
 	 * How to access the switch configuration registers.
@@ -125,6 +130,8 @@ struct dsa_switch_tree {
 	 * Data for the individual switch chips.
 	 */
 	struct dsa_switch	*switches[DSA_MAX_SWITCHES];
+
+	struct list_head	ds;
 };
 
 struct dsa_port {
@@ -137,6 +144,8 @@ struct dsa_port {
 };
 
 struct dsa_switch {
+	struct list_head	list;
+
 	/*
 	 * Parent switch tree, and switch index.
 	 */
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index aa4a61a..b0055c7 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -842,6 +842,8 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	int i;
 	unsigned configured = 0;
 
+	INIT_LIST_HEAD(&dst->ds);
+
 	dst->pd = pd;
 	dst->master_netdev = dev;
 	dst->cpu_switch = -1;
@@ -858,6 +860,7 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 		}
 
 		dst->switches[i] = ds;
+		list_add_tail(&ds->list, &dst->ds);
 
 		++configured;
 	}
-- 
2.8.0
