From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipvlan: fix various issues in
 ipvlan_process_multicast()
Date: Wed, 21 Dec 2016 17:58:32 -0800
Message-ID: <1482371912.8944.77.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1482355800.8944.75.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAF2d9jhPAmkCNDNXUaUVRgQMq3TSCyKBdzdepnjczQf-=x1Oag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar
         =?UTF-8?Q?=28=E0=A4=AE=E0=A4=B9=E0=A5=87=E0=A4=B6_?=
         =?UTF-8?Q?=E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE?=
         =?UTF-8?Q?=E0=A4=B0=29?= <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36546 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753755AbcLVB6f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 20:58:35 -0500
Received: by mail-pg0-f67.google.com with SMTP id w68so12226682pgw.3
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 17:58:34 -0800 (PST)
In-Reply-To: <CAF2d9jhPAmkCNDNXUaUVRgQMq3TSCyKBdzdepnjczQf-=x1Oag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-21 at 14:21 -0800, Mahesh Bandewar (महेश बंडेवार) wrote:
> >
> Thank you Eric for all these fixes.

Thanks Mahesh. I will send a V2 to include this part as well :

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 693ec5b6622233cd3a28c64c11d6abb97585318b..8b0f99300cbc97d8c8b93c3dfa99cd841914c086 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -135,6 +135,7 @@ static int ipvlan_port_create(struct net_device *dev)
 static void ipvlan_port_destroy(struct net_device *dev)
 {
 	struct ipvl_port *port = ipvlan_port_get_rtnl(dev);
+	struct sk_buff *skb;
 
 	dev->priv_flags &= ~IFF_IPVLAN_MASTER;
 	if (port->mode == IPVLAN_MODE_L3S) {
@@ -144,7 +145,11 @@ static void ipvlan_port_destroy(struct net_device *dev)
 	}
 	netdev_rx_handler_unregister(dev);
 	cancel_work_sync(&port->wq);
-	__skb_queue_purge(&port->backlog);
+	while ((skb = __skb_dequeue(&port->backlog)) != NULL) {
+		if (skb->dev)
+			dev_put(skb->dev);
+		kfree_skb(skb);
+	}
 	kfree(port);
 }
 
