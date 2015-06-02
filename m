From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 5/5] rocker: remove support for legacy VLAN ndo ops
Date: Tue, 2 Jun 2015 00:10:12 -0700
Message-ID: <CAE4R7bBL+=-akoNLPqPae=zrYe3DH59t=8UK_T7KhcHSNaKUtw@mail.gmail.com>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
 <1433183947-13095-6-git-send-email-sfeldma@gmail.com> <556D363A.5010005@lab.ntt.co.jp>
 <20150601.222442.1854333703599698362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:35564 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbbFBHKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 03:10:33 -0400
Received: by qgg60 with SMTP id 60so55787452qgg.2
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 00:10:32 -0700 (PDT)
In-Reply-To: <20150601.222442.1854333703599698362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 1, 2015 at 10:24 PM, David Miller <davem@davemloft.net> wrote:
> From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Date: Tue, 02 Jun 2015 13:51:06 +0900
>
>> On 2015/06/02 3:39, sfeldma@gmail.com wrote:
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>
>>> Remove support for legacy ndo ops
>>> .ndo_vlan_rx_add_vid/.ndo_vlan_rx_kill_vid.  Rocker will use
>>> bridge_setlink/dellink exclusively for VLAN add/del operations.
>>>
>>> The legacy ops are needed if using 8021q driver module to setup VLANs on
>>> the port.  But an alternative exists in using bridge_setlink/delink to
>>> setup VLANs, which doesn't depend on 8021q module.  So rocker will switch
>>> to the newer setlink/dellink ops.  VLANs can added/delete from the port,
>>> regardless if port is bridged or not, using the bridge commands:
>>>
>>>      bridge vlan [add|del] vid VID dev DEV self
>>
>> Hi Scott,
>>
>> This doesn't look transparent with bridge.
>>
>> Before this patch, I was able to add vid in the same way as software bridge:
>>
>>   ip link set DEV master br0
>>   bridge vlan add vid VID dev DEV
>>
>> Now I need to add "self", which is different from software bridge...
>
> I'm already not liking the looks of this....

Actually, we're now consistent with bridge man page which says master
is the default.

Want we want, I believe, is to adjust what the man page says (and the
bridge vlan command itself), by making the default master and self.
The kernel and driver are fine, it's the default in the bridge command
that needs adjusting.  Once we do this, we'll be back to transparent
with software-only bridge.

How did we get here?   So the RTM_SETLINK for PF_BRIDGE calls
rtnl_bridge_setlink().  rtnl_bridge_setlink() calls ndo_bridge_setlink
for the master (the bridge side of the port) and self (the device side
of the port), depending on if MASTER and/or SELF flags are set.  Since
the default from the iproute2 bridge vlan cmd is to only set MASTER,
only the bridge's ndo_bridge_setlink is called.  But if you dig down
into the bridge's ndo_bridge_setlink, you'll see it will call into the
port driver's ndo_vlan_rx_add_vid() to add the vlan to the device side
of the port.  So we have a MASTER cmd that is doing some SELF work.
My guess this was done to avoid having to update all the NIC drivers
from  ndo_vlan_rx_add_vid to ndo_bridge_setlink.  When you remove
ndo_vlan_rx_add_vid() from the port driver, the cmd needs to target
MASTER and SELF for both sides of the port to be called.  But the
current cmd only sets MASTER.  This is why you (currently) need to add
SELF for cmd to target the device side of the port.

On top of all of this, you can use RTM_SETLINK for PF_BRIDGE on
non-bridged ports, in which case only SELF is used to program the VLAN
on the device, using the device's ndo_bridge_setlink.  This is the
confusing part where you can set VLANs on non-bridged ports using the
bridge cmd.

To summarize, pseudo code for rtnl_bridge_setlink() is:

    rtnl_bridge_setlink()
        if MASTER
            call bridge's ndo_bridge_setlink()
                if bridge port implements ndo_vlan_rx_add_vid()
                    call ndo_vlan_rx_add_vid() on port device to set vlan
        if SELF
            call port device's ndo_bridge_setlink()

If DEV is bridged, today we have:

    bridge vlan add vid VID dev DEV                              sets
MASTER (default)
    bridge vlan add vid VID dev DEV master                   sets MASTER
    bridge vlan add vid VID dev DEV self                        sets SELF
    bridge vlan add vid VID dev DEV master self             sets MASTER and SELF

if DEV is not bridged, today we have:

    bridge vlan add vid VID dev DEV                              //
fails  (no master device)
    bridge vlan add vid VID dev DEV self                        sets SELF

What I propose is we change the bridge vlan cmd for the DEV bridged
case as such:

    bridge vlan add vid VID dev DEV                              sets
MASTER and SELF (default)
    bridge vlan add vid VID dev DEV master                   sets MASTER
    bridge vlan add vid VID dev DEV self                        sets SELF
    bridge vlan add vid VID dev DEV master self             sets MASTER and SELF

For existing users of ndo_vlan_rx_add_vid/ndo_vlan_rx_kill_vid,
nothing really changes.  If they also have an ndo_bridge_setlink,
it'll get called but they're not doing any vlan stuff there today
anyway, so it's ignored.

For rocker, we're switching to doing all vlan stuff in
ndo_bridge_setlink.  Switching to ndo_bridge_setlink for switchdev
gives us support for stacked drivers with the transaction model,
something we don't get with ndo_vlan_rx_add_vid.

If this makes sense, I'll post the follow up bridge vlan cmd change to
default to master and self.

-scott
