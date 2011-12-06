From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Tue, 06 Dec 2011 14:24:38 +0100
Message-ID: <1323177878.2448.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
	 <1323172634.23681.73.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:34138 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933196Ab1LFNYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 08:24:43 -0500
Received: by vcbfk14 with SMTP id fk14so4846893vcb.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 05:24:42 -0800 (PST)
In-Reply-To: <1323172634.23681.73.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 d=C3=A9cembre 2011 =C3=A0 11:57 +0000, Ian Campbell a =C3=A9=
crit :
> On Wed, 2011-11-09 at 15:01 +0000, Ian Campbell wrote:
> >       * split linear data allocation and shinfo allocation into two=
=2E I
> >         suspect this will have its own performance implications? On=
 the
> >         positive side skb_shared_info could come from its own fixed=
 size
> >         pool/cache which might have some benefits
>=20
> I played with this to see how it would look. Illustrative patch below=
=2E=20
>=20
> I figure that lots of small frames is the interesting workload for a
> change such as this but I don't know if iperf is necessarily the best
> benchmark for measuring that.
> Before changing things I got:
>         iperf -c qarun -m -t 60 -u -b 10000M -l 64
>         ------------------------------------------------------------
>         Client connecting to qarun, UDP port 5001
>         Sending 64 byte datagrams
>         UDP buffer size:   224 KByte (default)
>         ------------------------------------------------------------
>         [  3] local 10.80.225.63 port 45857 connected with 10.80.224.=
22 port 5001
>         [ ID] Interval       Transfer     Bandwidth
>         [  3]  0.0-60.0 sec    844 MBytes    118 Mbits/sec
>         [  3] Sent 13820376 datagrams
>         [  3] Server Report:
>         [  3]  0.0-60.0 sec    844 MBytes    118 Mbits/sec  0.005 ms =
   0/13820375 (0%)
>         [  3]  0.0-60.0 sec  1 datagrams received out-of-order
> whereas with the patch:
>         # iperf -c qarun -m -t 60 -u -b 10000M -l 64
>         ------------------------------------------------------------
>         Client connecting to qarun, UDP port 5001
>         Sending 64 byte datagrams
>         UDP buffer size:   224 KByte (default)
>         ------------------------------------------------------------
>         [  3] local 10.80.225.63 port 42504 connected with 10.80.224.=
22 port 5001
>         [ ID] Interval       Transfer     Bandwidth
>         [  3]  0.0-60.0 sec    833 MBytes    116 Mbits/sec
>         [  3] Sent 13645857 datagrams
>         [  3] Server Report:
>         [  3]  0.0-60.0 sec    833 MBytes    116 Mbits/sec  0.005 ms =
   0/13645856 (0%)
>         [  3]  0.0-60.0 sec  1 datagrams received out-of-order
>=20
> With 1200 byte datagrams I get basically identical throughput.
>=20
> (nb: none of the skb destructor stuff was present in either case)

Sorry, but the real problem is that if skb producer and consumer are no=
t
on same CPU, each skb will now hit SLUB slowpath three times instead of
two.

Some workloads are : One cpu fully handling IRQ from device, dispatchin=
g
skbs to consumers on other cpus.

Plus skb->truesize is wrong after your patch.
Not sure if cloning is correct either...

Anyway, do we _really_ need 16 frags per skb, I dont know....

This gives problems when/if skb must be linearized and we hit
PAGE_ALLOC_COSTLY_ORDER

Alternatively, we could use order-1 or order-2 pages on x86 to get
8192/16384 bytes frags. (fallback to order-0 pages in case of allocatio=
n
failures)
