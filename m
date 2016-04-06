From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Wed, 6 Apr 2016 14:42:26 -0300
Message-ID: <CALx6S36h4nZy10=dzfjgEgyXzokEfiteSNM_L3k4jFgg9-kgYA@mail.gmail.com>
References: <20160405.194517.431351466693438399.davem@davemloft.net>
	<5704F156.8030804@solarflare.com>
	<CALx6S34Sqp7tnmkPRWH0RF_CKrBLLNWFjHbr6Uq2r=6=scMMow@mail.gmail.com>
	<20160406.114339.1083222124758102992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Jesse Gross <jesse@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:33183 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbcDFRm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 13:42:27 -0400
Received: by mail-io0-f179.google.com with SMTP id o126so42696302iod.0
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 10:42:26 -0700 (PDT)
In-Reply-To: <20160406.114339.1083222124758102992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 6, 2016 at 12:43 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Wed, 6 Apr 2016 10:53:52 -0300
>
>> Packets that are forwarded really should not be GRO'ed in the first
>> place because of the loss of information and added latency.
>
> First of all GRO is supposed to be lossless, so please stop saying this
> would be a reason to turn it off on a router.
>
> Second of all, the biggest piece of overhead is the routing lookup,
> therefore GRO batching helps enormously with routing workloads, and
> therefore is appropriate to be enabled on routers.
>
> Yes, I agree that for locally terminated stuff it helps more, but don't
> turn this into a "GRO on routers, meh..." type argument.  It simply is
> not true at all.
>
GRO on routers will help in a limited case where there is little load
and the traffic is nicely groomed high tput TCP connections. But for
routers with significant load, handling large quantities other
protocols like UDP, GRO is not necessarily helpful and presents a
nondeterministic performance improvement. For instance, I cannot
provision a router with any assumptions that GRO will be effective for
any % of packets to save any % of CPU, we need to provision based
purely on ability to forward by pps assuming no benefit from GRO.
Technically, this provisioning argument applies to end hosts also. We
have seen real cases on video servers where servers were
mis-provisioned with the assumption that GSO is always effective. So
when were getting good GSO benefits we might be using something like
80% CPU, but if some connectivity event occurs forcing all the cwnds
of the active connections drop, we find we need 110% of CPU to
recover.

This discussion is relevant because there is a big push now to replace
dedicated HW with commodity HW running Linux, this is already happened
significantly in load balancers but I expect this to extend to even
some cases of basic switching. Besides, I seriously doubt you'll find
any commercial router in the world that does GRO.

Yes, GRO needs to work correctly in all cases, but for system
performance in routing we a bound to per packet actions like route
lookup. As I said, optimizing GRO as Edward is suggesting for
forwarding case seems to have diminishing benefits.

Tom
