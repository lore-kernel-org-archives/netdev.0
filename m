From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] rfs: Receive Flow Steering
Date: Fri, 09 Apr 2010 09:17:37 +0200
Message-ID: <1270797457.2623.19.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004082331250.19688@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:55734 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab0DIHRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 03:17:42 -0400
Received: by bwz1 with SMTP id 1so2306860bwz.21
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 00:17:40 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1004082331250.19688@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 avril 2010 =C3=A0 23:33 -0700, Tom Herbert a =C3=A9crit :
> Version 3 of RFS:
> - Use sysctl instead using kernel init parameter and alloc_large_syst=
em_hash
> - Created inline function for "queue->input_queue_head++" to reduce n=
umber of #ifdef's
> - Added RFS support for connected UDP sockets (thanks Eric!)
> ---
> This patch implements receive flow steering (RFS).  RFS steers receiv=
ed packets for layer 3 and 4 processing to the CPU where the applicatio=
n for the corresponding flow is running.  RFS is an extension of Receiv=
e Packet Steering (RPS).
>=20
> The basic idea of RFS is that when an application calls recvmsg (or s=
endmsg) the application's running CPU is stored in a hash table that is=
 indexed by the connection's rxhash which is stored in the socket struc=
ture.  The rxhash is passed in skb's received on the connection from ne=
tif_receive_skb.  For each received packet, the associated rxhash is us=
ed to look up the CPU in the hash table, if a valid CPU is set then the=
 packet is steered to that CPU using the RPS mechanisms.
>=20
> The convolution of the simple approach is that it would potentially a=
llow OOO packets.  If threads are thrashing around CPUs or multiple thr=
eads are trying to read from the same sockets, a quickly changing CPU v=
alue in the hash table could cause rampant OOO packets-- we consider th=
is a non-starter.
>=20
> To avoid OOO packets, this solution implements two types of hash tabl=
es: rps_sock_flow_table and rps_dev_flow_table.
>=20
> rps_sock_table is a global hash table.  Each entry is just a CPU numb=
er and it is populated in recvmsg and sendmsg as described above.  This=
 table contains the "desired" CPUs for flows.
>=20
> rps_dev_flow_table is specific to each device queue.  Each entry cont=
ains a CPU and a tail queue counter.  The CPU is the "current" CPU for =
a matching flow.  The tail queue counter holds the value of a tail queu=
e counter for the associated CPU's backlog queue at the time of last en=
queue for a flow matching the entry.
>=20
> Each backlog queue has a queue head counter which is incremented on d=
equeue, and so a queue tail counter is computed as queue head count + q=
ueue length.  When a packet is enqueued on a backlog queue, the current=
 value of the queue tail counter is saved in the hash entry of the rps_=
dev_flow_table.
>=20
> And now the trick: when selecting the CPU for RPS (get_rps_cpu) the r=
ps_sock_flow table and the rps_dev_flow table for the RX queue are cons=
ulted.  When the desired CPU for the flow (found in the rps_sock_flow t=
able) does not match the current CPU (found in the rps_dev_flow table),=
 the current CPU is changed to the desired CPU if one of the following =
is true:
>=20
> - The current CPU is unset (equal to NR_CPUS)
> - Current CPU is offline
> - The current CPU's queue head counter >=3D queue tail counter in the=
 rps_dev_flow table.  This checks if the queue tail has advanced beyond=
 the last packet that was enqueued using this table entry.  This guaran=
tees that all packets queued using this entry have been dequeued, thus =
preserving in order delivery.
>=20
> Making each queue have its own rps_dev_flow table has two advantages:=
 1) the tail queue counters will be written on each receive, so keeping=
 the table local to interrupting CPU s good for locality.  2) this allo=
ws lockless access to the table-- the CPU number and queue tail counter=
 need to be accessed together under mutual exclusion from netif_receive=
_skb, we assume that this is only called from device napi_poll which is=
 non-reentrant.
>=20
> This patch implements RFS for TCP and connected UDP sockets.  It shou=
ld be usable for other flow oriented protocols.
>=20
> There are two configuration parameters for RFS.  The "rps_flow_entrie=
s" kernel init parameter sets the number of entries in the rps_sock_flo=
w_table, the per rxqueue sysfs entry "rps_flow_cnt" contains the number=
 of entries in the rps_dev_flow table for the rxqueue.  Both are rounde=
d to power of two.
>=20
> The obvious benefit of RFS (over just RPS) is that it achieves CPU lo=
cality between the receive processing for a flow and the applications p=
rocessing; this can result in increased performance (higher pps, lower =
latency).
>=20
> The benefits of RFS are dependent on cache hierarchy, application loa=
d, and other factors.  On simple benchmarks, we don't necessarily see i=
mprovement and sometimes see degradation.  However, for more complex be=
nchmarks and for applications where cache pressure is much higher this =
technique seems to perform very well.
>=20
> Below are some benchmark results which show the potential benfit of t=
his patch.  The netperf test has 500 instances of netperf TCP_RR test w=
ith 1 byte req. and resp.  The RPC test is an request/response test sim=
ilar in structure to netperf RR test ith 100 threads on each host, but =
does more work in userspace that netperf.
>=20
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

Changelog messages should be formatted with small lines (70 char limits=
)

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index d1a21b5..573e775 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -530,14 +530,77 @@ struct rps_map {
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
> +	u16 fill;
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
> +	u16 ents[0];
> +};
> +#define	RPS_SOCK_FLOW_TABLE_SIZE(_num) (sizeof(struct rps_sock_flow_=
table) + \
> +    (_num * sizeof(u16)))
> +
> +extern int rps_sock_flow_sysctl(ctl_table *table, int write,
> +				void __user *buffer, size_t *lenp,
> +				loff_t *ppos);
> +
> +#define RPS_NO_CPU 0xffff
> +
> +static inline void rps_record_sock_flow(struct rps_sock_flow_table *=
table,
> +					u32 hash)
> +{
> +	if (table && hash) {
> +		unsigned int cpu, index =3D hash & table->mask;
> +
> +		/* We only give a hint, preemption can change cpu under us */
> +		cpu =3D raw_smp_processor_id();
> +
> +		if (table->ents[index] !=3D cpu)
> +			table->ents[index] =3D cpu;
> +	}
> +}
> +
> +static inline void rps_reset_sock_flow(struct rps_sock_flow_table *t=
able,
> +				       u32 hash)
> +{
> +	if (table && hash)
> +		table->ents[hash & table->mask] =3D RPS_NO_CPU;
> +}
> +
> +extern struct rps_sock_flow_table *rps_sock_flow_table;
> +
>  /* This structure contains an instance of an RX queue. */
>  struct netdev_rx_queue {
>  	struct rps_map *rps_map;
> +	struct rps_dev_flow_table *rps_flow_table;
>  	struct kobject kobj;
>  	struct netdev_rx_queue *first;
>  	atomic_t count;
>  } ____cacheline_aligned_in_smp;
> -#endif
> +#endif /* CONFIG_RPS */
> =20
>  /*
>   * This structure defines the management hooks for network devices.
> @@ -1331,13 +1394,21 @@ struct softnet_data {
>  	struct sk_buff		*completion_queue;
> =20
>  	/* Elements below can be accessed between CPUs for RPS */
> -#ifdef CONFIG_SMP
> +#ifdef CONFIG_RPS
>  	struct call_single_data	csd ____cacheline_aligned_in_smp;
> +	unsigned int		input_queue_head;
>  #endif
>  	struct sk_buff_head	input_pkt_queue;
>  	struct napi_struct	backlog;
>  };
> =20
> +static inline void incr_input_queue_head(struct softnet_data *queue)
> +{
> +#ifdef CONFIG_RPS
> +	queue->input_queue_head++;
> +#endif
> +}
> +
>  DECLARE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
> =20
>  #define HAVE_NETIF_QUEUE
> diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
> index 83fd344..b487bc1 100644
> --- a/include/net/inet_sock.h
> +++ b/include/net/inet_sock.h
> @@ -21,6 +21,7 @@
>  #include <linux/string.h>
>  #include <linux/types.h>
>  #include <linux/jhash.h>
> +#include <linux/netdevice.h>
> =20
>  #include <net/flow.h>
>  #include <net/sock.h>
> @@ -101,6 +102,7 @@ struct rtable;
>   * @uc_ttl - Unicast TTL
>   * @inet_sport - Source port
>   * @inet_id - ID counter for DF pkts
> + * @rxhash - flow hash received from netif layer
>   * @tos - TOS
>   * @mc_ttl - Multicasting TTL
>   * @is_icsk - is this an inet_connection_sock?
> @@ -124,6 +126,9 @@ struct inet_sock {
>  	__u16			cmsg_flags;
>  	__be16			inet_sport;
>  	__u16			inet_id;
> +#ifdef CONFIG_RPS
> +	__u32			rxhash;
> +#endif

I am a bit worried, because dirtying this cache line might hurt non RPS
setups (if network interrupts are balanced to all cpus)

Best place would be to put rxhash close to sk_refcnt (because we dirty
it to get a reference on rcu sk lookups)

I believe we have a 32bits hole on 64bit arches for this :)


While testint latest net-nex-2.6 on my nehalem machine, I got a crash
(in RPS I am afraid...)

I am going to correct this crash before testing RFS and let you know th=
e
results.

Thanks


