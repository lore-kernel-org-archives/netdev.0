From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: xdp_redirect ifindex vs port. Was: best API for returning/setting
 egress port?
Date: Wed, 19 Apr 2017 21:38:44 -0700
Message-ID: <58F83B54.7060605@gmail.com>
References: <20170418215856.5fda7127@redhat.com>
 <20170419200259.GK4730@C02RW35GFVH8.dhcp.broadcom.net>
 <58F7E9F3.5090604@iogearbox.net>
 <20170420025611.GA53935@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:34401 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938898AbdDTEjJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 00:39:09 -0400
In-Reply-To: <20170420025611.GA53935@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 07:56 PM, Alexei Starovoitov wrote:
> On Thu, Apr 20, 2017 at 12:51:31AM +0200, Daniel Borkmann wrote:
>>
>> Is there a concrete reason that all the proposed future cases like sockets
>> have to be handled within the very same XDP_REDIRECT return code? F.e. why
>> not XDP_TX_NIC that only assumes ifindex as proposed in the patch, and future
>> ones would get a different return code f.e. XDP_TX_SK only handling sockets
>> when we get there implementation-wise?
> 
> yeah. let's keep redirect to sockets, tunnels, crypto and exotic things
> out of this discussion.
> XDP_REDIRECT should assume L2 raw packet is being redirected to another L2 netdev.
> If we make it too generic it will lose performance.
> 
> For cls_bpf the ifindex concept is symmetric. The program can access it as
> skb->ifindex on receive and can redirect to another ifindex via bpf_redirect() helper.
> Since netdev is not locked, it's actually big plus, since container management
> control plane can simply delete netns+veth and it goes away. The program can
> have dangling ifindex (if control plane is buggy and didn't update the bpf side),
> but it's harmless. Packets that redirect to non-existing ifindex are dropped.
> This approach already understood and works well, so for XDP I suggest to use
> the same approach initially before starting to reinvent the wheel.
> struct xdp_md needs ifindex field and xdp_redirect() helper that redirects
> to L2 netdev only. That's it. Simple and easy.
> I think the main use cases in John's and Jesper's minds is something like
> xdpswitch where packets are coming from VMs and from physical eths and
> being redirected to either physical eth or to VM via upcoming vhost+xdp support.
> This xdp_md->ifindex + xdp_redirect(to_ifindex) will solve it just fine.

hmm I must be missing something, bpf_redirect() helper should be used as a
return statement, e.g.

	return bpf_redirect(ifindex, flags);

Its a bit awkward to use in any other way. You would have to ensure the
program returns TC_ACT_REDIRECT in all cases I presume. It seems incredibly
fragile and gains nothing as far as I can tell. bpf_redirect uses per_cpu
data and expects the core to call skb_do_redirect() to push the packet into
the correct netdev. bpf_redirect() does not modify the skb->ifindex value,
looking at the code now.

Are you suggesting using xdp_md to store the ifindex value instead of a per
cpu variable in the redirect helper? Do you really mean the xdp_md struct in
the uapi headers? I don't see why it needs to be in the UAPI at all. If we
don't like per cpu variables it could be pushed as part of xdp_buff I guess.

My suggestion is we could add an ifindex to the xdp_md structure and have the
receiving NIC driver populate the value assuming it is useful to programs. But,
if we use cls_bpf as a model then xdp_md ifindex is more or less independent of
the redirect helper. In my opinion we should avoid diverging cls bpf and xdp bpf
in subtle ways like handling of ifindex and redirect.

> 
> Once we have vhost+xdp and all other bits implemented, we must come back
> to this discussion about having port mapping table. As I mentioned
> during netconf I think it's very useful, but I don't think we should
> gate vhost+xdp and xdp_redirect work on this discussion.
> As far as this port mapping table we would need 'port' field in xdp_md as well
> and xdp_redirect_port() done via helper or via extra 'out_port' field in xdp_md
> plus another XDP_REDIRECT_PORT action code.
> The actual port table (array) should be populated by user space with netdevs
> and these netdev will have their refcnt incremented. Then we'll have discussion
> what to do with netdev_unregister notifiers, whether they should be auto-removed
> from port table or bpf should have a chance to be notified and act on it.
> Such port mapping will allow us to optimize inevitable call
> dev_get_by_index_rcu(dev_net(skb->dev), ri->ifindex);
> away, since netdevs will be stored in the port table and direct deref
> port_map_array[xdp_md->out_port] will give us target netdev quickly.
> It's nice optimization and there are other more powerful optimizations we
> can do with such port table (since we will know in advance which netdevs
> the program will be redirecting too), but I still think we should do
> ifindex based xdp_redirect first and only add this port table later.
> 

Agreed on all this further optimization would be welcome of course after
basic implementation is in place.
