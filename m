From: Edward Cree <ecree@solarflare.com>
Subject: Re: Checksum offload queries
Date: Tue, 8 Dec 2015 18:03:56 +0000
Message-ID: <56671B8C.7060908@solarflare.com>
References: <5665A848.9010001@solarflare.com>
 <CALx6S37+YVqpVL6XX2KCHZad84DGpqpL+K4LdDZr5H-feiyjow@mail.gmail.com>
 <5666FF46.6030702@solarflare.com>
 <CALx6S37T8gA8ZNRTgWt5MBW8QLYa7ODnAoZm-=Xk5VNg_t3QSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:1562 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750733AbbLHSED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 13:04:03 -0500
In-Reply-To: <CALx6S37T8gA8ZNRTgWt5MBW8QLYa7ODnAoZm-=Xk5VNg_t3QSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/15 16:43, Tom Herbert wrote:
> On Tue, Dec 8, 2015 at 8:03 AM, Edward Cree <ecree@solarflare.com> wrote:
>> On 07/12/15 17:29, Tom Herbert wrote:
>>> On Mon, Dec 7, 2015 at 7:39 AM, Edward Cree <ecree@solarflare.com> wrote:
>>>> 2) Transmit checksums.
>>> It's analogous to CHECKSUM_COMPLETE, NETIF_F_HW_CSUM works for all
>>> cases of checksum offload and any combination of protocol layering.
>> ... until a protocol combination comes along that doesn't allow all but the innermost checksum to be 0.  NETIF_F_HW_CSUM is limited to one checksum per packet.
> So is NETIF_F_IP[V6]_CSUM, again the interface into the driver to
> offload a checksum is csum_start, csum_offset.
Well, we don't use those values, and I'd be surprised if other NETIF_F_IP[V6]_CSUM drivers did.  The reason why our hardware is restricted to checksumming IP, rather than being able to checksum everything, is that it works out the start and offset itself (and only knows how to do that for IP).  Our transmit descriptors don't include csum_start and csum_offset.  That may mean we're Doing It Wrong, but I don't see why anyone Doing It Right would need to be NETIF_F_IP[V6]_CSUM in the first place, rather than NETIF_F_HW_CSUM.
> Only one checksum can
> be offloaded at a time. We have no way to tell the driver that there
> are two checksums in a packet to be offloaded.
But again, hardware that figures it out for itself doesn't _need_ to be told.  For instance, for a VXLAN-encapsulated TCP packet, our new chip can fill in the IP header checksum, the (outer) UDP checksum, and the (inner) TCP checksum.  (Our previous chip would do the first two, but not the inner checksum.)  I had assumed that NETIF_F_IP_CSUM included IP header checksum offload; now I'm wondering if the stack is already filling that in and our hardware is overwriting it with the same value.  From a quick look at our driver, it looks like that is indeed happening; I guess I should fix that.
