From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fix potential wild pointer when NIC is dying
Date: Wed, 14 Apr 2010 07:33:32 +0200
Message-ID: <1271223212.16881.598.camel@edumazet-laptop>
References: <1271247503-2973-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:61182 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753163Ab0DNFdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 01:33:37 -0400
Received: by bwz19 with SMTP id 19so283091bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 22:33:36 -0700 (PDT)
In-Reply-To: <1271247503-2973-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 avril 2010 =C3=A0 20:18 +0800, Changli Gao a =C3=A9crit =
:
> fix potential wild pointer when NIC is dying.
>=20
> flush_backlog() works with the assumption: the NIC doesn't enqueue pa=
ckets to
> linux kernel, so there are two places, which packets are in, softnet =
queue or
> being processed in net-rx softirq. flush_backlog() is used to drop th=
e first
> kind of packets, and for the later, a grace period is used to wait th=
e
> finishing of the packets processing.
>=20
> It always works without RPS. If RPS is used, although the NIC doesn't=
 enqueue
> packets to linux kernel, RPS may do. There may be condition, a grace =
period has
> passed due to softirq running time limit, there are still packets, wh=
ich refer
> to the died NIC, and are enqueued by RPS after flush_backlog() return=
s.
>=20

I dont see how the problem can happens, and how RPS is involved.

Did you got a single panic, could you provide us a stack trace ?

Maybe are you referring to NAPI ?

NAPI process packets delivered by NIC, and through RPS deliver it to a
(possibly) remote CPU queue.

But at device dismantle time, we should stop NAPI on this device and
packet delivery machinery. RPS being on or not, NAPI wont deliver new
packets. The fact that NAPI can be throtled doesnt change the napi
instance being disabled at this point. No more packet will be delivered
(RPS or not)

Only after this point we call flush_backlog() to make sure we dont have
any queued packet in each cpu input_pkt_queue pointing to the device we
dismantle.

RPS doesnt change this at all.

Hmm ???



> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  net/core/dev.c |   24 +++++++++++++++---------
>  1 file changed, 15 insertions(+), 9 deletions(-)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a10a216..fe4a821 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -131,6 +131,7 @@
>  #include <linux/random.h>
>  #include <trace/events/napi.h>
>  #include <linux/pci.h>
> +#include <linux/stop_machine.h>
> =20
>  #include "net-sysfs.h"
> =20
> @@ -2791,19 +2792,24 @@ int netif_receive_skb(struct sk_buff *skb)
>  EXPORT_SYMBOL(netif_receive_skb);
> =20
>  /* Network device is going away, flush any packets still pending  */
> -static void flush_backlog(void *arg)
> +static int flush_backlog(void *arg)
>  {
>  	struct net_device *dev =3D arg;
> -	struct softnet_data *queue =3D &__get_cpu_var(softnet_data);
>  	struct sk_buff *skb, *tmp;
> +	struct softnet_data *queue;
> +	int cpu;
> =20
> -	rps_lock(queue);
> -	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
> -		if (skb->dev =3D=3D dev) {
> -			__skb_unlink(skb, &queue->input_pkt_queue);
> -			kfree_skb(skb);
> +	for_each_online_cpu(cpu) {
> +		queue =3D &per_cpu(softnet_data, cpu);
> +		skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp) {
> +			if (skb->dev =3D=3D dev) {
> +				__skb_unlink(skb, &queue->input_pkt_queue);
> +				kfree_skb(skb);
> +			}
>  		}
> -	rps_unlock(queue);
> +	}
> +
> +	return 0;
>  }
> =20
>  static int napi_gro_complete(struct sk_buff *skb)
> @@ -5027,7 +5033,7 @@ void netdev_run_todo(void)
> =20
>  		dev->reg_state =3D NETREG_UNREGISTERED;
> =20
> -		on_each_cpu(flush_backlog, dev, 1);
> +		stop_machine(flush_backlog, dev, NULL);
> =20
>  		netdev_wait_allrefs(dev);
> =20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


