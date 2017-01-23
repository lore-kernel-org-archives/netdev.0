From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: XDP offload to hypervisor
Date: Tue, 24 Jan 2017 00:26:50 +0200
Message-ID: <20170124000408-mutt-send-email-mst@kernel.org>
References: <20170123230727-mutt-send-email-mst@kernel.org>
 <58867C00.1060901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42602 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751355AbdAWW0v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 17:26:51 -0500
Content-Disposition: inline
In-Reply-To: <58867C00.1060901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 01:56:16PM -0800, John Fastabend wrote:
> On 17-01-23 01:40 PM, Michael S. Tsirkin wrote:
> > I've been thinking about passing XDP programs from guest to the
> > hypervisor.  Basically, after getting an incoming packet, we could run
> > an XDP program in host kernel.
> > 
> 
> Interesting. I am planning on adding XDP to tun driver. My use case
> is we want to use XDP to restrict VM traffic. I was planning on pushing
> the xdp program execution into tun_get_user(). So different then "offloading"
> an xdp program into hypervisor.

tun currently supports TUNATTACHFILTER. Do you plan to extend it then?

So maybe there's need to support more than one program.

Would it work if we run one (host-supplied)
and then if we get XDP_PASS run another (guest supplied)
otherwise don't wake up guest?


> > If the result is XDP_DROP or XDP_TX we don't need to wake up the guest at all!
> > 
> 
> nice win.
> 
> > When using tun for networking - especially with adjust_head - this
> > unfortunately probably means we need to do a data copy unless there is
> > enough headroom.  How much is enough though?
> 
> We were looking at making headroom configurable on Intel drivers or at
> least matching it with XDP headroom guidelines. (although the developers
> had the same complaint about 256B being large).
> Then at least on supported
> drivers the copy could be an exception path.

So I am concerned that userspace comes to depend on support for 256byte
headroom that this patchset enables. How about 
-#define XDP_PACKET_HEADROOM 256
+#define XDP_PACKET_HEADROOM 64
so we start with a concervative value?
In fact NET_SKB_PAD would be ideal I think but it's
platform dependent.

Or at least do the equivalent for virtio only ...

> > 
> > Another issue is around host/guest ABI. Guest BPF could add new features
> > at any point. What if hypervisor can not support it all?  I guess we
> > could try loading program into hypervisor and run it within guest on
> > failure to load, but this ignores question of cross-version
> > compatibility - someone might start guest on a new host
> > then try to move to an old one. So we will need an option
> > "behave like an older host" such that guest can start and then
> > move to an older host later. This will likely mean
> > implementing this validation of programs in qemu userspace unless linux
> > can supply something like this. Is this (disabling some features)
> > something that might be of interest to larger bpf community?
> 
> This is interesting to me at least. Another interesting "feature" of
> running bpf in qemu userspace is it could work with vhost_user as well
> presumably?

I think with vhost user you would want to push it out
to the switch, not run it in qemu.
IOW qemu gets the program and sends it to the switch.
Response is sent to guest so it knows whether switch can support it.

> > 
> > With a device such as macvtap there exist configurations where a single
> > guest is in control of the device (aka passthrough mode) in that case
> > there's a potential to run xdp on host before host skb is built, unless
> > host already has an xdp program attached.  If it does we could run the
> > program within guest, but what if a guest program got attached first?
> > Maybe we should pass a flag in the packet "xdp passed on this packet in
> > host". Then, guest can skip running it.  Unless we do a full reset
> > there's always a potential for packets to slip through, e.g. on xdp
> > program changes. Maybe a flush command is needed, or force queue or
> > device reset to make sure nothing is going on. Does this make sense?
> > 
> 
> Could the virtio driver pretend its "offloading" the XDP program to
> hardware? This would make it explicit in VM that the program is run
> before data is received by virtio_net. Then qemu is enabling the
> offload framework which would be interesting.

On qemu side this is not a problem a command causes
a trap and qemu could flush the queue. But the packets
are still in the rx queue and get processed by napi later.
I think the cleanest interface for it might be a command consuming
an rx buffer and writing a pre-defined pattern into it.
This way guest can figure out how far did device get in the rx queue.


> > Thanks!
> > 
