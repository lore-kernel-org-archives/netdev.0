From: <Joe.Ghalam@dell.com>
Subject: Re: macvlan: Fix device ref leak when purging bc_queue
Date: Thu, 20 Apr 2017 16:09:56 +0000
Message-ID: <1492704599476.84165@Dell.com>
References: <1492618528011.11322@Dell.com>,<20170420125512.GA9113@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: <davem@davemloft.net>, <Clifford.Wichmann@dell.com>,
        <netdev@vger.kernel.org>
To: <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa7.dell-outbound.iphmx.com ([68.232.153.96]:31722 "EHLO
        esa7.dell-outbound.iphmx.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1033329AbdDTQXP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 12:23:15 -0400
In-Reply-To: <20170420125512.GA9113@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,=0A=
I agree with this change, but the same purge would be needed for the macvla=
n_dellink() call also. =0A=
Thanks,=0A=
Joe=0A=
=0A=
________________________________________=0A=
From: Herbert Xu <herbert@gondor.apana.org.au>=0A=
Sent: Thursday, April 20, 2017 5:55 AM=0A=
To: Ghalam, Joe=0A=
Cc: davem@davemloft.net; Wichmann, Clifford; netdev@vger.kernel.org=0A=
Subject: macvlan: Fix device ref leak when purging bc_queue=0A=
=0A=
When a parent macvlan device is destroyed we end up purging its=0A=
broadcast queue without dropping the device reference count on=0A=
the packet source device.  This causes the source device to linger.=0A=
=0A=
This patch drops that reference count.=0A=
=0A=
Fixes: 260916dfb48c ("macvlan: Fix potential use-after free for...")=0A=
Reported-by: Joe Ghalam <Joe.Ghalam@dell.com>=0A=
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>=0A=
=0A=
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c=0A=
index 9261722..b34eaaa 100644=0A=
--- a/drivers/net/macvlan.c=0A=
+++ b/drivers/net/macvlan.c=0A=
@@ -1139,6 +1139,7 @@ static int macvlan_port_create(struct net_device *dev=
)=0A=
 static void macvlan_port_destroy(struct net_device *dev)=0A=
 {=0A=
        struct macvlan_port *port =3D macvlan_port_get_rtnl(dev);=0A=
+       struct sk_buff *skb;=0A=
=0A=
        dev->priv_flags &=3D ~IFF_MACVLAN_PORT;=0A=
        netdev_rx_handler_unregister(dev);=0A=
@@ -1147,7 +1148,15 @@ static void macvlan_port_destroy(struct net_device *=
dev)=0A=
         * but we need to cancel it and purge left skbs if any.=0A=
         */=0A=
        cancel_work_sync(&port->bc_work);=0A=
-       __skb_queue_purge(&port->bc_queue);=0A=
+=0A=
+       while ((skb =3D __skb_dequeue(&port->bc_queue))) {=0A=
+               const struct macvlan_dev *src =3D MACVLAN_SKB_CB(skb)->src;=
=0A=
+=0A=
+               if (src)=0A=
+                       dev_put(src->dev);=0A=
+=0A=
+               kfree_skb(skb);=0A=
+       }=0A=
=0A=
        kfree(port);=0A=
 }=0A=
--=0A=
Email: Herbert Xu <herbert@gondor.apana.org.au>=0A=
Home Page: http://gondor.apana.org.au/~herbert/=0A=
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt=
