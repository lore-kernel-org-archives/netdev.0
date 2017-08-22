From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Tue, 22 Aug 2017 08:37:10 +0200
Message-ID: <20170822083710.47a182a2@redhat.com>
References: <20170821212506.1cb0d5d6@redhat.com>
        <20170821223540.atktdricmks26c27@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        =?UTF-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>,
        brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35570 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752736AbdHVGhS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 02:37:18 -0400
In-Reply-To: <20170821223540.atktdricmks26c27@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Aug 2017 15:35:42 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Mon, Aug 21, 2017 at 09:25:06PM +0200, Jesper Dangaard Brouer wrote:
> > 
> > Third gotcha(3): You got this far, loaded xdp on both interfaces, and
> > notice now that (with default setup) you can RX with 14Mpps but only
> > TX with 6.9Mpps (and might have 5% idle cycles).  I debugged this via
> > perf tracepoint event xdp:xdp_redirect, and found this was due to
> > overrunning the xdp TX ring-queue size.  
> 
> we should probably fix this somehow.

Gotcha-3 (quoted above) is an interesting problem.  At first it looks
like a driver tuning problem. But it is actually an inherent property
of XDP, as there is no-queue or push-back flow control with XDP, there
is no way to handle TX queue overrun.
 My proposed solution: I want to provide a facility for userspace to
load another eBPF program (at the tracepoint xdp_redirect), which can
"see" the issue occurring.  This allows a XDP/BPF developer to
implement their own reaction/mitigation flow-control (e.g. via a map
shared with the XDP program).


> Once tx-ing netdev added to devmap we can enable xdp on it automatically?

I think you are referring to Gotcha-2 here:

  Second gotcha(2): you cannot TX out a device, unless it also have a
  xdp bpf program attached. (This is an implicit dependency, as the
  driver code need to setup XDP resources before it can ndo_xdp_xmit).

Yes, we should work on improving this situation.  Auto enabling XDP
when a netdev is added to a devmap is a good solution.  Currently this
is tied to loading an XDP bpf_prog.  Do you propose loading a dummy
bpf_prog on the netdev? (then we need to handle 1. not replacing
existing bpf_prog, 2. on take-down don't remove "later" loaded
bpf_prog).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
