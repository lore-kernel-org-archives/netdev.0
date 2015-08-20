From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: Re: [RFC v2 3/3] iwlwifi: mvm: transfer the truesize to the last
 TSO segment
Date: Thu, 20 Aug 2015 13:53:09 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E82654B@hasmsx107.ger.corp.intel.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1439989181-4444-4-git-send-email-emmanuel.grumbach@intel.com>
	 <1439994266.6610.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8253CF@hasmsx107.ger.corp.intel.com>
	 <1440016762.6610.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8257BD@hasmsx107.ger.corp.intel.com>
 <1440076269.6610.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ido@wizery.com" <ido@wizery.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sharon, Sara" <sara.sharon@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31149 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639AbbHTNxO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 09:53:14 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/20/2015 04:11 PM, Eric Dumazet wrote:
> On Thu, 2015-08-20 at 06:21 +0000, Grumbach, Emmanuel wrote:
>>
>> On 08/19/2015 11:39 PM, Eric Dumazet wrote:
>>> On Wed, 2015-08-19 at 19:17 +0000, Grumbach, Emmanuel wrote:
>>>
>>>> Hm.. how would net/core/tso.c avoid this?
>>>
>>> Because a driver using these helpers keep around the original LSO packet
>>> and frees it normally at TX completion time.
>>>
>>
>> Which is why I can't really use it. The complexity is that I have to
>> (ieee802.11 specification) split an LSO is several 802.11 packets. The
>> maximal 802.11 packet I can send under ideal condition is 11K long or
>> so. So I *must* generate several 802.11 frames from one single LSO
>> packet. OTOH, I can have more than MSS bytes in a 802.11 A-MSDU.
>>
> 
> Who said you had to free original packet ? Just keep it around.
> 
> TCP will work better ( check skb_still_in_host_queue() helper if you
> want to know why)

I do keep the original skb: it becomes the first 802.11 packet generated
from that LSO skb. Thing is that it will be freed first and I wanted the
*last packet* to release the pressure on the socket.
So I guess that skb_still_in_host_queue will still find it and avoid
retransmissions at least until the first skb of the LSO is freed.
But unless you are fine with releasing the pressing on the socket as
soon as the *first* 802.11 skb is freed, I need that code.

I'll try to look at dev->gso_max_size that you mentioned below. This can
really be a game changer for me.

> 
>> Maybe what would help would be to be able to dynamically change the
>> maximal size of an LSO packet. That would allow the wifi driver to
>> ensure that the LSO can fit in a single 802.11 packet. Note that since
>> the maximal length of the A-MSDU can vary based on link conditions
>> (since there is only one CRC for the whole A-MSDU, you don't want long
>> A-MSDUs in bad link conditions) the driver would need to be able to tell
>> the TCP stack to modify the length of an LSO packet.
>> To me, this sounds to be ... an overkill?
> 
> It is already doable. Check dev->gso_max_size ( and
> netif_set_gso_max_size())
> 
> Make sure you do not reinvent the wheel ;)
> 
> 
> 
