From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv7 2/5][RESEND] rtnetlink: send a single notification on device state changes
Date: Tue, 18 Dec 2007 13:29:55 +0100
Message-ID: <119798099767-git-send-email-panther@balabit.hu>
References: <11979809963141-git-send-email-panther@balabit.hu>
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <11979809963141-git-send-email-panther@balabit.hu>
In-Reply-To: <1196352710402-git-send-email-panther@balabit.hu>
References: <1196352710402-git-send-email-panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In do_setlink() a single notification is sent at the end of the function
if any modification occured. If the address has been changed, another
notification is sent.

Both of them is required because originally only the NETDEV_CHANGEADDR notification
was sent and although device state change implies address change, some programs may
expect the original notification. It remains for compatibity.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---

 net/core/rtnetlink.c |   27 ++++++++++++++++++++-------
 1 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index f95c6c5..6be8608 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -542,7 +542,7 @@ int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
 
 EXPORT_SYMBOL_GPL(rtnl_put_cacheinfo);
 
-static void set_operstate(struct net_device *dev, unsigned char transition)
+static int set_operstate(struct net_device *dev, unsigned char transition)
 {
 	unsigned char operstate = dev->operstate;
 
@@ -563,8 +563,9 @@ static void set_operstate(struct net_device *dev, unsigned char transition)
 
 	if (dev->operstate != operstate) {
 		dev->operstate = operstate;
-		netdev_state_change(dev);
-	}
+		return 1;
+	} else
+		return 0;
 }
 
 static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
@@ -858,6 +859,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	if (tb[IFLA_BROADCAST]) {
 		nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_len);
 		send_addr_notify = 1;
+		modified = 1;
 	}
 
 	if (ifm->ifi_flags || ifm->ifi_change) {
@@ -870,14 +872,21 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		dev_change_flags(dev, flags);
 	}
 
-	if (tb[IFLA_TXQLEN])
-		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
+	if (tb[IFLA_TXQLEN]) {
+		if (dev->tx_queue_len != nla_get_u32(tb[IFLA_TXQLEN])) {
+			dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
+			modified = 1;
+		}
+	}
 
 	if (tb[IFLA_OPERSTATE])
-		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
+		modified |= set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 
 	if (tb[IFLA_LINKMODE]) {
-		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
+		if (dev->link_mode != nla_get_u8(tb[IFLA_LINKMODE])) {
+			dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
+			modified = 1;
+		} 
 	}
 
 	err = 0;
@@ -891,6 +900,10 @@ errout:
 
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+
+	if (modified)
+		netdev_state_change(dev);
+
 	return err;
 }
 
