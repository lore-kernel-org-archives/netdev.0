From: Tom Herbert <therbert@google.com>
Subject: Re: Get rxhash fixes and RFS support in tun
Date: Wed, 20 Nov 2013 17:09:01 -0800
Message-ID: <CA+mtBx91hSmYKrbUsPrtnXRjYR8QDGZ+GAAnMixauUqw9LFkiQ@mail.gmail.com>
References: <alpine.DEB.2.02.1311201220510.19725@tomh.mtv.corp.google.com>
	<20131120.190252.940036939480739452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jerry Chu <hkchu@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:43683 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481Ab3KUBJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 20:09:03 -0500
Received: by mail-ie0-f182.google.com with SMTP id as1so8711879iec.41
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 17:09:01 -0800 (PST)
In-Reply-To: <20131120.190252.940036939480739452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 20, 2013 at 4:02 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Wed, 20 Nov 2013 12:25:48 -0800 (PST)
>
>> This patch series fixes some subtle bugs in tun use of skb->rxhash, all
>> rxhash hash not be cleared appropraitely, and adds support for tun flows
>> to work with RFS.
>>
>> Testing, in particular with tun, hasn't been completed yet.
>
> I think this needs to be reworked slightly.
>
> We really only have two boolean states:
>
> 1) Is the rxhash value in this SKB valid?
>
> 2) Is it a full L4 tuple hash?
>
> You are adding a "this is a SW computed hash" boolean state but I do
> not think you should distinguish sw vs. hw especially.  If the
> hardware computed the rxhash on a tunneled packet in the
> pre-decapsulated state, we very much want to recompute it, in
> software, upon tunnel decapsulation in ip_tunnel_core.c
>
In either case it would be recomputed in SW if L4 hash was not set
(i.e. no flow_dissector done finding L4).  If L4 hash is set, that
should refer to the hash of the inner 4-tuple, so I don't think you'd
need to recompute it.  I suppose there could be a case like encap in
UDP where there are potentially two 4-tuples to deal with, but then
the rxhash could just be cleared in decap to force recomputing hash
over the inner packet-- even better I would hope that the trick of
using outer source port to hold the hash of the inner packet (like in
nvgre) is used so that the hash on the outer header is good for L4.

The primary reason for sw_rhash is to know whether it is a comparable
value to match against that of a flow whose hash was computed in SW
(tun case).

> This is actually implemented in this patch set, by testing two states.
> Both the "l4_rxhash" and "sw_rxhash".
>
> Why don't we just do everything in a straightforward manner, where
> nothing directly sets rxhash values.  Only helper routines do.
>
> 1) skb_set_rxhash(struct sk_buff *skb, __u32 rxhash, bool l4_rxhash)
>
Yes, we should be using helper functions for this anyway.  I'll make
that change.

>    Update all drivers to call this.
>
> 2) Add "rxhash_valid" boolean to sk_buff, set it in skb_set_rxhash,
>    test it in skb_get_rxhash(), propagate it in SKB copies.
>
I think the sw_rxhash holds more useful information.  In
skb_get_rxhash() either we have an L4 hash or we try to get one by
doing the SW computation, this means we don't ever return a HW hash
which is not L4 so basically that case is treated as an invalid hash.
So after a call to skb_get_rxhash, at least one of l4_rxhash or
sw_rxhash is and we won't redo flow dissection on subsequent calls
unless the rxhash is cleared.

Thanks,
Tom

> 3) Your skb_clear_rxhash() now just clears rxhash_valid.
>
> Now, if the issue is that HW computed hashes sometimes do the tunnel
> demux and look into the inner L4 headers to compute the hash, you'll
> need a boolean to indicate _that_ rather than unconditionally treating
> hardware that way.  Because not all of them will do this, and for
> those that do not you do want to compute the hash in SW after tunnel
> decapsulation.
>
> Thoughts?
