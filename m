From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC v3 2/6] bridge: trigger a bridge calculation upon
	port changes
Date: Mon,  3 Mar 2014 14:47:01 -0800
Message-ID: <1393886825-24323-3-git-send-email-mcgrof@do-not-panic.com>
References: <1393886825-24323-1-git-send-email-mcgrof@do-not-panic.com>
Cc: kvm@vger.kernel.org, mcgrof@suse.com, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	xen-devel@lists.xenproject.org
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1393886825-24323-1-git-send-email-mcgrof@do-not-panic.com>
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

From: "Luis R. Rodriguez" <mcgrof@suse.com>

If netlink is used to tune a port we currently don't trigger a
new recalculation of the bridge id, ensure that happens just as
if we're adding a new net_device onto the bridge.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: bridge@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
Cc: kvm@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 net/bridge/br_netlink.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e74b6d53..6f1b26d 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -364,6 +364,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 	struct net_bridge_port *p;
 	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
 	int err = 0;
+	bool changed;
 
 	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_PROTINFO);
 	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
@@ -386,7 +387,12 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 
 			spin_lock_bh(&p->br->lock);
 			err = br_setport(p, tb);
+			changed = br_stp_recalculate_bridge_id(p->br);
 			spin_unlock_bh(&p->br->lock);
+			if (changed)
+				call_netdevice_notifiers(NETDEV_CHANGEADDR,
+							 p->br->dev);
+			netdev_update_features(p->br->dev);
 		} else {
 			/* Binary compatibility with old RSTP */
 			if (nla_len(protinfo) < sizeof(u8))
-- 
1.9.0
