From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next 1/8] af_packet: Check return of dev_set_promiscuity/allmulti
Date: Fri, 20 Jun 2008 08:54:32 +0800
Message-ID: <485AFFC8.2040701@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64819 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751240AbYFTA6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 20:58:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_set_promiscuity/allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

In af_packet, we check all positive increment for promiscuity and allmulti
to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/packet/af_packet.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2cee87d..c6a1e36 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1175,7 +1175,8 @@ static int packet_getname(struct socket *sock, struct sockaddr *uaddr,
 	return 0;
 }
 
-static void packet_dev_mc(struct net_device *dev, struct packet_mclist *i, int what)
+static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
+			 int what)
 {
 	switch (i->type) {
 	case PACKET_MR_MULTICAST:
@@ -1185,13 +1186,14 @@ static void packet_dev_mc(struct net_device *dev, struct packet_mclist *i, int w
 			dev_mc_delete(dev, i->addr, i->alen, 0);
 		break;
 	case PACKET_MR_PROMISC:
-		dev_set_promiscuity(dev, what);
+		return dev_set_promiscuity(dev, what);
 		break;
 	case PACKET_MR_ALLMULTI:
-		dev_set_allmulti(dev, what);
+		return dev_set_allmulti(dev, what);
 		break;
 	default:;
 	}
+	return 0;
 }
 
 static void packet_dev_mclist(struct net_device *dev, struct packet_mclist *i, int what)
@@ -1245,7 +1247,8 @@ static int packet_mc_add(struct sock *sk, struct packet_mreq_max *mreq)
 	i->count = 1;
 	i->next = po->mclist;
 	po->mclist = i;
-	packet_dev_mc(dev, i, +1);
+	/* Positive increment should be checked for overflow --WCN */
+	err = packet_dev_mc(dev, i, 1);
 
 done:
 	rtnl_unlock();
-- 
1.5.3.4


