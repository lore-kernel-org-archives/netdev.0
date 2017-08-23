From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Wed, 23 Aug 2017 10:56:38 +0200
Message-ID: <20170823105638.332a8348@redhat.com>
References: <20170821212506.1cb0d5d6@redhat.com>
        <20170821223540.atktdricmks26c27@ast-mbp>
        <20170822083710.47a182a2@redhat.com>
        <20170822170913.35umf4j6hlmcnwtm@ast-mbp>
        <599C6747.8010005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        =?UTF-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>,
        brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44608 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753496AbdHWI4p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 04:56:45 -0400
In-Reply-To: <599C6747.8010005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Aug 2017 10:17:59 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> On 08/22/2017 10:09 AM, Alexei Starovoitov wrote:
> > On Tue, Aug 22, 2017 at 08:37:10AM +0200, Jesper Dangaard Brouer wrote:  
> >>
> >>  
> >>> Once tx-ing netdev added to devmap we can enable xdp on it automatically?  
> >>
> >> I think you are referring to Gotcha-2 here:  
> > 
> > oops. yes :)
> >   
> >>
> >>   Second gotcha(2): you cannot TX out a device, unless it also have a
> >>   xdp bpf program attached. (This is an implicit dependency, as the
> >>   driver code need to setup XDP resources before it can ndo_xdp_xmit).
> >>
> >> Yes, we should work on improving this situation.  Auto enabling XDP
> >> when a netdev is added to a devmap is a good solution.  Currently this
> >> is tied to loading an XDP bpf_prog.  Do you propose loading a dummy
> >> bpf_prog on the netdev? (then we need to handle 1. not replacing
> >> existing bpf_prog, 2. on take-down don't remove "later" loaded
> >> bpf_prog).  
> > 
> > right. these things need to be taken care of.
> > Technically for ndo_xdp_xmit to work the program doesn't need
> > to be attached, but the device needs to be in xdp mode with
> > configured xdp tx rings.
> > The easiest, of course, is just to document it :)
> > and may be add some sort of warning that if netdev is added
> > to devmap and it's not in xdp mode, return warning or error.
> >   
> 
> When I wrote this I assumed some user space piece could
> load the "dummy" nop program on devices as needed. It seemed
> easier than putting semi-complex logic in the kernel to load
> programs on update_elem, but only if the user hasn't already
> loaded a program and then unload it but again only if some
> criteria is met. Then we would have one more kernel path into
> load/unload BPF programs and would need all the tests and what
> not.

I agree, it is not good to add this kind of logic to the kernel. We
would create too many funny race conditions with userspace.

> +1 for documenting and userland usability patches.

We still don't have a good place for XDP documentation.  My own[1]
attempt have gotten out-of-sync, and I need to restructure the
rst-docs, before I want to propose it for the kernel.

[1] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/index.html

I want to create some samples/examples with XDP_REDIRECT, that
highlight this property.  Maybe the samples/bpf/xdp_redirect{,_map}
should automatically attach a XDP bpf_prog to the egress device?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
