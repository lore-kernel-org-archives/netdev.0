From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Wed, 23 Mar 2016 11:19:39 -0700
Message-ID: <CAKgT0Uc9FNJ59529V8=0vtZnVij+JrZ2s-uOpFjnvbiqNHdVYQ@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	<20160318232522.14955.13475.stgit@localhost.localdomain>
	<CALx6S35wK2_eR1e5OTHnQTkQRg763unS0sCMQU+Jk6e27F26Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36766 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754956AbcCWSTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 14:19:40 -0400
Received: by mail-io0-f182.google.com with SMTP id 124so55422870iov.3
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 11:19:40 -0700 (PDT)
In-Reply-To: <CALx6S35wK2_eR1e5OTHnQTkQRg763unS0sCMQU+Jk6e27F26Vw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 10:09 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Mar 18, 2016 at 4:25 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> This patch adds support for something I am referring to as GSO partial.
>> The basic idea is that we can support a broader range of devices for
>> segmentation if we use fixed outer headers and have the hardware only
>> really deal with segmenting the inner header.  The idea behind the naming
>> is due to the fact that everything before csum_start will be fixed headers,
>> and everything after will be the region that is handled by hardware.
>>
> Personally, I don't like the name ;-) This technique should be
> "generic" to handle almost all GSO except those case where headers are
> not fixed which we should be able to avoid as a design point in any
> new encapsulations. Besides, what if someday we perform GSO on
> something where csum_start is not set?

Well the "partial" component of it refers to the fact that we have to
do a certain amount of this in software before we offload the work to
hardware.  So it isn't a full segmentation offload, it is a partial
one.

The csum_start is a bit of a red herring in terms of the naming.  I
was using csum_start as that works for TCP offloads since it will
always point to the inner-most transport header.  It was basically
just a convenient optimization for the drivers and makes it so that we
can essentially use just one code path in the case of ixgbe since
network header and checksum_start will always represent the two
headers we need to update for TSO regardless of it being partial or
complete offload.

> Can you add some description about strategy for dealing with ip_id?

Yeah.  I still need to add more documentation.  I just didn't want to
get into details on it until we have finalized things a bit more.  I'm
still wondering if we should follow the pattern of ipip tunnels in
terms of setting the DF bit if the inner header has the DF bit set.
If we end up needing to add code to do that then it makes it so that
the ip_id value can be fixed for both inner and outer which makes the
segmentation much simpler since the only header that would ever really
need to be updated would be the transport header in order to get the
checksum correct.

- Alex
