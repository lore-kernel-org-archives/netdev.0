From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next-2.6] veth: use batched device unregister
Date: Mon, 09 May 2011 09:45:48 +0200
Message-ID: <1304927148.3342.4.camel@edumazet-laptop>
References: <1304793749.3207.26.camel@edumazet-laptop>
	 <1304838742.3207.45.camel@edumazet-laptop>
	 <F57561A93EFF5E88729A8D53@nimrod.local>
	 <7B76F9D75FD26D716624004B@nimrod.local>
	 <20110508125028.GK2641@linux.vnet.ibm.com>
	 <B2891EFD056565BBD4DBCE16@nimrod.local>
	 <20110508134425.GL2641@linux.vnet.ibm.com>
	 <C449131127D58077CB25C9D8@Ximines.local>
	 <20110508144749.GR2641@linux.vnet.ibm.com>
	 <AB9DE9E04289CF29CA79CC67@Ximines.local>
	 <20110508154854.GT2641@linux.vnet.ibm.com>
	 <1304888447.3207.66.camel@edumazet-laptop>
	 <1304916275.3207.79.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alex Bligh <alex@alex.org.uk>, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ben Greear <greearb@candelatech.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:58923 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753261Ab1EIHpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 03:45:52 -0400
Received: by wwk4 with SMTP id 4so2088237wwk.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 00:45:51 -0700 (PDT)
In-Reply-To: <1304916275.3207.79.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

veth devices dont use the batched device unregisters yet.

Since veth are a pair of devices, it makes sense to use a batch of two
unregisters, this roughly divide dismantle time by two.

Reported-by: Alex Bligh <alex@alex.org.uk>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jesse Gross <jesse@nicira.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Ben Greear <greearb@candelatech.com>
---
v2: added a list_del(&list) for safety (see commit ceaaec98)
 drivers/net/veth.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 3b0151a..b41d6a9 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -416,8 +416,17 @@ static void veth_dellink(struct net_device *dev, struct list_head *head)
 	priv = netdev_priv(dev);
 	peer = priv->peer;
 
-	unregister_netdevice_queue(dev, head);
-	unregister_netdevice_queue(peer, head);
+	if (head == NULL) {
+		LIST_HEAD(list);
+		/* make a batch of two devices to speedup unregister */
+		unregister_netdevice_queue(dev, &list);
+		unregister_netdevice_queue(peer, &list);
+		unregister_netdevice_many(&list);
+		list_del(&list);
+	} else {
+		unregister_netdevice_queue(dev, head);
+		unregister_netdevice_queue(peer, head);
+	}
 }
 
 static const struct nla_policy veth_policy[VETH_INFO_MAX + 1];


