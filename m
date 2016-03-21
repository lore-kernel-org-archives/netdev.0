From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 0/9] RFC6864 compliant GRO and GSO partial offload
Date: Mon, 21 Mar 2016 12:46:19 -0700
Message-ID: <CAKgT0UdZU9u1i0Er2RhmQ1kOQgNRkQ3_DQUbGybpWcA3MzN-kw@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	<20160321.145014.2053938894183716531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35929 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757798AbcCUTqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 15:46:20 -0400
Received: by mail-io0-f172.google.com with SMTP id 124so69669519iov.3
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 12:46:20 -0700 (PDT)
In-Reply-To: <20160321.145014.2053938894183716531.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 21, 2016 at 11:50 AM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <aduyck@mirantis.com>
> Date: Fri, 18 Mar 2016 16:24:38 -0700
>
>> This patch series addresses two things.
>>
>> First it enables what I am calling RFC6864 compliant GRO.  Basically what
>> I am doing is allowing one of two patterns for incoming frames.  Either the
>> IP ID will increment, or if the DF bit is set it can either increment or
>> stay the same value.  This allows us to perform GRO if the IP ID is forced
>> to stay at a static value as may occur if we are replicating an IP header
>> instead of actually having it offloaded.
>>
>> The last 3 patches introduce what I am calling GSO partial.  The best way
>> to describe it is that it is a GSO offload in which the portion pointed to
>> by csum_start must be handled by the hardware, and the region before that
>> can be optionally handled.  So for example with i40e the only pieces it was
>> missing from the full offload was the checksum so this is computed in
>> software and the hardware will update inner and outer IP headers.  In the
>> example for ixgbe the hardware will only update the outer IP header.  The
>> outer UDP or GRE header and inner IP header are unmodified.
>
> Conceptually I am completely fine with these changes.
>
>> The one concern here is that if the outer IP header does not have
>> the DF bit set and does not update the IP ID field we run the risk
>> of causing all sorts of problems if the packet is fragmented in
>> flight.
>
> I think we absolutely cannot let such a packet be output from our
> stack.

My concern is that there may be devices doing just that.  That is one
of the motivations behind updating the GRO code so that if DF is not
set we refuse to aggregate frames that do not increment the IP ID.  If
nothing else we just have to wait and see who comes screaming about
performance regressions once the patch is applied.  That will tell us
who is cheating and segmenting frames with the IP ID not being updated
and DF bit not being set.  There was already the comment in
inet_gro_receive about how some devices weren't updating this
correctly so we probably need to figure out if those devices are at
least setting the DF bit.

The other bit I would be interested in seeing is how this will work
with drivers from other vendors.  In the case of the Intel parts the
outer IPv4/IPv6 header doesn't really matter since we zero the length
and recompute the checksum anyway.  I'm wondering if it would be
preferred to leave the outer IPv4/IPv6 header unmodified for the
larger frame or to modify it as I currently am so that it matches the
setup for the headers that were going to be transmitted.

- Alex
