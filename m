From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: fix samples to add fake KBUILD_MODNAME
Date: Wed, 26 Oct 2016 09:44:38 -0700
Message-ID: <20161026164436.GA38823@ast-mbp.thefacebook.com>
References: <1fdac65566ed6e0cff486507c5019f45807d1e89.1477434641.git.daniel@iogearbox.net>
 <20161026011713.GA35732@ast-mbp.thefacebook.com>
 <581054DC.5000904@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34171 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752427AbcJZQom (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 12:44:42 -0400
Received: by mail-pf0-f196.google.com with SMTP id u84so2842013pfj.1
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 09:44:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <581054DC.5000904@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 09:01:48AM +0200, Daniel Borkmann wrote:
> On 10/26/2016 03:17 AM, Alexei Starovoitov wrote:
> >On Wed, Oct 26, 2016 at 12:37:53AM +0200, Daniel Borkmann wrote:
> >>Some of the sample files are causing issues when they are loaded with tc
> >>and cls_bpf, meaning tc bails out while trying to parse the resulting ELF
> >>file as program/map/etc sections are not present, which can be easily
> >>spotted with readelf(1).
> >>
> >>Currently, BPF samples are including some of the kernel headers and mid
> >>term we should change them to refrain from this, really. When dynamic
> >>debugging is enabled, we bail out due to undeclared KBUILD_MODNAME, which
> >>is easily overlooked in the build as clang spills this along with other
> >>noisy warnings from various header includes, and llc still generates an
> >>ELF file with mentioned characteristics. For just playing around with BPF
> >>examples, this can be a bit of a hurdle to take.
> >>
> >>Just add a fake KBUILD_MODNAME as a band-aid to fix the issue, same is
> >>done in xdp*_kern samples already.
> >>
> >>Fixes: 65d472fb007d ("samples/bpf: add 'pointer to packet' tests")
> >>Fixes: 6afb1e28b859 ("samples/bpf: Add tunnel set/get tests.")
> >>Fixes: a3f74617340b ("cgroup: bpf: Add an example to do cgroup checking in BPF")
> >>Reported-by: Chandrasekar Kannan <ckannan@console.to>
> >>Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> >>---
> >>  samples/bpf/parse_ldabs.c        | 1 +
> >>  samples/bpf/parse_simple.c       | 1 +
> >>  samples/bpf/parse_varlen.c       | 1 +
> >>  samples/bpf/tcbpf1_kern.c        | 1 +
> >>  samples/bpf/tcbpf2_kern.c        | 1 +
> >>  samples/bpf/test_cgrp2_tc_kern.c | 1 +
> >>  6 files changed, 6 insertions(+)
> >
> >It's also needed for all of tracex*_kern.c, right?
> 
> Rest compiles just fine for me and readelf output looks good on all
> tracex*_kern.o, too.
> 
> I see just warnings coming from various kernel header inclusions (see
> log), but no errors anymore.

ahh. good to know. I guess networking examples include some header
with dynamic debug that tracing examples don't.
Thanks for checking.

> ./include/linux/cgroup-defs.h:322:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension [-Wgnu-variable-sized-type-not-at-end]
>         struct cgroup cgrp;
>                       ^
> 2 warnings generated.

this cgroup warning is crazy annoying and would have to be fixed anyway
for kernel to be compiled with clang.
