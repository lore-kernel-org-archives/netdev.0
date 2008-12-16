From: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Subject: Re: Bonding gigabit and fast?
Date: Tue, 16 Dec 2008 22:55:47 +0000
Message-ID: <200812162255.47731.tvrtko@ursulin.net>
References: <200812161939.30033.tvrtko@ursulin.net> <200812162012.29811.tvrtko@ursulin.net> <4948119B.5050000@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mk-outboundfilter-6-a-2.mail.uk.tiscali.com ([212.74.114.16]:26910
	"EHLO mk-outboundfilter-6-a-2.mail.uk.tiscali.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259AbYLPWzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 17:55:54 -0500
In-Reply-To: <4948119B.5050000@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 16 December 2008 20:37:47 Chris Snook wrote:
> >> The gigabit card might be sharing a PCI bus with your disk controller,
> >> so swapping which slots the cards are in might make gigabit work faster,
> >> but it sounds more like the driver is doing something stupid with
> >> interrupt servicing.
> >
> > Dang you are right, they really do share the same interrupt. And I have
> > nowhere else to move that card since it is a single PCI slot.
> > Interestingly, fast ethernet (eth0) generates double number of interrupts
> > than gigabit (eth1) and SATA combined.
> >
> > From powertop:
> >
> > Top causes for wakeups:
> >   65.5% (11091.1)       <interrupt> : eth0
> >   32.9% (5570.5)       <interrupt> : sata_sil, eth1
> >
> > Tvrtko
>
> Sharing an interrupt shouldn't be a problem, unless the other driver is
> doing bad things.  Sharing the bus limits PCI bandwidth though, and that
> can hurt.
>
> The fact that you're getting more interrupts on the card moving more
> packets isn't surprising.
>
> It occurred to me that the alb algorithm is not designed for asymmetric
> bonds, so part of the problem is likely the distribution of traffic.  You
> always end up with somewhat unbalanced distribution, and it happens to be
> favoring the slower card.

I was using balance-rr, alb flavour does not seem to like 8139too.

> The real problem is that you get such lousy performance in unbonded gigabit
> mode.  Try oprofiling it to see where it's spending all that time.

Could it be something scheduling related? Or maybe CIFS on the client which is also running a flavour of 2.6.27? I had to put vanilla 2.6.27.9 on the server in order 
to run oprofile so maybe I'll have to do the same thing on the client..

In the meantime these are the latest testing results. When serving over Samba I get 9.6Mb/s and oprofile looks like this:

Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit mask of 0x00 (No unit mask) count 100000
samples  %        image name               app name                 symbol name
43810    11.2563  skge                     skge                     (no symbols)
36363     9.3429  vmlinux                  vmlinux                  handle_fasteoi_irq
32805     8.4287  vmlinux                  vmlinux                  __napi_schedule
30122     7.7394  vmlinux                  vmlinux                  handle_IRQ_event
22270     5.7219  vmlinux                  vmlinux                  copy_user_generic_string
13444     3.4542  vmlinux                  vmlinux                  native_read_tsc
7606      1.9542  smbd                     smbd                     (no symbols)
7492      1.9250  vmlinux                  vmlinux                  mcount
6014      1.5452  libmythui-0.21.so.0.21.0 libmythui-0.21.so.0.21.0 (no symbols)
5689      1.4617  vmlinux                  vmlinux                  memcpy_c
5090      1.3078  libc-2.8.90.so           libc-2.8.90.so           (no symbols)
4176      1.0730  vmlinux                  vmlinux                  native_safe_halt
3970      1.0200  vmlinux                  vmlinux                  ioread8

It is generally not very CPU intensive, but as I said it oscillates a lot. For example vmstat 1 output from middle of this transfer:

 1  0      0  33684  18908 532240    0    0  8832   128 8448 1605  0  9 86  5
 0  0      0  21040  18908 544768    0    0 12544     0 11615 1876  0 10 89  1
 0  0      0  17168  18908 548636    0    0  3840     0 3999  978  0  5 95  0
 0  0      0  10904  18972 554412    0    0  5772     0 5651 1050  1  7 86  6
 1  0      0   8976  18840 556312    0    0  3200     0 3573  891  0  4 96  0
 0  0      0   9948  18792 555716    0    0  7168     0 6776 1202  0  9 89  2

Or bandwith log (500msec period):

1229466433;eth1;6448786.50;206129.75;6654916.50;103271;3230842;4483.03;2608.78;7091.82;1307;2246;0.00;0.00;0;0
1229466433;eth1;11794112.00;377258.00;12171370.00;188629;5897056;8186.00;4772.00;12958.00;2386;4093;0.00;0.00;0;0
1229466434;eth1;4417197.50;141690.62;4558888.50;70987;2213016;3069.86;1792.42;4862.28;898;1538;0.00;0.00;0;0
1229466434;eth1;6059886.00;194222.00;6254108.00;97111;3029943;4212.00;2458.00;6670.00;1229;2106;0.00;0.00;0;0
1229466435;eth1;9232362.00;295816.38;9528178.00;148204;4625413;6413.17;3742.52;10155.69;1875;3213;0.00;0.00;0;0
1229466435;eth1;20735192.00;663600.00;21398792.00;331800;10367596;14398.00;8400.00;22798.00;4200;7199;0.00;0.00;0;0
1229466436;eth1;12515441.00;399852.31;12915294.00;200326;6270236;8688.62;5063.87;13752.50;2537;4353;0.00;0.00;0;0

On the other hand when I pulled the same file with scp I got pretty stable 22.3 Mb/s and this oprofile:

samples  %        image name               app name                 symbol name
242779   48.4619  libcrypto.so.0.9.8       libcrypto.so.0.9.8       (no symbols)
30214     6.0311  skge                     skge                     (no symbols)
29276     5.8439  vmlinux                  vmlinux                  copy_user_generic_string
21052     4.2023  vmlinux                  vmlinux                  handle_fasteoi_irq
19124     3.8174  vmlinux                  vmlinux                  __napi_schedule
15394     3.0728  libc-2.8.90.so           libc-2.8.90.so           (no symbols)
14327     2.8599  vmlinux                  vmlinux                  handle_IRQ_event
5303      1.0585  vmlinux                  vmlinux                  native_read_tsc

Hm, let me do one more test which has no CPU taxing network transport like netcat. Nope, same "fast" ~22Mb/s speed, or:

samples  %        image name               app name                 symbol name
29719    11.5280  vmlinux                  vmlinux                  copy_user_generic_string
28354    10.9985  skge                     skge                     (no symbols)
18259     7.0826  vmlinux                  vmlinux                  handle_fasteoi_irq
17359     6.7335  vmlinux                  vmlinux                  __napi_schedule
15095     5.8553  vmlinux                  vmlinux                  handle_IRQ_event
7422      2.8790  vmlinux                  vmlinux                  native_read_tsc
5619      2.1796  vmlinux                  vmlinux                  mcount
3966      1.5384  libmythui-0.21.so.0.21.0 libmythui-0.21.so.0.21.0 (no symbols)
3709      1.4387  libc-2.8.90.so           libc-2.8.90.so           (no symbols)
3510      1.3615  vmlinux                  vmlinux                  memcpy_c

Maybe also NFS.. no, also fast. 

So this points to Samba/scheduler/CIFS client regression I think. I'll try to do more testing in the following days. All this assuming that ~22Mb/s is the best this 
machine can do and only hunting for slow and unstable speed over Samba.

But I find it strange iperf also couldn't do more and it does not put any load on the shared interrupt line. Especially since it did 400Mbps in the other direction. 

Thank you for your help of course, forgot to say it earlier!

Tvrtko
