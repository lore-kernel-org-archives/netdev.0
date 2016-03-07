From: Jesse Gross <jesse@kernel.org>
Subject: Re: [net-next PATCH 3/4] vxlan: Enforce IP ID verification on outer headers
Date: Mon, 7 Mar 2016 15:42:59 -0800
Message-ID: <CAEh+42goYHorJiP2ShhMj6CXCfPyn1r+obb0YsKXLeZFNW2PLw@mail.gmail.com>
References: <20160307172201.5295.69740.stgit@localhost.localdomain>
 <20160307172214.5295.52624.stgit@localhost.localdomain> <CAJ3xEMgpiaaLJrSqefOgrDVXsyKDtqSYQ7O01jq_UYp+UeT4bg@mail.gmail.com>
 <20160307.140947.1831226984496616218.davem@davemloft.net> <CAMt9YRoWs1iYxpAbw0SD6Q3GM=gBoe2dGXh-OBR3r-_=BjK8vA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alex Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:39423 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933569AbcCGXnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 18:43:17 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 48FA320263
	for <netdev@vger.kernel.org>; Mon,  7 Mar 2016 23:43:16 +0000 (UTC)
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C47A12021A
	for <netdev@vger.kernel.org>; Mon,  7 Mar 2016 23:43:14 +0000 (UTC)
Received: by mail-qg0-f41.google.com with SMTP id t4so110595182qge.0
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 15:43:14 -0800 (PST)
In-Reply-To: <CAMt9YRoWs1iYxpAbw0SD6Q3GM=gBoe2dGXh-OBR3r-_=BjK8vA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 7, 2016 at 3:06 PM, Alex Duyck <aduyck@mirantis.com> wrote:
> On Mon, Mar 7, 2016 at 11:09 AM, David Miller <davem@davemloft.net> wrote:
>> From: Or Gerlitz <gerlitz.or@gmail.com>
>> Date: Mon, 7 Mar 2016 20:05:20 +0200
>>
>>> On Mon, Mar 7, 2016 at 7:22 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>>> This change enforces the IP ID verification on outer headers.  As a result
>>>> if the DF flag is not set on the outer header we will force the flow to be
>>>> flushed in the event that the IP ID is out of sequence with the existing
>>>> flow.
>>>
>>> Can you please state the precise requirement for aggregation w.r.t IP
>>> IDs here? and point to where/how this is enforced, e.g for
>>> non-tunneled TCP GRO-ing?
>>
>> I also didn't see a nice "PATCH 0/4" posting explaining this series and
>> I'd really like to see that.
>
> Sorry about that.  I forgot to add the cover page when I sent this.
>
> The enforcement is coming from the IP and TCP layers.  If you take a
> look in inet_gro_receive we have the NAPI_GRO_CB(p)->flush_id value
> being populated based on the difference between the expected ID and
> the received one.  So for IPv4 we overwrite it, and for IPv6 we set it
> to 0.  The only consumer currently using it is TCP in tcp_gro_receive.
> The problem is with tunnels we lose the data for the outer when the
> inner overwrites it, as a result we can put whatever we want currently
> in the outer IP ID and it will be accepted.
>
> The patch set is based off of a conversation several of us had on the
> list about doing TSO for tunnels and the fact that the IP IDs for the
> outer header have to advance.  It makes it easier for me to validate
> that I am doing things properly if GRO doesn't destroy the IP ID data
> for the outer headers.

In net/ipv4/af_inet.c:inet_gro_receive() there is the following
comment above where NAPI_GRO_CB(p)->flush_id is set:

/* Save the IP ID check to be included later when we get to
* the transport layer so only the inner most IP ID is checked.
* This is because some GSO/TSO implementations do not
* correctly increment the IP ID for the outer hdrs.
*/

There was a long discussion about this a couple years ago and the
conclusion was that it is the inner IP ID is really the important one
in the case of encapsulation. Obviously, things like TCP/IP header
compression don't apply to the outer encapsulation header.
