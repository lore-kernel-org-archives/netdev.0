From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v1 7/7] macvlan: add FDB bridge ops and new macvlan
 mode
Date: Tue, 10 Apr 2012 07:25:58 -0700
Message-ID: <4F8442F6.5070707@intel.com>
References: <20120409215419.3288.50790.stgit@jf-dev1-dcblab> <20120409220053.3288.40867.stgit@jf-dev1-dcblab> <20120410080916.GB26540@redhat.com> <4F843544.8060209@intel.com> <20120410134321.GB18899@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: roprabhu@cisco.com, stephen.hemminger@vyatta.com,
	davem@davemloft.net, hadi@cyberus.ca, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gregory.v.rose@intel.com, krkumar2@in.ibm.com, sri@us.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18545 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758876Ab2DJOZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 10:25:59 -0400
In-Reply-To: <20120410134321.GB18899@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/2012 6:43 AM, Michael S. Tsirkin wrote:
> On Tue, Apr 10, 2012 at 06:27:32AM -0700, John Fastabend wrote:
>> On 4/10/2012 1:09 AM, Michael S. Tsirkin wrote:
>>> On Mon, Apr 09, 2012 at 03:00:54PM -0700, John Fastabend wrote:
>>>> This adds a new macvlan mode MACVLAN_PASSTHRU_NOPROMISC
>>>> this mode acts the same as the original passthru mode _except_
>>>> it does not set promiscuous mode on the lowerdev. Because the
>>>> lowerdev is not put in promiscuous mode any unicast or multicast
>>>> addresses the device should receive must be explicitely added
>>>> with the FDB bridge ops. In many use cases the management stack
>>>> will know the mac addresses needed (maybe negotiated via EVB/VDP)
>>>> or may require only receiving known "good" mac addresses. This
>>>> mode with the FDB ops supports this usage model.
>>>
>>>
>>> Looks good to me. Some questions below:
>>>
>>>> This patch is a result of Roopa Prabhu's work. Follow up
>>>> patches are needed for VEPA and VEB macvlan modes.
>>>
>>> And bridge too?
>>>
>>
>> Yes I called this mode VEB here but this is defined in if_link.h
>> as IFLA_MACVLAN_MODE_BRIDGE. From a IEEE point of view I think
>> the macvlan bridge mode acts more like a 802.1Q VEB then a 802.1d
>> bridge.
> 
> grep didn't find IFLA_MACVLAN_MODE_BRIDGE - which kernel
> are you looking at?

grr sorry typo MACVLAN_MODE_BRIDGE in if_link.h

> 
>>> Also, my understanding is that other modes won't need a flag
>>> like this since they don't put the device in promisc mode initially,
>>> so no assumptions are broken if we require all addresses
>>> to be declared, right?
>>>
>>
>> correct. But requires extra work to the hash table so the forwarding
>> works correctly.
>>
>>> A final question: I think we'll later add a macvlan mode
>>> that does not flood all multicasts. This would change behaviour
>>> in an incompatible way so we'll probably need yet another
>>> flag. Would it make sense to combine this functionality
>>> with nopromisc so we have less modes to support?
>>>
>>
>> For VEPA and bridge modes this makes sense to me.
> 
> Hmm okay, but this would mean we should convert
> MACVLAN_MODE_PASSTHRU_NOPROMISC to something
> that can combined with all modes. E.g.
> MACVLAN_MODE_BRIDGE | MACVLAN_MODE_FLAG_XXXXX
> 
> and document that it does not promise to flood
> multicast.
>

How about changing MACVLAN_MODE_PASSTHRU_NOPROMISC -> MACVLAN_MODE_NOPORMISC
for this patch. Then a follow on series can rework bridge
and VEPA to use it as well.
 
>> If you want
>> the flood behavior you can create it by adding the addr to all
>> the devices or just to a subset of them to get the non-flooding
>> capabilities.
>>
>> .John
> 
> BTW we seem to try to flood in pass-through too, not sure why.
> 

Suppose your looking at macvlan_handle_frame()? It does
seem unneeded.

.John
