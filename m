From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/3] Gianfar byte queue limits
Date: Sun, 18 Mar 2012 13:30:34 -0700
Message-ID: <1332102634.3647.1.camel@edumazet-laptop>
References: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, therbert@google.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:62856 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753245Ab2CRUaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 16:30:39 -0400
Received: by dajr28 with SMTP id r28so8869308daj.19
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 13:30:39 -0700 (PDT)
In-Reply-To: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 18 mars 2012 =C3=A0 12:56 -0400, Paul Gortmaker a =C3=A9cri=
t :
> The BQL support here is unchanged from what I posted earlier as an
> RFC[1] -- with the exception of the fact that I'm now happier with
> the runtime testing vs. the simple "hey it boots" that I'd done
> for the RFC.  Plus I added a couple trivial cleanup patches.
>=20
> For testing, I made a couple spiders homeless by reviving an ancient
> 10baseT hub.  I connected an sbc8349 into that, and connected the
> yellowing hub into a GigE 16port, which was also connected to the
> recipient x86 box.
>=20
> Gianfar saw the interface as follows:
>=20
> fsl-gianfar e0024000.ethernet: eth0: mac: 00:a0:1e:a0:26:5a
> fsl-gianfar e0024000.ethernet: eth0: Running with NAPI enabled
> fsl-gianfar e0024000.ethernet: eth0: RX BD ring size for Q[0]: 256
> fsl-gianfar e0024000.ethernet: eth0: TX BD ring size for Q[0]: 256
> PHY: mdio@e0024520:19 - Link is Up - 10/Half
>=20
> With the sbc8349 being diskless, I simply used an scp of /proc/kcore
> to the connected x86 box as a rudimentary Tx heavy workload.
>=20
> BQL data was collected by changing into the dir:
>=20
>   /sys/devices/e0000000.soc8349/e0024000.ethernet/net/eth0/queues/tx-=
0/byte_queue_limits
>=20
> and running the following:
>=20
>   for i in * ; do echo -n $i": " ; cat $i ; done
>=20
> Running with the defaults, data like below was typical:
>=20
> hold_time: 1000
> inflight: 4542
> limit: 3456
> limit_max: 1879048192
> limit_min: 0
>=20
> hold_time: 1000
> inflight: 4542
> limit: 3378
> limit_max: 1879048192
> limit_min: 0
>=20
> i.e. 2 or 3 MTU sized packets in flight and the limit value lying
> somewhere between those two values.
>=20
> The interesting thing is that the interactive speed reported by scp
> seemed somewhat erratic, ranging from ~450 to ~700kB/s. (This was
> the only traffic on the old junk - perhaps expected oscillations such
> as those seen in isolated ARED tests?)  Average speed for 100M was:
>=20
> 104857600 bytes (105 MB) copied, 172.616 s, 607 kB/s
>=20

Still half duplex, or full duplex ?

Limiting to one packet on half duplex might avoid collisions :)

> Anyway, back to BQL testing; setting the values as follows:
>=20
> hold_time: 1000
> inflight: 1514
> limit: 1400
> limit_max: 1400
> limit_min: 1000
>=20
> had the effect of serializing the interface to a single packet, and
> the crusty old hub seemed much happier with this arrangement, keeping
> a constant speed and achieving the following on a 100MB Tx block:
>=20
> 104857600 bytes (105 MB) copied, 112.52 s, 932 kB/s
>=20
> It might be interesting to know more about why the defaults suffer
> the slowdown, but the hub could possibly be ancient spec violating
> trash.  Definitely something that nobody would ever use for anything
> today. (aside from contrived tests like this)
>=20
> But it did give me an example of where I could see the effects of
> changing the BQL settings, and I'm reasonably confident they are
> working as expected.
>=20

Seems pretty good to me !
