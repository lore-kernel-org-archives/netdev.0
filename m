From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 3/6 v4] rtnetlink: Add support to set MAC/VLAN
	filters
Date: Tue, 08 Nov 2011 23:55:51 -0800
Message-ID: <20111109075551.13549.65530.stgit@rhel6.1>
References: <20111109075449.13549.58135.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: chrisw@redhat.com, sri@us.ibm.com, dragos.tatulea@gmail.com,
	kvm@vger.kernel.org, arnd@arndb.de, mst@redhat.com,
	gregory.v.rose@intel.com, mchan@broadcom.com, dwang2@cisco.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com, kaber@trash.net,
	benve@cisco.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111109075449.13549.58135.stgit@rhel6.1>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds support in rtnetlink for IFLA_RX_FILTER and
IFLA_VF_RX_FILTERS set. It calls netdev_ops->set_rx_filter_addr and
rtnl_link_ops->set_rx_filter_vlan

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 include/linux/if_link.h |    2 +
 net/core/rtnetlink.c    |  101 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 103 insertions(+), 0 deletions(-)


diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 74a9f17..a8c2c14 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -268,6 +268,8 @@ enum macvlan_mode {
 
 /* SR-IOV virtual function management section */
 
+#define SELF_VF		-1
+
 enum {
 	IFLA_VF_INFO_UNSPEC,
 	IFLA_VF_INFO,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9eead8e..a042910 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1294,6 +1294,66 @@ static int do_set_master(struct net_device *dev, int ifindex)
 	return 0;
 }
 
+static int do_set_rx_filter(struct net_device *dev, int vf,
+			    struct nlattr *rx_filter[],
+			    int *modified)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	int err = 0;
+
+	if (rx_filter[IFLA_RX_FILTER_ADDR]) {
+		struct nlattr *addr_filter[IFLA_RX_FILTER_ADDR_MAX+1];
+
+		if (!ops->ndo_set_rx_filter_addr) {
+			err = -EOPNOTSUPP;
+			goto errout;
+		}
+
+		err = nla_parse_nested(addr_filter, IFLA_RX_FILTER_ADDR_MAX,
+				rx_filter[IFLA_RX_FILTER_ADDR],
+				ifla_addr_filter_policy);
+		if (err < 0)
+			goto errout;
+
+		if (addr_filter[IFLA_RX_FILTER_ADDR_FLAGS]) {
+			unsigned int flags = nla_get_u32(
+					addr_filter[IFLA_RX_FILTER_ADDR_FLAGS]);
+			if (flags & ~RX_FILTER_FLAGS) {
+				err = -EINVAL;
+				goto errout;
+			}
+		}
+
+		err = ops->ndo_set_rx_filter_addr(dev, vf, addr_filter);
+		if (err < 0)
+			goto errout;
+		*modified = 1;
+	}
+
+	if (rx_filter[IFLA_RX_FILTER_VLAN]) {
+		struct nlattr *vlan_filter[IFLA_RX_FILTER_VLAN_MAX+1];
+
+		if (!ops->ndo_set_rx_filter_vlan) {
+			err = -EOPNOTSUPP;
+			goto errout;
+		}
+
+		err = nla_parse_nested(vlan_filter, IFLA_RX_FILTER_VLAN_MAX,
+				rx_filter[IFLA_RX_FILTER_VLAN],
+				ifla_vlan_filter_policy);
+		if (err < 0)
+			goto errout;
+
+		err = ops->ndo_set_rx_filter_vlan(dev, vf, vlan_filter);
+		if (err < 0)
+			goto errout;
+		*modified = 1;
+	}
+
+errout:
+	return err;
+}
+
 static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		      struct nlattr **tb, char *ifname, int modified)
 {
@@ -1515,6 +1575,47 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 			modified = 1;
 		}
 	}
+
+	if (tb[IFLA_VF_RX_FILTERS]) {
+		struct nlattr *vf_rx_filter[IFLA_RX_FILTER_MAX+1];
+		struct nlattr *attr;
+		int vf;
+		int rem;
+
+		nla_for_each_nested(attr, tb[IFLA_VF_RX_FILTERS], rem) {
+			if (nla_type(attr) != IFLA_VF_RX_FILTER)
+				continue;
+			err = nla_parse_nested(vf_rx_filter, IFLA_RX_FILTER_MAX,
+					attr, ifla_rx_filter_policy);
+			if (err < 0)
+				goto errout;
+
+			if (!vf_rx_filter[IFLA_RX_FILTER_VF]) {
+				err = -EOPNOTSUPP;
+				goto errout;
+			}
+			vf = nla_get_u32(vf_rx_filter[IFLA_RX_FILTER_VF]);
+
+			err = do_set_rx_filter(dev, vf, vf_rx_filter,
+					 &modified);
+			if (err < 0)
+				goto errout;
+		}
+	}
+
+	if (tb[IFLA_RX_FILTER]) {
+		struct nlattr *rx_filter[IFLA_RX_FILTER_MAX+1];
+
+		err = nla_parse_nested(rx_filter, IFLA_RX_FILTER_MAX,
+				tb[IFLA_RX_FILTER], ifla_rx_filter_policy);
+		if (err < 0)
+			goto errout;
+
+		err = do_set_rx_filter(dev, SELF_VF, rx_filter, &modified);
+		if (err < 0)
+			goto errout;
+	}
+
 	err = 0;
 
 errout:

