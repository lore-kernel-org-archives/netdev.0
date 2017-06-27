From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next 1/2] vxlan: change vxlan_validate() to use netlink_ext_ack for error reporting
Date: Tue, 27 Jun 2017 22:47:57 +0200
Message-ID: <f2c1ed0d8e70a1d2bc900f0dd4b5a93f4df5a3e3.1498595233.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com, roopa@cumulusnetworks.com,
        pshelar@ovn.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel log is not where users expect error messages for netlink
requests; as we have extended acks now, we can replace pr_debug() with
NL_SET_ERR_MSG_ATTR().

While we're at it, also fix the !is_valid_ether_addr() error message (as it
not only rejects the all-zero address, but also multicast addresses), and
add messages for the remaining attributes.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---
 drivers/net/vxlan.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index fd0ff97e3d81..01957e39f2cd 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2716,12 +2716,14 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[],
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN) {
-			pr_debug("invalid link address (not ethernet)\n");
+			NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_ADDRESS],
+					    "invalid link address (not ethernet)");
 			return -EINVAL;
 		}
 
 		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS]))) {
-			pr_debug("invalid all zero ethernet address\n");
+			NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_ADDRESS],
+					    "invalid ethernet address");
 			return -EADDRNOTAVAIL;
 		}
 	}
@@ -2729,8 +2731,11 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[],
 	if (tb[IFLA_MTU]) {
 		u32 mtu = nla_get_u32(tb[IFLA_MTU]);
 
-		if (mtu < ETH_MIN_MTU || mtu > ETH_MAX_MTU)
+		if (mtu < ETH_MIN_MTU || mtu > ETH_MAX_MTU) {
+			NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_MTU],
+					    "invalid MTU");
 			return -EINVAL;
+		}
 	}
 
 	if (!data)
@@ -2739,8 +2744,11 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[],
 	if (data[IFLA_VXLAN_ID]) {
 		u32 id = nla_get_u32(data[IFLA_VXLAN_ID]);
 
-		if (id >= VXLAN_N_VID)
+		if (id >= VXLAN_N_VID) {
+			NL_SET_ERR_MSG_ATTR(extack, data[IFLA_VXLAN_ID],
+					    "invalid VXLAN ID");
 			return -ERANGE;
+		}
 	}
 
 	if (data[IFLA_VXLAN_PORT_RANGE]) {
@@ -2748,8 +2756,8 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[],
 			= nla_data(data[IFLA_VXLAN_PORT_RANGE]);
 
 		if (ntohs(p->high) < ntohs(p->low)) {
-			pr_debug("port range %u .. %u not valid\n",
-				 ntohs(p->low), ntohs(p->high));
+			NL_SET_ERR_MSG_ATTR(extack, data[IFLA_VXLAN_PORT_RANGE],
+					    "port range not valid");
 			return -EINVAL;
 		}
 	}
-- 
2.13.2
