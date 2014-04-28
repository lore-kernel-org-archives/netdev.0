From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9 v2] net: Add sysctl to trust checksum_complete
Date: Sun, 27 Apr 2014 23:32:04 -0400 (EDT)
Message-ID: <20140427.233204.1660487737838648405.davem@davemloft.net>
References: <alpine.DEB.2.02.1404261402390.27405@tomh.mtv.corp.google.com>
	<20140426193135.7390d306@samsung-9>
	<CA+mtBx-hAJDvXigrw1w3S1OBhmG4iiZvBBKNtCXZMt+8ZzFduw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbaD1DcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 23:32:05 -0400
In-Reply-To: <CA+mtBx-hAJDvXigrw1w3S1OBhmG4iiZvBBKNtCXZMt+8ZzFduw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 27 Apr 2014 10:03:48 -0700

> On Sat, Apr 26, 2014 at 7:31 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> On Sat, 26 Apr 2014 14:26:35 -0700 (PDT)
>> Tom Herbert <therbert@google.com> wrote:
>>
>>> Currently if a device provides CHECKSUM_COMPLETE but the checksum
>>> is calculated to be invalid we recompute the checksum and try
>>> again in software. On the other hand, if device returns
>>> CHECKSUM_UNNECESSARY we implicitly trust it and don't verify what it
>>> did. This seems backwards!
>>>
>>> Add a sysctl to trust the device and report an invalid checksum when
>>> CHECKSUM_COMPLETE shows it is incorrect. sysctl defaults to enabled.
>>>
>>> Signed-off-by: Tom Herbert <therbert@google.com>
>>> ---
>>
>> NO. Make one choice and do it consistently.
>>
>> Papering over driver bugs or design confusion with a sysctl is not a
>> reasonable choice.
>>
>> If some device (or code path) has invalid checksum logic, it should
>> be reported once and go ahead and fix it in software. The problem with
>> CHECKSUM_UNNECESSARY is that there is no way to check that the device
>> is broken without computing the checksum (catch-22).
>>
> Unlike CHECKSUM_UNNECESSARY, CHECKSUM_COMPLETE provides information
> for both valid and invalid checksums. Also, CHECKSUM_COMPLETE is well
> defined and specific as to what the device and driver are returning
> and I have to believe should be easier to get right. So I don't see
> any reason why we shouldn't use the negative information returned by
> CHECKSUM_COMPLETE; always recomputing an invalid checksum in SW is a
> waste of CPU cycles and could become a basis for DOS attack at high
> speeds.
> 
> In the unlikely event that the HW (or driver) is incorrectly computing
> the checksum this would manifest itself as checksum errors. This is
> quite debuggable, and the sysctl would be useful to narrow down
> whether the issue is in checksum calculation logic or actual bad
> checksums. Compare this to incorrect reporting of CHECKSUM_UNNECESSARY
> which could result in packets with errors being accepted without any
> detection-- it might take years to identify such a problem!

If we do anything, we should do it consistently and not just for one
specific checksum delivery type.

So if we add a sysctl, it should revalidate the checksum in software
for all checksum offload variants, and such a sysctl should be off by
default.
