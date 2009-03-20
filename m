From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [NET] net: reorder struct net_device_ops
Date: Fri, 20 Mar 2009 10:44:16 +0100
Message-ID: <49C36570.4010903@cosmosbay.com>
References: <49C354B5.3060404@cosmosbay.com> <20090320.013611.67498837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39256 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756514AbZCTJoZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 05:44:25 -0400
In-Reply-To: <20090320.013611.67498837.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 20 Mar 2009 09:32:53 +0100
>=20
>> There is no point to use prefetch() call here.
>> start_xmit() is a function like others...
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> Yes but the operation pointer might not be in the CPU
> cache at this time?
>=20
> And if it's not we can get it into the cpu whilst we do
> other processing, such as the dev_queue_xmit_nit() stuff.

This slow down fast path, but we can find a compromise.

I saw a strange effect on oprofile because of this prefetch()
on a situation we call xxx.xxx times per second dev_hard_start_xmit()
(So this ought to be in CPU cache already)

prefetch() is *free* only if the address computation is fast too :)

Thank you

[NET] net: reorder struct net_device_ops

Moving ndo_start_xmit() field at first position in
struct net_device_ops reduce the assembly needed to compute
the prefetch() address.

There seems to be an issue here on some cpus as spotted by oprofile
in dev_hard_start_xmit()
(prefetch() has a dependancy on previous add instruction)

	mov    %eax,-0x14(%ebp) /* store ops */
	add    $0x10,%eax       /* compute &ops->ndo_start_xmit */
	prefetcht0 (%eax)       /* stall here */

After patch, no add instruction is needed anymore.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index be3ebd7..e507c6e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -547,14 +547,14 @@ struct netdev_queue {
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
-	int			(*ndo_init)(struct net_device *dev);
-	void			(*ndo_uninit)(struct net_device *dev);
-	int			(*ndo_open)(struct net_device *dev);
-	int			(*ndo_stop)(struct net_device *dev);
 	int			(*ndo_start_xmit) (struct sk_buff *skb,
 						   struct net_device *dev);
 	u16			(*ndo_select_queue)(struct net_device *dev,
 						    struct sk_buff *skb);
+	int			(*ndo_init)(struct net_device *dev);
+	void			(*ndo_uninit)(struct net_device *dev);
+	int			(*ndo_open)(struct net_device *dev);
+	int			(*ndo_stop)(struct net_device *dev);
 #define HAVE_CHANGE_RX_FLAGS
 	void			(*ndo_change_rx_flags)(struct net_device *dev,
 						       int flags);
diff --git a/net/core/dev.c b/net/core/dev.c
index c013031..2e5ebd0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1670,7 +1670,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 	const struct net_device_ops *ops =3D dev->netdev_ops;
 	int rc;
=20
-	prefetch(&dev->netdev_ops->ndo_start_xmit);
+	prefetch(&ops->ndo_start_xmit);
 	if (likely(!skb->next)) {
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);

