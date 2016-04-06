From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 5/5] Add sample for adding simple drop program to link
Date: Wed, 6 Apr 2016 16:11:49 -0700
Message-ID: <20160406231147.GA11421@ast-mbp.thefacebook.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-6-git-send-email-bblanco@plumgrid.com>
 <20160406214848.7568235b@redhat.com>
 <20160406220100.0df04925@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, tom@herbertland.com,
	Or Gerlitz <ogerlitz@mellanox.com>, daniel@iogearbox.net,
	john.fastabend@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34701 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754364AbcDFXLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 19:11:54 -0400
Received: by mail-pa0-f43.google.com with SMTP id fe3so41933180pab.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 16:11:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160406220100.0df04925@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 06, 2016 at 10:01:00PM +0200, Jesper Dangaard Brouer wrote:
> On Wed, 6 Apr 2016 21:48:48 +0200
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > If I do multiple flows, via ./pktgen_sample05_flow_per_thread.sh
> > then I hit this strange 14.5Mpps limit (proto 17:   14505558 drops/s).
> > And the RX 4x CPUs are starting to NOT use 100% in softirq, they have
> > some cycles attributed to %idle. (I verified generator is sending at
> > 24Mpps).
...
> > If I change the program to not touch packet data (don't call
> > load_byte()) then the performance increase to 14.6Mpps (single
> > flow/cpu).  And the RX CPU is mostly idle... mlx4_en_process_rx_cq()
> > and page alloc/free functions taking the time.

Please try it with module param log_num_mgm_entry_size=-1
It should get to 20Mpps when bpf doesn't touch the packet.

> Before someone else point out the obvious... I forgot to enable JIT.
> Enable it::
> 
>  # echo 1 > /proc/sys/net/core/bpf_jit_enable
> 
> Performance increased to: 10.8Mpps (proto 17:   10819446 drops/s)
> 
>  Samples: 51K of event 'cycles', Event count (approx.): 56775706510
>    Overhead  Command      Shared Object     Symbol
>  +   55.90%  ksoftirqd/7  [kernel.vmlinux]  [k] sk_load_byte_positive_offset
>  +   10.71%  ksoftirqd/7  [mlx4_en]         [k] mlx4_en_alloc_frags
... 
> It is a very likely cache-miss in sk_load_byte_positive_offset().

yes, likely due to missing ddio as you said.
