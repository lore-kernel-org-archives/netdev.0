From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH] net/mlx4_en: protect ring->xdp_prog with rcu_read_lock
Date: Tue, 30 Aug 2016 18:50:59 -0700
Message-ID: <20160831015058.GA30198@gmail.com>
References: <20160826203808.23664-1-bblanco@plumgrid.com>
 <c03157a0-b7d0-bde7-0fe9-4f3b19a68d08@mellanox.com>
 <20160829155558.GA13971@gmail.com>
 <CALx6S34nt0iLEse45y4UrJFbfBFNoZ6oYzu+3Hdq3A=6Rn9hrg@mail.gmail.com>
 <CALzJLG8WGA5+cbyMd2f8Y2Qpcx=b72r2hSZ7Vn7+N-o3BzBvZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Or Gerlitz <gerlitz.or@gmail.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34161 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752071AbcHaBvD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 21:51:03 -0400
Received: by mail-pf0-f171.google.com with SMTP id p64so13635597pfb.1
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 18:51:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALzJLG8WGA5+cbyMd2f8Y2Qpcx=b72r2hSZ7Vn7+N-o3BzBvZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 30, 2016 at 12:35:58PM +0300, Saeed Mahameed wrote:
> On Mon, Aug 29, 2016 at 8:46 PM, Tom Herbert <tom@herbertland.com> wrote:
> > On Mon, Aug 29, 2016 at 8:55 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> >> On Mon, Aug 29, 2016 at 05:59:26PM +0300, Tariq Toukan wrote:
> >>> Hi Brenden,
> >>>
> >>> The solution direction should be XDP specific that does not hurt the
> >>> regular flow.
> >> An rcu_read_lock is _already_ taken for _every_ packet. This is 1/64th of
> 
> In other words "let's add  new small speed bump, we already have
> plenty ahead, so why not slow down now anyway".
> 
> Every single new instruction hurts performance, in this case maybe you
> are right, maybe we won't feel any performance
> impact, but that doesn't mean it is ok to do this.
Actually, I will make a stronger assertion. Unless your .config contains
CONFIG_PREEMPT=y (not most distros) or something like DEBUG_ATOMIC_SLEEP
(to trigger PREEMPT_COUNT), the code in this patch will be a nop.
Therefore, adding the protections that you mention below will be
_slower_ than the code already proposed.
> 
> 
> >> that.
> >>>
> >>> On 26/08/2016 11:38 PM, Brenden Blanco wrote:
> >>> >Depending on the preempt mode, the bpf_prog stored in xdp_prog may be
> >>> >freed despite the use of call_rcu inside bpf_prog_put. The situation is
> >>> >possible when running in PREEMPT_RCU=y mode, for instance, since the rcu
> >>> >callback for destroying the bpf prog can run even during the bh handling
> >>> >in the mlx4 rx path.
> >>> >
> >>> >Several options were considered before this patch was settled on:
> >>> >
> >>> >Add a napi_synchronize loop in mlx4_xdp_set, which would occur after all
> >>> >of the rings are updated with the new program.
> >>> >This approach has the disadvantage that as the number of rings
> >>> >increases, the speed of udpate will slow down significantly due to
> >>> >napi_synchronize's msleep(1).
> >>> I prefer this option as it doesn't hurt the data path. A delay in a
> >>> control command can be tolerated.
> >>> >Add a new rcu_head in bpf_prog_aux, to be used by a new bpf_prog_put_bh.
> >>> >The action of the bpf_prog_put_bh would be to then call bpf_prog_put
> >>> >later. Those drivers that consume a bpf prog in a bh context (like mlx4)
> >>> >would then use the bpf_prog_put_bh instead when the ring is up. This has
> >>> >the problem of complexity, in maintaining proper refcnts and rcu lists,
> >>> >and would likely be harder to review. In addition, this approach to
> >>> >freeing must be exclusive with other frees of the bpf prog, for instance
> >>> >a _bh prog must not be referenced from a prog array that is consumed by
> >>> >a non-_bh prog.
> >>> >
> >>> >The placement of rcu_read_lock in this patch is functionally the same as
> >>> >putting an rcu_read_lock in napi_poll. Actually doing so could be a
> >>> >potentially controversial change, but would bring the implementation in
> >>> >line with sk_busy_loop (though of course the nature of those two paths
> >>> >is substantially different), and would also avoid future copy/paste
> >>> >problems with future supporters of XDP. Still, this patch does not take
> >>> >that opinionated option.
> >>> So you decided to add a lock for all non-XDP flows, which are 99% of
> >>> the cases.
> >>> We should avoid this.
> >> The whole point of rcu_read_lock architecture is to be taken in the fast
> >> path. There won't be a performance impact from this patch.
> >
> > +1, this is nothing at all like a spinlock and really this should be
> > just like any other rcu like access.
> >
> > Brenden, tracking down how the structure is freed needed a few steps,
> > please make sure the RCU requirements are well documented. Also, I'm
> > still not a fan of using xchg to set the program, seems that a lock
> > could be used in that path.
> >
> > Thanks,
> > Tom
> 
> Sorry folks I am with Tariq on this, you can't just add a single
> instruction which is only valid/needed for 1% of the use cases
> to the driver's general data path, even if it was as cheap as one cpu cycle!
How about 0?

$ diff mlx4_en.ko.norcu.s mlx4_en.ko.rcu.s | wc -l                                                                                                                                                                                                                           
0

> 
> Let me try to suggest something:
> instead of taking the rcu_read_lock for the whole
> mlx4_en_process_rx_cq, we can minimize to XDP code path only
> by double checking xdp_prog (non-protected check followed by a
> protected check inside mlx4 XDP critical path).
> 
> i.e instead of:
> 
> rcu_read_lock();
> 
> xdp_prog = ring->xdp_prog;
> 
> //__Do lots of non-XDP related stuff__
> 
> if (xdp_prog) {
>     //Do XDP magic ..
> }
> //__Do more of non-XDP related stuff__
> 
> rcu_read_unlock();
> 
> 
> We can minimize it to XDP critical path only:
> 
> //Non protected xdp_prog dereference.
> if (xdp_prog) {
>      rcu_read_lock();
>      //Protected dereference to ring->xdp_prog
>      xdp_prog = ring->xdp_prog;
>      if(unlikely(!xdp_prg)) goto unlock;

The addition of this branch and extra deref is now slowing down the xdp
path compared to the current proposal.

>     //Do XDP magic ..
> 
> unlock:
>      rcu_read_unlock();
> }
