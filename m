From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rfs: Receive Flow Steering
Date: Fri, 02 Apr 2010 10:35:04 +0200
Message-ID: <1270197304.1936.179.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:43647 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559Ab0DBIfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 04:35:10 -0400
Received: by bwz1 with SMTP id 1so1367502bwz.21
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 01:35:09 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 avril 2010 =C3=A0 20:59 -0700, Tom Herbert a =C3=A9crit :

> e1000e on 8 core Intel
>    No RFS or RPS		104K tps at 30% CPU
>    No RFS (best RPS config):    290K tps at 63% CPU
>    RFS				303K tps at 61% CPU
>=20
> RPC test		tps	CPU%	50/90/99% usec latency	StdDev
>    No RFS or RPS	103K	48%	757/900/3185		4472.35
>    RPS only:		174K	73%	415/993/2468		491.66
>    RFS			223K	73%	379/651/1382		315.61
>   =20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index b5670ab..ea6ebca 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -543,14 +543,72 @@ struct rps_map {
>  };
>  #define RPS_MAP_SIZE(_num) (sizeof(struct rps_map) + (_num * sizeof(=
u16)))
> =20
> +/*
> + * The rps_dev_flow structure contains the mapping of a flow to a CP=
U and the
> + * tail pointer for that CPU's input queue at the time of last enque=
ue.
> + */
> +struct rps_dev_flow {
> +	u16 cpu;

please use a 32bit quantity, it is faster on many arches, and avoid a
16bits hole.

> +	unsigned int last_qtail;
> +};
> +
> +/*
> + * The rps_dev_flow_table structure contains a table of flow mapping=
s.
> + */
> +struct rps_dev_flow_table {
> +	unsigned int mask;
> +	struct rcu_head rcu;
> +	struct work_struct free_work;
> +	struct rps_dev_flow flows[0];
> +};
> +#define RPS_DEV_FLOW_TABLE_SIZE(_num) (sizeof(struct rps_dev_flow_ta=
ble) + \
> +    (_num * sizeof(struct rps_dev_flow)))
> +
> +/*
> + * The rps_sock_flow_table contains mappings of flows to the last CP=
U
> + * on which they were processed by the application (set in recvmsg).
> + */
> +struct rps_sock_flow_table {
> +	unsigned int mask;
> +	u16 *ents;
> +};
> +
> +#define RPS_NO_CPU NR_CPUS

using 0xFFFF might be faster

> +
> +static inline void rps_set_sock_flow(struct rps_sock_flow_table *tab=
le,
> +				     u32 hash, int cpu)
> +{
> +	if (table->ents && hash) {
> +		unsigned int index =3D hash & table->mask;
> +
> +		if (table->ents[index] !=3D cpu)
> +			table->ents[index] =3D cpu;
> +	}
> +}
> +
> +static inline void rps_record_sock_flow(struct rps_sock_flow_table *=
table,
> +					u32 hash)
> +{

Hmm, so rps_record_sock_flow() is always called from non preemptable
contextes ?

> +	rps_set_sock_flow(table, hash, smp_processor_id());
> +}
> +
> +static inline void rps_reset_sock_flow(struct rps_sock_flow_table *t=
able,
> +				       u32 hash)
> +{
> +	rps_set_sock_flow(table, hash, RPS_NO_CPU);
> +}
> +

Could you respin your patch against latest net-next-2.6, because it
doesnt apply after latest RPS commit from Changli.

Thanks !


