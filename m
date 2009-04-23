From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: about latencies
Date: Fri, 24 Apr 2009 01:07:06 +0200
Message-ID: <49F0F49A.1050609@cosmosbay.com>
References: <49F0E579.5030200@cosmosbay.com> <alpine.WNT.2.00.0904231520300.5352@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49464 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbZDWXH7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 19:07:59 -0400
In-Reply-To: <alpine.WNT.2.00.0904231520300.5352@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse a =E9crit :
> On Thu, 23 Apr 2009, Eric Dumazet wrote:
>> Some time later, NIC tells us TX was completed.
>> We free skb().
>>  1) dst_release()   (might dirty one cache line, that was increased =
by application cpu)
>>
>>  2) and more important... since UDP is now doing memory accounting..=
=2E
>>
>> sock_wfree()
>>   -> sock_def_write_space()
>>      -> _read_lock()
>>      -> __wake_up_sync_key()
>>   and lot of functions calls to wakeup the task, for nothing since i=
t
>> will just schedule again. Lot of cache lines dirtied...
>>
>>
>> We could improve this.
>>
>> 1) dst_release at xmit time, should save a cache line ping-pong on g=
eneral case
>> 2) sock_wfree() in advance, done at transmit time (generally the thr=
ead/cpu doing the send)
>=20
> how much does the effect socket accounting?  will the app then fill t=
he=20
> hardware tx ring all the time because there is no application throttl=
ing=20
> due to delayed kfree?

tx ring is limited to 256 or 512 or 1024 elements, but yes this might
defeat udp mem accounting on sending side, unless using qdiscs...

Alternative would be to seperate sleepers (waiting for input or output)
to avoid extra wakeups. I am pretty sure every network dev always wante=
d
to do that eventually :)

>=20
>> 3) changing bnx2_poll_work() to first call bnx2_rx_int(), then bnx2_=
tx_int() to consume tx.
>=20
> at least all of the intel drivers that have a single vector (function=
)=20
> handling interrupts, always call tx clean first so that any tx buffer=
s are=20
> free to be used immediately because the NAPI calls can generate tx tr=
affic=20
> (acks in the case of tcp and full routed packet transmits in the case=
 of=20
> forwarding)
>=20
> of course in the case of MSI-X (igb/ixgbe) most times the tx cleanup =
is=20
> handled independently (completely async) of rx.
>=20
>=20
>> What do you think ?
>=20
> you're running a latency sensitive test on a NOHZ kernel below, isn't=
 that=20
> a bad idea?

I tried worst case to match (eventually) Christoph data.
I usually am not using NOHZ, but what about linux distros ?

>=20
> OT - the amount of timer code (*ns*) and spinlocks noted below seems=20
> generally disturbing.
>=20
>> function ftrace of one "tx completion, extra wakeup, incoming udp, o=
utgoing udp"
>=20
> thanks for posting this, very interesting to see the flow of calls.  =
A ton=20
> of work is done to handle just two packets.

yes, it costs about 30000 cycles...

> =20
> might also be interesting to see what happens (how much shorter the c=
all=20
> chain is) on a UP kernel.

Here is a preliminary patch that does this, not for inclusion, testing =
only and
comments welcomed.

It saves more than 2 us on preliminary tests (! NOHZ kernel)
and CPU0 handling both IRQ and application.

# udpping -n 10000 -l 40 192.168.20.110
udp ping 0.0.0.0:9001 -> 192.168.20.110:9000 10000 samples ....
742759.61us (70.86us/74.28us/480.32us)

BTW, UDP mem accounting was added in 2.6.25.

[RFC] bnx2: Optimizations

1) dst_release() at xmit time, should save a cache line ping-pong on ge=
neral case,
   where TX completion is done by another cpu.

2) sock_wfree() in advance, done at transmit time (generally the thread=
/cpu doing the send),
   instead doing it at completion time, by another cpu.

This reduces latency of UDP receive/send by 2 us at least

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d478391..1078c85 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6168,7 +6168,13 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_=
device *dev)
=20
 	tx_buf =3D &txr->tx_buf_ring[ring_prod];
 	tx_buf->skb =3D skb;
-
+	dst_release(skb->dst);
+	skb->dst =3D NULL;
+	if (skb->destructor =3D=3D sock_wfree) {
+		sock_wfree(skb);
+		skb->destructor =3D NULL;
+	}
+=09
 	txbd =3D &txr->tx_desc_ring[ring_prod];
=20
 	txbd->tx_bd_haddr_hi =3D (u64) mapping >> 32;

