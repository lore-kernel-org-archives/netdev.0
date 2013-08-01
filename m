From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: fix usage of NLM_F_EXCL or NLM_F_REPLACE
Date: Wed, 31 Jul 2013 17:03:48 -0700 (PDT)
Message-ID: <20130731.170348.1752477967026355787.davem@davemloft.net>
References: <1375093804-7534-1-git-send-email-pablo@netfilter.org>
	<20130730.164423.1103943978365554977.davem@davemloft.net>
	<20130731111215.GA6062@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748Ab3HAADt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 20:03:49 -0400
In-Reply-To: <20130731111215.GA6062@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed, 31 Jul 2013 13:12:15 +0200

> Hi David!
> 
> On Tue, Jul 30, 2013 at 04:44:23PM -0700, David Miller wrote:
>> From: Pablo Neira Ayuso <pablo@netfilter.org>
>> Date: Mon, 29 Jul 2013 12:30:04 +0200
>> 
>> > Currently, it is not possible to use neither NLM_F_EXCL nor
>> > NLM_F_REPLACE from genetlink. This is due to this checking in
>> > genl_family_rcv_msg:
>> > 
>> > 	if (nlh->nlmsg_flags & NLM_F_DUMP)
>> > 
>> > NLM_F_DUMP is NLM_F_MATCH|NLM_F_ROOT. Thus, if NLM_F_EXCL or
>> > NLM_F_REPLACE flag is set, genetlink believes that you're
>> > requesting a dump and it calls the .dumpit callback.
>> > 
>> > The solution that I propose is to refine this checking to
>> > make it stricter:
>> > 
>> > 	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP)
>> > 
>> > And given the combination NLM_F_REPLACE and NLM_F_EXCL does
>> > not make sense to me, it removes the ambiguity.
>> > 
>> > There was a patch that tried to fix this some time ago (0ab03c2
>> > netlink: test for all flags of the NLM_F_DUMP composite) but it
>> > tried to resolve this ambiguity in *all* existing netlink subsystems,
>> > not only genetlink. That patch was reverted since it broke iproute2,
>> > which is using NLM_F_ROOT to request the dump of the routing cache.
>> > 
>> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
>> 
>> Yes, I remember that old attempt to fix this.
>> 
>> Ok, let's see what happens when we limit the scope of this change
>> to just genetlink users.
>>
>> I honestly can't believe that NLM_F_EXCL and NLM_F_REPLACE are
>> completely unusable in normal rtnetlink interfaces.
> 
> I guess you mean 'genetlink' instead of 'rtnetlink'.

I really meant 'rtnetlink' and netlink in general.  As you stated, we
tried to make the same check for all netlink users, and it had to
be reverted because iproute2 uses NLM_F_ROOT to get a dump.

Therefore I don't see how NLM_F_REPLACE and NLM_F_EXCL can be used
at all, in those places, because the check is still "& NLM_F_DUMP"
