From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net] vxlan: release rt when found circular route
Date: Mon, 9 Dec 2013 14:27:55 +0800
Message-ID: <52A562EB.9050606@windriver.com>
References: <1386230631-2504-1-git-send-email-fan.du@windriver.com> <20131206.151407.756289328683473825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:59176 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932354Ab3LIG2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 01:28:04 -0500
In-Reply-To: <20131206.151407.756289328683473825.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8807=E6=97=A5 04:14, David Miller wrote:
> From: Fan Du<fan.du@windriver.com>
> Date: Thu, 5 Dec 2013 16:03:51 +0800
>
>> Otherwise causing dst memory leakage.
>> Have Checked all other type tunnel device transmit implementation,
>> no such things happens anymore.
>>
>> Signed-off-by: Fan Du<fan.du@windriver.com>
> ...
>> @@ -1665,6 +1665,7 @@ static void vxlan_xmit_one(struct sk_buff *skb=
, struct net_device *dev,
>>   		}
>>
>>   		if (rt->dst.dev =3D=3D dev) {
>> +			ip_rt_put(rt);
>>   			netdev_dbg(dev, "circular route to %pI4\n",
>>   				&dst->sin.sin_addr.s_addr);
>>   			dev->stats.collisions++;
>
> There is already a "rt_tx_error" label that will handle releasing the
> 'rt', so at the end of this basic block, goto rt_tx_error instead of
> just plain tx_error.

My first thought is using rt_tx_error indeed :), but second thought is
this might criticized by being ugly. Anyway please review.

 From 8867cb9783511a1c945a087209484f74de912689 Mon Sep 17 00:00:00 2001
=46rom: Fan Du <fan.du@windriver.com>
Date: Mon, 9 Dec 2013 10:33:53 +0800
Subject: [PATCHv2 net] vxlan: release rt when found circular route

Otherwise causing dst memory leakage.
Have Checked all other type tunnel device transmit implementation,
no such things happens anymore.

Signed-off-by: Fan Du <fan.du@windriver.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
v2: use rt_tx_error label to release rt.
---
  drivers/net/vxlan.c |    2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0358c07..249e01c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1668,7 +1668,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, s=
truct net_device *dev,
  			netdev_dbg(dev, "circular route to %pI4\n",
  				   &dst->sin.sin_addr.s_addr);
  			dev->stats.collisions++;
-			goto tx_error;
+			goto rt_tx_error;
  		}

  		/* Bypass encapsulation if the destination is local */
--=20
1.7.9.5


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
