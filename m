From: Jesse Gross <jesse@kernel.org>
Subject: Re: [RFC PATCH 1/9] ipv4/GRO: Allow multiple frames to use the same
 IP ID
Date: Sun, 27 Mar 2016 21:57:55 -0700
Message-ID: <CAEh+42iAWwKFLuorcOEM+=uUr0qOkwJWv9bE6Vvhyv4j9m3wrw@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
 <20160318232444.14955.38133.stgit@localhost.localdomain> <CAEh+42ir0ich=MyEtr7NkKiUBhE7Md_AF8YzQ2bCv=cy=5ziFg@mail.gmail.com>
 <CAKgT0UeH4qEHeaES2k31CNbb3cXD1zxm_vutqEZ_svO2F73b9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:44119 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754007AbcC1E6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 00:58:14 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 9661120272
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 04:58:12 +0000 (UTC)
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A727F2026F
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 04:58:10 +0000 (UTC)
Received: by mail-qg0-f54.google.com with SMTP id u110so101078100qge.3
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2016 21:58:10 -0700 (PDT)
In-Reply-To: <CAKgT0UeH4qEHeaES2k31CNbb3cXD1zxm_vutqEZ_svO2F73b9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 7:21 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Wed, Mar 23, 2016 at 6:43 PM, Jesse Gross <jesse@kernel.org> wrote:
>> On Fri, Mar 18, 2016 at 4:24 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>> In RFC 6864 it is stated that we can essentially ignore the IPv4 ID field
>>> if we have not and will not use fragmentation.  Such a frame is defined
>>> as having the DF flag set to 1, and the MF and frag_offset as 0.  Currently
>>> for GRO we were requiring that the inner header always have an increasing
>>> IPv4 ID, but we are ignoring the outer value.
>>>
>>> This patch is a first step in trying to reverse some of that.  Specifically
>>> what this patch does is allow us to coalesce frames that have a static IPv4
>>> ID value.  So for example if we had a series of frames where the DF flag
>>> was set we would allow the same IPv4 ID value to be used for all the frames
>>> belonging to that flow.  This would become the standard behavior for TCP so
>>> it would support either a fixed IPv4 ID value, or one in which the value
>>> increments.
>>>
>>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>>
>> One thing that is a bit odd is that the TSO output procedure stays the
>> same. So that means that if we get a stream of packets with the DF bit
>> set and a constant IP ID, aggregate them with GRO, and the retransmit
>> with GSO/TSO then we'll get packets with IDs that increment for each
>> burst and then start back again to the original value. I guess it
>> doesn't matter in practice since the IDs are supposed to be ignored
>> but it does seem a little strange - especially because the new packets
>> will now be violating the rules of the same GRO implementation that
>> produced them.
>
> Yes and no.  The rule for GRO with this patch is that the IP ID has to
> be either incrementing or if DF is set it has the option to be a fixed
> value for a given grouping of packets.  In that regard either GSO
> partial or standard GSO are still both reversible via GRO so that you
> can aggregate to get back to the original frame (ignoring the IP ID)
> that GSO segmented.  The bit I am still trying to work out is what to
> do about the case where we GRO 2 frames out of one GSO segment.  I
> wonder if I should just totally ignore the IP ID value since it ends
> up creating an artificial boundary between the two frames if they are
> segmented using the incrementing GSO versus the fixed IP ID GSO.

Yeah, I agree that it should work in practice, it just seems a bit odd
to have the IP IDs skip around like that. It does also mean that GRO
will no longer be completely, transparently reversible.

I guess that's fine though as long as we fully embrace the idea that
the DF bit means that IP IDs are not used. In that case, it seems best
to allow any ID when DF is set so we are at least self-consistent.
