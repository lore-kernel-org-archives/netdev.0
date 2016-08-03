From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v10 12/12] bpf: add sample for xdp forwarding and
 rewrite
Date: Wed, 03 Aug 2016 11:29:47 -0700 (PDT)
Message-ID: <20160803.112947.1365083919840672357.davem@davemloft.net>
References: <CALx6S34b1O6iiFn6M2=xX3iduGWDQm=G+jweYVvGqY-xa4E2sg@mail.gmail.com>
	<20160803171118.GA37742@ast-mbp.thefacebook.com>
	<CALx6S36ARsfC8XxPHYsbD+T6Dx3SOgxdxv2CDJWuVZGf+H1oAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
	netdev@vger.kernel.org, jhs@mojatatu.com,
	saeedm@dev.mellanox.co.il, kafai@fb.com, brouer@redhat.com,
	as754m@att.com, gerlitz.or@gmail.com, john.fastabend@gmail.com,
	hannes@stressinduktion.org, tgraf@suug.ch, daniel@iogearbox.net,
	ttoukan.linux@gmail.com, haoxuany@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837AbcHCSaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 14:30:18 -0400
In-Reply-To: <CALx6S36ARsfC8XxPHYsbD+T6Dx3SOgxdxv2CDJWuVZGf+H1oAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 3 Aug 2016 10:29:58 -0700

> On Wed, Aug 3, 2016 at 10:11 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
>> On Wed, Aug 03, 2016 at 10:01:54AM -0700, Tom Herbert wrote:
>>> On Tue, Jul 19, 2016 at 12:16 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
>>> > Add a sample that rewrites and forwards packets out on the same
>>> > interface. Observed single core forwarding performance of ~10Mpps.
>>> >
>>> > Since the mlx4 driver under test recycles every single packet page, the
>>> > perf output shows almost exclusively just the ring management and bpf
>>> > program work. Slowdowns are likely occurring due to cache misses.
>>> >
>>> > Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
>>> > ---
>>> >  samples/bpf/Makefile    |   5 +++
>>> >  samples/bpf/xdp2_kern.c | 114 ++++++++++++++++++++++++++++++++++++++++++++++++
>>> >  2 files changed, 119 insertions(+)
>>> >  create mode 100644 samples/bpf/xdp2_kern.c
>>> >
>>> > diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
>>> > index 0e4ab3a..d2d2b35 100644
>>> > --- a/samples/bpf/Makefile
>>> > +++ b/samples/bpf/Makefile
>>> > @@ -22,6 +22,7 @@ hostprogs-y += map_perf_test
>>> >  hostprogs-y += test_overhead
>>> >  hostprogs-y += test_cgrp2_array_pin
>>> >  hostprogs-y += xdp1
>>> > +hostprogs-y += xdp2
>>> >
>>> >  test_verifier-objs := test_verifier.o libbpf.o
>>> >  test_maps-objs := test_maps.o libbpf.o
>>> > @@ -44,6 +45,8 @@ map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
>>> >  test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
>>> >  test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
>>> >  xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
>>> > +# reuse xdp1 source intentionally
>>> > +xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
>>> >
>>> >  # Tell kbuild to always build the programs
>>> >  always := $(hostprogs-y)
>>> > @@ -67,6 +70,7 @@ always += test_overhead_kprobe_kern.o
>>> >  always += parse_varlen.o parse_simple.o parse_ldabs.o
>>> >  always += test_cgrp2_tc_kern.o
>>> >  always += xdp1_kern.o
>>> > +always += xdp2_kern.o
>>> >
>>> >  HOSTCFLAGS += -I$(objtree)/usr/include
>>> >
>>> > @@ -88,6 +92,7 @@ HOSTLOADLIBES_spintest += -lelf
>>> >  HOSTLOADLIBES_map_perf_test += -lelf -lrt
>>> >  HOSTLOADLIBES_test_overhead += -lelf -lrt
>>> >  HOSTLOADLIBES_xdp1 += -lelf
>>> > +HOSTLOADLIBES_xdp2 += -lelf
>>> >
>>> >  # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
>>> >  #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
>>> > diff --git a/samples/bpf/xdp2_kern.c b/samples/bpf/xdp2_kern.c
>>> > new file mode 100644
>>> > index 0000000..38fe7e1
>>> > --- /dev/null
>>> > +++ b/samples/bpf/xdp2_kern.c
>>> > @@ -0,0 +1,114 @@
>>> > +/* Copyright (c) 2016 PLUMgrid
>>> > + *
>>> > + * This program is free software; you can redistribute it and/or
>>> > + * modify it under the terms of version 2 of the GNU General Public
>>> > + * License as published by the Free Software Foundation.
>>> > + */
>>> > +#define KBUILD_MODNAME "foo"
>>> > +#include <uapi/linux/bpf.h>
>>> > +#include <linux/in.h>
>>> > +#include <linux/if_ether.h>
>>> > +#include <linux/if_packet.h>
>>> > +#include <linux/if_vlan.h>
>>> > +#include <linux/ip.h>
>>> > +#include <linux/ipv6.h>
>>> > +#include "bpf_helpers.h"
>>> > +
>>> > +struct bpf_map_def SEC("maps") dropcnt = {
>>> > +       .type = BPF_MAP_TYPE_PERCPU_ARRAY,
>>> > +       .key_size = sizeof(u32),
>>> > +       .value_size = sizeof(long),
>>> > +       .max_entries = 256,
>>> > +};
>>> > +
>>> > +static void swap_src_dst_mac(void *data)
>>> > +{
>>> > +       unsigned short *p = data;
>>> > +       unsigned short dst[3];
>>> > +
>>> > +       dst[0] = p[0];
>>> > +       dst[1] = p[1];
>>> > +       dst[2] = p[2];
>>> > +       p[0] = p[3];
>>> > +       p[1] = p[4];
>>> > +       p[2] = p[5];
>>> > +       p[3] = dst[0];
>>> > +       p[4] = dst[1];
>>> > +       p[5] = dst[2];
>>> > +}
>>> > +
>>> > +static int parse_ipv4(void *data, u64 nh_off, void *data_end)
>>> > +{
>>> > +       struct iphdr *iph = data + nh_off;
>>> > +
>>> > +       if (iph + 1 > data_end)
>>> > +               return 0;
>>> > +       return iph->protocol;
>>> > +}
>>> > +
>>> > +static int parse_ipv6(void *data, u64 nh_off, void *data_end)
>>> > +{
>>> > +       struct ipv6hdr *ip6h = data + nh_off;
>>> > +
>>> > +       if (ip6h + 1 > data_end)
>>> > +               return 0;
>>> > +       return ip6h->nexthdr;
>>> > +}
>>> > +
>>> > +SEC("xdp1")
>>> > +int xdp_prog1(struct xdp_md *ctx)
>>> > +{
>>> > +       void *data_end = (void *)(long)ctx->data_end;
>>> > +       void *data = (void *)(long)ctx->data;
>>>
>>> Brendan,
>>>
>>> It seems that the cast to long here is done because data_end and data
>>> are u32s in xdp_md. So the effect is that we are upcasting a
>>> thirty-bit integer into a sixty-four bit pointer (in fact without the
>>> cast we see compiler warnings). I don't understand how this can be
>>> correct. Can you shed some light on this?
>>
>> please see:
>> http://lists.iovisor.org/pipermail/iovisor-dev/2016-August/000355.html
>>
> That doesn't explain it.

Yes it does explain it, think more about the word "meta" and what the
code generator might be doing.
