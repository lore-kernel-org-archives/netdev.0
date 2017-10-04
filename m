From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net] net: br: Fix igmp snooping offload with
 CONFIG_BRIDGE_VLAN_FILTERING
Date: Wed, 4 Oct 2017 13:52:20 +0900
Message-ID: <c422306b-b6e5-34aa-4428-ea5a8b5f1a02@lab.ntt.co.jp>
References: <1506992111-25004-1-git-send-email-andrew@lunn.ch>
 <37af5488-a064-37dc-b1ce-373119ae7b05@lab.ntt.co.jp>
 <20171003121636.GB13548@lunn.ch>
 <ad0d7686-298b-02c7-d8f8-b9363f4630f3@gmail.com>
 <20171003153031.GP17713@lunn.ch>
 <87infwtd0b.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20171003164211.GA5177@shredder.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <toshiaki.makita1@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Ido Schimmel <idosch@idosch.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:42171 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750871AbdJDE4q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:56:46 -0400
In-Reply-To: <20171003164211.GA5177@shredder.mtl.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/10/04 1:42, Ido Schimmel wrote:
> On Tue, Oct 03, 2017 at 12:25:08PM -0400, Vivien Didelot wrote:
>> Andrew Lunn <andrew@lunn.ch> writes:
>>
>>>> The vlan will be effective only when vlan_filtering is enabled.
>>>> When vlan_filtering is disabled, vlan information is still kept in the
>>>> bridge and gets effective later when vlan_filtering becomes enable.
>>>
>>> O.K, so things are starting to get clearer.
>>>
>>> So when vlan filtering is disabled, the hardware should just ignore
>>> the requests to add the vlan to the hardware?
>>>
>>> When vlan_filtering is enabled, are all the vlans in the software
>>> bridge again offloaded? Or do we need to remember all the vlans which
>>> we ignored while vlan filtering was disabled? The average switch has
>>> nowhere to store these disabled vlans. It can only store active vlans.

Seems that __br_vlan_filter_toggle() only propagates
SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING.
IMHO vlan-related objects (vlan, fdb, and mdb) should be remembered if
vlan_filtering can be enabled later. But this sounds redundant as the
same information is maintained in the bridge so I'm not sure this is the
best way.

>>
>> When vlan_filtering is enabled on the bridge, the bridge code does
>> propagates the default_pvid again if I recall correctly.

I couldn't find it in the source...

>>
>> In my opinion the hardware mustn't ignore the VLAN requests, because we
>> seem to agree that vlan_filtering disabled means that the target ports
>> should not care yet about 802.1Q. So having some unused hardware VLAN
>> entries and some ports with disabled 802.1Q mode must work together.

Probably I don't fully understand you, but I think hardware can ignore
VLAN requests while vlan_filtering is disabled, as long as they are
properly populated to hardware on enabling vlan_filtering.

>>
>> That being said we still have the wrong hardware FDB populated when
>> CONFIG_BRIDGE_VLAN_FILTERING is enabled but not vlan_filtering...
> 
> The driver can make sure it's able to handle the configured
> `vlan_filtering` state during port enslavement to the bridge and also
> forbid it from being toggled once it's enslaved.

That is a simple solution.
One concern is backward compatibility. I wonder if we can prohibit
toggling for some driver which currently allows it.

-- 
Toshiaki Makita
