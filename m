From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v6 12/12] net/mlx4_en: add prefetch in xdp rx path
Date: Thu, 7 Jul 2016 21:16:14 -0700
Message-ID: <20160708041612.GA15452@ast-mbp.thefacebook.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
 <1467944124-14891-13-git-send-email-bblanco@plumgrid.com>
 <1467950191.17638.3.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32786 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbcGHEQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 00:16:20 -0400
Received: by mail-pf0-f193.google.com with SMTP id c74so3695913pfb.0
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 21:16:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1467950191.17638.3.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 08, 2016 at 05:56:31AM +0200, Eric Dumazet wrote:
> On Thu, 2016-07-07 at 19:15 -0700, Brenden Blanco wrote:
> > XDP programs read and/or write packet data very early, and cache miss is
> > seen to be a bottleneck.
> > 
> > Add prefetch logic in the xdp case 3 packets in the future. Throughput
> > improved from 10Mpps to 12.5Mpps.  LLC misses as reported by perf stat
> > reduced from ~14% to ~7%.  Prefetch values of 0 through 5 were compared
> > with >3 showing dimishing returns.
> 
> This is what I feared with XDP.
> 
> Instead of making generic changes in the driver(s), we now have 'patches
> that improve XDP numbers'
> 
> Careful prefetches make sense in NIC drivers, regardless of XDP being
> used or not.
> 
> On mlx4, prefetching next cqe could probably help as well.

I've tried this style of prefetching in the past for normal stack
and it didn't help at all.
It helps XDP because inner processing loop is short with small number
of memory accesses, so prefetching Nth packet in advance helps.
Prefetching next packet doesn't help as much, since bpf prog is
too short and hw prefetch logic doesn't have time to actually pull
the data in.
The effectiveness of this patch depends on size of the bpf program
and ammount of work it does. For small and medium sizes it works well.
For large prorgrams probably not so much, but we didn't get to
this point yet. I think eventually the prefetch distance should
be calculated dynamically based on size of prog and amount of work
it does or configured via knob (which would be unfortunate).
The performance gain is sizable, so I think it makes sense to
keep it... even to demonstrate the prefetch logic.
Also note this is ddio capable cpu. On desktop class cpus
the prefetch is mandatory for all bpf programs to have good performance.

Another alternative we considered is to allow bpf programs to
indicate to xdp infra how much in advance to prefetch, so
xdp side will prefetch only when program gives a hint.
But that would be the job of future patches.
