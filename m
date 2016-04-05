From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Tue, 5 Apr 2016 11:29:05 +0200
Message-ID: <20160405112905.66b84e13@redhat.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	<1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
	<57022A85.6040002@iogearbox.net>
	<20160404150700.1456ae80@redhat.com>
	<57026DFA.3090201@iogearbox.net>
	<CALx6S37aK79AbkUPBFTHkonUziSb7A1KV47vnG1OgciPD2qXcA@mail.gmail.com>
	<20160404171227.1f862cb1@redhat.com>
	<20160404152948.GA495@gmail.com>
	<57029127.3040303@gmail.com>
	<20160404161720.GB495@gmail.com>
	<20160404200032.GA69842@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ogerlitz@mellanox.com, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755956AbcDEJ3L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 05:29:11 -0400
In-Reply-To: <20160404200032.GA69842@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 4 Apr 2016 13:00:34 -0700 Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> As seen in 'perf report' from patch 5:
>   3.32%  ksoftirqd/1    [kernel.vmlinux]  [k] sk_load_byte_positive_offset
> this is 14Mpps and 4 assembler instructions in the above function
> are consuming 3% of the cpu.

At this level we also need to take into account the cost/overhead of a
function call.  Which I've measured to between 5-7 cycles, part of my
time_bench_sample[1] test.

> Making new_load_byte to be single  x86 insn would be really cool.
> 
> Of course, there are other pieces to accelerate:
>  12.71%  ksoftirqd/1    [mlx4_en]         [k] mlx4_en_alloc_frags
>   6.87%  ksoftirqd/1    [mlx4_en]         [k] mlx4_en_free_frag
>   4.20%  ksoftirqd/1    [kernel.vmlinux]  [k] get_page_from_freelist
>   4.09%  swapper        [mlx4_en]         [k] mlx4_en_process_rx_cq
> and I think Jesper's work on batch allocation is going help that a lot.

Actually, it looks like all of this "overhead" comes from the page
alloc/free (+ dma unmap/map). We would need a page-pool recycle
mechanism to solve/remove this overhead.  For the early drop case we
might be able to hack recycle the page directly in the driver (and also
avoid dma_unmap/map cycle).


[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench_sample.c
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
