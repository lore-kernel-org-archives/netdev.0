From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Fri, 23 Sep 2016 15:00:40 +0200
Message-ID: <20160923150040.0e3dc7d5@redhat.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
        <1474408824-418864-2-git-send-email-tom@herbertland.com>
        <06280af8-5451-c423-d295-a5f3f51e63cf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
        netdev@vger.kernel.org, kernel-team@fb.com, tariqt@mellanox.com,
        bblanco@plumgrid.com, alexei.starovoitov@gmail.com,
        eric.dumazet@gmail.com, brouer@redhat.com,
        Thomas Graf <tgraf@suug.ch>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43428 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759830AbcIWNAr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 09:00:47 -0400
In-Reply-To: <06280af8-5451-c423-d295-a5f3f51e63cf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Sep 2016 07:13:30 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 16-09-20 06:00 PM, Tom Herbert wrote:
> > This patch creates an infrastructure for registering and running code at
> > XDP hooks in drivers. This is based on the orignal XDP?BPF and borrows
> > heavily from the techniques used by netfilter to make generic nfhooks.
> >
> > An XDP hook is defined by the  xdp_hook_ops. This structure contains the
> > ops of an XDP hook. A pointer to this structure is passed into the XDP
> > register function to set up a hook. The XDP register function mallocs
> > its own xdp_hook_ops structure and copies the values from the
> > xdp_hook_ops passed in. The register function also stores the pointer
> > value of the xdp_hook_ops argument; this pointer is used in subsequently
> > calls to XDP to identify the registered hook.
> >
> > The interface is defined in net/xdp.h. This includes the definition of
> > xdp_hook_ops, functions to register and unregister hook ops on a device
> > or individual instances of napi, and xdp_hook_run that is called by
> > drivers to run the hooks.
> >  
> 
> Tom,
> perused the thread and it seems you are serious ;->
> Are we heading towards Frankenstein Avenue?
> The whole point behind letting in XDP is so that _small programs_
> can be written to do some quick thing. eBPF 4K program limit was
> touted as the check and bound. eBPF sounded fine.
> This sounds like a huge contradiction.
> 
> cheers,
> jamal

Hi Jamal,

I don't understand why you think this is so controversial. The way I
see it (after reading the thread): This is about allowing kernel
components to _also_ use the XDP hook.

I believe Tom have a valid use-case in ILA. The NVE (Network
Virtualization Edge) component very naturally fits in the XDP hook, as
it only need to look at the IPv6 address and do a table lookup (in a
ILA specific data structure) to see if this packet is for local stack
delivery or forward.  For forward it does not need take the performance
hit of allocating SKBs etc.

You can see it as a way to accelerate the NVE component. I can imagine
it could be done in approx 10-20 lines of code, as it would use the
existing ILA lookup function calls.

AFAIK Thomas Graf also see XDP as an acceleration for bpf_cls, but he
is lucky because his code is already eBFP based.

To support Tom's case, with eBPF, I think we would have to implement
specific eBPF helper functions that can do the ILA table lookups.  And
then need a userspace component to load the eBPF program.  Why add all
this, when we could contain all this in the kernel, and simply call
this as native C-code via the XDP hook?

Notice, this is not about throwing eBPF out.  Using eBPF is _very_
essential for XDP.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
