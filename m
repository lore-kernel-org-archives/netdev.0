From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Local checksum offload for VXLAN
Date: Fri, 25 Dec 2015 23:41:46 -0500 (EST)
Message-ID: <20151225.234146.1839604131444627126.davem@davemloft.net>
References: <5672D466.6050900@solarflare.com>
	<CALx6S360nGbiD0fV4ggE_XT9SVcP4MZy-yR0Gma4jMdNuSKkug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbbLZEls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2015 23:41:48 -0500
In-Reply-To: <CALx6S360nGbiD0fV4ggE_XT9SVcP4MZy-yR0Gma4jMdNuSKkug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 17 Dec 2015 10:06:13 -0800

> On Thu, Dec 17, 2015 at 7:27 AM, Edward Cree <ecree@solarflare.com> wrote:
>> When the inner packet checksum is offloaded, the outer UDP checksum is easy
>>  to calculate as it doesn't depend on the payload (because the inner checksum
>>  cancels out everything from the inner packet except the pseudo header).
>> Thus, transmit checksums for VXLAN (and in principle other encapsulations,
>>  but I haven't enabled it for / tested with those) can be offloaded on any
>>  device supporting NETIF_F_HW_CSUM.  Only the innermost checksum has to be
>>  offloaded, the rest are filled in by the stack.
>> Tested by hacking a driver to report NETIF_F_HW_CSUM, call skb_checksum_help
>>  before transmitting a packet, and not actually offload anything to the hw.
>> In principle it should also be possible to apply this technique when the
>>  inner packet has been checksummed by software, but only if skb->csum_start
>>  and skb->csum_offset have been filled in to describe the inner checksum.
>>  However in this case it is easier to use skb->csum and skb->csum_start, as
>>  gso_make_checksum() already does - a similar but simpler technique.  It's
>>  not clear to me where else this should be done, so this is out of scope for
>>  this patch series.
>>
> Edward, it took me a while to understand how this works, but this
> really is an amazing trick! This implies that we don't need to worry
> about HW support for offloading multiple checksums.
> 
> I'm not sure that we need bits in VXLAN or any other encapsulation. It
> should be sufficient in udp_set_csum that if we already have
> CHECKSUM_PARTIAL that can always be used to do local checksum offload.
> This is also should be independent as to whether the device does
> NETIF_F_HW_CSUM or can offload  NETIF_F_IP[V6]_CSUM for encapsulated
> packets.
> 
> It would be nice to have a more formal documentation also. This is a
> very powerful mechanism but the math behind it and requirements are
> subtle.

I also think this is amazing, but should be generalized.

Also the pseudo header bits should be optimized a bit, running
skb_checksum_help() on a two byte part of the packet can certainly be
improved for example. :-)
