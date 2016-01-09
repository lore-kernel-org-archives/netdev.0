From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 0/4] bpf: bpf_htab: Add BPF_MAP_TYPE_PERCPU_HASH
Date: Fri, 8 Jan 2016 16:44:43 -0800
Message-ID: <20160109004443.GA33292@kafai-mba.local>
References: <1452206155-1492617-1-git-send-email-kafai@fb.com>
 <CACVXFVNhEOrroAfiEOC32dB3ZV=73WYJxUtNrpqEE94tvY2fXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	FB Kernel Team <kernel-team@fb.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:3942 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756165AbcAIAov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 19:44:51 -0500
Content-Disposition: inline
In-Reply-To: <CACVXFVNhEOrroAfiEOC32dB3ZV=73WYJxUtNrpqEE94tvY2fXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 08, 2016 at 02:55:32PM +0800, Ming Lei wrote:
> On Fri, Jan 8, 2016 at 6:35 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> > This patchset adds BPF_MAP_TYPE_PERCPU_HASH map type which allows
> > percpu value.
>
> I am also thinking about using percpu variable to ebpf map, but IMO it
> should be better for ARRAY map instead of HASH map, then we can
> avoid the atomic op in eBPF program, see example of tracex3, sockex1
> and sockex3 in sample/bpf/ of kernel tree.  Also looks the ARRAY map
> usage in bcc is wrong, strictly speaking.
array and hash are two different use cases. May be we should have percpu
value for array map too.

>
> For HASH map, it is easy to make cpu id as part of key, then the map
> can be thought as percpu too, and atomic op isn't needed in eBPF program.
Putting the cpu id as part of the key was indeed the first hack I did
to get a sense of potential benefit.

However, by extending the real-key with cpu-id, it is not intuitive to
use and it is prone to error.  For example, how to delete a real-key for
all cpus?  Iterating a particular real-key for all cpu is also tricky.  What
does it mean if a real-key exists for cpu#0 but not cpu#1? The real-key
got deleted from all cpu while iterating? or something else?  I believe
there are ways to get around but it is better to provide a clean
implementation instead.

> Given it is always related with performance, could you provide some data
> about the improvement? Also you can compare this patchset with the
> approach of providing cpu id as hash key.
In my test (bpf+kprobe at tcp_rcv_established()), both this patchset and
extend(real_key, cpu_id) approach save ~3% CPU while receiving ~4Mpps
in a 40cores machine.  The bpf is mostly bumping some counters for
each received packet.
