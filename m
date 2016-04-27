From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 07/20] net: dsa: list ports in switch
Date: Wed, 27 Apr 2016 18:30:04 -0400
Message-ID: <1461796217-18893-8-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39173 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753822AbcD0Wax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 18:30:53 -0400
In-Reply-To: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

List DSA port structures in their switch structure, so that drivers can
iterate on them to retrieve information such as their ports membership.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 9 +++++++++
 net/dsa/dsa.c     | 4 ++++
 2 files changed, 13 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 69e467c..5f2e7df 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -32,6 +32,11 @@ enum dsa_tag_protocol {
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
 
+#define dsa_switch_for_each_port(_ds, _dp, _num_ports)			\
+	for (_dp = list_first_entry(&_ds->dp, typeof(*_dp), list);	\
+	     &_dp->list != (&_ds->dp) && _dp->port < _num_ports;	\
+	     _dp = list_next_entry(_dp, list))
+
 struct dsa_chip_data {
 	/*
 	 * How to access the switch configuration registers.
@@ -123,6 +128,8 @@ struct dsa_switch_tree {
 };
 
 struct dsa_port {
+	struct list_head	list;
+
 	struct dsa_switch	*ds;
 	int			port;
 
@@ -173,6 +180,8 @@ struct dsa_switch {
 	u32			phys_mii_mask;
 	struct mii_bus		*slave_mii_bus;
 	struct net_device	*ports[DSA_MAX_PORTS];
+
+	struct list_head	dp;
 };
 
 static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 222494c..3daffb6 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -225,6 +225,8 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	int index = ds->index;
 	int i, ret;
 
+	INIT_LIST_HEAD(&ds->dp);
+
 	/*
 	 * Validate supplied switch configuration.
 	 */
@@ -238,6 +240,8 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		dp[i]->ds = ds;
 		dp[i]->port = i;
 
+		list_add_tail(&dp[i]->list, &ds->dp);
+
 		name = pd->port_names[i];
 		if (name == NULL)
 			continue;
-- 
2.8.0
