From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] bridge: netlink: fix
	slave_changelink/br_setport race conditions
Date: Wed, 22 Jul 2015 13:03:40 +0200
Message-ID: <1437563020-23506-1-git-send-email-razor@blackwall.org>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	bridge@lists.linux-foundation.org, jiri@resnulli.us, davem@davemloft.net
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

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Since slave_changelink support was added there have been a few race
conditions when using br_setport() since some of the port functions it
uses require the bridge lock. It is very easy to trigger a lockup due to
some internal spin_lock() usage without bh disabled, also it's possible to
get the bridge into an inconsistent state.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Fixes: 3ac636b8591c ("bridge: implement rtnl_link_ops->slave_changelink")
---
 net/bridge/br_netlink.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 364bdc98bd9b..3da5525eb8a2 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -693,9 +693,17 @@ static int br_port_slave_changelink(struct net_device *brdev,
 				    struct nlattr *tb[],
 				    struct nlattr *data[])
 {
+	struct net_bridge *br = netdev_priv(brdev);
+	int ret;
+
 	if (!data)
 		return 0;
-	return br_setport(br_port_get_rtnl(dev), data);
+
+	spin_lock_bh(&br->lock);
+	ret = br_setport(br_port_get_rtnl(dev), data);
+	spin_unlock_bh(&br->lock);
+
+	return ret;
 }
 
 static int br_port_fill_slave_info(struct sk_buff *skb,
-- 
2.4.3
