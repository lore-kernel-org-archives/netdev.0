From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Fri, 23 Sep 2016 13:20:59 -0400
Message-ID: <20160923172059.GB2484@oracle.com>
References: <20160920190929.57ddaeb0@griffin>
 <20160922.015242.735026657310158125.davem@davemloft.net>
 <20160922213010.GA32052@oracle.com>
 <20160923.080618.678103827885223586.davem@davemloft.net>
 <CAKgT0UcoDb5T9xwfAq83cNwU=XAKZxf0TmPiJZQyHFPr82zggg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Benc <jbenc@redhat.com>,
        Netdev <netdev@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Paolo Abeni <pabeni@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17237 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758967AbcIWRVX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 13:21:23 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UcoDb5T9xwfAq83cNwU=XAKZxf0TmPiJZQyHFPr82zggg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/23/16 07:17), Alexander Duyck wrote:
> >> Is this basically about, e.g., putting the vxlanhdr in its own
> >> skb_frag_t, or something else?
> >
> > Yes, and this way skb_header_pointer() is forced to do a memcpy.
  :
> For Tx it all becomes a bit trickier since it would likely require us
> to shift the frags up by 1 when we go from outer headers to inner
> headers.  

here's how I thought through this so far, based on what I'm seeing for 
mld_newpack/vxlan (not sure if this can be extended for all the 
other tunnelling cases as well)..

today the skb is set up so that we reserve LL_RESERVED_SPACE
in the headroom, and vxlan sets up needed headroom for 
(outer_ether + ip + udp + vxlan + inner_ether). Insterad, if it
set up the needed_headroom for just (outer_ether, ip, udp) and
we had something like a "needed_fragroom" in the net_device, 
maybe we could set up the skb so that we dont have to shift the frags
by 1. 

Drawbacks: this ends up with every skb going through vxlan etc being
non-linear, so it is a lot of churn for several functions (e.g.,
even mld_newpack() cannot just skb_put() things around). Also
this probably gets quickly messy if we are dealing with multiple 
encaapsulations (even in the simple vxlan case we have 
vxlan + inner mac/ip/etc)

BTW, I wonder if there is a small vxlan bug here- are we
accounting for the outer_ether twice in LL_RESERVED_SPACE: once in 
->hard_header_len, and once in ->needed_headroom?

> One thought I had on that is that we could possibly avoid
> having to do any allocation and could just take a reference on the
> head_frag if that is what we are using.  Then we just add a 2 byte pad
> and resume writing headers in place and the pointer offsets for the
> inner headers would remain valid, though they would be past the point
> of skb->tail.

I am not sure I follow, can you elaborate? Doesnt this also assume
that every skb is necessarily non-linear?

--Sowmini
