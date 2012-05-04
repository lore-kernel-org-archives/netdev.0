From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Thu, 3 May 2012 20:22:22 -0700
Message-ID: <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Deng-Cheng Zhu <dczhu@mips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:39161 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753156Ab2EDDWX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 23:22:23 -0400
Received: by ghrr11 with SMTP id r11so2451757ghr.19
        for <netdev@vger.kernel.org>; Thu, 03 May 2012 20:22:23 -0700 (PDT)
In-Reply-To: <1336035412-2161-1-git-send-email-dczhu@mips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +struct cpu_flow {
> + =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 u32 rxhash;
> + =A0 =A0 =A0 unsigned long ts;
> +};

This seems like overkill, we already have the rps_flow_table and this
used in accelerated RFS so the device can also take advantage of
steering.  Maybe somehow program that table for your sparse flows?

Tom

> +#endif
> +
> =A0/*
> =A0* This structure holds an RPS map which can be of variable length.=
 =A0The
> =A0* map is an array of CPUs.
> diff --git a/net/Kconfig b/net/Kconfig
> index e07272d..d5aa682 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -222,6 +222,28 @@ config RPS
> =A0 =A0 =A0 =A0depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
> =A0 =A0 =A0 =A0default y
>
> +config RPS_SPARSE_FLOW_OPTIMIZATION
> + =A0 =A0 =A0 bool "RPS optimizations for sparse flows"
> + =A0 =A0 =A0 depends on RPS
> + =A0 =A0 =A0 default n
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 This feature will try to map some network flows to =
consecutive
> + =A0 =A0 =A0 =A0 CPUs in the RPS map. It will bring in some per pack=
et overhead
> + =A0 =A0 =A0 =A0 but should be able to do good to network throughput=
 in the case
> + =A0 =A0 =A0 =A0 of low number of connections while not much affecti=
ng other
> + =A0 =A0 =A0 =A0 cases. (e.g. relatively consistent and high bandwid=
th in single
> + =A0 =A0 =A0 =A0 connection tests).
> +
> +config NR_RPS_MAP_LOOPS
> + =A0 =A0 =A0 int "Number of loops walking RPS map before hash indexi=
ng (1-5)"
> + =A0 =A0 =A0 range 1 5
> + =A0 =A0 =A0 depends on RPS_SPARSE_FLOW_OPTIMIZATION
> + =A0 =A0 =A0 default "4"
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 It defines how many loops to go through the RPS map=
 while
> + =A0 =A0 =A0 =A0 determing target CPU to process the incoming packet=
=2E After that,
> + =A0 =A0 =A0 =A0 the decision will fall back on hash indexing the RP=
S map.
> +
> =A0config RFS_ACCEL
> =A0 =A0 =A0 =A0boolean
> =A0 =A0 =A0 =A0depends on RPS && GENERIC_HARDIRQS
> diff --git a/net/core/dev.c b/net/core/dev.c
> index c25d453..92e292b 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2698,6 +2698,61 @@ set_rps_cpu(struct net_device *dev, struct sk_=
buff *skb,
> =A0 =A0 =A0 =A0return rflow;
> =A0}
>
> +#ifdef CONFIG_RPS_SPARSE_FLOW_OPTIMIZATION
> +static DEFINE_PER_CPU(struct cpu_flow [CONFIG_NR_RPS_MAP_LOOPS], cpu=
_flows);
> +static unsigned long hash_active;
> +
> +#define FLOW_INACTIVE(now, base) (time_after((now), (base) + HZ) || =
\
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unlikely(time_before=
((now), (base))))
> +
> +static u16 find_cpu(const struct rps_map *map, const struct sk_buff =
*skb)
> +{
> + =A0 =A0 =A0 struct cpu_flow *flow;
> + =A0 =A0 =A0 u16 cpu;
> + =A0 =A0 =A0 int i, l, do_alloc =3D 0;
> + =A0 =A0 =A0 unsigned long now =3D jiffies;
> +
> +retry:
> + =A0 =A0 =A0 for (l =3D 0; l < CONFIG_NR_RPS_MAP_LOOPS; l++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D map->len - 1; i >=3D 0; i--)=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu =3D map->cpus[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flow =3D &per_cpu(cpu_f=
lows, cpu)[l];
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (do_alloc) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (flo=
w->dev =3D=3D NULL ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 FLOW_INACTIVE(now, flow->ts)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 flow->dev =3D skb->dev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 flow->rxhash =3D skb->rxhash;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 flow->ts =3D now;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 return cpu;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Un=
like hash indexing, this avoids packet
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* pr=
ocessing imbalance across CPUs.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (flo=
w->rxhash =3D=3D skb->rxhash &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 flow->dev =3D=3D skb->dev &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 !FLOW_INACTIVE(now, flow->ts)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 flow->ts =3D now;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 return cpu;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (FLOW_INACTIVE(now, hash_active) && do_alloc =3D=3D =
0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_alloc =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto retry;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* For all other flows */
> + =A0 =A0 =A0 hash_active =3D now;
> +
> + =A0 =A0 =A0 return map->cpus[((u64) skb->rxhash * map->len) >> 32];
> +}
> +#endif
> +
> =A0/*
> =A0* get_rps_cpu is called from netif_receive_skb and returns the tar=
get
> =A0* CPU from the RPS map of the receiving queue for a given skb.
> @@ -2780,7 +2835,11 @@ static int get_rps_cpu(struct net_device *dev,=
 struct sk_buff *skb,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (map) {
> +#ifdef CONFIG_RPS_SPARSE_FLOW_OPTIMIZATION
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcpu =3D find_cpu(map, skb);
> +#else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcpu =3D map->cpus[((u64) skb->rxhash =
* map->len) >> 32];
> +#endif
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cpu_online(tcpu)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cpu =3D tcpu;
> --
> 1.7.1
>
