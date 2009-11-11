From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Wed, 11 Nov 2009 11:30:13 +0100
Message-ID: <4AFA9235.1030004@gmail.com>
References: <4AFA8911.7050204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48347 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380AbZKKKaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 05:30:18 -0500
In-Reply-To: <4AFA8911.7050204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =A8=A6crit :
> ifb: add multi-queue support
>=20
> Add multi-queue support, and one kernel thread is created for per que=
ue.
> It can used to emulate multi-queue NIC in software, and distribute wo=
rk
> among CPUs.
> gentux linux # modprobe ifb numtxqs=3D2
> gentux linux # ifconfig ifb0 up
> gentux linux # pgrep ifb0
> 18508
> 18509
> gentux linux # taskset -p 1 18508
> pid 18508's current affinity mask: 3
> pid 18508's new affinity mask: 1
> gentux linux # taskset -p 2 18509
> pid 18509's current affinity mask: 3
> pid 18509's new affinity mask: 2
> gentux linux # tc qdisc add dev br0 ingress
> gentux linux # tc filter add dev br0 parent ffff: protocol ip basic
> action mirred egress redirect dev ifb0
>=20
> This patch also introduces a ip link option "numtxqs" for specifying =
the
> number of the TX queues. so you can add a new ifb with the command:
>=20
> ip link add numtxqs 4 type ifb
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
> drivers/net/ifb.c | 414 ++++++++++++++++++++++++++++++++-------------=
---
> include/linux/if_link.h | 1
> net/core/rtnetlink.c | 3
> 3 files changed, 283 insertions(+), 135 deletions(-)
>=20
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index 69c2566..ac04e85 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> @@ -33,161 +33,157 @@
>  #include <linux/etherdevice.h>
>  #include <linux/init.h>
>  #include <linux/moduleparam.h>
> +#include <linux/wait.h>
> +#include <linux/sched.h>
> +#include <linux/kthread.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <net/ip.h>
>  #include <net/pkt_sched.h>
>  #include <net/net_namespace.h>
> =20
> -#define TX_TIMEOUT  (2*HZ)
> -
>  #define TX_Q_LIMIT    32
> +
> +struct ifb_private_q {
> +	struct net_device	*dev;
> +	struct sk_buff_head	rq;
> +	struct sk_buff_head	tq;
> +	wait_queue_head_t	wq;
> +	struct task_struct	*task;
> +	unsigned long		rx_packets;
> +	unsigned long		rx_bytes;
> +	unsigned long		rx_dropped;
> +} ____cacheline_aligned_in_smp;
> +

Could you split this struct in two parts, one used by ifb_xmit(),
one used by the ifb_thread() ?
This would reduce number of cache line ping pongs...


struct ifb_private_q {

	struct net_device	*dev;
	struct task_struct	*task;

/* used by ifb_xmit() */

	struct sk_buff_head	rq;
	unsigned long		rx_packets;
	unsigned long		rx_bytes;
	unsigned long		rx_dropped;
	wait_queue_head_t	wq;

/* used by ifb_thread() */

	struct sk_buff_head	tq ____cacheline_aligned_in_smp;
} ____cacheline_aligned_in_smp;


Or even better, tq could be local to ifb_xmit()

ifb_xmit() would purge it itself, and could use __skb_dequeue() and
other lockless primitives.

The whole :

while ((skb =3D skb_dequeue(&pq->rq)) !=3D NULL)
	skb_queue_tail(&pq->tq, skb);

could be optimized a lot IMHO, its almost a skb_queue_splice() thing...

