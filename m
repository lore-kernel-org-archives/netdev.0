From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Tue, 16 Mar 2010 22:00:27 +0100
Message-ID: <1268773227.2932.34.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1003121210050.25665@pokey.mtv.corp.google.com>
	 <1268429319.2947.10.camel@edumazet-laptop>
	 <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	 <4B9FC7F1.5010507@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:54764 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755408Ab0CPVAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 17:00:35 -0400
Received: by bwz3 with SMTP id 3so453471bwz.29
        for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 14:00:33 -0700 (PDT)
In-Reply-To: <4B9FC7F1.5010507@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 mars 2010 =C3=A0 11:03 -0700, Tom Herbert a =C3=A9crit :
> Tom Herbert wrote:

>=20
> This patch implements software receive side packet steering (RPS).  R=
PS
> distributes the load of received packet processing across multiple CP=
Us.
>=20
> Problem statement: Protocol processing done in the NAPI context for r=
eceived
> packets is serialized per device queue and becomes a bottleneck under=
 high
> packet load.  This substantially limits pps that can be achieved on a=
 single
> queue NIC and provides no scaling with multiple cores.
>=20
> This solution queues packets early on in the receive path on the back=
log queues
> of other CPUs.   This allows protocol processing (e.g. IP and TCP) to=
 be
> performed on packets in parallel.   For each device (or each receive =
queue in
> a multi-queue device) a mask of CPUs is set to indicate the CPUs that=
 can
> process packets. A CPU is selected on a per packet basis by hashing c=
ontents
> of the packet header (e.g. the TCP or UDP 4-tuple) and using the resu=
lt to index
> into the CPU mask.  The IPI mechanism is used to raise networking rec=
eive
> softirqs between CPUs.  This effectively emulates in software what a =
multi-queue
> NIC can provide, but is generic requiring no device support.
>=20
> Many devices now provide a hash over the 4-tuple on a per packet basi=
s
> (e.g. the Toeplitz hash).  This patch allow drivers to set the HW rep=
orted hash
> in an skb field, and that value in turn is used to index into the RPS=
 maps.
> Using the HW generated hash can avoid cache misses on the packet when
> steering it to a remote CPU.
>=20
> The CPU mask is set on a per device and per queue basis in the sysfs =
variable
> /sys/class/net/<device>/queues/rx-<n>/rps_cpus.  This is a set of can=
onical
> bit maps for receive queues in the device (numbered by <n>).  If a de=
vice
> does not support multi-queue, a single variable is used for the devic=
e (rx-0).
>=20
> Generally, we have found this technique increases pps capabilities of=
 a single
> queue device with good CPU utilization.  Optimal settings for the CPU=
 mask
> seem to depend on architectures and cache hierarcy.  Below are some r=
esults
> running 500 instances of netperf TCP_RR test with 1 byte req. and res=
p.
> Results show cumulative transaction rate and system CPU utilization.
>=20
> e1000e on 8 core Intel
>    Without RPS: 108K tps at 33% CPU
>    With RPS:    311K tps at 64% CPU
>=20
> forcedeth on 16 core AMD
>    Without RPS: 156K tps at 15% CPU
>    With RPS:    404K tps at 49% CPU
>   =20
> bnx2x on 16 core AMD
>    Without RPS  567K tps at 61% CPU (4 HW RX queues)
>    Without RPS  738K tps at 96% CPU (8 HW RX queues)
>    With RPS:    854K tps at 76% CPU (4 HW RX queues)
>=20
> Caveats:
> - The benefits of this patch are dependent on architecture and cache =
hierarchy.
> Tuning the masks to get best performance is probably necessary.
> - This patch adds overhead in the path for processing a single packet=
=2E  In
> a lightly loaded server this overhead may eliminate the advantages of
> increased parallelism, and possibly cause some relative performance d=
egradation.
> We have found that masks that are cache aware (share same caches with
> the interrupting CPU) mitigate much of this.
> - The RPS masks can be changed dynamically, however whenever the mask=
 is changed
> this introduces the possibility of generating out of order packets.  =
It's
> probably best not change the masks too frequently.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
>=20

Well, I tested this on my dev machine, with a vlan over bonding setup,
tg3 and bnx2 drivers (mono queue), and all is good. UDP bench not
anymore using 100% of one cpu and dropping frames.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Herbert, this gives a very good fanout of network load on cpus,
this is a huge improvement, I cannot wait 2.6.35 :)


