From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Questions on XDP
Date: Thu, 16 Feb 2017 14:36:41 -0800
Message-ID: <58A62979.1050600@gmail.com>
References: <CAKgT0Uc0RQyK0SCALEUVGBj8JMHCfp+CqiBsTJXN9mat9jUNjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Alexander Duyck <alexander.duyck@gmail.com>,
        Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36656 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933507AbdBPWgy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 17:36:54 -0500
Received: by mail-pf0-f170.google.com with SMTP id 189so8459602pfu.3
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 14:36:54 -0800 (PST)
In-Reply-To: <CAKgT0Uc0RQyK0SCALEUVGBj8JMHCfp+CqiBsTJXN9mat9jUNjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-16 12:41 PM, Alexander Duyck wrote:
> So I'm in the process of working on enabling XDP for the Intel NICs
> and I had a few questions so I just thought I would put them out here
> to try and get everything sorted before I paint myself into a corner.
> 

Added Daniel.

> So my first question is why does the documentation mention 1 frame per
> page for XDP?  Is this with the intention at some point to try and
> support page flipping into user space, or is it supposed to have been
> for the use with an API such as the AF_PACKET mmap stuff?  If I am not
> mistaken the page flipping has been tried in the past and failed, and
> as far as the AF_PACKET stuff my understanding is that the pages had
> to be mapped beforehand so it doesn't gain us anything without a
> hardware offload to a pre-mapped queue.

+1 here. The implementation for virtio does not use page per packet and
works fine. And agreed AF_PACKET does not require it.

If anyone has page-flipping code I would be happy to benchmark it.

> 
> Second I was wondering about supporting jumbo frames and scatter
> gather.  Specifically if I let XDP handle the first 2-3K of a frame,
> and then processed the remaining portion of the frame following the
> directive set forth based on the first frame would that be good enough
> to satisfy XDP or do I actually have to support 1 linear buffer
> always.

For now yes. But, I need a solution to support 64k TSO packets or else
VM to VM traffic is severely degraded in my vswitch use case.

> 
> Finally I was looking at xdp_adjust_head.  From what I can tell all
> that is technically required to support it is allowing the head to be
> adjusted either in or out.  I'm assuming there is some amount of
> padding that is preferred.  With the setup I have currently I am
> guaranteeing at least NET_SKB_PAD + NET_IP_ALIGN, however I have found
> that there should be enough room for 192 bytes on an x86 system if I
> am using a 2K buffer.  I'm just wondering if that is enough padding or
> if we need more for XDP.
> 

Not surprisingly I'm also in agreement here it would help the ixgbe
implementation out.

> Anyway sorry for the stupid questions but I haven't been paying close
> of attention to this and was mostly focused on the DMA bits needed to
> support this so now I am playing catch-up.

None of the above are stupid IMO. Let me send out the ixgbe implementation
later this afternoon so you can have a look at my interpretation of the
rules.

> 
> - Alex
> 
