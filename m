From: Jesse Gross <jesse@kernel.org>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Sun, 27 Mar 2016 22:35:06 -0700
Message-ID: <CAEh+42jQ7POqFRv1mTQXOtoNNO2PsJSqXdMcMsYuXPgOtTQ=Kg@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
 <20160318232522.14955.13475.stgit@localhost.localdomain> <CALx6S35wK2_eR1e5OTHnQTkQRg763unS0sCMQU+Jk6e27F26Vw@mail.gmail.com>
 <CAKgT0Uc9FNJ59529V8=0vtZnVij+JrZ2s-uOpFjnvbiqNHdVYQ@mail.gmail.com>
 <CAEh+42jKm0_89n_-vZwMRZHUpNgNVJLJ5Qo4YrhRZx7UZD0Swg@mail.gmail.com> <CAKgT0UcbX+Kfa0+B57ZOMfeNgDvAuFhQO=oVw2m4kGyurBqFSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:45769 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754383AbcC1FfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 01:35:24 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id D9F6C20279
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 05:35:22 +0000 (UTC)
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F1A6A201ED
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 05:35:21 +0000 (UTC)
Received: by mail-qg0-f52.google.com with SMTP id c67so67712048qgc.1
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2016 22:35:21 -0700 (PDT)
In-Reply-To: <CAKgT0UcbX+Kfa0+B57ZOMfeNgDvAuFhQO=oVw2m4kGyurBqFSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 7:53 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Wed, Mar 23, 2016 at 6:37 PM, Jesse Gross <jesse@kernel.org> wrote:
>> That being said, I actually think that it is good to have the DF bit
>> on by default for encapsulation headers being added. Unintentional
>> (and perhaps multiple layers of) fragmentation usually results in
>> unuseably bad performance and so it best to try to correct it,
>> hopefully automatically in most cases. And, of course, this is the
>> direction that IPv6 has already gone. If we can assume that this is
>> the most common case then in practice we can keep the outer headers
>> constant for the high performance path.
>
> I'm still weighting my options on how to address the DF issue.  I'm
> not really sure having DF always on for outer headers is the best way
> to go either.  I kind of like the idea that if DF is set for the inner
> headers then we set it for the outer headers.  I just have to see how
> hard something like that would be to implement.

I don't think it would be too hard to implement. We already have code
that copies things like ECN between the inner and outer headers, so it
shouldn't be an issue to add this if that's what we decide is right.

My first concern was that we have a way to turn off the DF bit in the
event that it breaks things. Otherwise, I think it is a performance
win both from the perspective of avoiding fragmentation and allowing
blind copying of headers through TSO by avoiding the need to increment
the ID. In practice, there's probably not too much difference between
turning it on by default and inheriting from the inner frame other
than it might affect what is considered to be the 'fast path'.

>> To me, incrementing the inner IP really seems the best choice. The
>> inner header is most likely someone else's traffic so it best to not
>> mess with that whereas the outer headers are likely ours and we know
>> the parameters for them (and can set the DF bit as we believe is
>> correct). Also, if you are looking forward to the future as far as
>> stacking multiple layers of tunnels, I think the only consistent thing
>> to do is have the inner ID increment and all of the tunnel headers
>> stay fixed - it is hard to justify why the first tunnel header should
>> increment but not the second one. And finally, as a nice bonus, this
>> is what the GRO code has been expecting already so you won't cause any
>> performance regressions with existing systems.
>
> Agreed.  However in the case of the igb and ixgbe incrementing the
> inner isn't really going to work well as it introduces a number of
> issues.  I've considered not enabling GSO partial by default on those
> parts, but leaving it as an available feature.  In the case of i40e we
> will not have any of those issues as both the inner and outer IP IDs
> will increment.
>
> The regressions issue shouldn't be all that big.  In most cases
> tunnels are point to point links.  Odds are if someone is running a
> network they should have similar devices on both ends.  So in the case
> of the Intel drivers I have patched here updating i40e isn't that big
> of a deal since it retains the original GSO behavior.  In the case of
> ixgbe it didn't support any tunnel offloads so there is no GRO support
> without checksums being enabled in the tunnel, and Tx checksum support
> vi HW_CSUM has yet to be pushed upstream from Jeff's tree so things
> are currently throttled by the Tx side.
>
> GSO partial is going to end up being very driver specific in terms of
> what increments and what doesn't as we are having to really hack our
> way around to make it do things the spec sheets say it cannot do.
> Some implementations are going to end up working out better than
> others in terms of interoperability and what can make use of other
> advanced features such as GRO on legacy systems.

I have to admit that I'm a little concerned about the fact that
different drivers will end up doing different things as a result of
this series. Generally speaking, it doesn't seem all that good for
drivers to be setting policy for what packets look like.

That being said, if we are OK with IP IDs jumping around when DF is
set as a result of the first patch, then this shouldn't really be a
problem as the effect is similar. We just obviously need to make sure
that we don't let a packet without DF and and non-incrementing IP IDs
escape out in the wild.

Anyways, I think you've already covered a lot of this ground in the
other thread, so I don't think there is any real reason to rehash it
here.
