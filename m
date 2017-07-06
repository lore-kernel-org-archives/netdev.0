From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [PATCH net-next RFC 08/12] net: dsa: Remove support for bypass
 bridge port attributes/vlan set
Date: Thu, 6 Jul 2017 14:00:01 +0300
Message-ID: <b28de8fe-5bf0-b982-1868-4fbab42c17c2@mellanox.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
 <1499268990-19251-9-git-send-email-arkadis@mellanox.com>
 <9b066beb-190f-ddc8-74bd-c59cee98d059@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, stephen@networkplumber.org,
        mlxsw@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0087.outbound.protection.outlook.com ([104.47.1.87]:11168
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752414AbdGFLAM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 07:00:12 -0400
In-Reply-To: <9b066beb-190f-ddc8-74bd-c59cee98d059@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/05/2017 10:45 PM, Florian Fainelli wrote:
> On 07/05/2017 08:36 AM, Arkadi Sharshevsky wrote:
>> The bridge port attributes/vlan for DSA devices should be set only
>> from bridge code. Furthermore, The vlans are synced totally with the
>> bridge so there is no need for special dump support.
>>
>> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> I would be more comfortable if we still had a way to dump HW entries by
> calling into drivers, because it's useful for debugging, and doing that
> using standard tools plus an additional flag for instance:
> 
> bridge fdb show
> 
> would dump the SW-maintained VLANs, but:
> 
> bridge fdb show hw
> 

I agree that in your case, the FDBs are exception because they cannot be
synced with the sw bridge due to lack of interrupt per learned entry,
but note that this ability of bypass dump should not be supported by
switchdev code because its contradicts the model. That is why I moved it
inside DSA in one of the following patches (another reason is that
nobody is using it beside you so there is no reason to leave it there).

This is especially true for vlans which are synced completely with the
software bridge.

Regarding debugging, if you want to see the hardware tables you can
easily use dpipe for that. For example you can add table which does
match on vlan and mac and set the output port, or some table that
matches port and incoming packets vlan into internal metadata (FID)
that can be used for lookup.

I just don't think it is good idea for mixing this tools together.

> would dump the HW-maintained VLANs, or any flag name really, but the
> point is that we can keep using a standard tool to expose debugging
> features. debugfs (or something else) could be used, but was rejected by
> David.
> 
> Also, technically, it ought to be possible to configure a port's VLAN
> membership (although using poor semantics) through e.g: vconfig add
> sw0p0 1, which would call ndo_vlan_rx_add_vid() (DSA does not support it
> but mlxsw does), and so being able to dump that configuration would be

Yeah, in mlxsw the vlan devices are used mainly for vlan unaware bridge,
so the vlans will not be visible by the bridge, but the correct API to
see this is via:

$ip -d link show sw1p7.8

> somehow helpful.
> 
