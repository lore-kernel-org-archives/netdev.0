From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Mon, 10 Apr 2017 15:33:26 -0400 (EDT)
Message-ID: <20170410.153326.450347050098977889.davem@davemloft.net>
References: <20170409.133528.660876505013192371.davem@davemloft.net>
        <20170410021807.GA17150@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50556 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751656AbdDJTd2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 15:33:28 -0400
In-Reply-To: <20170410021807.GA17150@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Sun, 9 Apr 2017 19:18:09 -0700

> On Sun, Apr 09, 2017 at 01:35:28PM -0700, David Miller wrote:
>> +	if (skb_linearize(skb))
>> +		goto do_drop;
> 
> do we need to force disable gro ?

I think we do.

> Otherwise if we linearize skb_is_gso packet it will be huge
> and not similar to normal xdp packets?

I completely agree.

> gso probably needs to disabled too to avoid veth surprises?

I'm not so sure about that.

> 
>> +
>> +	hlen = skb_headlen(skb);
>> +	xdp.data = skb->data;
> 
> it probably should be
> hlen = skb_headlen(skb) + skb->mac_len;
> xdp.data = skb->data - skb->mac_len;
> to make sure xdp program is looking at l2 header.

This is why Andy's tests aren't working properly, good find.

>> +	xdp.data_end = xdp.data + hlen;
>> +	xdp.data_hard_start = xdp.data - skb_headroom(skb);
>> +	orig_data = xdp.data;
>> +	act = bpf_prog_run_xdp(xdp_prog, &xdp);
>> +
>> +	off = xdp.data - orig_data;
>> +	if (off)
>> +		__skb_push(skb, off);
> 
> and restore l2 back somehow and get new skb->protocol ?
> if we simply do __skb_pull(skb, skb->mac_len); like
> we do with cls_bpf, it will not work correctly,

Yep.

I completely overlooked the fact that the MAC header was pulled
by the time we get here already.

> I suspect there always be drivers that don't support xdp (like e100),
> so this generic_xdp_install() will stay with us forever.
> Since it will stay, can we enable it for xdp enabled drivers too?

Yes it will be useful for debugging.

Andy already ran into this, he wanted to test it with a driver
that supports XDP so he had to comment out the driver's ndo op.

> Another advantage that it will help to flush out the differences
> between skb- and raw- modes in the drivers that support xdp already.

Indeed, this will be very valuable.
