From: Patrick McHardy <kaber@trash.net>
Subject: Re: error handling for dev_mc_sync (__dev_addr_add)
Date: Tue, 09 Jun 2009 16:36:38 +0200
Message-ID: <4A2E7376.4080407@trash.net>
References: <1244556667.4672.18.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64511 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757920AbZFIOgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 10:36:37 -0400
In-Reply-To: <1244556667.4672.18.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> I can't seem to figure out how to handle errors from dev_mc_sync(). I
> can see why it fails, looking at __dev_addr_add(), because memory
> allocations can fail. However, it seems that __dev_addr_sync() will then
> leave the netdev in a state where some addresses were added, but others
> were not. And ndo_set_multicast_list() cannot even return an error code.
> 
> So how am I supposed to handle the error? Isn't it possible that
> dev_mc_unsync() will then cause trouble because it removes something
> that wasn't actually added? OTOH, there always is da->synced, but then
> __dev_addr_sync() confuses me -- why does it not increment da->da_users?

It does:

	if (!da->da_synced) {
		err = __dev_addr_add(to, to_count,
				     da->da_addr, da->da_addrlen, 0);
		if (err < 0)
			break;
		da->da_synced = 1;
		da->da_users++;

The problem on errors is that it can't determine which addresses
were added in this run, and which were previously. So it can't undo
just the actions of the last run. A generation count for da_synced
could be used to fix that, but it would need to be bigger than the
currently used u8.

But that wouldn't fix the fundamental problem that almost no callers
of dev_mc_add checks for errors, so even if you abort and clean up
properly, the higher layers will take it as success and not retry.

> Basically what I need is the patch below to maintain a multicast list,
> but I'm wondering if it's all correct that way and what error handling I
> need and am currently lacking if I ignore the return value of
> dev_mc_sync().

Adding proper error handling looks like a bigger task. First we
need all the callers of multicast address manipulation functions
to actually check the return value and perform some kind of
recovery on failure - which might not be possible in all cases,
I'm not sure (IPv6). Then we need to be able to propagate errors
from ->set_multicast_list() and abort address list changes when
synchronization fails - which is not particulary complicated, but
requires touching a lot of drivers.
