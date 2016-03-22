From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Tue, 22 Mar 2016 10:47:19 -0700
Message-ID: <CAKgT0Ud9uPG+9AdT47Q1VygLBnjygyY29sRf=y4Pqe=f2e+bkw@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	<20160318232522.14955.13475.stgit@localhost.localdomain>
	<56F17A13.8090701@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:35082 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759383AbcCVRrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 13:47:20 -0400
Received: by mail-io0-f178.google.com with SMTP id o5so166266723iod.2
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 10:47:19 -0700 (PDT)
In-Reply-To: <56F17A13.8090701@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2016 at 10:00 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 18/03/16 23:25, Alexander Duyck wrote:
>> This patch adds support for something I am referring to as GSO partial.
>> The basic idea is that we can support a broader range of devices for
>> segmentation if we use fixed outer headers and have the hardware only
>> really deal with segmenting the inner header.  The idea behind the naming
>> is due to the fact that everything before csum_start will be fixed headers,
>> and everything after will be the region that is handled by hardware.
>>
>> With the current implementation it allows us to add support for the
>> following GSO types with an inner TSO or TSO6 offload:
>> NETIF_F_GSO_GRE
>> NETIF_F_GSO_GRE_CSUM
>> NETIF_F_UDP_TUNNEL
>> NETIF_F_UDP_TUNNEL_CSUM
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>> ---
> If I'm correctly understanding what you're doing, you're building a large
> TCP segment, feeding it through the encapsulation drivers as normal, then
> at GSO time you're fixing up length fields, checksums etc. in the headers.
> I think we can do this more simply, by making it so that at the time when
> we _generate_ the TCP segment, we give it headers saying it's one MSS big,
> but have several MSS of data.  Similarly when adding the encap headers,
> they all need to get their lengths from what the layer below tells them,
> rather than the current length of data in the SKB.  Then at GSO time all
> the headers already have the right things in, and you don't need to call
> any per-protocol GSO callbacks for them.

One issue I have to deal with here is that we have no way of knowing
what the underlying hardware can support at the time of segment being
created.  You have to keep in mind that what we have access to is the
tunnel dev in many cases, not the underlying dev so we don't know if
things can be offloaded to hardware or not.  By pushing this logic
into the GSO code we can actually implement it without much overhead
since we either segment it into an MSS multiple, or into single MSS
sized chunks.  This way we defer the decision until the very last
moment when we actually know if we can offload some portion of this in
hardware or not.

> Any protocol that noticed it was putting something non-copyable in its
> headers (e.g. GRE with the Counter field, or an outer IP layer without DF
> set needing real IPIDs) would set a flag in the SKB to indicate that we
> really do need to call through the per-protocol GSO stuff.  (Ideally, if
> we had a separate skb->gso_start field rather than piggybacking on
> csum_start, we could reset it to point just before us, so that any further
> headers outside us still can be copied rather than taking callbacks.  But
> I'm not sure whether that's worth using up sk_buff real estate for.)

The idea behind piggybacking on csum_start was due to the fact that we
cannot perform GSO/TSO unless CHECKSUM_PARTIAL is set.  As far as I
know in the case of TCP offloads this always ends up being the
inner-most L4 header so it works out in that it actually reduces code
path as we were having to deal with all the skb->encapsulation checks.
It was a relationship that already existed, I just decided to make use
of it since it simplifies things pretty significantly.

As far as retreating I don't really see how that would work. In most
cases it is an all-or-nothing proposition to setup these outer
headers.  Either we can segment the frame with the outer headers
replicated or we cannot.  I suspect it would end up being a common
case where the hardware will update the outer IP and inner TCP
headers, but I think the outer L4 and inner IP headers will be the
ones that most likely always end up being static.  Also we already
have code paths in place in the GRE driver for instance that prevent
us from using GSO in the case of TUNNEL_SEQ being enabled.

> (It might still be necessary to put the true length in the TCP header, if
> hardware is using that as an input to segmentation.  I think sfc hardware
> just uses 'total length of all payload DMA descriptors', but others might
> behave differently.)

That is what most drivers do.  The way I kind of retained that is that
the TCP header doesn't include an actual length field, but I left the
pseudo-header using the full length of all data.  My thought was to
end up using something like the ixgbe approach for most devices.  What
I did there was replicate the tunnel headers and inner IPv4 or IPv6
header.  In the case of ixgbe and i40e I can throw away the checksum
and length values for the outer IP header, one thing I was curious
about is if I really needed to retain the full packet size for those.

> However, I haven't yet had the time to attempt to implement this, so there
> might be some obvious reason I'm missing why this is impossible.
> Also, it's possible that I've completely misunderstood your patch and it's
> orthogonal to and can coexist with what I'm suggesting.

The one piece I could really use would be an understanding of what
inputs your hardware is expecting in order for us to extend TSO to
support this kind of approach.  Then I could start tailoring the
output generated so that we had something that would work with more
devices.  I was thinking the approach I have taken is fairly generic
since essentially it allows us to get away with TSO as long as we are
allowed to provide the offsets for the IP header and the TCP header.
>From what I can tell it looks like the Solarflare drivers do something
similar so you might even try making changes similar to what I did for
ixgbe to see if you can get a proof of concept working for sfc.

- Alex
