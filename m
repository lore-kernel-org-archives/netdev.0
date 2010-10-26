From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 10:37:53 -0700
Message-ID: <AANLkTi=P80OUBSy3xCt_qOjPGTwNjrtFL1iLJnkc9joq@mail.gmail.com>
References: <4CC708CE.4040404@hp.com> <20101026.101038.260090183.davem@davemloft.net>
 <AANLkTin-u_bZj6_wpoV6fNaLg81JbFN0EvhNrA6wX6SG@mail.gmail.com> <20101026.102145.246528067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:22834 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932875Ab0JZRiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:38:18 -0400
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o9QHcGTB029745
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:38:17 -0700
Received: from gyg8 (gyg8.prod.google.com [10.243.50.136])
	by kpbe16.cbf.corp.google.com with ESMTP id o9QHc3JS008011
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:38:15 -0700
Received: by gyg8 with SMTP id 8so3637021gyg.38
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:38:15 -0700 (PDT)
In-Reply-To: <20101026.102145.246528067.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 10:21 AM, David Miller <davem@davemloft.net> wrote:
>> Removing autoconfigured addresses is what the kernel currently does
>> when the link goes down. The patch just makes sure it happens when
>> carrier is lost as well, since losing link might mean that when
>> carrier comes back, the host might be on a different link than it was
>> before.
>
> I just think validating that fact would be a better approach than
> simply assuming link down/up means link change.

So when the link comes back, we'd have to wait for all RAs to come in
(there could be multiple routers on a link, each announcing different
prefixes), and when this is all done, compare the list of addresses to
the prefixes that are currently on the link and delete the ones that
don't match. We'd have to do the same with default routers and /64
routes to all the link prefixes.

Also, we'd have to figure out how long to wait for RAs, and when to
time out if there are no RAs. Bear in mind that for as long as you
have an invalid IPv6 address, you can't reach dual-stack websites at
all (well, technically you can, but only if you're prepared to wait 3
minutes for the connection to time out). The damage starts when
associating to the link and only stops when the addresses and routes
are removed.

Is the extra complexity worth it? This patch is three lines, deals
with what I think is the common case, and has no obvious downsides
we've spotted so far. And at least in my testing, it's a definite
improvement. Would you be opposed to doing something like this as a
first cut and iterating or backing out if it turns out to be
insufficient or broken?
