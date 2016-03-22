From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Tue, 22 Mar 2016 17:00:03 +0000
Message-ID: <56F17A13.8090701@solarflare.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
 <20160318232522.14955.13475.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <aduyck@mirantis.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <alexander.duyck@gmail.com>,
	<tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:61938 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753134AbcCVRAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 13:00:17 -0400
In-Reply-To: <20160318232522.14955.13475.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/03/16 23:25, Alexander Duyck wrote:
> This patch adds support for something I am referring to as GSO partial.
> The basic idea is that we can support a broader range of devices for
> segmentation if we use fixed outer headers and have the hardware only
> really deal with segmenting the inner header.  The idea behind the naming
> is due to the fact that everything before csum_start will be fixed headers,
> and everything after will be the region that is handled by hardware.
>
> With the current implementation it allows us to add support for the
> following GSO types with an inner TSO or TSO6 offload:
> NETIF_F_GSO_GRE
> NETIF_F_GSO_GRE_CSUM
> NETIF_F_UDP_TUNNEL
> NETIF_F_UDP_TUNNEL_CSUM
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
If I'm correctly understanding what you're doing, you're building a large
TCP segment, feeding it through the encapsulation drivers as normal, then
at GSO time you're fixing up length fields, checksums etc. in the headers.
I think we can do this more simply, by making it so that at the time when
we _generate_ the TCP segment, we give it headers saying it's one MSS big,
but have several MSS of data.  Similarly when adding the encap headers,
they all need to get their lengths from what the layer below tells them,
rather than the current length of data in the SKB.  Then at GSO time all
the headers already have the right things in, and you don't need to call
any per-protocol GSO callbacks for them.
Any protocol that noticed it was putting something non-copyable in its
headers (e.g. GRE with the Counter field, or an outer IP layer without DF
set needing real IPIDs) would set a flag in the SKB to indicate that we
really do need to call through the per-protocol GSO stuff.  (Ideally, if
we had a separate skb->gso_start field rather than piggybacking on
csum_start, we could reset it to point just before us, so that any further
headers outside us still can be copied rather than taking callbacks.  But
I'm not sure whether that's worth using up sk_buff real estate for.)
(It might still be necessary to put the true length in the TCP header, if
hardware is using that as an input to segmentation.  I think sfc hardware
just uses 'total length of all payload DMA descriptors', but others might
behave differently.)
However, I haven't yet had the time to attempt to implement this, so there
might be some obvious reason I'm missing why this is impossible.
Also, it's possible that I've completely misunderstood your patch and it's
orthogonal to and can coexist with what I'm suggesting.
-Ed
