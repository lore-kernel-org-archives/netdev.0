From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Thu, 13 Apr 2017 12:04:35 -0400 (EDT)
Message-ID: <20170413.120435.668996251377211355.davem@davemloft.net>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
        <58EF9FD2.90807@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60866 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751554AbdDMQEh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 12:04:37 -0400
In-Reply-To: <58EF9FD2.90807@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 13 Apr 2017 17:57:06 +0200

> On 04/12/2017 08:54 PM, David Miller wrote:
> [...]
>> +static u32 netif_receive_generic_xdp(struct sk_buff *skb,
>> +				     struct bpf_prog *xdp_prog)
>> +{
>> +	struct xdp_buff xdp;
>> +	u32 act = XDP_DROP;
>> +	void *orig_data;
>> +	int hlen, off;
>> +
>> +	if (skb_linearize(skb))
> 
> Btw, given the skb can come from all kind of points in the stack,
> it could also be a clone at this point. One example is act_mirred
> which in fact does skb_clone() and can push the skb back to
> ingress path through netif_receive_skb() and thus could then go
> into generic xdp processing, where skb can be mangled.
> 
> Instead of skb_linearize() we would therefore need to use something
> like skb_ensure_writable(skb, skb->len) as equivalent, which also
> makes sure that we unclone whenever needed.

We could use skb_cow() for this purpose, which deals with cloning as
well as enforcing headroom.

However, thinking further about this, the goal is to make generic XDP
match precisely how in-driver-XDP behaves.  Therefore, such redirects
from act_mirred would never flow through the XDP path.

No other possibility can cause us to see a cloned packet here, we
are before network taps are processed, etc.  So in my opinion the
thing to do is to elide generic XDP if the SKB is cloned.
