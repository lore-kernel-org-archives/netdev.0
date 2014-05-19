From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH ipsec-next 2/2] xfrm: configure policy hash table thresholds
 by /proc
Date: Mon, 19 May 2014 09:41:05 +0200
Message-ID: <5379B591.6020001@6wind.com>
References: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com> <1399902325-1788-3-git-send-email-christophe.gouault@6wind.com> <20140515083447.GC32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:44927 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbaESHlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 03:41:17 -0400
Received: by mail-wi0-f170.google.com with SMTP id bs8so4737968wib.3
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 00:41:16 -0700 (PDT)
In-Reply-To: <20140515083447.GC32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2014 10:34 AM, Steffen Klassert wrote:
> On Mon, May 12, 2014 at 03:45:25PM +0200, Christophe Gouault wrote:
>> Enable to specify local and remote prefix length thresholds
>> for the policy hash table via /proc entries. Example:
>>
>> echo 0 24 > /proc/sys/net/ipv4/xfrm4_policy_hash_tresh
>> echo 0 56 > /proc/sys/net/ipv6/xfrm6_policy_hash_tresh
>
> I would not like to have this configurable from userspace.
> Fist of all, a good threshold depends on the IPsec configuration
> and can change during runtime. So it is not obvious for a user
> which values are good for his configuration. Most users will
> just leave the default, so they will not benefit from your
> changes.

Hi Steffen,

Like for several other /proc entries, the default values are suitable
for simple use cases and users can let them unchanged. Users usually
only start tuning them when they have a specific use case (typically
scalability needs).

Moreover, I am concerned that any heuristic for automatic changes would
be a performance killer when the system is flapping. See below.

> Second, on the long run we have to remove the IPsec flowcache
> as this has the same limitation as our routing cache had.
> To do this, we need to replace the hashlist based policy and
> state lookups by a well performing lookup algorithm and I
> would like to do that without any user visible changes.

Efficient lookup is a field we have studied for long in my company.
There are many thesis about multi-field classification, but none enables
to cover all use cases. All suffer from limitations (building time,
memory consumption, number of fields, time and memory
unpredictability...) and each is adapted to a specific use case.

The best seems to offer several methods and enable to select and tune
them according to the use case.

The main advantage of the hash table with configurable thresholds is
that it enables to cover a wide variety of use cases by adjusting the
thresholds. And we have the benefit of "keep it simple".

> Can't we tune the hash threshold internally? We could maintain
> a per hashlist policy counter. If we have 'many' policies and
> most of these policies are in the same hashlist we could change
> the hash threshold. We could check this when we add policies
> and update the hash threshold if needed.

I think that finding a generic algorithm to determine a good tradeof for
the local and remote thresholds is quite tough. I'm afraid tracking the
number of entries in each hlist is not enough. It would help to trigger
a change, but not to choose the new values. Thresholds both
determine which SPs will actually be hashed (vs. ones that will just be
enqueued in the inexact list) and the number of bits that will be
included in the hash key (and hence the entropy of the key). Moreover,
it is a pair of thresholds, which makes the choice even harder.

A user who knows what his SPD contains would probably prefer to be able
to tune the hash thresholds instead of relying on an uncontrolled,
automatic algorithm.

Exporting a userland API (here by /proc) enables a user or a daemon to
choose a strategy according to information the kernel does not
necessarily have, and enables to implement various (possibly complex)
policies.

> Everything else looks pretty good, thanks!
>

You're welcome :)
