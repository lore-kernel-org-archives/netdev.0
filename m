From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: xdp_redirect ifindex vs port. Was: best API for
 returning/setting egress port?
Date: Thu, 20 Apr 2017 08:10:51 +0200
Message-ID: <20170420081051.77a41aa8@redhat.com>
References: <20170418215856.5fda7127@redhat.com>
        <20170419200259.GK4730@C02RW35GFVH8.dhcp.broadcom.net>
        <58F7E9F3.5090604@iogearbox.net>
        <20170420025611.GA53935@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46452 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941306AbdDTGK7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 02:10:59 -0400
In-Reply-To: <20170420025611.GA53935@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Apr 2017 19:56:13 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Thu, Apr 20, 2017 at 12:51:31AM +0200, Daniel Borkmann wrote:
> > 
> > Is there a concrete reason that all the proposed future cases like sockets
> > have to be handled within the very same XDP_REDIRECT return code? F.e. why
> > not XDP_TX_NIC that only assumes ifindex as proposed in the patch, and future
> > ones would get a different return code f.e. XDP_TX_SK only handling sockets
> > when we get there implementation-wise?  
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
> 
> Once we have vhost+xdp and all other bits implemented, we must come back
> to this discussion about having port mapping table. As I mentioned
> during netconf I think it's very useful, but I don't think we should
> gate vhost+xdp and xdp_redirect work on this discussion.
> As far as this port mapping table we would need 'port' field in xdp_md as well
> and xdp_redirect_port() done via helper or via extra 'out_port' field in xdp_md
> plus another XDP_REDIRECT_PORT action code.

Guess it would be easier to talk about if we name it "ingress_port" and
"egress_port".

> The actual port table (array) should be populated by user space with netdevs
> and these netdev will have their refcnt incremented. Then we'll have discussion
> what to do with netdev_unregister notifiers, whether they should be auto-removed
> from port table or bpf should have a chance to be notified and act on it.
> Such port mapping will allow us to optimize inevitable call
> dev_get_by_index_rcu(dev_net(skb->dev), ri->ifindex);
> away, since netdevs will be stored in the port table and direct deref
> port_map_array[xdp_md->out_port] will give us target netdev quickly.

I agree with above paragraph, and is happy that you can see that this
will actually be faster than using ifindex'es.

> It's nice optimization and there are other more powerful optimizations we
> can do with such port table (since we will know in advance which netdevs
> the program will be redirecting too), but I still think we should do
> ifindex based xdp_redirect first and only add this port table later.

No, we cannot first do an ifindex based xdp_redirect. The point of the
port table is to sandbox which ports XDP can use.

XDP is different than TC/cls_bpf, as it does "bypass", there is no
other layer that can stop or inspect these packets. The TC hooks
redirect into the network stack, which have all the usual facilities
available for filtering, inspection and debugging what is going on
(e.g. tcpdump works for TC redirect).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
