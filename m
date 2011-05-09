From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] veth: use batched device unregister
Date: Mon, 09 May 2011 06:44:35 +0200
Message-ID: <1304916275.3207.79.camel@edumazet-laptop>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alex Bligh <alex@alex.org.uk>, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ben Greear <greearb@candelatech.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49561 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111Ab1EIEok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 00:44:40 -0400
Received: by wwa36 with SMTP id 36so5337635wwa.1
        for <netdev@vger.kernel.org>; Sun, 08 May 2011 21:44:39 -0700 (PDT)
In-Reply-To: <1304888447.3207.66.camel@edumazet-laptop>
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
 drivers/net/veth.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 3b99f64..77c4679 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -451,8 +451,16 @@ static void veth_dellink(struct net_device *dev, struct list_head *head)
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
+	} else {
+		unregister_netdevice_queue(dev, head);
+		unregister_netdevice_queue(peer, head);
+	}
 }
 
 static const struct nla_policy veth_policy[VETH_INFO_MAX + 1];


