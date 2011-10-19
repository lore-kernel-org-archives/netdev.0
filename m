From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 3/8 RFC v2] rtnetlink: Add support to set
	MAC/VLAN filters
Date: Tue, 18 Oct 2011 23:26:09 -0700
Message-ID: <20111019062609.7242.31512.stgit@savbu-pc100.cisco.com>
References: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dragos.tatulea@gmail.com, arnd@arndb.de,
	kvm@vger.kernel.org, mst@redhat.com, davem@davemloft.net,
	mchan@broadcom.com, dwang2@cisco.com, shemminger@vyatta.com,
	eric.dumazet@gmail.com, kaber@trash.net, benve@cisco.com
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds support in rtnetlink for IFLA_RX_FILTER set.
It adds code in do_setlink to parse IFLA_RX_FILTER and call
the rtnl_link_ops->set_rx_addr_filter and
rtnl_link_ops->set_rx_vlan_filter to set MAC and VLAN filters.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 net/core/rtnetlink.c |   67 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 67 insertions(+), 0 deletions(-)


diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a3b213f..bc1074d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1296,6 +1296,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		      struct nlattr **tb, char *ifname, int modified)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+	const struct rtnl_link_ops *rtnl_ops;
 	int send_addr_notify = 0;
 	int err;
 
@@ -1513,6 +1514,72 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 			modified = 1;
 		}
 	}
+
+	if (tb[IFLA_RX_FILTER]) {
+		struct nlattr *filters[IFLA_RX_FILTER_MAX+1];
+
+		err = -EOPNOTSUPP;
+		rtnl_ops = dev->rtnl_link_ops;
+		if (!rtnl_ops)
+			goto errout;
+
+		err = nla_parse_nested(filters,
+			IFLA_RX_FILTER_MAX, tb[IFLA_RX_FILTER],
+			ifla_rx_filter_policy);
+		if (err < 0)
+			goto errout;
+
+		if (filters[IFLA_RX_ADDR_FILTER]) {
+			struct nlattr *addr_filters[IFLA_ADDR_FILTER_MAX+1];
+
+			if (!rtnl_ops->set_rx_addr_filter) {
+				err = -EOPNOTSUPP;
+				goto errout;
+			}
+
+			err = nla_parse_nested(addr_filters,
+				IFLA_ADDR_FILTER_MAX,
+				filters[IFLA_RX_ADDR_FILTER],
+				ifla_addr_filter_policy);
+			if (err < 0)
+				goto errout;
+
+			if (addr_filters[IFLA_ADDR_FILTER_FLAGS]) {
+				unsigned int flags = nla_get_u32(
+					addr_filters[IFLA_ADDR_FILTER_FLAGS]);
+				if (flags & ~RX_FILTER_FLAGS) {
+					err = -EINVAL;
+					goto errout;
+				}
+			}
+
+			err = rtnl_ops->set_rx_addr_filter(dev, addr_filters);
+			if (err < 0)
+				goto errout;
+			modified = 1;
+		}
+
+		if (filters[IFLA_RX_VLAN_FILTER]) {
+			struct nlattr *vlan_filters[IFLA_VLAN_FILTER_MAX+1];
+
+			if (!rtnl_ops->set_rx_vlan_filter) {
+				err = -EOPNOTSUPP;
+				goto errout;
+			}
+
+			err = nla_parse_nested(vlan_filters,
+				IFLA_VLAN_FILTER_MAX,
+				filters[IFLA_RX_VLAN_FILTER],
+				ifla_vlan_filter_policy);
+			if (err < 0)
+				goto errout;
+
+			err = rtnl_ops->set_rx_vlan_filter(dev, vlan_filters);
+			if (err < 0)
+				goto errout;
+			modified = 1;
+		}
+	}
 	err = 0;
 
 errout:

