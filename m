From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Wed, 7 Dec 2011 13:35:29 +0000
Message-ID: <1323264929.23681.178.camel@zakaz.uk.xensource.com>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
	 <1323172634.23681.73.camel@zakaz.uk.xensource.com>
	 <1323177878.2448.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:64314 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390Ab1LGNfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 08:35:32 -0500
In-Reply-To: <1323177878.2448.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-12-06 at 13:24 +0000, Eric Dumazet wrote:
> Le mardi 06 d=C3=A9cembre 2011 =C3=A0 11:57 +0000, Ian Campbell a =C3=
=A9crit :
> > On Wed, 2011-11-09 at 15:01 +0000, Ian Campbell wrote:
> > >       * split linear data allocation and shinfo allocation into t=
wo. I
> > >         suspect this will have its own performance implications? =
On the
> > >         positive side skb_shared_info could come from its own fix=
ed size
> > >         pool/cache which might have some benefits
> >=20
> > I played with this to see how it would look. Illustrative patch bel=
ow.=20
> >=20
> > I figure that lots of small frames is the interesting workload for =
a
> > change such as this but I don't know if iperf is necessarily the be=
st
> > benchmark for measuring that.
> > Before changing things I got:
> >         iperf -c qarun -m -t 60 -u -b 10000M -l 64
> >         -----------------------------------------------------------=
-
> >         Client connecting to qarun, UDP port 5001
> >         Sending 64 byte datagrams
> >         UDP buffer size:   224 KByte (default)
> >         -----------------------------------------------------------=
-
> >         [  3] local 10.80.225.63 port 45857 connected with 10.80.22=
4.22 port 5001
> >         [ ID] Interval       Transfer     Bandwidth
> >         [  3]  0.0-60.0 sec    844 MBytes    118 Mbits/sec
> >         [  3] Sent 13820376 datagrams
> >         [  3] Server Report:
> >         [  3]  0.0-60.0 sec    844 MBytes    118 Mbits/sec  0.005 m=
s    0/13820375 (0%)
> >         [  3]  0.0-60.0 sec  1 datagrams received out-of-order
> > whereas with the patch:
> >         # iperf -c qarun -m -t 60 -u -b 10000M -l 64
> >         -----------------------------------------------------------=
-
> >         Client connecting to qarun, UDP port 5001
> >         Sending 64 byte datagrams
> >         UDP buffer size:   224 KByte (default)
> >         -----------------------------------------------------------=
-
> >         [  3] local 10.80.225.63 port 42504 connected with 10.80.22=
4.22 port 5001
> >         [ ID] Interval       Transfer     Bandwidth
> >         [  3]  0.0-60.0 sec    833 MBytes    116 Mbits/sec
> >         [  3] Sent 13645857 datagrams
> >         [  3] Server Report:
> >         [  3]  0.0-60.0 sec    833 MBytes    116 Mbits/sec  0.005 m=
s    0/13645856 (0%)
> >         [  3]  0.0-60.0 sec  1 datagrams received out-of-order
> >=20
> > With 1200 byte datagrams I get basically identical throughput.
> >=20
> > (nb: none of the skb destructor stuff was present in either case)
>=20
> Sorry, but the real problem is that if skb producer and consumer are =
not
> on same CPU, each skb will now hit SLUB slowpath three times instead =
of
> two.
>=20
> Some workloads are : One cpu fully handling IRQ from device, dispatch=
ing
> skbs to consumers on other cpus.

So something like a multithreaded apache benchmark would be interesting=
?

> Plus skb->truesize is wrong after your patch.
> Not sure if cloning is correct either...

Me neither, the patch was just one which happened to run well enough to
run some numbers on. I'll be sure to double-check/correct that stuff if
I persist with the approach.

> Anyway, do we _really_ need 16 frags per skb, I dont know....

MAX_SKB_FRAGS is:
        /* To allow 64K frame to be packed as single skb without frag_l=
ist. Since
         * GRO uses frags we allocate at least 16 regardless of page si=
ze.
         */
        #if (65536/PAGE_SIZE + 2) < 16
        #define MAX_SKB_FRAGS 16UL
        #else
        #define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
        #endif
       =20
So I think actually it turns out to be 18 on systems with 4k pages. If
we reduced that to be 16 that would save 48 bytes on amd64 which pulls
the shinfo size down to 440 and then

        NET_SKB_PAD (64) + 1500 + 14 + 440 =3D 2018

which does fit in half a page.

Using 16 still means that a 64k frame fits precisely in frags on a 4096
page size system. I don't know what the extra 2 was for (it predates
git), perhaps just to allow for some slop due to misalignment in the
first page of data?

> This gives problems when/if skb must be linearized and we hit
> PAGE_ALLOC_COSTLY_ORDER
>=20
> Alternatively, we could use order-1 or order-2 pages on x86 to get
> 8192/16384 bytes frags. (fallback to order-0 pages in case of allocat=
ion
> failures)

Or fallback to separate allocation of shinfo?

Ian.
