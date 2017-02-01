From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 net-next 0/4] sfc: encapsulated filters
Date: Wed, 1 Feb 2017 14:02:04 +0000
Message-ID: <46cf3b66-f7c4-7d0a-5027-7a2894d60997@solarflare.com>
References: <9baa375c-b3b1-f640-04fb-e234c85a4e93@solarflare.com>
 <CALx6S359v=kUv2DAgkmDRSdMvM=sk+zYLxLKSAWhZEQwp=aTDQ@mail.gmail.com>
 <848d3b88-7e6e-4b9e-ba68-967aa45e9552@solarflare.com>
 <CALx6S36ztVKytRo615kkYbvpwhUYnEcb3tCLmeBfxmmvcr7huw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:32946 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750936AbdBAOCO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 09:02:14 -0500
In-Reply-To: <CALx6S36ztVKytRo615kkYbvpwhUYnEcb3tCLmeBfxmmvcr7huw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/01/17 17:38, Tom Herbert wrote:
> On Tue, Jan 31, 2017 at 3:42 AM, Edward Cree <ecree@solarflare.com> wrote:
>> Unless the NIC has been told to consider a particular UDP port as either VXLAN
>> or GENEVE, it _will_ treat it as "_just_ UDP packets" and go through the normal
>> filtering.  It's only NVGRE that (without this series) gets dropped.
> That doesn't sound much better. NICs have no business to drop any
> properly formed IP packet for any IP protocol as a default behavior.
> If packets should be dropped that should only be configured by the
> user.
I think it's exactly analogous to the un-encapsulated case.
At least on SFC NICs, the filter table determines which RXQs should receive a
packet.  If the filter table were empty, the firmware wouldn't know who to
deliver the packet to, so it would drop it.  Note that until the driver comes
along and inserts (say) its station MAC address filters, the filter table _is_
empty, so any packets that come in during that time are dropped.  They may all
be "properly formed IP packets for any IP protocol", but no functions have
asked to receive them, so how does the NIC know which RXQs to deliver them to?
(There may not even _be_ any RXQs yet, if driver hadn't got around to it yet.)

So, taking the above as "totally sane behaviour", and adding the fact that the
8000 series SFC NICs have separate filters for "regular packet on station MAC"
and "encapsulated packet on station MAC", it's not _wrong_ of the NIC to drop
encapsulated packets that no VI has asked for.  (And if the inner-frame
filters exist, the regular filters _have_ to exclude them else you'd get
duplicates.)
It's a _driver_ bug not to set up that filter, and it's now fixed.

-Ed
