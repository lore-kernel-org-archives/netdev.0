From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH 2/4] rtnetlink: Add support to rtnetlink for setting
	hardware queue MAC and VLAN filters
Date: Tue, 17 Nov 2009 13:50:22 -0800
Message-ID: <20091117215021.15119.50121.stgit@localhost.localdomain>
References: <20091117214923.15119.98918.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:38482 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752343AbZKQVug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 16:50:36 -0500
In-Reply-To: <20091117214923.15119.98918.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/if_link.h |   14 ++++++++++++++
 net/core/rtnetlink.c    |   27 +++++++++++++++++++++++++++
 2 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 1d3b242..44d3726 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -78,6 +78,8 @@ enum {
 #define IFLA_LINKINFO IFLA_LINKINFO
 	IFLA_NET_NS_PID,
 	IFLA_IFALIAS,
+	IFLA_QUEUE_MAC,		/* Hardware queue specific attributes */
+	IFLA_QUEUE_VLAN,
 	__IFLA_MAX
 };
 
@@ -181,4 +183,16 @@ struct ifla_vlan_qos_mapping {
 	__u32 to;
 };
 
+/* subqueue managment section */
+
+struct ifla_queue_mac {
+	__u32 queue;
+	__u8 mac[32];	/* MAX_ADDR_LEN */
+};
+
+struct ifla_queue_vlan {
+	__u32 queue;
+	__u32 vlan;
+};
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 33148a5..ad65683 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -725,6 +725,10 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_LINKINFO]		= { .type = NLA_NESTED },
 	[IFLA_NET_NS_PID]	= { .type = NLA_U32 },
 	[IFLA_IFALIAS]	        = { .type = NLA_STRING, .len = IFALIASZ-1 },
+	[IFLA_QUEUE_MAC]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_queue_mac) },
+	[IFLA_QUEUE_VLAN]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_queue_vlan) },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -898,6 +902,29 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		write_unlock_bh(&dev_base_lock);
 	}
 
+	if (tb[IFLA_QUEUE_MAC]) {
+		struct ifla_queue_mac *iqm;
+		iqm = nla_data(tb[IFLA_QUEUE_MAC]);
+		write_lock_bh(&dev_base_lock);
+		if (ops->ndo_set_queue_mac)
+			err = ops->ndo_set_queue_mac(dev, iqm->queue, iqm->mac);
+		write_unlock_bh(&dev_base_lock);
+		if (err < 0)
+			goto errout;
+		modified = 1;
+	}
+
+	if (tb[IFLA_QUEUE_VLAN]) {
+		struct ifla_queue_vlan *iqv;
+		iqv = nla_data(tb[IFLA_QUEUE_VLAN]);
+		write_lock_bh(&dev_base_lock);
+		if (ops->ndo_set_queue_vlan)
+			ops->ndo_set_queue_vlan(dev, iqv->queue, iqv->vlan);
+		write_unlock_bh(&dev_base_lock);
+		if (err < 0)
+			goto errout;
+		modified = 1;
+	}
 	err = 0;
 
 errout:

