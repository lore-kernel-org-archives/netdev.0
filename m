From: Jason Wang <jasowang@redhat.com>
Subject: Re: XDP offload to hypervisor
Date: Wed, 25 Jan 2017 10:51:22 +0800
Message-ID: <18a59e79-771c-af94-8630-6eb8de3bf536@redhat.com>
References: <20170123230727-mutt-send-email-mst@kernel.org>
 <20170124010201.GB60699@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56428 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751201AbdAYCvf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 21:51:35 -0500
In-Reply-To: <20170124010201.GB60699@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月24日 09:02, Alexei Starovoitov wrote:
> On Mon, Jan 23, 2017 at 11:40:29PM +0200, Michael S. Tsirkin wrote:
>> I've been thinking about passing XDP programs from guest to the
>> hypervisor.  Basically, after getting an incoming packet, we could run
>> an XDP program in host kernel.
>>
>> If the result is XDP_DROP or XDP_TX we don't need to wake up the guest at all!
> that's an interesting idea!
> Long term 'xdp offload' needs to be defined, since NICs become smarter
> and can accelerate xdp programs.
> So pushing the xdp program down from virtio in the guest into host
> and from x86 into nic cpu should probably be handled through the same api.
>
>> When using tun for networking - especially with adjust_head - this
>> unfortunately probably means we need to do a data copy unless there is
>> enough headroom.  How much is enough though?
> Frankly I don't understand the whole virtio nit picking that was happening.
> imo virtio+xdp by itself is only useful for debugging, development and testing
> of xdp programs in a VM. The discussion about performance of virtio+xdp
> will only be meaningful when corresponding host part is done.

I was doing a prototype to make XDP rx works for macvtap (with minor 
changes in the driver e.g mlx4). Tests shows improvements, plan to post 
as RFC after spring festival holiday in China. This is even useful for 
nested VM but can not work well for XDP offload.

> Likely in the form of vhost extensions and may be driver changes.
> Trying to optimize virtio+xdp when host is doing traditional skb+vhost
> isn't going to be impactful.
> But when host can do xdp in phyiscal NIC that can deliver raw
> pages into vhost that gets picked up by guest virtio, then we hopefully
> will be around 10G line rate. page pool is likely needed in such scenario.
> Some new xdp action like xdp_tx_into_vhost or whatever.

Yes, in my prototype, mlx4 XDP rx page pool were reused.

Thanks

> And guest will be seeing full pages that host nic provided and discussion
> about headroom will be automatically solved.
> Arguing that skb has 64-byte headroom and therefore we need to
> reduce XDP_PACKET_HEADROOM is really upside down.
>
>> Another issue is around host/guest ABI. Guest BPF could add new features
>> at any point. What if hypervisor can not support it all?  I guess we
>> could try loading program into hypervisor and run it within guest on
>> failure to load, but this ignores question of cross-version
>> compatibility - someone might start guest on a new host
>> then try to move to an old one. So we will need an option
>> "behave like an older host" such that guest can start and then
>> move to an older host later. This will likely mean
>> implementing this validation of programs in qemu userspace unless linux
>> can supply something like this. Is this (disabling some features)
>> something that might be of interest to larger bpf community?
> In case of x86->nic offload not all xdp features will be supported
> by the nic and that is expected. The user will request 'offload of xdp prog'
> in some form and if it cannot be done, then xdp programs will run
> on x86 as before. Same thing, I imagine, is applicable to virtio->host
> offload. Therefore I don't see a need for user space visible
> feature negotiation.
>
>> With a device such as macvtap there exist configurations where a single
>> guest is in control of the device (aka passthrough mode) in that case
>> there's a potential to run xdp on host before host skb is built, unless
>> host already has an xdp program attached.  If it does we could run the
>> program within guest, but what if a guest program got attached first?
>> Maybe we should pass a flag in the packet "xdp passed on this packet in
>> host". Then, guest can skip running it.  Unless we do a full reset
>> there's always a potential for packets to slip through, e.g. on xdp
>> program changes. Maybe a flush command is needed, or force queue or
>> device reset to make sure nothing is going on. Does this make sense?
> All valid questions and concerns.
> Since there is still no xdp_adjust_head support in virtio,
> it feels kinda early to get into detailed 'virtio offload' discussion.
>
