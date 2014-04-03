From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [RFC PATCH] vlan: Try to adjust lower device mtu when configuring
 802.1AD vlans
Date: Thu, 03 Apr 2014 17:32:21 +0900
Message-ID: <533D1C95.6010705@lab.ntt.co.jp>
References: <1396387054-4510-1-git-send-email-vyasevic@redhat.com>	 <20140402122121.GD26334@macbook.localnet> <533C113E.2000908@redhat.com> <1396456652.2215.42.camel@localhost.localdomain> <533C3E60.8070509@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <toshiaki.makita1@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:41658 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162550AbaDCIch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 04:32:37 -0400
In-Reply-To: <533C3E60.8070509@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2014/04/03 1:44), Vlad Yasevich wrote:
> On 04/02/2014 12:37 PM, Toshiaki Makita wrote:
>> On Wed, 2014-04-02 at 09:31 -0400, Vlad Yasevich wrote:
>>> On 04/02/2014 08:21 AM, Patrick McHardy wrote:
>>>> On Tue, Apr 01, 2014 at 05:17:34PM -0400, Vlad Yasevich wrote:
>>>>> 802.1AD vlans supposed to encapsulate 802.1Q vlans.  To
>>>>> do this, we need an extra 4 bytes of header which are typically
>>>>> not accounted for by lower devices.  Some devices can not
>>>>> support frames longer then 1522 bytes at all.  Such devices
>>>>> can not really support 802.1AD, even in software, without
>>>>> the vlan reducing its mtu value.
>>>>>
>>>>> This patch propses to increate the lower devices MTU to 1504
>>>>> in case of 802.1AD configuration, and if device doesn't
>>>>> support it, fail the creation of the vlan.  The user has an
>>>>> option to configure older-style Q-in-Q vlans and manually
>>>>> lower the mtu to support such encapsulation.
>>>>
>>>> I think you should do the opposite. The lower layer device may be used
>>>> for other things than the VLAN, so it doesn't seem right to change it's
>>>> MTU. Instead I'd propose to set the MTU of the 802.1ad VLAN device to
>>>> the lower device'e MTU - 4 unless a MTU has been specified by the user.
>>>>
>>>
>>> The decrease of vlan mtu was my initial take on this as well.  The
>>> problematic case with this is forwarding by an encapsulating
>>> bridge (bridge that has 802.1AD as one port and ethX as others). The
>>> frame from ethX will not fit into the mtu of the vlan device in
>>> this case and the packet is dropped.  Ideally, we'd generate and ICMP
>>> Too Big, but with the bridge we can't/don't do that.
>>>
>>> Another problem is that linux assumes that MTU == MRU in case of
>>> device receive buffer programming.  Thus, full sized 802.1AD
>>> frames transmitted by the switch supporting it will probably get dropped
>>> by the driver/firmware as too long.  I've tested this and saw it
>>> happen on my systems.
>>>
>>> An alternative I've thought off is to adjust the rx size in the drivers
>>> when 802.1AD is configured, but that touches all the drivers, and
>>> doesn't work well for not vlan-filtering drivers.  It needs a new
>>> ndo api to adjust the rx length to make it consistent across all
>>> devices.
>>>
>>>> BTW, I couldn't find anything related to MTU handling in the 802.1ad
>>>> standard, however I only have an old copy and might have looked in the
>>>> wrong place. Do you have any information how this is supposed to be
>>>> handled?
>>>>
>>>
>>> The standard doesn't seem to mention anything about it, but looking
>>> at switch implementations, most of them require a bump in the mtu to
>>> 1504 to support 802.1AD.  Some allow for the decrease in vlan mtu, but
>>> that also requires mss translations as well.
>>
>> 802.1ad was merged into 802.1Q-2011, and G.2.2 in it refers to maximum
>> pdu size. However, this doesn't seem to mention the case where frames
>> are double tagged.
>>
>> MEF 6.1 requires UNI MTU size >= 1522 and MEF 31 requires E-NNI MTU size
>>> = 1526 (In these documents, MTU seems to mean frame size).
>> This implies that we should allow 1508 bytes of MTU size when we use
>> 802.1AD.
>>
> 
> 1522 = 1500 + 14 + 4 (.1Q) + 4 (FCS)
> 
>> Is 1504 enough?
> 
> 1526 = 1500 + 14 +4 (.1Q) + 4 (.1AD) + 4(FCS)

Thank you for the supplementation.

> 
> This is why Cisco docs recommend mtu of 1504.
> 
> Of course this doesn't in any way account for stacked .1AD tags.

So we are likely to receive 1508 (1526) sized frames in 802.1ad network.
Is it correct that you confirmed most NICs can receive 1508 sized frames
with 1504 mtu size setting?

Thanks,
Toshiaki Makita
