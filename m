From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH v5 0/6] XDP for virtio_net
Date: Thu, 8 Dec 2016 11:38:16 -0800
Message-ID: <20161208193814.GA1954@ast-mbp.thefacebook.com>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
 <20161208.141702.1346950420275854265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.fastabend@gmail.com, daniel@iogearbox.net, mst@redhat.com,
        shm@cumulusnetworks.com, tgraf@suug.ch, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35520 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752312AbcLHTiV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:38:21 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so27702622pga.2
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 11:38:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161208.141702.1346950420275854265.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 02:17:02PM -0500, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Wed, 07 Dec 2016 12:10:47 -0800
> 
> > This implements virtio_net for the mergeable buffers and big_packet
> > modes. I tested this with vhost_net running on qemu and did not see
> > any issues. For testing num_buf > 1 I added a hack to vhost driver
> > to only but 100 bytes per buffer.
>  ...
> 
> So where are we with this?
> 
> I'm not too thrilled with the idea of making XDP_TX optional or
> something like that.  If someone enables XDP, there is a tradeoff.
> 
> I also have reservations about the idea to make jumbo frames work
> without giving XDP access to the whole packet.  If it wants to push or
> pop a header, it might need to know the whole packet length.  How will
> you pass that to the XDP program?
> 
> Some kinds of encapsulation require trailers, thus preclusing access
> to the entire packet precludes those kinds of transformations.

+1

> This is why we want simple, linear, buffer access for XDP.
> 
> Even the most seemingly minor exception turns into a huge complicated
> mess.

+1

and from the other thread:
> > Can't we disable XDP_TX somehow? Many people might only want RX drop,
> > and extra queues are not always there.
> >
> 
> Alexei, Daniel, any thoughts on this?

I don't like it.

> I know we were trying to claim some base level of feature support for
> all XDP drivers. I am sympathetic to this argument though for DDOS we
> do not need XDP_TX support. And virtio can become queue constrained
> in some cases.

especially for ddos case doing lro/gro is not helpful.
I frankly don't see a use case where you'd want to steer a packet
all the way into VM just to drop them there?
Without XDP_TX it's too crippled. adjust_head() won't be possible,
packet mangling would have to be disabled and so on.
If xdp program doesn't see raw packet it can only parse the headers of
this jumbo meta-packet and drop it, but for virtio it's really too late.
ddos protection needs to be done at the earliest hw nic receive.
I think if driver claims xdp support it needs to support
drop/pass/tx and adjust_head. For metadata passing up into stack from xdp
we need adjust_head, for encap/decap we need it too. And lro is in the way
of such transformations.
We struggled a lot with cls_bpf due to all metadata inside skb that needs
to be kept correct. Feeding non-raw packets into xdp is a rat hole.
