From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/4] net: dsa: Allow switch drivers to indicate number of TX queues
Date: Fri,  1 Sep 2017 16:59:11 -0700
Message-ID: <1504310354-42773-2-git-send-email-f.fainelli@gmail.com>
References: <1504310354-42773-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33771 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752329AbdIBAFT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 20:05:19 -0400
Received: by mail-qt0-f194.google.com with SMTP id h15so1255353qta.0
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 17:05:19 -0700 (PDT)
In-Reply-To: <1504310354-42773-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let switch drivers indicate how many TX queues they support. Some
switches, such as Broadcom Starfighter 2 are designed with 8 egress
queues. Future changes will allow us to leverage the queue mapping and
direct the transmission towards a particular queue.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 3 +++
 net/dsa/slave.c   | 8 ++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 398ca8d70ccd..dd44d6ce1097 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -243,6 +243,9 @@ struct dsa_switch {
 	/* devlink used to represent this switch device */
 	struct devlink		*devlink;
 
+	/* Number of switch port queues */
+	unsigned int		num_tx_queues;
+
 	/* Dynamically allocated ports, keep last */
 	size_t num_ports;
 	struct dsa_port ports[];
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 78e78a6e6833..2afa99506f8b 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1259,8 +1259,12 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 	cpu_dp = ds->dst->cpu_dp;
 	master = cpu_dp->netdev;
 
-	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
-				 NET_NAME_UNKNOWN, ether_setup);
+	if (!ds->num_tx_queues)
+		ds->num_tx_queues = 1;
+
+	slave_dev = alloc_netdev_mqs(sizeof(struct dsa_slave_priv), name,
+				     NET_NAME_UNKNOWN, ether_setup,
+				     ds->num_tx_queues, 1);
 	if (slave_dev == NULL)
 		return -ENOMEM;
 
-- 
1.9.1
