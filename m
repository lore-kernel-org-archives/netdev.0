From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Thu, 11 Oct 2007 00:57:31 -0600
Message-ID: <m1r6k2i1es.fsf@ebiederm.dsl.xmission.com>
References: <m1r6ki9tib.fsf@ebiederm.dsl.xmission.com>
	<20071010.211654.85404234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:42981 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754851AbXJKG64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 02:58:56 -0400
In-Reply-To: <20071010.211654.85404234.davem@davemloft.net> (David Miller's
	message of "Wed, 10 Oct 2007 21:16:54 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Fri, 28 Sep 2007 18:59:08 -0600
>
>> 
>> Currently we have the call path:
>> macvlan_open -> dev_unicast_add -> __dev_set_rx_mode ->
>> 	__dev_set_promiscuity -> ASSERT_RTNL -> mutex_trylock
>> 
>> When mutex debugging is on taking a mutex complains if we are not
>> allowed to sleep.  At that point we have called netif_tx_lock_bh
>> so we are clearly not allowed to sleep.  Arguably this is not a
>> problem for mutex_trylock.
>> 
>> However we can avoid the complaint and make the ASSERT_RTNL code
>> cheaper, faster and more obvious by simply calling mutex_is_locked.
>> 
>> So this patch adds rtnl_is_locked (which does mutex_is_locked on
>> the rtnl_mutex) and changes ASSERT_RTNL to use that.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>
> There was a lot of discussion about how to do this right and
> therefore you'll need to resubmit all of this with this
> discussioned issues addressed.

Thanks for the update on where this patch sits.

My understanding is that the patch as I submitted it is correct.

The code path that sparked this patch has been seen to be extremely
convoluted from a locking perspective.  Herbert and Patrick have been
discussing that code path and it was my impression they were working
together to figure out how to refactor that code path to make the
locking simpler.  There are enough convoluted details that I
do not feel comfortable refactoring that code path.

There was a practical suggestion by Herbert that ASSERT_RTNL have a
might_sleep() added.  That suggestion will currently result in
ASSERT_RTNL firing unnecessarily from the macvlan_open code path.

So I do not feel comfortable adding a might_sleep() into ASSERT_RTNL,
as it appears that it will warn on currently correct code.  Even if
that code has code has nearly incomprehensible locking.

Eric
