From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/1] net: validate HWTSTAMP ioctl parameters
Date: Fri, 14 Oct 2011 11:37:48 +0200
Message-ID: <eca6d279cd96da44d9ad26bdda8fc8c2130c03c1.1318584677.git.richard.cochran@omicron.at>
References: <cover.1318584677.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63268 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152Ab1JNJht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 05:37:49 -0400
Received: by mail-bw0-f46.google.com with SMTP id zt4so2589293bkb.19
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 02:37:48 -0700 (PDT)
In-Reply-To: <cover.1318584677.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1318584677.git.richard.cochran@omicron.at>
References: <20110926.160443.1205173553442138535.davem@davemloft.net> <cover.1318584677.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a sanity check on the values provided by user space for
the hardware time stamping configuration. If the values lie outside of
the absolute limits, then the ioctl request will be denied.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/net_tstamp.h |    4 +-
 net/core/dev.c             |   58 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+), 2 deletions(-)

diff --git a/include/linux/net_tstamp.h b/include/linux/net_tstamp.h
index 3df0984..ae5df12 100644
--- a/include/linux/net_tstamp.h
+++ b/include/linux/net_tstamp.h
@@ -45,7 +45,7 @@ struct hwtstamp_config {
 };
 
 /* possible values for hwtstamp_config->tx_type */
-enum {
+enum hwtstamp_tx_types {
 	/*
 	 * No outgoing packet will need hardware time stamping;
 	 * should a packet arrive which asks for it, no hardware
@@ -72,7 +72,7 @@ enum {
 };
 
 /* possible values for hwtstamp_config->rx_filter */
-enum {
+enum hwtstamp_rx_filters {
 	/* time stamp no incoming packet at all */
 	HWTSTAMP_FILTER_NONE,
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 70ecb86..bc347e6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -136,6 +136,7 @@
 #include <linux/if_tunnel.h>
 #include <linux/if_pppox.h>
 #include <linux/ppp_defs.h>
+#include <linux/net_tstamp.h>
 
 #include "net-sysfs.h"
 
@@ -1477,6 +1478,57 @@ static inline void net_timestamp_check(struct sk_buff *skb)
 		__net_timestamp(skb);
 }
 
+static int net_hwtstamp_validate(struct ifreq *ifr)
+{
+	struct hwtstamp_config cfg;
+	enum hwtstamp_tx_types tx_type;
+	enum hwtstamp_rx_filters rx_filter;
+	int tx_type_valid = 0;
+	int rx_filter_valid = 0;
+
+	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
+		return -EFAULT;
+
+	if (cfg.flags) /* reserved for future extensions */
+		return -EINVAL;
+
+	tx_type = cfg.tx_type;
+	rx_filter = cfg.rx_filter;
+
+	switch (tx_type) {
+	case HWTSTAMP_TX_OFF:
+	case HWTSTAMP_TX_ON:
+	case HWTSTAMP_TX_ONESTEP_SYNC:
+		tx_type_valid = 1;
+		break;
+	}
+
+	switch (rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+	case HWTSTAMP_FILTER_ALL:
+	case HWTSTAMP_FILTER_SOME:
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		rx_filter_valid = 1;
+		break;
+	}
+
+	if (!tx_type_valid || !rx_filter_valid)
+		return -ERANGE;
+
+	return 0;
+}
+
 static inline bool is_skb_forwardable(struct net_device *dev,
 				      struct sk_buff *skb)
 {
@@ -4921,6 +4973,12 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 		ifr->ifr_newname[IFNAMSIZ-1] = '\0';
 		return dev_change_name(dev, ifr->ifr_newname);
 
+	case SIOCSHWTSTAMP:
+		err = net_hwtstamp_validate(ifr);
+		if (err)
+			return err;
+		/* fall through */
+
 	/*
 	 *	Unknown or private ioctl
 	 */
-- 
1.7.2.5
