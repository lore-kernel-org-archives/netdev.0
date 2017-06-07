From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/5] net: dsa: Associate slave network device with CPU port
Date: Tue,  6 Jun 2017 17:03:15 -0700
Message-ID: <20170607000317.14729-4-f.fainelli@gmail.com>
References: <20170607000317.14729-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        john@phrozen.org, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34253 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750766AbdFGADe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 20:03:34 -0400
Received: by mail-wm0-f65.google.com with SMTP id 70so133253wme.1
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 17:03:33 -0700 (PDT)
In-Reply-To: <20170607000317.14729-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for supporting multiple CPU ports with DSA, have the
dsa_port structure know which CPU it is associated with. This will be
important in order to make sure the correct CPU is used for transmission
of the frames. If not for functional reasons, for performance (e.g: load
balancing) and forwarding decisions.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h  | 1 +
 net/dsa/dsa_priv.h | 2 +-
 net/dsa/slave.c    | 5 ++++-
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 7e93869819f9..58969b9a090c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -171,6 +171,7 @@ struct dsa_port {
 	struct dsa_switch	*ds;
 	unsigned int		index;
 	const char		*name;
+	struct dsa_port		*cpu_dp;
 	struct net_device	*netdev;
 	struct device_node	*dn;
 	unsigned int		ageing_time;
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 5c510f4ba0ce..7c2326f3b538 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -185,7 +185,7 @@ extern const struct dsa_device_ops trailer_netdev_ops;
 
 static inline struct net_device *dsa_master_netdev(struct dsa_slave_priv *p)
 {
-	return p->dp->ds->dst->cpu_dp->netdev;
+	return p->dp->cpu_dp->netdev;
 }
 
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index ea4ed0285922..de1ab41cfd38 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1139,9 +1139,11 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	struct net_device *master;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
+	struct dsa_port *cpu_dp;
 	int ret;
 
-	master = ds->dst->cpu_dp->netdev;
+	cpu_dp = ds->dst->cpu_dp;
+	master = cpu_dp->netdev;
 
 	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
 				 NET_NAME_UNKNOWN, ether_setup);
@@ -1176,6 +1178,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	p->old_duplex = -1;
 
 	ds->ports[port].netdev = slave_dev;
+	p->dp->cpu_dp = cpu_dp;
 	ret = register_netdev(slave_dev);
 	if (ret) {
 		netdev_err(master, "error %d registering interface %s\n",
-- 
2.9.3
