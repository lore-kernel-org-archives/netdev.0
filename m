From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: remove useless prefetch() call
Date: Fri, 20 Mar 2009 11:07:33 +0100
Message-ID: <49C36AE5.6040807@cosmosbay.com>
References: <49C354B5.3060404@cosmosbay.com> <20090320.013611.67498837.davem@davemloft.net> <49C36570.4010903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39462 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760579AbZCTKHh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 06:07:37 -0400
In-Reply-To: <49C36570.4010903@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> David Miller a =E9crit :
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Fri, 20 Mar 2009 09:32:53 +0100
>>
>>> There is no point to use prefetch() call here.
>>> start_xmit() is a function like others...
>>>
>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>> Yes but the operation pointer might not be in the CPU
>> cache at this time?
>>
>> And if it's not we can get it into the cpu whilst we do
>> other processing, such as the dev_queue_xmit_nit() stuff.
>=20
> This slow down fast path, but we can find a compromise.
>=20

Hmm.. it seems that ndo_select_queue is accessed right before
ndo_start_xmit - by dev_pick_tx()) - and they share same cache line,
so operation pointer is in CPU cache.

So first patch is OK, what about this updated Changelog ?

Thank you

[PATCH] net: remove useless prefetch() call

There is no gain using prefetch() in dev_hard_start_xmit(), since
we already had to read ops->ndo_select_queue pointer in dev_pick_tx(),
and both pointers are probably located in the same cache line.

This prefetch call slows down fast path because of a stall in address
computation.

diff --git a/net/core/dev.c b/net/core/dev.c
index c013031..c97e27d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1670,7 +1670,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 	const struct net_device_ops *ops =3D dev->netdev_ops;
 	int rc;
=20
-	prefetch(&dev->netdev_ops->ndo_start_xmit);
 	if (likely(!skb->next)) {
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);

