From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 9/9 v2] net: Add sysctl to trust checksum_complete
Date: Sun, 27 Apr 2014 10:03:48 -0700
Message-ID: <CA+mtBx-hAJDvXigrw1w3S1OBhmG4iiZvBBKNtCXZMt+8ZzFduw@mail.gmail.com>
References: <alpine.DEB.2.02.1404261402390.27405@tomh.mtv.corp.google.com>
	<20140426193135.7390d306@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:43139 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbaD0RDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 13:03:49 -0400
Received: by mail-ie0-f172.google.com with SMTP id at1so2305679iec.17
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2014 10:03:48 -0700 (PDT)
In-Reply-To: <20140426193135.7390d306@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 26, 2014 at 7:31 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Sat, 26 Apr 2014 14:26:35 -0700 (PDT)
> Tom Herbert <therbert@google.com> wrote:
>
>> Currently if a device provides CHECKSUM_COMPLETE but the checksum
>> is calculated to be invalid we recompute the checksum and try
>> again in software. On the other hand, if device returns
>> CHECKSUM_UNNECESSARY we implicitly trust it and don't verify what it
>> did. This seems backwards!
>>
>> Add a sysctl to trust the device and report an invalid checksum when
>> CHECKSUM_COMPLETE shows it is incorrect. sysctl defaults to enabled.
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>
> NO. Make one choice and do it consistently.
>
> Papering over driver bugs or design confusion with a sysctl is not a
> reasonable choice.
>
> If some device (or code path) has invalid checksum logic, it should
> be reported once and go ahead and fix it in software. The problem with
> CHECKSUM_UNNECESSARY is that there is no way to check that the device
> is broken without computing the checksum (catch-22).
>
Unlike CHECKSUM_UNNECESSARY, CHECKSUM_COMPLETE provides information
for both valid and invalid checksums. Also, CHECKSUM_COMPLETE is well
defined and specific as to what the device and driver are returning
and I have to believe should be easier to get right. So I don't see
any reason why we shouldn't use the negative information returned by
CHECKSUM_COMPLETE; always recomputing an invalid checksum in SW is a
waste of CPU cycles and could become a basis for DOS attack at high
speeds.

In the unlikely event that the HW (or driver) is incorrectly computing
the checksum this would manifest itself as checksum errors. This is
quite debuggable, and the sysctl would be useful to narrow down
whether the issue is in checksum calculation logic or actual bad
checksums. Compare this to incorrect reporting of CHECKSUM_UNNECESSARY
which could result in packets with errors being accepted without any
detection-- it might take years to identify such a problem!
