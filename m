From: Patrick McHardy <kaber@trash.net>
Subject: Re: error handling for dev_mc_sync (__dev_addr_add)
Date: Tue, 09 Jun 2009 17:00:57 +0200
Message-ID: <4A2E7929.9070705@trash.net>
References: <1244556667.4672.18.camel@johannes.local>	 <4A2E7376.4080407@trash.net> <1244558606.4672.25.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64983 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219AbZFIPA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 11:00:58 -0400
In-Reply-To: <1244558606.4672.25.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> On Tue, 2009-06-09 at 16:36 +0200, Patrick McHardy wrote:
>>> So how am I supposed to handle the error? Isn't it possible that
>>> dev_mc_unsync() will then cause trouble because it removes something
>>> that wasn't actually added? OTOH, there always is da->synced, but then
>>> __dev_addr_sync() confuses me -- why does it not increment da->da_users?
>> It does:
>>
>> 	if (!da->da_synced) {
>> 		err = __dev_addr_add(to, to_count,
>> 				     da->da_addr, da->da_addrlen, 0);
>> 		if (err < 0)
>> 			break;
>> 		da->da_synced = 1;
>> 		da->da_users++;
>>
>> The problem on errors is that it can't determine which addresses
>> were added in this run, and which were previously. So it can't undo
>> just the actions of the last run. A generation count for da_synced
>> could be used to fix that, but it would need to be bigger than the
>> currently used u8.
> 
> Hmm, ok, but in the da_synced case why is da_users not incremented? I
> don't claim to understand any of this code though :)

Its kind of a mess. In my excuse, it was even worse before the
synchronization functions were added :)

The __dev_addr_sync() function is for both incremental additions and
removals. In the da_synced (== already synced) case, it deletes the
address if it has a only a single reference left, which means its
only held for unsychronization, and releases the address completely
afterwards.

>> Adding proper error handling looks like a bigger task. First we
>> need all the callers of multicast address manipulation functions
>> to actually check the return value and perform some kind of
>> recovery on failure - which might not be possible in all cases,
>> I'm not sure (IPv6). 
> 
> Right.
> 
>> Then we need to be able to propagate errors
>> from ->set_multicast_list() and abort address list changes when
>> synchronization fails - which is not particulary complicated, but
>> requires touching a lot of drivers.
> 
> I think you're overstating?

Am I?

# grep -r set_multicast_list drivers/net/ | wc -l
499

It probably includes some false positives, but I think its still
quite a lot. You could of course add a new callback for those few
drivers which actually can fail.

> Regular drivers should need to be changed,
> would they, except for adding changing 'return' to 'return 0;' and
> adding a 'return 0;' at the end which is a quite simple spatch I'd
> think.

Right.

> Not that I want to do that now, I'm just confused by the semantics here,
> and the lack of error handling. Additionally, I'm worried if that might
> be causing the occasional 'multicast leaked' messages I was seeing, but
> I doubt it.

It shouldn't cause this from what I can tell.
