From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Fri, 9 Dec 2011 13:47:07 +0000
Message-ID: <1323438427.20077.57.camel@zakaz.uk.xensource.com>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
	 <1323172634.23681.73.camel@zakaz.uk.xensource.com>
	 <1323177878.2448.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1323264929.23681.178.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:23807 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829Ab1LINrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 08:47:09 -0500
In-Reply-To: <1323264929.23681.178.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-07 at 13:35 +0000, Ian Campbell wrote:
> On Tue, 2011-12-06 at 13:24 +0000, Eric Dumazet wrote:
> > Le mardi 06 d=C3=A9cembre 2011 =C3=A0 11:57 +0000, Ian Campbell a =C3=
=A9crit :
> > > On Wed, 2011-11-09 at 15:01 +0000, Ian Campbell wrote:
> > > >       * split linear data allocation and shinfo allocation into=
 two. I
> > > >         suspect this will have its own performance implications=
? On the
> > > >         positive side skb_shared_info could come from its own f=
ixed size
> > > >         pool/cache which might have some benefits
> > >=20
> > > I played with this to see how it would look. Illustrative patch b=
elow.=20
> > >=20
> > > I figure that lots of small frames is the interesting workload fo=
r a
> > > change such as this but I don't know if iperf is necessarily the =
best
> > > benchmark for measuring that.
> > > Before changing things I got:
> > >         iperf -c qarun -m -t 60 -u -b 10000M -l 64
> > >         ---------------------------------------------------------=
---
> > >         Client connecting to qarun, UDP port 5001
> > >         Sending 64 byte datagrams
> > >         UDP buffer size:   224 KByte (default)
> > >         ---------------------------------------------------------=
---
> > >         [  3] local 10.80.225.63 port 45857 connected with 10.80.=
224.22 port 5001
> > >         [ ID] Interval       Transfer     Bandwidth
> > >         [  3]  0.0-60.0 sec    844 MBytes    118 Mbits/sec
> > >         [  3] Sent 13820376 datagrams
> > >         [  3] Server Report:
> > >         [  3]  0.0-60.0 sec    844 MBytes    118 Mbits/sec  0.005=
 ms    0/13820375 (0%)
> > >         [  3]  0.0-60.0 sec  1 datagrams received out-of-order
> > > whereas with the patch:
> > >         # iperf -c qarun -m -t 60 -u -b 10000M -l 64
> > >         ---------------------------------------------------------=
---
> > >         Client connecting to qarun, UDP port 5001
> > >         Sending 64 byte datagrams
> > >         UDP buffer size:   224 KByte (default)
> > >         ---------------------------------------------------------=
---
> > >         [  3] local 10.80.225.63 port 42504 connected with 10.80.=
224.22 port 5001
> > >         [ ID] Interval       Transfer     Bandwidth
> > >         [  3]  0.0-60.0 sec    833 MBytes    116 Mbits/sec
> > >         [  3] Sent 13645857 datagrams
> > >         [  3] Server Report:
> > >         [  3]  0.0-60.0 sec    833 MBytes    116 Mbits/sec  0.005=
 ms    0/13645856 (0%)
> > >         [  3]  0.0-60.0 sec  1 datagrams received out-of-order
> > >=20
> > > With 1200 byte datagrams I get basically identical throughput.
> > >=20
> > > (nb: none of the skb destructor stuff was present in either case)
> >=20
> > Sorry, but the real problem is that if skb producer and consumer ar=
e not
> > on same CPU, each skb will now hit SLUB slowpath three times instea=
d of
> > two.
> >=20
> > Some workloads are : One cpu fully handling IRQ from device, dispat=
ching
> > skbs to consumers on other cpus.
>=20
> So something like a multithreaded apache benchmark would be interesti=
ng?
>=20
> > Plus skb->truesize is wrong after your patch.
> > Not sure if cloning is correct either...
>=20
> Me neither, the patch was just one which happened to run well enough =
to
> run some numbers on. I'll be sure to double-check/correct that stuff =
if
> I persist with the approach.
>=20
> > Anyway, do we _really_ need 16 frags per skb, I dont know....
>=20
> MAX_SKB_FRAGS is:
>         /* To allow 64K frame to be packed as single skb without frag=
_list. Since
>          * GRO uses frags we allocate at least 16 regardless of page =
size.
>          */
>         #if (65536/PAGE_SIZE + 2) < 16
>         #define MAX_SKB_FRAGS 16UL
>         #else
>         #define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
>         #endif
>        =20
> So I think actually it turns out to be 18 on systems with 4k pages. I=
f
> we reduced that to be 16 that would save 48 bytes on amd64 which pull=
s
> the shinfo size down to 440 and then
>=20
>         NET_SKB_PAD (64) + 1500 + 14 + 440 =3D 2018
>=20
> which does fit in half a page.
>=20
> Using 16 still means that a 64k frame fits precisely in frags on a 40=
96
> page size system. I don't know what the extra 2 was for (it predates
> git), perhaps just to allow for some slop due to misalignment in the
> first page of data?

Tracked it down in TGLX's historic tree as:
http://git.kernel.org/?p=3Dlinux/kernel/git/tglx/history.git;a=3Dcommit=
diff;h=3D80223d5186f73bf42a7e260c66c9cb9f7d8ec9cf

Having found the title I did a bit of searching around for discussion
but all I could find was other folks not having any idea where the + 2
comes from either...

http://kerneltrap.org/mailarchive/linux-netdev/2008/4/21/1529914 sort o=
f
wonders if the + 2 might be including a head which crosses a page
boundary. I'm not sure it is sane/useful to account for that in
MAX_SKB_FRAGS. If we had a concept like MAX_SKB_PAGES then it would
perhaps make sense to have + 2 there, but AFAICT drivers etc are alread=
y
accounting for this appropriately by adding a further + 2 (or sometimes
+ 1) to MAX_SKB_FRAGS.

Ian.

>=20
> > This gives problems when/if skb must be linearized and we hit
> > PAGE_ALLOC_COSTLY_ORDER
> >=20
> > Alternatively, we could use order-1 or order-2 pages on x86 to get
> > 8192/16384 bytes frags. (fallback to order-0 pages in case of alloc=
ation
> > failures)
>=20
> Or fallback to separate allocation of shinfo?
>=20
> Ian.
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
