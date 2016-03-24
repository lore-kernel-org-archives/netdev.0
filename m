From: Jesse Gross <jesse@kernel.org>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Wed, 23 Mar 2016 18:37:02 -0700
Message-ID: <CAEh+42jKm0_89n_-vZwMRZHUpNgNVJLJ5Qo4YrhRZx7UZD0Swg@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
 <20160318232522.14955.13475.stgit@localhost.localdomain> <CALx6S35wK2_eR1e5OTHnQTkQRg763unS0sCMQU+Jk6e27F26Vw@mail.gmail.com>
 <CAKgT0Uc9FNJ59529V8=0vtZnVij+JrZ2s-uOpFjnvbiqNHdVYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:33896 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752350AbcCXBhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2016 21:37:20 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id B214C20381
	for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 01:37:18 +0000 (UTC)
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5674920351
	for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 01:37:17 +0000 (UTC)
Received: by mail-qg0-f50.google.com with SMTP id j92so2839250qgj.1
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 18:37:17 -0700 (PDT)
In-Reply-To: <CAKgT0Uc9FNJ59529V8=0vtZnVij+JrZ2s-uOpFjnvbiqNHdVYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 11:19 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Wed, Mar 23, 2016 at 10:09 AM, Tom Herbert <tom@herbertland.com> wrote:
>> Can you add some description about strategy for dealing with ip_id?
>
> Yeah.  I still need to add more documentation.  I just didn't want to
> get into details on it until we have finalized things a bit more.  I'm
> still wondering if we should follow the pattern of ipip tunnels in
> terms of setting the DF bit if the inner header has the DF bit set.
> If we end up needing to add code to do that then it makes it so that
> the ip_id value can be fixed for both inner and outer which makes the
> segmentation much simpler since the only header that would ever really
> need to be updated would be the transport header in order to get the
> checksum correct.

I tried to do this years ago but in practice it broke things.

There's enough middleboxes/firewalls/etc. out there that filter ICMP
messages that path MTU discovery isn't necessarily reliable. And while
you might argue that if the box is breaking things then the same would
be true for the original, unencapsulated TCP stream but a lot of times
there are some other hacks built in (like MSS clamping) that make
assumptions that the traffic is TCP. So at the minimum it is generally
good to have an option to force the DF bit off.

That being said, I actually think that it is good to have the DF bit
on by default for encapsulation headers being added. Unintentional
(and perhaps multiple layers of) fragmentation usually results in
unuseably bad performance and so it best to try to correct it,
hopefully automatically in most cases. And, of course, this is the
direction that IPv6 has already gone. If we can assume that this is
the most common case then in practice we can keep the outer headers
constant for the high performance path.

To me, incrementing the inner IP really seems the best choice. The
inner header is most likely someone else's traffic so it best to not
mess with that whereas the outer headers are likely ours and we know
the parameters for them (and can set the DF bit as we believe is
correct). Also, if you are looking forward to the future as far as
stacking multiple layers of tunnels, I think the only consistent thing
to do is have the inner ID increment and all of the tunnel headers
stay fixed - it is hard to justify why the first tunnel header should
increment but not the second one. And finally, as a nice bonus, this
is what the GRO code has been expecting already so you won't cause any
performance regressions with existing systems.
