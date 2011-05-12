From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCHv3 net-next-2.6 2/3] qlcnic: Take FW dump via ethtool
Date: Thu, 12 May 2011 13:54:19 -0700
Message-ID: <135A6631-C557-4C01-9FDD-F9E58F555168@qlogic.com>
References: <1305154448-9687-1-git-send-email-anirban.chakraborty@qlogic.com>
 <1305154448-9687-4-git-send-email-anirban.chakraborty@qlogic.com>
 <1305221242.5214.36.camel@bwh-desktop>
 <F9877D83-226B-4C7A-AD01-E9AA441AD1CD@qlogic.com>
 <1305227938.5214.48.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:38714 "EHLO
	TX2EHSOBE008.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758559Ab1ELUyX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 16:54:23 -0400
In-Reply-To: <1305227938.5214.48.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 12, 2011, at 12:18 PM, Ben Hutchings wrote:

> On Thu, 2011-05-12 at 11:53 -0700, Anirban Chakraborty wrote:
>> On May 12, 2011, at 10:27 AM, Ben Hutchings wrote:
>> 
>>> On Wed, 2011-05-11 at 15:54 -0700, Anirban Chakraborty wrote:
>>>> Driver checks if the previous dump has been cleared before taking the dump.
>>>> It doesn't take the dump if it is not cleared.
>>>> 
>>>> Changes from v2:
>>>> Added lock to protect dump data structures from being mangled while
>>>> dumping or setting them via ethtool.
>>> 
>>> Unfortunately it still seems to be possible for the dump length to
>>> change between the ethtool core calling qlcnic_get_dump_flag() and
>>> qlcnic_get_dump_data().
>> 
>> dump length is serialized via the driver lock. dump length is a static
>> entity for a given capture mask and it can only be changed when there
>> is a different capture mask set in the driver (via calling set_dump()
>> from ethtool core).
> 
> OK.
> 
>> Actual dump size is determined during the initial steps of FW dump
>> which takes the driver lock to start with. So, I am not sure how the
>> dump length could be changed between the calls to get_dump_flag and
>> get_dump_data from within the ethtool core without a call to
>> set_dump() in between.
> [...]
> 
> What prevents this sequence:
> 
> 1. Driver detects firmware dump is required, and creates the dump
> (length L1).
> 2. User changes firmware dump flags through ethtool.
> 3. User starts to save firmware dump through ethtool:
>   a. ethtool utility reads dump length (= L1) and allocates user buffer
>   b. ethtool utility reads dump:
>   c. ethtool core reads dump length (L1) and allocates kernel buffer
> 4. Meanwhile, driver detects firmware dump is required again, and
> creates a new dump (length L2, since dump flags changed)

This step won't happen as driver ensures that if a dump is taken that is not
cleared yet by ethtool utility, it is not going to take any further dump. So, until
the get_dump_data() has been called to fetch the dump data, changing dump
flag (and hence dump size) will not have any effect.
In 3 above, ethtool core created a buffer of L1 size but hasn't yet called 
get_dump_data() of the driver, so driver is still holding onto its previously
dumped data even though capture mask has been changed and the driver
encountered a situation where it ought to take the dump.

-Anirban
