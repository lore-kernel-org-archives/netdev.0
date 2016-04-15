From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/2] act_bpf, cls_bpf: send eBPF bytecode through
Date: Fri, 15 Apr 2016 11:44:47 -0700
Message-ID: <20160415184445.GA58007@ast-mbp.thefacebook.com>
References: <1460714856-7221-1-git-send-email-quentin.monnet@6wind.com>
 <5710C541.7070609@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Quentin Monnet <quentin.monnet@6wind.com>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34584 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbcDOSov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 14:44:51 -0400
Received: by mail-pa0-f42.google.com with SMTP id r5so3978921pag.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 11:44:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5710C541.7070609@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 15, 2016 at 12:41:05PM +0200, Daniel Borkmann wrote:
> Hi Quentin,
> 
> On 04/15/2016 12:07 PM, Quentin Monnet wrote:
> >When a new BPF traffic control filter or action is set up with tc, the
> >bytecode is sent back to userspace through a netlink socket for cBPF, but
> >not for eBPF (the file descriptor pointing to the object file containing
> >the bytecode is sent instead).
> >
> >This patch makes cls_bpf and act_bpf modules send the bytecode for eBPF as
> >well (in addition to the file descriptor).
> >
> >New BPF flags are used in order to differenciate what BPF version is in
> >use, so that userspace tools can process the bytecode properly.
> >
> >Once the series is accepted and merged, it is intended to submit a patch
> >for the iproute2 package, so as to fix tc utility so as to use the new
> >flags and to display the bytecode in eBPF format when needed. This tc
> >patch is already available at:
> >https://github.com/6WIND/iproute2/commits/netlink_eBPF
> 
> Thanks for working on this, but it's unfortunately not that easy. Let
> me ask, what would be the intended use-case to dump the insns?

+1

> I'm asking because if you dump them as-is, then a reinject at a later
> time of that bytecode back into the kernel will most likely be rejected
> by the verifier.
> 
> This is because on load time, verifier does rewrites/expansion on some
> of the insns (f.e. map pointers, helper functions, ctx access etc, see
> also appendix in [1]), so the code as seen in the kernel would need to
> be sanitized first.

+1
we had similar discussion about this in seccomp context and decided that
the only sensible way is to keep original instructions, but it's wasteful
to do unconditionally and snapshotting of maps is not possible,
so there was no use for such dumping facility other than debugging.
Is it what the patch after?
We need to discuss it in the proper context.

> Also, how would you make sense/transform maps into a meaningful
> representation (probably possible to find a scheme when they are pinned)?
> 
> Another possibility is that such programs need to be pinned (can be done
> easily by tc in the background) and then implement a CRIU facility into
> the bpf(2) syscall to retrieve them. tc could make use of this w/o too
> much effort, and at the same time it would help CRIU folks, too. It
> also seems cleaner to have only one central api (bpf(2)) to dump them,
> but needs a bit of thought.

+1
any debugging or criu needs to be done in a centralized way via syscall
and/or bpffs.
