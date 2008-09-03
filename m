From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Wed, 03 Sep 2008 10:14:02 +0300
Message-ID: <48BE393A.50309@iki.fi>
References: <48BE2E63.8000707@iki.fi>	<20080902.233538.200370430.davem@davemloft.net>	<48BE329C.2010209@iki.fi> <20080902.234723.163403187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:12801 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359AbYICHNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 03:13:54 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2105786fkq.5
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2008 00:13:53 -0700 (PDT)
In-Reply-To: <20080902.234723.163403187.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Get creative, use a key of some sort to continue the walk, that's what
> other netlink'ish subsystems use.

Ok. ctnetlink_dump_table() seems to iterate the hash list and keeps
a unique id where it left. If that entry was deleted it starts again
from that hash bucket.

We could iterate SPD by idx. By SPI would be nice for SAD, but not
all entries have SPI. I guess we could use either of the bysrc or bydst
hash and memorize xfrm_id. Restart from first hash bucket entry if
the memorized entry gets deleted, and restart from the beginning
if hash gets resized.

This way we could avoid the additional locking and guarantee that all
entries are dumped in reasonable time.

>> Yes, but the dumping code produced crap. It could dump same entry
>> multiple times, miss entries and was dog slow. With it there was
>> no possibility to keep userland in sync with kernel SPD/SAD because
>> entries were lost.
> 
> I'd rather see an entry twice in a dump than have my IPSEC gateway
> lockup, or run slower because we take a lock twice as often as
> necessary during object destruction.

Seeing entry twice is not a problem. Not seeing an entry at all was
the real problem. Also listing SAD could take tens of seconds on
modern system. That's not nice either.

- Timo
