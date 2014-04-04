From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH] vlan: Try to adjust lower device mtu when configuring
 802.1AD vlans
Date: Fri, 04 Apr 2014 11:22:14 -0400
Message-ID: <533ECE26.3060702@redhat.com>
References: <1396387054-4510-1-git-send-email-vyasevic@redhat.com>		 <20140402122121.GD26334@macbook.localnet> <533C113E.2000908@redhat.com>	 <1396456652.2215.42.camel@localhost.localdomain>	 <533C3E60.8070509@redhat.com> <533D1C95.6010705@lab.ntt.co.jp>	 <533D5D24.9080005@redhat.com> <1396624132.1771.15.camel@localhost.localdomain>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25409 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752647AbaDDPWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2014 11:22:21 -0400
In-Reply-To: <1396624132.1771.15.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/2014 11:08 AM, Toshiaki Makita wrote:
> On Thu, 2014-04-03 at 09:07 -0400, Vlad Yasevich wrote:
>> On 04/03/2014 04:32 AM, Toshiaki Makita wrote:
>>> (2014/04/03 1:44), Vlad Yasevich wrote:
>>>> On 04/02/2014 12:37 PM, Toshiaki Makita wrote:
>>>>> On Wed, 2014-04-02 at 09:31 -0400, Vlad Yasevich wrote:
>>>>>> On 04/02/2014 08:21 AM, Patrick McHardy wrote:
>>>>>>> On Tue, Apr 01, 2014 at 05:17:34PM -0400, Vlad Yasevich wrote:
>>>>>>>> 802.1AD vlans supposed to encapsulate 802.1Q vlans.  To
>>>>>>>> do this, we need an extra 4 bytes of header which are typically
>>>>>>>> not accounted for by lower devices.  Some devices can not
>>>>>>>> support frames longer then 1522 bytes at all.  Such devices
>>>>>>>> can not really support 802.1AD, even in software, without
>>>>>>>> the vlan reducing its mtu value.
>>>>>>>>
>>>>>>>> This patch propses to increate the lower devices MTU to 1504
>>>>>>>> in case of 802.1AD configuration, and if device doesn't
>>>>>>>> support it, fail the creation of the vlan.  The user has an
>>>>>>>> option to configure older-style Q-in-Q vlans and manually
>>>>>>>> lower the mtu to support such encapsulation.
>>>>>>>
>>>>>>> I think you should do the opposite. The lower layer device may be used
>>>>>>> for other things than the VLAN, so it doesn't seem right to change it's
>>>>>>> MTU. Instead I'd propose to set the MTU of the 802.1ad VLAN device to
>>>>>>> the lower device'e MTU - 4 unless a MTU has been specified by the user.
>>>>>>>
>>>>>>
>>>>>> The decrease of vlan mtu was my initial take on this as well.  The
>>>>>> problematic case with this is forwarding by an encapsulating
>>>>>> bridge (bridge that has 802.1AD as one port and ethX as others). The
>>>>>> frame from ethX will not fit into the mtu of the vlan device in
>>>>>> this case and the packet is dropped.  Ideally, we'd generate and ICMP
>>>>>> Too Big, but with the bridge we can't/don't do that.
>>>>>>
>>>>>> Another problem is that linux assumes that MTU == MRU in case of
>>>>>> device receive buffer programming.  Thus, full sized 802.1AD
>>>>>> frames transmitted by the switch supporting it will probably get dropped
>>>>>> by the driver/firmware as too long.  I've tested this and saw it
>>>>>> happen on my systems.
>>>>>>
>>>>>> An alternative I've thought off is to adjust the rx size in the drivers
>>>>>> when 802.1AD is configured, but that touches all the drivers, and
>>>>>> doesn't work well for not vlan-filtering drivers.  It needs a new
>>>>>> ndo api to adjust the rx length to make it consistent across all
>>>>>> devices.
>>>>>>
>>>>>>> BTW, I couldn't find anything related to MTU handling in the 802.1ad
>>>>>>> standard, however I only have an old copy and might have looked in the
>>>>>>> wrong place. Do you have any information how this is supposed to be
>>>>>>> handled?
>>>>>>>
>>>>>>
>>>>>> The standard doesn't seem to mention anything about it, but looking
>>>>>> at switch implementations, most of them require a bump in the mtu to
>>>>>> 1504 to support 802.1AD.  Some allow for the decrease in vlan mtu, but
>>>>>> that also requires mss translations as well.
>>>>>
>>>>> 802.1ad was merged into 802.1Q-2011, and G.2.2 in it refers to maximum
>>>>> pdu size. However, this doesn't seem to mention the case where frames
>>>>> are double tagged.
>>>>>
>>>>> MEF 6.1 requires UNI MTU size >= 1522 and MEF 31 requires E-NNI MTU size
>>>>>> = 1526 (In these documents, MTU seems to mean frame size).
>>>>> This implies that we should allow 1508 bytes of MTU size when we use
>>>>> 802.1AD.
>>>>>
>>>>
>>>> 1522 = 1500 + 14 + 4 (.1Q) + 4 (FCS)
>>>>
>>>>> Is 1504 enough?
>>>>
>>>> 1526 = 1500 + 14 +4 (.1Q) + 4 (.1AD) + 4(FCS)
>>>
>>> Thank you for the supplementation.
>>>
>>>>
>>>> This is why Cisco docs recommend mtu of 1504.
>>>>
>>>> Of course this doesn't in any way account for stacked .1AD tags.
>>>
>>> So we are likely to receive 1508 (1526) sized frames in 802.1ad network.
>>
>> 1526 byte frame is 1504 mtu, as demonstrated above.
> 
> Not so sure.
> It's true only if NIC reserves extra 4 bytes for mtu.

Pretty much all drivers reserve extra 4 bytes for the .1Q header.

> If the outer 802.1ad tag is not recognized as a vlan tag by NIC, both
> the outer tag and the inner tag are not ethernet header but payload to
> the NIC.

But the nic doesn't really care about MTU values itself.  It uses it
to compute the frame length that it will support for rx and tx.  That
computation is what the above math shows.

So, the nics that do not support .1AD acceleration (the ones you
mentioned above), will already account for the .1Q header, but the MTU
(payload) needs to increased by 4 bytes to account for .1AD header.
We don't have to account for .1Q header again.

This actually reminds me that there is a bug in the e1000e code where
setting mtu to 1504 doesn't make it work.  One has to got up to 1508 to
get the right sizing.

> 
>>
>>> Is it correct that you confirmed most NICs can receive 1508 sized frames
>>> with 1504 mtu size setting?
>>
>> Some might, but I haven't confirmed that.  Most NICs already account for
>> 802.1Q header in their receive buffer calculations.  Some nics jump
>> to the 2K rx size and enable jumbo mode once rx size goes above 1522
>> bytes.  I think those will be able to receive larger frames. 
> 
> Thank you very much, got it.
> 
>> Others
>> don't support jumbo mode at all.  These nics can't support 802.1AD
>> without reducing mtu on the vlan interface itself.  
> 
> Doesn't setting mtu to 1508 help us in some cases?

Not in the cases where jumbo is _not_ supported.  The only thing
that makes these nics work is reduction of the mtu on the vlan device.
On nics that support jumbo, going up to 1504 makes things work.

-vlad

> 
> Thanks,
> Toshiaki Makita
> 
>> That, however, leads
>> to other necessary configuration changes which is why this proposal
>> leaves it up to the user to configure.
> 
> 
