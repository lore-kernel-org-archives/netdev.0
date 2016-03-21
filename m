From: Jesse Gross <jesse@kernel.org>
Subject: Re: [RFC PATCH 0/9] RFC6864 compliant GRO and GSO partial offload
Date: Mon, 21 Mar 2016 13:10:08 -0700
Message-ID: <CAEh+42gMSg8vEnYZSDYtzgnvGm6_UpZNLU77m5M4at_ZcHxCtQ@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
 <20160321.145014.2053938894183716531.davem@davemloft.net> <CAKgT0UdZU9u1i0Er2RhmQ1kOQgNRkQ3_DQUbGybpWcA3MzN-kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Alex Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:35524 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757314AbcCUUK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2016 16:10:27 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 9414F202FE
	for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 20:10:25 +0000 (UTC)
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F363120263
	for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 20:10:23 +0000 (UTC)
Received: by mail-qg0-f54.google.com with SMTP id w104so161785720qge.1
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 13:10:23 -0700 (PDT)
In-Reply-To: <CAKgT0UdZU9u1i0Er2RhmQ1kOQgNRkQ3_DQUbGybpWcA3MzN-kw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 21, 2016 at 12:46 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Mon, Mar 21, 2016 at 11:50 AM, David Miller <davem@davemloft.net> wrote:
>> From: Alexander Duyck <aduyck@mirantis.com>
>> Date: Fri, 18 Mar 2016 16:24:38 -0700
>>
>>> This patch series addresses two things.
>>>
>>> First it enables what I am calling RFC6864 compliant GRO.  Basically what
>>> I am doing is allowing one of two patterns for incoming frames.  Either the
>>> IP ID will increment, or if the DF bit is set it can either increment or
>>> stay the same value.  This allows us to perform GRO if the IP ID is forced
>>> to stay at a static value as may occur if we are replicating an IP header
>>> instead of actually having it offloaded.
>>>
>>> The last 3 patches introduce what I am calling GSO partial.  The best way
>>> to describe it is that it is a GSO offload in which the portion pointed to
>>> by csum_start must be handled by the hardware, and the region before that
>>> can be optionally handled.  So for example with i40e the only pieces it was
>>> missing from the full offload was the checksum so this is computed in
>>> software and the hardware will update inner and outer IP headers.  In the
>>> example for ixgbe the hardware will only update the outer IP header.  The
>>> outer UDP or GRE header and inner IP header are unmodified.
>>
>> Conceptually I am completely fine with these changes.
>>
>>> The one concern here is that if the outer IP header does not have
>>> the DF bit set and does not update the IP ID field we run the risk
>>> of causing all sorts of problems if the packet is fragmented in
>>> flight.
>>
>> I think we absolutely cannot let such a packet be output from our
>> stack.
>
> My concern is that there may be devices doing just that.  That is one
> of the motivations behind updating the GRO code so that if DF is not
> set we refuse to aggregate frames that do not increment the IP ID.  If
> nothing else we just have to wait and see who comes screaming about
> performance regressions once the patch is applied.  That will tell us
> who is cheating and segmenting frames with the IP ID not being updated
> and DF bit not being set.  There was already the comment in
> inet_gro_receive about how some devices weren't updating this
> correctly so we probably need to figure out if those devices are at
> least setting the DF bit.

It's clearly wrong to send packets without the DF bit and the same IP
ID (but I agree that there may be some devices that are doing this by
accident). However, I don't think that we want the device to be
changing the value of the DF bit to somehow compensate for that.

I was surprised to see that the DF bit is not on for outer IP headers
- it seems like that should at least be the default. If it is turned
off and the device isn't capable of updating the outer IP ID, well,
then it shouldn't be doing TSO.
