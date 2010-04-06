From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rfs: Receive Flow Steering
Date: Tue, 06 Apr 2010 15:04:56 +0200
Message-ID: <1270559096.2081.35.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004052248390.29212@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.com, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:53547 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754567Ab0DFNFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 09:05:08 -0400
Received: by bwz1 with SMTP id 1so3580181bwz.21
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 06:05:06 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1004052248390.29212@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 avril 2010 =C3=A0 22:56 -0700, Tom Herbert a =C3=A9crit :
> Version 2:
> - added a u16 filler to pad rps_dev_flow structure
> - define RPS_NO_CPU as 0xffff
> - add inet_rps_save_rxhash helper function to copy skb's rxhash into =
inet_sk
> - add a "voidflow" which can be used get_rps_cpu does not return a fl=
ow (avoids some conditionals)
> - use raw_smp_processor_id in rps_record_sock_flow, this is no requir=
ement to pr
> event preemption
> ---
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
> ---

Running on a preprod machine here, seems fine.

Some questions :

1) The need to add "rps_flow_entries=3Dxxx" at boot time is problematic=
=2E
   Maybe we can allow it being dynamic (and use vmalloc() instead of
alloc_large_system_hash())

2) inet_rps_save_rxhash(sk, skb->rxhash);

	It should have a check to make sure some part of the stack doesnt feed
many different rxhash for a given socket (Make sure we dont pollute flo=
w
table with pseudo random values)

3) UDP connected sockets dont benefit of RFS currently
   (Not sure many apps use connected UDP sockets, I do have some of the=
m
in house)

I am trying following code for IPV4 only :

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7af756d..5c2d37a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1216,6 +1216,7 @@ int udp_disconnect(struct sock *sk, int flags)
 	sk->sk_state =3D TCP_CLOSE;
 	inet->inet_daddr =3D 0;
 	inet->inet_dport =3D 0;
+	inet_rps_save_rxhash(sk, 0);
 	sk->sk_bound_dev_if =3D 0;
 	if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
 		inet_reset_saddr(sk);
@@ -1257,8 +1258,12 @@ EXPORT_SYMBOL(udp_lib_unhash);
=20
 static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
-	int rc =3D sock_queue_rcv_skb(sk, skb);
+	int rc;
+
+	if (inet_sk(sk)->inet_daddr)
+		inet_rps_save_rxhash(sk, skb->rxhash);
=20
+	rc =3D sock_queue_rcv_skb(sk, skb);
 	if (rc < 0) {
 		int is_udplite =3D IS_UDPLITE(sk);
=20


