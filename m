From: Alex Duyck <aduyck@mirantis.com>
Subject: Re: [net-next PATCH 3/4] vxlan: Enforce IP ID verification on outer headers
Date: Mon, 7 Mar 2016 15:06:00 -0800
Message-ID: <CAMt9YRoWs1iYxpAbw0SD6Q3GM=gBoe2dGXh-OBR3r-_=BjK8vA@mail.gmail.com>
References: <20160307172201.5295.69740.stgit@localhost.localdomain>
	<20160307172214.5295.52624.stgit@localhost.localdomain>
	<CAJ3xEMgpiaaLJrSqefOgrDVXsyKDtqSYQ7O01jq_UYp+UeT4bg@mail.gmail.com>
	<20160307.140947.1831226984496616218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:36074 "EHLO
	mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932686AbcCGXGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 18:06:01 -0500
Received: by mail-vk0-f46.google.com with SMTP id c3so135357284vkb.3
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 15:06:00 -0800 (PST)
In-Reply-To: <20160307.140947.1831226984496616218.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 7, 2016 at 11:09 AM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <gerlitz.or@gmail.com>
> Date: Mon, 7 Mar 2016 20:05:20 +0200
>
>> On Mon, Mar 7, 2016 at 7:22 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>> This change enforces the IP ID verification on outer headers.  As a result
>>> if the DF flag is not set on the outer header we will force the flow to be
>>> flushed in the event that the IP ID is out of sequence with the existing
>>> flow.
>>
>> Can you please state the precise requirement for aggregation w.r.t IP
>> IDs here? and point to where/how this is enforced, e.g for
>> non-tunneled TCP GRO-ing?
>
> I also didn't see a nice "PATCH 0/4" posting explaining this series and
> I'd really like to see that.

Sorry about that.  I forgot to add the cover page when I sent this.

The enforcement is coming from the IP and TCP layers.  If you take a
look in inet_gro_receive we have the NAPI_GRO_CB(p)->flush_id value
being populated based on the difference between the expected ID and
the received one.  So for IPv4 we overwrite it, and for IPv6 we set it
to 0.  The only consumer currently using it is TCP in tcp_gro_receive.
The problem is with tunnels we lose the data for the outer when the
inner overwrites it, as a result we can put whatever we want currently
in the outer IP ID and it will be accepted.

The patch set is based off of a conversation several of us had on the
list about doing TSO for tunnels and the fact that the IP IDs for the
outer header have to advance.  It makes it easier for me to validate
that I am doing things properly if GRO doesn't destroy the IP ID data
for the outer headers.

- Alex
