From: Bart Van Assche <bvanassche@acm.org>
Subject: [PATCH] bridge: Unbreak netconsole
Date: Sat, 08 Feb 2014 19:41:15 +0100
Message-ID: <52F67A4B.9000504@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Jiri Pirko <jiri@resnulli.us>,
	Neil Horman <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.stone-is.org ([87.238.162.65]:60445 "EHLO
	smtpgw.stone-is.be" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751022AbaBHTJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Feb 2014 14:09:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sending netconsole messages over a bridge network interface doesn't
work anymore since kernel v3.12. Bisecting this led to the patch
"bridge: cleanup netpoll code". Hence revert that patch (commit
93d8bf9fb8f39d6d3e461db60f883d9f81006159).

Signed-off-by: Bart Van Assche <bvanassche@acm.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: <stable@vger.kernel.org> # 3.12
Reference: https://bugzilla.kernel.org/show_bug.cgi?id=70071
---
 net/bridge/br_device.c  | 12 ++++++------
 net/bridge/br_if.c      |  3 +--
 net/bridge/br_private.h | 10 ++++++++++
 3 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index e4401a5..ab69594 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -252,22 +252,22 @@ fail:
 int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp)
 {
 	struct netpoll *np;
-	int err;
-
-	if (!p->br->dev->npinfo)
-		return 0;
+	int err = 0;
 
 	np = kzalloc(sizeof(*p->np), gfp);
+	err = -ENOMEM;
 	if (!np)
-		return -ENOMEM;
+		goto out;
 
 	err = __netpoll_setup(np, p->dev, gfp);
 	if (err) {
 		kfree(np);
-		return err;
+		goto out;
 	}
 
 	p->np = np;
+
+out:
 	return err;
 }
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index cffe1d6..639231a 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -366,8 +366,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto err2;
 
-	err = br_netpoll_enable(p, GFP_KERNEL);
-	if (err)
+	if (br_netpoll_info(br) && ((err = br_netpoll_enable(p, GFP_KERNEL))))
 		goto err3;
 
 	err = netdev_master_upper_dev_link(dev, br->dev);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index fcd1233..52d63bf 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -339,6 +339,11 @@ void br_dev_setup(struct net_device *dev);
 void br_dev_delete(struct net_device *dev, struct list_head *list);
 netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
+static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
+{
+	return br->dev->npinfo;
+}
+
 static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 				       struct sk_buff *skb)
 {
@@ -351,6 +356,11 @@ static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp);
 void br_netpoll_disable(struct net_bridge_port *p);
 #else
+static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
+{
+	return NULL;
+}
+
 static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 				       struct sk_buff *skb)
 {
-- 
1.8.4.5
