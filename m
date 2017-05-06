From: David Ahern <dsahern@gmail.com>
Subject: [PATCH RFC net-next 6/6] net: add uapi for creating lightweight devices
Date: Sat,  6 May 2017 10:07:34 -0600
Message-ID: <20170506160734.47084-7-dsahern@gmail.com>
References: <20170506160734.47084-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        nicolas.dichtel@6wind.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35499 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753180AbdEFQH5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 12:07:57 -0400
Received: by mail-pf0-f196.google.com with SMTP id u26so4383718pfd.2
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 09:07:52 -0700 (PDT)
In-Reply-To: <20170506160734.47084-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow users to make new devices lightweight by setting IFLA_LWT_NETDEV
attribute in the newlink request.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 10 +++++++++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8e56ac70e0d1..f57a16e542b7 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -157,6 +157,7 @@ enum {
 	IFLA_GSO_MAX_SIZE,
 	IFLA_PAD,
 	IFLA_XDP,
+	IFLA_LWT_NETDEV,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a4db1cd91c4a..9c18e6dec379 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2378,6 +2378,7 @@ struct net_device *rtnl_create_link(struct net *net,
 	struct net_device *dev;
 	unsigned int num_tx_queues = 1;
 	unsigned int num_rx_queues = 1;
+	unsigned int flags = 0;
 
 	if (tb[IFLA_NUM_TX_QUEUES])
 		num_tx_queues = nla_get_u32(tb[IFLA_NUM_TX_QUEUES]);
@@ -2389,8 +2390,15 @@ struct net_device *rtnl_create_link(struct net *net,
 	else if (ops->get_num_rx_queues)
 		num_rx_queues = ops->get_num_rx_queues();
 
+	if (tb[IFLA_LWT_NETDEV]) {
+		u8 lwt_dev = !!nla_get_u8(tb[IFLA_LWT_NETDEV]);
+
+		if (lwt_dev)
+			flags |= IFF_LWT_NETDEV;
+	}
+
 	dev = alloc_netdev_mqs(ops->priv_size, ifname, name_assign_type,
-			       ops->setup, num_tx_queues, num_rx_queues, 0);
+			       ops->setup, num_tx_queues, num_rx_queues, flags);
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.11.0 (Apple Git-81)
