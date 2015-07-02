From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] bridge: vlan: fix usage of vlan 0 and 4095
	again
Date: Thu,  2 Jul 2015 05:48:17 -0700
Message-ID: <1435841297-44200-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	vyasevich@gmail.com, davem@davemloft.net, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Vlan ids 0 and 4095 were disallowed by commit:
8adff41c3d25 ("bridge: Don't use VID 0 and 4095 in vlan filtering")
but then the check was removed when vlan ranges were introduced by:
bdced7ef7838 ("bridge: support for multiple vlans and vlan ranges in setlink and dellink requests")
So reintroduce the vlan range check.
Before patch:
[root@testvm ~]# bridge vlan add vid 0 dev eth0 master
(succeeds)
After Patch:
[root@testvm ~]# bridge vlan add vid 0 dev eth0 master
RTNETLINK answers: Invalid argument

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Fixes: bdced7ef7838 ("bridge: support for multiple vlans and vlan ranges in setlink and dellink requests")
---
 net/bridge/br_netlink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 6b67ed3831de..364bdc98bd9b 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -457,6 +457,8 @@ static int br_afspec(struct net_bridge *br,
 		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
 			return -EINVAL;
 		vinfo = nla_data(attr);
+		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
+			return -EINVAL;
 		if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
 			if (vinfo_start)
 				return -EINVAL;
-- 
2.4.3
