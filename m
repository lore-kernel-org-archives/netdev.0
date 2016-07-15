From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Fri, 15 Jul 2016 09:56:53 -0700
Message-ID: <20160715165651.GB3693@ast-mbp.thefacebook.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
 <20160714092543.776f8d8c@redhat.com>
 <20160715033057.GA98180@ast-mbp.thefacebook.com>
 <20160715102123.28efb815@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36364 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbcGOQ47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 12:56:59 -0400
Received: by mail-pa0-f67.google.com with SMTP id ez1so2981585pab.3
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 09:56:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160715102123.28efb815@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15, 2016 at 10:21:23AM +0200, Jesper Dangaard Brouer wrote:
> > 
> > attaching program to all rings at once is a fundamental part for correct
> > operation. As was pointed out in the past the bpf_prog pointer
> > in the ring design loses atomicity of the update. While the new program is
> > being attached the old program is still running on other rings.
> > That is not something user space can compensate for.
> 
> I don't see a problem with this.  This is how iptables have been
> working for years.  The iptables ruleset exchange is atomic, but only
> atomic per CPU.  It's been working fine for iptables.

And how is that a good thing?

> > So for current 'one prog for all rings' we cannot do what you're suggesting,
> > yet it doesn't mean we won't do prog per ring tomorrow. To do that the other
> > aspects need to be agreed upon before we jump into implementation:
> > - what is the way for the program to know which ring it's running on?
> >   if there is no such way, then attaching the same prog to multiple
> >   ring is meaningless.
> >   we can easily extend 'struct xdp_md' in the future if we decide
> >   that it's worth doing.
> 
> Not sure we need to extend 'struct xdp_md' with a ring number. If we
> allow assigning the program to a specific queue (if not we might need to).
> 
> The setup sequence would be:
> 1. userspace setup ntuple filter into a queue number
> 2. userspace register XDP program on this queue number
> 3. kernel XDP program queue packets into SPSC queue (like netmap)
>    (no locking, single RX queue, single producer)
> 4. userspace reads packets from SPSC queue (like netmap)
> 
> For step 2, the XDP program should return some identifier for the SPSC
> queue.  And step 3, is of cause a new XDP feature.

so you want 2 now while having zero code for 3 and 4 ?
Frankly I thought with all the talk about zero copy the goal was
to improve networking performance of VM traffic, but above sounds
like that you want to build a new kernel bypass (like netmap).
In such case there is no need for bpf or xdp at all.
Building kernel bypass looks like separatere problem to me with
its own headaches. We can certainly discuss it, but let's keep
xdp out of the picture then, since the goals are not aligned.

> > - should we allow different programs to attach to different rings?
> 
> Yes, that is one of my main points.  You assume that a single program
> own the entire NIC.  John's proposal was that he can create 1000's of
> queues, and wanted to bind this to (e.g. 1000) different applications.

reserving rx queues for different applications is yet another very
different problem. I think it would quite cool to do that, but
I don't see how it's related to what we want to achieve with xdp.
