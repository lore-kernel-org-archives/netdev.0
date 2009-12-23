From: Chris Wright <chrisw@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 09:00:17 -0800
Message-ID: <20091223170017.GB31132@x200.localdomain>
References: <4B1D4F29.8020309@gmail.com>
 <87637zdy9g.fsf@basil.nowhere.org>
 <4B30E654.40702@codemonkey.ws>
 <200912221701.56840.bzolnier@gmail.com>
 <4B30F214.80206@codemonkey.ws>
 <20091223065129.GA19600@elte.hu>
 <20091223101340.GC20539@basil.fritz.box>
 <4B31EF65.6070000@redhat.com>
 <20091223121431.GF20539@basil.fritz.box>
 <4B3211A3.1090202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>,
	Chris Wright <chrisw@redhat.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30607 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbZLWRA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2009 12:00:57 -0500
Content-Disposition: inline
In-Reply-To: <4B3211A3.1090202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Avi Kivity (avi@redhat.com) wrote:
> On 12/23/2009 02:14 PM, Andi Kleen wrote:
> >>http://www.redhat.com/f/pdf/summit/cwright_11_open_source_virt.pdf
> >>
> >>See slide 32.  This is without vhost-net.
> >Thanks. Do you also have latency numbers?
> 
> No.  Copying Chris.  This was with the tx mitigation timer disabled,
> so you won't see the usual atrocious userspace virtio latencies, but
> it won't be as good as a host kernel implementation since we take a
> heavyweight exit and qemu is pretty unoptimized.

Those numbers don't show cpu cycles per packet nor do they show latencies.
You won't see the timer based latency, because the tx mitigation scheme
is not timer based for those numbers.  Below are some numbers comparing
bare metal, an assigned device, and virtio (not vhost-net, so we are still
doing a heavy-weight exit to qemu and syscalls to deliver to tap device).

> >It seems like there's definitely still potential for improvement
> >with messages<4K. But for the large messages they indeed
> >look rather good.

You are misreading the graph.  At <4K it is tracking bare metal (the
green and yellow lines are bare metal, the red and blue bars are virtio).
At >4k we start to drop off (esp. on RX).

This (slide 9) shows AMQP latencies for bare metal, an assigned device,
and virtio.  
http://www.redhat.com/f/pdf/summit/bche_320_red_hat_enterprise_mrg.pdf

Similarly, here's some much rawer latency numbers from netpipe, all done
in usecs.

                bare    assigned
                metal   PCI NIC virtio
                (usecs) (usecs) (usecs)
                -----   -----   -----
    1 bytes	22.20	36.16	53.19
    2 bytes	22.21	35.98	53.23
    3 bytes	22.22	36.18	53.29
    4 bytes	22.25	33.77	53.43
    6 bytes	22.33	36.33	53.48
    8 bytes	22.32	36.24	53.27
   12 bytes	22.25	35.97	53.33
   13 bytes	22.40	35.94	53.54
   16 bytes	22.36	35.98	53.60
   19 bytes	22.40	35.95	53.51
   21 bytes	22.42	35.94	53.76
   24 bytes	22.32	36.18	53.45
   27 bytes	22.34	36.08	53.48
   29 bytes	22.36	36.02	53.42
   32 bytes	22.46	36.15	53.23
   35 bytes	22.36	36.23	53.13
   45 bytes	26.32	36.17	53.29
   48 bytes	26.24	35.94	53.50
   51 bytes	26.44	36.01	53.66
   61 bytes	26.43	33.66	53.28
   64 bytes	26.66	36.32	53.17
   67 bytes	26.35	36.21	53.53
   93 bytes	26.59	36.49	45.75
   96 bytes	26.48	36.28	45.72
   99 bytes	26.51	36.47	45.72
  125 bytes	26.74	36.48	45.99
  128 bytes	26.44	36.52	45.69
  131 bytes	26.52	35.71	45.80
  189 bytes	26.77	36.99	46.78
  192 bytes	26.96	37.45	47.00
  195 bytes	26.96	37.45	47.10
  253 bytes	27.01	38.03	47.36
  256 bytes	27.09	37.85	47.23
  259 bytes	26.98	37.82	47.28
  381 bytes	26.61	38.38	47.84
  384 bytes	26.72	38.54	48.01
  387 bytes	26.76	38.65	47.80
  509 bytes	25.13	39.19	48.30
  512 bytes	25.13	36.69	56.05
  515 bytes	25.15	37.42	55.70
  765 bytes	25.29	40.31	57.26
  768 bytes	25.25	39.76	57.32
  771 bytes	25.26	40.33	57.06
 1021 bytes	49.27	57.00	63.73
 1024 bytes	49.33	57.09	63.70
 1027 bytes	49.07	57.25	63.70
 1533 bytes	50.11	58.98	70.57
 1536 bytes	50.09	59.30	70.22
 1539 bytes	50.18	59.27	70.35
 2045 bytes	50.44	59.42	74.31
 2048 bytes	50.33	59.29	75.31
 2051 bytes	50.32	59.14	74.02
 3069 bytes	62.71	64.20	96.87
 3072 bytes	62.78	64.94	96.84
 3075 bytes	62.83	65.13	96.62
 4093 bytes	62.56	64.78	99.63
 4096 bytes	62.46	65.04	99.54
 4099 bytes	62.47	65.87	99.65
 6141 bytes	63.35	65.39	104.03
 6144 bytes	63.59	66.16	104.66
 6147 bytes	63.74	66.04	104.61
 8189 bytes	63.65	66.52	107.75
 8192 bytes	63.64	66.71	108.17
 8195 bytes	63.66	67.08	109.11
12285 bytes	63.26	84.58	114.13
12288 bytes	63.28	85.38	114.55
12291 bytes	63.22	83.71	114.40
16381 bytes	62.87	98.19	120.48
16384 bytes	63.12	97.96	122.19
16387 bytes	63.48	98.48	121.68
24573 bytes	93.26	108.93	152.67
24576 bytes	94.40	109.42	152.14
24579 bytes	93.37	108.86	153.51
32765 bytes	102.84	115.46	169.04
32768 bytes	100.01	114.62	166.19
32771 bytes	102.61	115.97	167.96
49149 bytes	125.46	144.78	209.99
49152 bytes	123.76	139.70	187.17
49155 bytes	125.13	137.97	185.44
