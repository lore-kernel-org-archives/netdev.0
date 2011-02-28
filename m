From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Mon, 28 Feb 2011 17:22:54 +0100
Message-ID: <1298910174.2941.585.camel@edumazet-laptop>
References: <20110225.112019.48513284.davem@davemloft.net>
	 <20110226005718.GA19889@gondor.apana.org.au>
	 <20110227110205.GE9763@canuck.infradead.org>
	 <20110227110614.GA6246@gondor.apana.org.au>
	 <20110228113659.GA20726@gondor.apana.org.au>
	 <20110228141322.GF9763@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34429 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754522Ab1B1QXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 11:23:05 -0500
Received: by bwz15 with SMTP id 15so3790368bwz.19
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 08:23:03 -0800 (PST)
In-Reply-To: <20110228141322.GF9763@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 09:13 -0500, Thomas Graf a =C3=A9c=
rit :
> On Mon, Feb 28, 2011 at 07:36:59PM +0800, Herbert Xu wrote:
> > But please do test them heavily, especially if you have an AMD
> > NUMA machine as that's where scalability problems really show
> > up.  Intel tends to be a lot more forgiving.  My last AMD machine
> > blew up years ago :)
>=20
> This is just a preliminary test result and not 100% reliable
> because half through the testing the machine reported memory
> issues and disabled a DIMM before booting the tested kernels.
>=20
> Nevertheless, bind 9.7.3:
>=20
> 2.6.38-rc5+: 62kqps
> 2.6.38-rc5+ w/ Herbert's patch: 442kqps
>=20
> This is on a 2 NUMA Intel Xeon X5560 @ 2.80GHz with 16 cores
>=20
> Again, this number is not 100% reliably but clearly shows that
> the concept of the patch is working very well.
>=20
> Will test Herbert's patch on the machine that did 650kqps with
> SO_REUSEPORT and also on some AMD machines.
> --

I suspect your queryperf input file hits many zones ?

With a single zone, my machine is able to give 250kps : most of the tim=
e
is consumed in bind code, dealing with rwlocks and false sharing
things...

(bind-9.7.2-P3)
Using two remote machines to perform queries, on bnx2x adapter, RSS
enabled : two cpus receive UDP frames for the same socket, so we also
hit false sharing in kernel receive path.


-----------------------------------------------------------------------=
----------------------------------------------------------
   PerfTop:  558863 irqs/sec  kernel:40.8%  exact:  0.0% [1000Hz cpu-cl=
ock-msecs],  (all, 16 CPUs)
-----------------------------------------------------------------------=
----------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ______________=
________________________

           137175.00 12.4% acpi_idle_enter_bm            [kernel.kallsy=
ms]                    =20
            63784.00  5.8% _raw_spin_unlock_irqrestore   [kernel.kallsy=
ms]                    =20
            54140.00  4.9% isc_rwlock_lock               /opt/src/bind-=
9.7.2-P3/bin/named/named
            32682.00  2.9% isc_rwlock_unlock             /opt/src/bind-=
9.7.2-P3/bin/named/named
            21823.00  2.0% dns_rbt_findnode              /opt/src/bind-=
9.7.2-P3/bin/named/named
            20306.00  1.8% __ticket_spin_lock            [kernel.kallsy=
ms]                    =20
            16881.00  1.5% finish_task_switch            [kernel.kallsy=
ms]                    =20
            15335.00  1.4% zone_find                     /opt/src/bind-=
9.7.2-P3/bin/named/named
            14082.00  1.3% decrement_reference           /opt/src/bind-=
9.7.2-P3/bin/named/named
            14064.00  1.3% __pthread_mutex_lock_internal /lib/tls/libpt=
hread-2.3.4.so         =20
            13519.00  1.2% isc_stats_increment           /opt/src/bind-=
9.7.2-P3/bin/named/named
            13027.00  1.2% __GI_memcpy                   /lib/tls/libc-=
2.3.4.so               =20
            12516.00  1.1% dns_name_concatenate          /opt/src/bind-=
9.7.2-P3/bin/named/named
            12499.00  1.1% currentversion                /opt/src/bind-=
9.7.2-P3/bin/named/named
            11412.00  1.0% dns_name_fullcompare          /opt/src/bind-=
9.7.2-P3/bin/named/named
            10814.00  1.0% new_reference.clone.6         /opt/src/bind-=
9.7.2-P3/bin/named/named
            10580.00  1.0% attach                        /opt/src/bind-=
9.7.2-P3/bin/named/named
             9805.00  0.9% zone_zonecut_callback         /opt/src/bind-=
9.7.2-P3/bin/named/named


