From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Wed, 10 Sep 2008 08:16:12 +0300
Message-ID: <48C7581C.1080800@iki.fi>
References: <20080910032304.GA28580@gondor.apana.org.au>	<20080909.203808.112347106.davem@davemloft.net>	<20080910040107.GA29695@gondor.apana.org.au> <20080909.210654.159776216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:6993 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbYIJFQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 01:16:06 -0400
Received: by nf-out-0910.google.com with SMTP id d3so840908nfc.21
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2008 22:16:03 -0700 (PDT)
In-Reply-To: <20080909.210654.159776216.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 10 Sep 2008 14:01:07 +1000
> 
>> On Tue, Sep 09, 2008 at 08:38:08PM -0700, David Miller wrote:
>>> No problem.  It might be a little bit of a chore because this new
>>> walker design is intimately tied to the af_key non-atomic dump
>>> changes.
>> Actually I was mistaken as to how the original dump worked.  I'd
>> thought that it actually kept track of which bucket it was in and
>> resumed from that bucket.  However in reality it only had a global
>> counter and would always start walking from the beginning up until
>> the counted value.  So it isn't as easy as just copying the old
>> code across :)
> 
> Only AF_KEY gave an error, and this ended the dump.  This was
> one of Timo's goals, to make AF_KEY continue where it left
> off in subsequent dump calls done by the user, when we hit the
> socket limit.

Yes, this was the other goal. The other goal was to speed up
dumping in netlink from O(n^2) to O(n). And fixing the problem that
netlink might miss to dump some entries (if an entry was removed
from the beginning of the hash when dumping was ongoing).

> ipsec: Restore hash based xfrm_state dumping.
> 
> Get rid of ->all member of struct xfrm_state, and just use a hash
> iteration like we used before.
> 
> This shrinks the size of struct xfrm_state, and also restores the
> dump ordering of 2.6.25 and previous.

I think bad things will happen if the hash gets resized between
xfrm_state_walk() calls. Since it assumes that the walk->state
entry has remained in walk->chain bucket.

The dumping order shouldn't really make any difference. But
reducing struct xfrm_state is definitely good. The only downside
is that when an entry is inserted to the beginning of the hash
while dump is ongoing, it won't be dumped at all. But that is
not really a problem since you get a notification about that
entry separately.

Cheers,
  Timo
