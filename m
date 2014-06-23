From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/5] net: Checksum offload changes - Part V
Date: Mon, 23 Jun 2014 09:29:35 -0700
Message-ID: <CA+mtBx-BPnw15gjgaGx-9zqZRTeBd4E88ZBQxC4dLYJxMwVzkw@mail.gmail.com>
References: <alpine.DEB.2.02.1406201629550.12225@tomh.mtv.corp.google.com>
	<1403327597.16682.14.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx-qvpO8SokC-8k-LOgJfN56Dbx_prEpN_n9G9aTHk-MSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:44690 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756341AbaFWQ3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 12:29:36 -0400
Received: by mail-ie0-f176.google.com with SMTP id rd18so5725399iec.7
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2014 09:29:35 -0700 (PDT)
In-Reply-To: <CA+mtBx-qvpO8SokC-8k-LOgJfN56Dbx_prEpN_n9G9aTHk-MSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2014 at 9:28 AM, Tom Herbert <therbert@google.com> wrote:
>>
>> > - Added GRO checksum validation functions
>> > - Call the GRO validations functions from TCP and GRE gro_receive
>> > - Perform checksum verification in the UDP gro_receive path using
>> >   GRO functions and add support for gro_receive in UDP6
>>  > What is in
>> What kind of speed regression / code bloat comes from all these
>> changes ?
>>
> Some cases should improve performance (like GRE w/csum), some cases will
> regress (like now that we're actually verifying UDP checksums instead of
> ignoring them). As for "code bloat", I think you can determine the extent of
> that by reading the code, but unifying all these separate ad hoc instances
> of checksum handling into one common set of functions still seems like a
> good thing to me :-).
>
>>
>> I see a lot of added complexity / code in GRO layer, but no performance
>> numbers...
>>
> These patches won't affect the simple case of GRO (plain TCP), but may have
> impact in presence of encapsulations. I'm happy to provide some performance
> numbers, but there are many possible combinations of encapsulation,
> configuration, hardware offload support-- are there any specific scenarios
> you'd like to see?
>
>>
>> __skb_gro_checksum_complete() for example calls skb_checksum() twice,
>> and we know this is expensive, particularly for IPv4 case where we know
>> the header checksum has to be 0.
>>
> GRE already does this and this ensures that we never compute the full packet
> checksum twice (one of the primary goals of my checksum patches). I believe
> this would worse than the incremental cost of making checksum complete.
>
> The alternative we could consider, is to never do the full checksum in GRO.
> It looks like there's some weak attempt in this direction (e.g. GRO can only
> be enabled with csum offload enabled, UDP encap enforcing complete or
> unnecessary). I suspect there will still be cases where the benefits of
> aggregation outweigh the costs of doing the the csum in GRO.
>
>> GRO performance is already not very good, lot of people just disable GRO
>> because of it being very slow. I'd like to not give them more
>> incentives...
>>
>> Without proper RFS support from the NIC, all encapsulated traffic tend
>> to land on a single RX queue, so performance of GRO layer is critical.
>
>
> Why would encapsulated traffic be any different than other traffic in this
> regard? RSS is still applicable and the point of all the work to define foo
> over UDP is leverage things like RSS and ECMP.
>
> Tom
>
>
