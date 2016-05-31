From: Vincent Bernat <vincent@bernat.im>
Subject: [net v4] veth: advertise peer link once both links are tied together
Date: Tue, 31 May 2016 08:30:21 +0200
Message-ID: <1464676221-4873-1-git-send-email-vincent@bernat.im>
References: <574C69DE.3050305@6wind.com>
Cc: Vincent Bernat <vincent@bernat.im>
To: "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:44871 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755686AbcEaGeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2016 02:34:05 -0400
In-Reply-To: <574C69DE.3050305@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the peer link is created, its "iflink" information is not
advertised through Netlink. Once created, the local device is advertised
with this information but if a user is maintaining a cache from all
updates, it will still miss the iflink for the peer link:

    2: veth0@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default
        link/ether ae:0e:08:af:fb:a0 brd ff:ff:ff:ff:ff:ff
    3: veth1@veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN group default
        link/ether 3a:31:f1:36:2e:e5 brd ff:ff:ff:ff:ff:ff

With this patch, we advertise again the peer link to let any user pick
the appropriate iflink information:

    3: veth0@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default
        link/ether fa:ba:12:26:99:00 brd ff:ff:ff:ff:ff:ff
    3: veth0@veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default
        link/ether fa:ba:12:26:99:00 brd ff:ff:ff:ff:ff:ff
    4: veth1@veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN group default
        link/ether ea:e4:e2:26:3c:87 brd ff:ff:ff:ff:ff:ff

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
v4:
 - use ~0U instead of IFF_SLAVE for ifi_change

v3:
 - send an additional netlink messages once the peer link is tied to
   avoid any chicken/egg problem

v2:
 - ensure the device is unregistered in case of link configuration failure

drivers/net/veth.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f37a6e61d4ad..aaa1b023b9f2 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -466,6 +466,8 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 
 	priv = netdev_priv(peer);
 	rcu_assign_pointer(priv->peer, dev);
+
+	rtmsg_ifinfo(RTM_NEWLINK, peer, ~0U, GFP_KERNEL);
 	return 0;
 
 err_register_dev:
-- 
2.8.1
