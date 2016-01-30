From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Fri, 29 Jan 2016 20:46:00 -0800
Message-ID: <CAKgT0Uc8hf8CeMrHQhF453LrC3zecwijk=7_fpi=2QCSmRka+g@mail.gmail.com>
References: <20160129180651.GA17127@oracle.com>
	<20160130024556.6227.51798.stgit@localhost.localdomain>
	<1454124234.7627.119.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160129.193520.477355610549821770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35979 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158AbcA3EqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 23:46:01 -0500
Received: by mail-io0-f171.google.com with SMTP id g73so110575859ioe.3
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 20:46:01 -0800 (PST)
In-Reply-To: <20160129.193520.477355610549821770.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 7:35 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 29 Jan 2016 19:23:54 -0800
>
>> On Fri, 2016-01-29 at 18:49 -0800, Alexander Duyck wrote:
>>> This patch fixes an issue with unaligned accesses when using
>>> eth_get_headlen on a page that was DMA aligned instead of being IP aligned.
>>> The fact is when trying to check the length we don't need to be looking at
>>> the flow label so we can reorder the checks to first check if we are
>>> supposed to gather the flow label and then make the call to actually get
>>> it.
>>>
>>> Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
>>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>>> ---
>>
>>
>> You did not quite follow the discussion Alexander, we did not exactly
>> took a decision about this bug.
>>
>> As we mentioned, there are other parts that need care.
>>
>> key_keyid->keyid = *keyid;
>>
>> Please address them, instead of having to 'wait' for the next crash.

The key_id bit is not part of the "basic" keys.  The basic keys only
require a 2 byte alignment, it is when you start parsing to populate a
hash that you get into the wider fields.  As far as I know there
aren't any length fields that are wider than 2 bytes.

> Indeed, this is a more fundamental issue.
>
> This change in and of itself isn't bad, and is probably a suitable
> micro-optimization for net-next, but it doesn't fix the bug in
> question.

Actually it does fix the bug as reported.  The problem as reported was
for ixgbe using the function for parsing the length.  In the case of
just getting the length my patch resolves the issue as there are no
other accesses wider than 2 bytes used when *just* computing the
length.  This is something that will have to get addressed sooner or
later anyway, and at least with this patch in the basic case of IPv6
over ixgbe won't cause any issues.

The key_id bit that Eric is pointing out is called in a path that is
only executed if you are actually attempting to compute a hash.  Odds
are the fix for that is going to be much more complicated and extends
well outside this function since it is a fundamental issue with VXLAN
and GRE TEB tunnels as either the inner or outer headers end up being
unaligned unless you want to break them into two buffers so that they
can both be aligned at the same time.

Extending beyond this has anyone taken a look at the transmit path for
these tunnels?  I would suspect we probably also have a number of
issues there since either the inner or outer IP headers have to be
unaligned when we are setting those up.

- Alex
