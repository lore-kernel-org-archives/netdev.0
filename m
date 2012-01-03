From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next v2] net_sched: qdisc_alloc_handle() can be too slow
Date: Tue, 3 Jan 2012 11:23:25 +0100
Message-ID: <CAA93jw4uzOZPGsQt-+JqBCtHfu+s8ivLL8Vnb1+tds56r7FK1A@mail.gmail.com>
References: <1325584697.2320.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1325584811.2320.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:42782 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347Ab2ACKX1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 05:23:27 -0500
Received: by iaeh11 with SMTP id h11so30680766iae.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 02:23:26 -0800 (PST)
In-Reply-To: <1325584811.2320.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2012 at 11:00 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> When trying to allocate ~32768 qdiscs using autohandle mechanism, we =
can
> fill the space managed by kernel (handles in [8000-FFFF]:0000 range)
>
> But O(N^2) qdisc_alloc_handle() loops 0x10000 times instead of 0x8000
>
> time tc add qdisc add dev eth0 parent 10:7fff pfifo limit 10
> RTNETLINK answers: Cannot allocate memory
> real =A0 =A01m54.826s
> user =A0 =A00m0.000s
> sys =A0 =A0 0m0.004s
>
> INFO: rcu_sched_state detected stall on CPU 0 (t=3D60000 jiffies)
>
> Half number of loops, and add a cond_resched() call.
> We hold rtnl at this point.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Dave Taht <dave.taht@gmail.com>
> ---
> v2: With the patch itself :)
>
> Next move is using rb-tree instead of a linked list, to speedup
> qdisc_lookup(). A complex qdisc setup is way too slow.
>
> =A0net/sched/sch_api.c | =A0 14 +++++++++-----
> =A01 file changed, 9 insertions(+), 5 deletions(-)
>
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index dca6c1a..3d8981f 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -618,20 +618,24 @@ void qdisc_class_hash_remove(struct Qdisc_class=
_hash *clhash,
> =A0}
> =A0EXPORT_SYMBOL(qdisc_class_hash_remove);
>
> -/* Allocate an unique handle from space managed by kernel */
> -
> +/* Allocate an unique handle from space managed by kernel
> + * Possible range is [8000-FFFF]:0000 (0x8000 values)
> + */
> =A0static u32 qdisc_alloc_handle(struct net_device *dev)
> =A0{
> - =A0 =A0 =A0 int i =3D 0x10000;
> + =A0 =A0 =A0 int i =3D 0x8000;
> =A0 =A0 =A0 =A0static u32 autohandle =3D TC_H_MAKE(0x80000000U, 0);
>
> =A0 =A0 =A0 =A0do {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0autohandle +=3D TC_H_MAKE(0x10000U, 0)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (autohandle =3D=3D TC_H_MAKE(TC_H_R=
OOT, 0))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0autohandle =3D TC_H_MA=
KE(0x80000000U, 0);
> - =A0 =A0 =A0 } while (qdisc_lookup(dev, autohandle) && --i > 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!qdisc_lookup(dev, autohandle))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return autohandle;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cond_resched();
> + =A0 =A0 =A0 } while (--i > 0);
>
> - =A0 =A0 =A0 return i > 0 ? autohandle : 0;
> + =A0 =A0 =A0 return 0;
> =A0}
>
> =A0void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
>
>

I take it this is from you trying to allocate XXk bins in staqfq.lua
and watching it
go boom? I'll gladly go and try to break more stuff if you like. :)

I ran yesterday's patches for sfq, and qfq on net-next all night on an =
x86 box,
successfully, on e1000e to ag71xx.

I'm not willing to declare victory on  QFQ yet, it was a really
hard problem to trigger... give me a day on it...

I'm testing the backport of those two patches to 3.1.6
 (no porting needed, they just apply) on cerowrt now, then I'm going to=
 setup
a fairly complex scenario (wireless,wired, 7-8 machines) in bloatlab #2

The wireless data I got a couple days back is rather noisy but the
median is promising.

http://www.teklibre.com/~d/bloat/wireless.qfqvspfifofast10iperfs.png

I'll get a lot more over the next few days and smooth it out.

--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
