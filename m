From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Fri, 15 Jan 2010 07:27:12 +0100
Message-ID: <4B500AC0.4060909@gmail.com>
References: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48151 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997Ab0AOG1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 01:27:21 -0500
In-Reply-To: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/01/2010 22:56, Tom Herbert a =E9crit :
> This patch implements software receive side packet steering (RPS).  R=
PS
> distributes the load of received packet processing across multiple CP=
Us.
>=20
> Problem statement: Protocol processing done in the NAPI context for
> received
> packets is serialized per device queue and becomes a bottleneck under=
 high
> packet load.  This substantially limits pps that can be achieved on a
> single
> queue NIC and provides no scaling with multiple cores.
>=20
> This solution queues packets early on in the receive path on the back=
log
> queues
> of other CPUs.   This allows protocol processing (e.g. IP and TCP) to=
 be
> performed on packets in parallel.   For each device (or NAPI instance=
 for
> a multi-queue device) a mask of CPUs is set to indicate the CPUs that=
 can
> process packets for the device. A CPU is selected on a per packet bas=
is by
> hashing contents of the packet header (the TCP or UDP 4-tuple) and us=
ing
> the
> result to index into the CPU mask.  The IPI mechanism is used to rais=
e
> networking receive softirqs between CPUs.  This effectively emulates =
in
> software what a multi-queue NIC can provide, but is generic requiring=
 no
> device
> support.
>=20
> Many devices now provide a hash over the 4-tuple on a per packet basi=
s
> (Toeplitz is popular).  This patch allow drivers to set the HW report=
ed
> hash
> in an skb field, and that value in turn is used to index into the RPS=
 maps.
> Using the HW generated hash can avoid cache misses on the packet when
> steering the packet to a remote CPU.
>=20
> The CPU masks is set on a per device basis in the sysfs variable
> /sys/class/net/<device>/rps_cpus.  This is a set of canonical bit map=
s for
> each NAPI nstance of the device.  For example:
>=20
> echo "0b 0b0 0b00 0b000" > /sys/class/net/eth0/rps_cpus
>=20
> would set maps for four NAPI instances on eth0.
>=20
> Generally, we have found this technique increases pps capabilities of=
 a
> single
> queue device with good CPU utilization.  Optimal settings for the CPU=
 mask
> seems to depend on architectures and cache hierarcy.  Below are some
> results
> running 500 instances of netperf TCP_RR test with 1 byte req. and res=
p.
> Results show cumulative transaction rate and system CPU utilization.
>=20
> e1000e on 8 core Intel
>    Without RPS: 90K tps at 33% CPU
>    With RPS:    239K tps at 60% CPU
>=20
> foredeth on 16 core AMD
>    Without RPS: 103K tps at 15% CPU
>    With RPS:    285K tps at 49% CPU
>=20
> Caveats:
> - The benefits of this patch are dependent on architecture and cache
> hierarchy.
> Tuning the masks to get best performance is probably necessary.
> - This patch adds overhead in the path for processing a single packet=
=2E  In
> a lightly loaded server this overhead may eliminate the advantages of
> increased parallelism, and possibly cause some relative performance
> degradation.
> We have found that RPS masks that are cache aware (share same caches =
with
> the interrupting CPU) mitigate much of this.
> - The RPS masks can be changed dynamically, however whenever the mask=
 is
> changed
> this introduces the possbility of generating out of order packets.  I=
t's
> probably best not change the masks too frequently.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>


>=20
> +/*
> + * net_rps_action sends any pending IPI's for rps.  This is only cal=
led
> from
> + * softirq and interrupts must be enabled.
> + */
> +static void net_rps_action(void)
> +{
> +    int cpu;
> +
> +    /* Send pending IPI's to kick RPS processing on remote cpus. */
> +    for_each_cpu_mask_nr(cpu, __get_cpu_var(rps_remote_softirq_cpus)=
) {
> +        struct softnet_data *queue =3D &per_cpu(softnet_data, cpu);
> +        cpu_clear(cpu, __get_cpu_var(rps_remote_softirq_cpus));
> +        if (cpu_online(cpu))
> +            __smp_call_function_single(cpu, &queue->csd, 0);
> +    }
> +}
>=20

So we have this last bit that might have a reentrance problem...

Do you plan a followup patch to copy the rps_remote_softirq_cpus in a l=
ocal variable
before enabling interrupts and calling net_rps_action() ?

	cpumask_t rps_copy;

	copy and clean rps_remote_softirq_cpus
	local_irq_enable();
	net_rps_action(&rps_copy);=20
