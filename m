From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v3 [PATCH net-next 1/7] af_packet: Check return of dev_set_promiscuity/allmulti
Date: Wed, 02 Jul 2008 16:12:24 +0800
Message-ID: <486B3868.8060206@cn.fujitsu.com>
References: <4869A251.108@cn.fujitsu.com> <4869A2D5.1010605@cn.fujitsu.com> <4869FA91.30405@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59779 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751575AbYGBIRF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 04:17:05 -0400
In-Reply-To: <4869FA91.30405@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2->v3:
  Do unwinding when error happens.

dev_set_promiscuity/allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

In af_packet, we check all positive increment for promiscuity and allmulti
to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2cee87d..7321825 100644
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
@@ -1245,7 +1247,11 @@ static int packet_mc_add(struct sock *sk, struct packet_mreq_max *mreq)
 	i->count = 1;
 	i->next = po->mclist;
 	po->mclist = i;
-	packet_dev_mc(dev, i, +1);
+	err = packet_dev_mc(dev, i, 1);
+	if (err) {
+		po->mclist = i->next;
+		kfree(i);
+	}
 
 done:
 	rtnl_unlock();

