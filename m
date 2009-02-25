From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Wed, 25 Feb 2009 08:18:47 +0100
Message-ID: <49A4F0D7.20304@trash.net>
References: <49A4D5D5.5090602@trash.net> <20090225061902.GA32430@gondor.apana.org.au> <49A4E3F8.4050406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53487 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500AbZBYHSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:18:50 -0500
In-Reply-To: <49A4E3F8.4050406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Herbert Xu wrote:
>> On Wed, Feb 25, 2009 at 06:23:33AM +0100, Patrick McHardy wrote:
>>> An easy fix would be to keep track of whether sysctl unregistration
>>> is in progress in IPv4/IPv6 and ignore new requests from that point
>>> on. Its not very elegant though, so I was wondering whether anyone
>>> has a better suggestion.
>>
>> We could make the unregistration asynchronous and invoke a callback
>> when it's done.  Then we can simply hold a net_device refcount and
>> relinquish it in the callback
> 
> That sounds simple enough. I'll see if I can come up with a patch, thanks.

Unfortunately its more complicated than I thought because of
device renames, where the sysctl pointer is reused after
unregistration and the rename/unregistration/re-registration
should be atomic. Deferring unregistration means we can't perform
the new registration immediately unless we allow multiple
registrations for a single device to be active simulaneously,
which introduces a whole new set of problems.

Simply ignoring the request during unregistration doesn't seem
so bad after all, the main problem is that it intoduces a different
race on renames where a write to the "forwarding" file returns
success, but the change doesn't take effect. We could return
-ENOENT, but that seems a bit strange after open() returned success.
Maybe -EBUSY, although I would prefer to make this transparent
to userspace.

Another alternative would be to simply not take the RTNL in
the sysctl handler since we're already taking dev_base_lock
before performing any forwaring changes. But in case of IPv4
we need it for disabling LRO.

I think I'm stuck. Will rethink it after some coffee :)

