From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: XDP user interface confusions
Date: Thu, 15 Sep 2016 11:58:35 -0700
Message-ID: <20160915185835.GA4418@gmail.com>
References: <20160915201402.15b65136@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "iovisor-dev@lists.iovisor.org" <iovisor-dev@lists.iovisor.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34685 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753580AbcIOS6i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 14:58:38 -0400
Received: by mail-pa0-f46.google.com with SMTP id wk8so18414696pab.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 11:58:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160915201402.15b65136@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 08:14:02PM +0200, Jesper Dangaard Brouer wrote:
> Hi Brenden,
> 
> I don't quite understand the semantics of the XDP userspace interface.
> 
> We allow XDP programs to be (unconditionally) exchanged by another
> program, this avoids taking the link down+up and avoids reallocating
> RX ring resources (which is great).
> 
> We have two XDP samples programs in samples/bpf/ xdp1 and xdp2.  Now I
> want to first load xdp1 and then to avoid the linkdown I load xdp2,
> and then afterwards remove/stop program xdp1.
> 
> This does NOT work, because (in samples/bpf/xdp1_user.c) when xdp1
> exits it unconditionally removes the running XDP program (loaded by xdp2)
> via set_link_xdp_fd(ifindex, -1).  The xdp2 user program is still
> running, and is unaware of its xdp/bpf program have been unloaded.
> 
> I find this userspace interface confusing. What this your intention?
> Perhaps you can explain what the intended semantics or specification is?

In practice, we've used a single agent process to manage bpf programs on
behalf of the user applications. This agent process uses common linux
functionalities to add semantics, while not really relying on the bpf
handles themselves to take care of that. For instance, the process may
put some lockfiles and what-not in /var/run/$PID, and maybe returns the
list of running programs through a http: or unix: interface.

So, from a user<->kernel API, the requirements are minimal...the agent
process just overwrites the loaded bpf program when the application
changes, or a new application comes online. There is nobody to 'notify'
when a handle changes.

When translating this into the kernel api that you see now, none of this
exists, because IMHO the kernel api should be unopinionated and generic.
The result is something that appears very "fire-and-forget", which
results in something simple yet safe at the same time; the refcounting
is done transparently by the kernel.

So, in practice, there is no xdp1 or xdp2, just xdp-agent at different
points in time. Or, better yet, no agent, just the programs running in
the kernel, with the handles of the programs residing solely in the
device, which are perhaps pinned to /sys/fs/bpf for semantic management
purposes. I didn't feel like it was appropriate to conflate different
bpf features in the kernel samples, so we don't see (and probably never
will) a sample which combines these features into a whole. That is best
left to userspace tools. It so happens that this is one of the projects
I am currently active on at $DAYJOB, and we fully intend to share the
details of that when it's in a suitable state.
> 
> -- 
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
