From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Thu, 12 Nov 2009 21:23:41 +0100
Message-ID: <4AFC6ECD.5030009@gmail.com>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54807 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754201AbZKLUXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 15:23:43 -0500
In-Reply-To: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert a =E9crit :
> Third version of RPS.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/interrupt.h |    1 +
>  include/linux/netdevice.h |   18 ++++
>  include/linux/skbuff.h    |    2 +
>  net/core/dev.c            |  227 +++++++++++++++++++++++++++++++++++=
+++-------
>  net/core/net-sysfs.c      |  135 +++++++++++++++++++++++++++
>  5 files changed, 348 insertions(+), 35 deletions(-)
>=20



@@ -2696,21 +2842,24 @@ static int process_backlog(struct napi_struct
*napi, int quota)
 	int work =3D 0;
 	struct softnet_data *queue =3D &__get_cpu_var(softnet_data);
 	unsigned long start_time =3D jiffies;
+	unsigned long flags;

 	napi->weight =3D weight_p;
 	do {
 		struct sk_buff *skb;

<<HERE>>	local_irq_disable();
+		spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
 		skb =3D __skb_dequeue(&queue->input_pkt_queue);
 		if (!skb) {
 			__napi_complete(napi);
-			local_irq_enable();
+			spin_unlock_irqrestore(&queue->input_pkt_queue.lock,
+			    flags);
 			break;
 		}
-		local_irq_enable();
+		spin_unlock_irqrestore(&queue->input_pkt_queue.lock, flags);

-		netif_receive_skb(skb);
+		__netif_receive_skb(skb);
 	} while (++work < quota && jiffies =3D=3D start_time);

 	return work;

Not sure you still want the local_irq_disable() before=20
spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);  ?

