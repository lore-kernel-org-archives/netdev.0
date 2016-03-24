From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 1/9] ipv4/GRO: Allow multiple frames to use the same
 IP ID
Date: Wed, 23 Mar 2016 19:21:13 -0700
Message-ID: <CAKgT0UeH4qEHeaES2k31CNbb3cXD1zxm_vutqEZ_svO2F73b9A@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	<20160318232444.14955.38133.stgit@localhost.localdomain>
	<CAEh+42ir0ich=MyEtr7NkKiUBhE7Md_AF8YzQ2bCv=cy=5ziFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35471 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843AbcCXCVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 22:21:14 -0400
Received: by mail-io0-f170.google.com with SMTP id v187so42684274ioe.2
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 19:21:13 -0700 (PDT)
In-Reply-To: <CAEh+42ir0ich=MyEtr7NkKiUBhE7Md_AF8YzQ2bCv=cy=5ziFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 6:43 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Fri, Mar 18, 2016 at 4:24 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> In RFC 6864 it is stated that we can essentially ignore the IPv4 ID field
>> if we have not and will not use fragmentation.  Such a frame is defined
>> as having the DF flag set to 1, and the MF and frag_offset as 0.  Currently
>> for GRO we were requiring that the inner header always have an increasing
>> IPv4 ID, but we are ignoring the outer value.
>>
>> This patch is a first step in trying to reverse some of that.  Specifically
>> what this patch does is allow us to coalesce frames that have a static IPv4
>> ID value.  So for example if we had a series of frames where the DF flag
>> was set we would allow the same IPv4 ID value to be used for all the frames
>> belonging to that flow.  This would become the standard behavior for TCP so
>> it would support either a fixed IPv4 ID value, or one in which the value
>> increments.
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>
> One thing that is a bit odd is that the TSO output procedure stays the
> same. So that means that if we get a stream of packets with the DF bit
> set and a constant IP ID, aggregate them with GRO, and the retransmit
> with GSO/TSO then we'll get packets with IDs that increment for each
> burst and then start back again to the original value. I guess it
> doesn't matter in practice since the IDs are supposed to be ignored
> but it does seem a little strange - especially because the new packets
> will now be violating the rules of the same GRO implementation that
> produced them.

Yes and no.  The rule for GRO with this patch is that the IP ID has to
be either incrementing or if DF is set it has the option to be a fixed
value for a given grouping of packets.  In that regard either GSO
partial or standard GSO are still both reversible via GRO so that you
can aggregate to get back to the original frame (ignoring the IP ID)
that GSO segmented.  The bit I am still trying to work out is what to
do about the case where we GRO 2 frames out of one GSO segment.  I
wonder if I should just totally ignore the IP ID value since it ends
up creating an artificial boundary between the two frames if they are
segmented using the incrementing GSO versus the fixed IP ID GSO.

- Alex
