From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: XDP offload to hypervisor
Date: Wed, 25 Jan 2017 05:17:10 +0200
Message-ID: <20170125051337-mutt-send-email-mst@kernel.org>
References: <20170123230727-mutt-send-email-mst@kernel.org>
 <58867C00.1060901@gmail.com>
 <7b09fb3f-34bc-23d2-563f-79f28e5aec44@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48320 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751137AbdAYDRM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 22:17:12 -0500
Content-Disposition: inline
In-Reply-To: <7b09fb3f-34bc-23d2-563f-79f28e5aec44@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 10:45:18AM +0800, Jason Wang wrote:
> 
> 
> On 2017年01月24日 05:56, John Fastabend wrote:
> > On 17-01-23 01:40 PM, Michael S. Tsirkin wrote:
> > > I've been thinking about passing XDP programs from guest to the
> > > hypervisor.  Basically, after getting an incoming packet, we could run
> > > an XDP program in host kernel.
> > > 
> > Interesting. I am planning on adding XDP to tun driver. My use case
> > is we want to use XDP to restrict VM traffic. I was planning on pushing
> > the xdp program execution into tun_get_user(). So different then "offloading"
> > an xdp program into hypervisor.
> 
> This looks interesting to me. BTW, I was playing a patch and tries to make
> use of XDP to accelerate macvtap in passthrough mode rx on host. With the
> patch, XDP buffer instead of sbk could be used for vhost rx, and tests shows
> nice results.
> 
> But this seems conflict with XDP offload idea here.
> 
> Thanks

One way is to add ability to attach two XDP
programs to macvtap: guest and host. Run host first on XDP_PASS
run guest.

> > 
> > > If the result is XDP_DROP or XDP_TX we don't need to wake up the guest at all!
> > > 
> > nice win.
> > 
> > > When using tun for networking - especially with adjust_head - this
> > > unfortunately probably means we need to do a data copy unless there is
> > > enough headroom.  How much is enough though?
> > We were looking at making headroom configurable on Intel drivers or at
> > least matching it with XDP headroom guidelines. (although the developers
> > had the same complaint about 256B being large). Then at least on supported
> > drivers the copy could be an exception path.
> > 
> > > Another issue is around host/guest ABI. Guest BPF could add new features
> > > at any point. What if hypervisor can not support it all?  I guess we
> > > could try loading program into hypervisor and run it within guest on
> > > failure to load, but this ignores question of cross-version
> > > compatibility - someone might start guest on a new host
> > > then try to move to an old one. So we will need an option
> > > "behave like an older host" such that guest can start and then
> > > move to an older host later. This will likely mean
> > > implementing this validation of programs in qemu userspace unless linux
> > > can supply something like this. Is this (disabling some features)
> > > something that might be of interest to larger bpf community?
> > This is interesting to me at least. Another interesting "feature" of
> > running bpf in qemu userspace is it could work with vhost_user as well
> > presumably?
> > 
> > > With a device such as macvtap there exist configurations where a single
> > > guest is in control of the device (aka passthrough mode) in that case
> > > there's a potential to run xdp on host before host skb is built, unless
> > > host already has an xdp program attached.  If it does we could run the
> > > program within guest, but what if a guest program got attached first?
> > > Maybe we should pass a flag in the packet "xdp passed on this packet in
> > > host". Then, guest can skip running it.  Unless we do a full reset
> > > there's always a potential for packets to slip through, e.g. on xdp
> > > program changes. Maybe a flush command is needed, or force queue or
> > > device reset to make sure nothing is going on. Does this make sense?
> > > 
> > Could the virtio driver pretend its "offloading" the XDP program to
> > hardware? This would make it explicit in VM that the program is run
> > before data is received by virtio_net. Then qemu is enabling the
> > offload framework which would be interesting.
> > 
> > > Thanks!
> > > 
