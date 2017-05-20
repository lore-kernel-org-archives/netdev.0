From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC net-next PATCH 3/5] net: introduce XDP driver features
 interface
Date: Sat, 20 May 2017 09:53:31 +0200
Message-ID: <20170520095331.18c6be36@redhat.com>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
        <149512210317.14733.15039298820296846614.stgit@firesoul>
        <591F27B9.9070003@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        netdev@vger.kernel.org, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59250 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753266AbdETHxi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 May 2017 03:53:38 -0400
In-Reply-To: <591F27B9.9070003@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 May 2017 19:13:29 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 05/18/2017 05:41 PM, Jesper Dangaard Brouer wrote:
> > There is a fundamental difference between normal eBPF programs
> > and (XDP) eBPF programs getting attached in a driver. For normal
> > eBPF programs it is easy to add a new bpf feature, like a bpf
> > helper, because is it strongly tied to the feature being
> > available in the current core kernel code.  When drivers invoke a
> > bpf_prog, then it is not sufficient to simply relying on whether
> > a bpf_helper exists or not.  When a driver haven't implemented a
> > given feature yet, then it is possible to expose uninitialized
> > parts of xdp_buff.  The driver pass in a pointer to xdp_buff,
> > usually "allocated" on the stack, which must not be exposed.  
> 
> When xdp_buff is being extended, then we should at least zero
> initialize all in-tree users that don't support or populate this
> field, thus that it's not uninitialized memory. Better would be
> to have a way to reject the prog in the first place until it's
> implemented (but further comments on feature bits below).

Going down a path where we need to zero out the xdp_buff looks a lot
like the sk_buff zeroing, which is the top perf cost associated with
SKBs see[1].  XDP is is about not repeating the same issue we had with
the SKB...

[1] https://prototype-kernel.readthedocs.io/en/latest/blogposts/xdp25_eval_generic_xdp_tx.html#analyzing-build-skb-and-memset


> > Only two user visible NETIF_F_XDP_* net_device feature flags are
> > exposed via ethtool (-k) seen as "xdp" and "xdp-partial".
> > The "xdp-partial" is detected when there is not feature equality
> > between kernel and driver, and a netdev_warn is given.  
> 
> I think having something like a NETIF_F_XDP_BIT for ethtool to
> indicate support as "xdp" is quite useful. Avoids having to grep
> the kernel tree for ndo_xdp callback. ;) A "xdp-partial" would
> still be unclear/confusing to the user whether his program loads
> or doesn't which is the only thing a user (or some loading infra)
> cares about eventually, so one still needs to go trying to load
> the XDP code to see whether that fails for the native case.

Good that we agree on usefulness of the NETIF_F_XDP_BIT.  The
"xdp-partial" or "xdp-challenged" is an early indication to the user
that they should complain to the vendor.  I tried to keep it simple
towards the user. Do you think every feature bit should be exposed to
userspace?


> > The idea is that XDP_DRV_* feature bits define a contract between
> > the driver and the kernel, giving a reliable way to know that XDP
> > features a driver promised to implement. Thus, knowing what bpf
> > side features are safe to allow.
> >
> > There are 3 levels of features: "required", "devel" and "optional".
> >
> > The motivation is pushing driver vendors forward to support all
> > the new XDP features.  Once a given feature bit is moved into
> > the "required" features, the kernel will reject loading XDP
> > program if feature isn't implemented by driver.  Features under
> > developement, require help from the bpf infrastrucure to detect
> > when a given helper or direct-access is used, using a bpf_prog
> > bit to mark a need for the feature, and pulling in this bit in
> > the xdp_features_check().  When all drivers have implemented
> > a "devel" feature, it can be moved to the "required" feature and  
> 
> The problem is that once you add bits markers to bpf_prog like we
> used to do in the past, then as you do in patch 4/5 with the
> xdp_rxhash_needed bit, they will need to be turned /on/ unconditionally
> when a prog has tail calls.

Yes, with tail calls, we have to enable all features.  But that is a
good thing, as it forces vendors to quickly implement all features.
And it is no different from moving a feature into the "required" bits,
once all drivers implement it.  It is only a limitation for tail calls,
and something we can fix later (for handling this for tail calls).

BPF have some nice features of evaluating the input program
"load-time", which is what I'm taking advantage of as an optimization
here (let use this nice bpf property).   It is only tail calls that
cannot evaluate this "load-time".  Thus, if you care about tail calls,
supporting intermediate features, we could later fix that by adding a
runtime feature check in the case of tail calls.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
