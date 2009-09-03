From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] vlan: multiqueue vlan devices
Date: Thu, 03 Sep 2009 11:17:13 +0200
Message-ID: <4A9F8999.1060404@gmail.com>
References: <4A9EBF9C.2030904@gmail.com>	<20090902120107.15146e4e@nehalam>	<4A9EC383.4070304@gmail.com> <20090902.180401.155663057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, brian.haley@hp.com, kaber@trash.net,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34879 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754725AbZICJRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 05:17:21 -0400
In-Reply-To: <20090902.180401.155663057.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 02 Sep 2009 21:12:03 +0200
>=20
>> [PATCH net-next-2.6] vlan: multiqueue vlan device
>>
>> vlan devices are currently not multi-queue capable.
>>
>> We can do that with a new rtnl_link_ops method,
>> get_tx_queues(), called from rtnl_create_link()
>>
>> This new method gets num_tx_queues/real_num_tx_queues
>> from real device.
>>
>> register_vlan_device() is also handled.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, but now I need you to do an audit :-)
>=20
> I believe that drivers will change the number of TX queues
> in use at times where we'll need to trigger an event or
> something so that vlan's can learn about the value changing.

Here is a followup to enable 'true' multiqueue vlan xmit.

I missed this in my first patch.

[PATCH net-next-2.6] vlan: enable multiqueue xmits

vlan_dev_hard_start_xmit() & vlan_dev_hwaccel_hard_start_xmit()
select txqueue number 0, instead of using index provided by
skb_get_queue_mapping().

This is not correct after commit 2e59af3dcbdf11635c03f
[vlan: multiqueue vlan device] because
txq->tx_packets  & txq->tx_bytes changes are performed on
a single location, and not the right locking.

=46ix is to take the appropriate struct netdev_queue pointer

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 53f84c7..3938c3e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -291,7 +291,8 @@ static int vlan_dev_hard_header(struct sk_buff *skb=
, struct net_device *dev,
 static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev)
 {
-	struct netdev_queue *txq =3D netdev_get_tx_queue(dev, 0);
+	int i =3D skb_get_queue_mapping(skb);
+	struct netdev_queue *txq =3D netdev_get_tx_queue(dev, i);
 	struct vlan_ethhdr *veth =3D (struct vlan_ethhdr *)(skb->data);
=20
 	/* Handle non-VLAN frames if they are sent to us, for example by DHCP=
=2E
@@ -329,7 +330,8 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct =
sk_buff *skb,
 static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *sk=
b,
 						    struct net_device *dev)
 {
-	struct netdev_queue *txq =3D netdev_get_tx_queue(dev, 0);
+	int i =3D skb_get_queue_mapping(skb);
+	struct netdev_queue *txq =3D netdev_get_tx_queue(dev, i);
 	u16 vlan_tci;
=20
 	vlan_tci =3D vlan_dev_info(dev)->vlan_id;
