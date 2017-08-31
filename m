From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 1/8] net: dsa: Allow switch drivers to indicate number of RX/TX queues
Date: Wed, 30 Aug 2017 17:18:45 -0700
Message-ID: <1504138732-65383-2-git-send-email-f.fainelli@gmail.com>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Cc: jiri@resnulli.us, jhs@mojatatu.com, davem@davemloft.net,
        xiyou.wangcong@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35385 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdHaA0o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 20:26:44 -0400
Received: by mail-wm0-f68.google.com with SMTP id e204so3360306wma.2
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 17:26:44 -0700 (PDT)
In-Reply-To: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let switch drivers indicate how many RX and TX queues they support. Some
switches, such as Broadcom Starfighter 2 are resigned with 8 egress
queues. Future changes will allow us to leverage the queue mapping and
direct the transmission towards a particular queue.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h |  4 ++++
 net/dsa/slave.c   | 10 ++++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 398ca8d70ccd..b10e8da3f8d7 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -243,6 +243,10 @@ struct dsa_switch {
 	/* devlink used to represent this switch device */
 	struct devlink		*devlink;
 
+	/* Number of switch port queues */
+	unsigned int		num_rx_queues;
+	unsigned int		num_tx_queues;
+
 	/* Dynamically allocated ports, keep last */
 	size_t num_ports;
 	struct dsa_port ports[];
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 78e78a6e6833..bfd7173a3c6a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1259,8 +1259,14 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 	cpu_dp = ds->dst->cpu_dp;
 	master = cpu_dp->netdev;
 
-	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
-				 NET_NAME_UNKNOWN, ether_setup);
+	if (!ds->num_rx_queues)
+		ds->num_rx_queues = 1;
+	if (!ds->num_tx_queues)
+		ds->num_tx_queues = 1;
+
+	slave_dev = alloc_netdev_mqs(sizeof(struct dsa_slave_priv), name,
+				     NET_NAME_UNKNOWN, ether_setup,
+				     ds->num_tx_queues, ds->num_rx_queues);
 	if (slave_dev == NULL)
 		return -ENOMEM;
 
-- 
1.9.1
