From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: XDP offload to hypervisor
Date: Mon, 23 Jan 2017 13:56:16 -0800
Message-ID: <58867C00.1060901@gmail.com>
References: <20170123230727-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36089 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbdAWV4d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 16:56:33 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so14682212pgf.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 13:56:32 -0800 (PST)
In-Reply-To: <20170123230727-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-23 01:40 PM, Michael S. Tsirkin wrote:
> I've been thinking about passing XDP programs from guest to the
> hypervisor.  Basically, after getting an incoming packet, we could run
> an XDP program in host kernel.
> 

Interesting. I am planning on adding XDP to tun driver. My use case
is we want to use XDP to restrict VM traffic. I was planning on pushing
the xdp program execution into tun_get_user(). So different then "offloading"
an xdp program into hypervisor.

> If the result is XDP_DROP or XDP_TX we don't need to wake up the guest at all!
> 

nice win.

> When using tun for networking - especially with adjust_head - this
> unfortunately probably means we need to do a data copy unless there is
> enough headroom.  How much is enough though?

We were looking at making headroom configurable on Intel drivers or at
least matching it with XDP headroom guidelines. (although the developers
had the same complaint about 256B being large). Then at least on supported
drivers the copy could be an exception path.

> 
> Another issue is around host/guest ABI. Guest BPF could add new features
> at any point. What if hypervisor can not support it all?  I guess we
> could try loading program into hypervisor and run it within guest on
> failure to load, but this ignores question of cross-version
> compatibility - someone might start guest on a new host
> then try to move to an old one. So we will need an option
> "behave like an older host" such that guest can start and then
> move to an older host later. This will likely mean
> implementing this validation of programs in qemu userspace unless linux
> can supply something like this. Is this (disabling some features)
> something that might be of interest to larger bpf community?

This is interesting to me at least. Another interesting "feature" of
running bpf in qemu userspace is it could work with vhost_user as well
presumably?

> 
> With a device such as macvtap there exist configurations where a single
> guest is in control of the device (aka passthrough mode) in that case
> there's a potential to run xdp on host before host skb is built, unless
> host already has an xdp program attached.  If it does we could run the
> program within guest, but what if a guest program got attached first?
> Maybe we should pass a flag in the packet "xdp passed on this packet in
> host". Then, guest can skip running it.  Unless we do a full reset
> there's always a potential for packets to slip through, e.g. on xdp
> program changes. Maybe a flush command is needed, or force queue or
> device reset to make sure nothing is going on. Does this make sense?
> 

Could the virtio driver pretend its "offloading" the XDP program to
hardware? This would make it explicit in VM that the program is run
before data is received by virtio_net. Then qemu is enabling the
offload framework which would be interesting.

> Thanks!
> 
