From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH V2 00/12] Add basic VLAN support to bridges
Date: Wed, 19 Dec 2012 11:25:34 -0500
Message-ID: <50D1EA7E.8080809@redhat.com>
References: <1355857263-31197-1-git-send-email-vyasevic@redhat.com> <20121218223244.GC1690@minipsycho.orion> <50D0F23D.4020508@redhat.com> <20121219082727.GB1637@minipsycho.orion>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755491Ab2LSQZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 11:25:42 -0500
In-Reply-To: <20121219082727.GB1637@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2012 03:27 AM, Jiri Pirko wrote:
> Tue, Dec 18, 2012 at 11:46:21PM CET, vyasevic@redhat.com wrote:
>> On 12/18/2012 05:32 PM, Jiri Pirko wrote:
>>>
>>>
>>> I see that this patchset replicates a lot of code which is already
>>> present in net/8021q/ or include/linux/if_vlan.h. I think it would
>>> be nice to move this code into some "common" place, wouldn't it?
>>>
>>
>> The only replication that I am aware of is in br_vlan_untag().  I
>> thought about pulling that piece out, but I think there is a reason
>> why it's not available when 801q support isn't turned on.  I noted that
>> openvswitch implemented its own vlan header manipulation functions as well.
>
> openvswitch should use the "common" code as well.
>
>>
>> What else are you seeing that's duplicate?
>
> For example I spotted check of ndo_vlan_rx_[add/kill]_vid and
> NETIF_F_HW_VLAN_FILTER and ndo_vlan_rx_[add/kill]_vid call

Ahh yes....  I can make that generic.  Thanks

-vlad

>
>
>>
>> -vlad
>>
>>> Jiri
>>>
>>> Tue, Dec 18, 2012 at 08:00:51PM CET, vyasevic@redhat.com wrote:
>>>> This series of patches provides an ability to add VLANs to the bridge
>>>> ports.  This is similar to what can be found in most switches.  The bridge
>>>> port may have any number of VLANs added to it including vlan 0 priority tagged
>>>> traffic.  When vlans are added to the port, only traffic tagged with particular
>>>> vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
>>>> entries and become part of the lookup.  This way we correctly identify the FDB
>>>> entry.
>>>>
>>>> A single vlan may also be designated as untagged.  Any untagged traffic
>>>> recieved by the port will be assigned to this vlan.  Any traffic exiting
>>>> the port with a VID matching the untagged vlan will exit untagged (the
>>>> bridge will strip the vlan header).  This is similar to "Native Vlan" support
>>>> available in most switches.
>>>>
>>>> The default behavior ofthe bridge is unchanged if no vlans have been
>>>> configured.
>>>>
>>>> Changes since v1:
>>>> - Fixed some forwarding bugs.
>>>> - Add vlan to local fdb entries.  New local entries are created per vlan
>>>>    to facilite correct forwarding to bridge interface.
>>>> - Allow configuration of vlans directly on the bridge master device
>>>>    in addition to ports.
>>>>
>>>> Changes since rfc v2:
>>>> - Per-port vlan bitmap is gone and is replaced with a vlan list.
>>>> - Added bridge vlan list, which is referenced by each port.  Entries in
>>>>    the birdge vlan list have port bitmap that shows which port are parts
>>>>    of which vlan.
>>>> - Netlink API changes.
>>>> - Dropped sysfs support for now.  If people think this is really usefull,
>>>>    can add it back.
>>>> - Support for native/untagged vlans.
>>>>
>>>> Changes since rfc v1:
>>>> - Comments addressed regarding formatting and RCU usage
>>>> - iocts have been removed and changed over the netlink interface.
>>>> - Added support of user added ndb entries.
>>>> - changed sysfs interface to export a bitmap.  Also added a write interface.
>>>>    I am not sure how much I like it, but it made my testing easier/faster.  I
>>>>    might change the write interface to take text instead of binary.
>>>>
>>>>
>>>> Vlad Yasevich (12):
>>>>   bridge: Add vlan filtering infrastructure
>>>>   bridge: Validate that vlan is permitted on ingress
>>>>   bridge: Verify that a vlan is allowed to egress on give port
>>>>   bridge: Cache vlan in the cb for faster egress lookup.
>>>>   bridge: Add vlan to unicast fdb entries
>>>>   bridge: Add vlan id to multicast groups
>>>>   bridge: Add netlink interface to configure vlans on bridge ports
>>>>   bridge: Add vlan support to static neighbors
>>>>   bridge: Add the ability to configure untagged vlans
>>>>   bridge: Implement untagged vlan handling
>>>>   bridge: Dump vlan information from a bridge port
>>>>   bridge: Add vlan support for local fdb entries
>>>>
>>>> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +-
>>>> drivers/net/macvlan.c                         |    2 +-
>>>> drivers/net/vxlan.c                           |    3 +-
>>>> include/linux/netdevice.h                     |    4 +-
>>>> include/uapi/linux/if_bridge.h                |   23 ++-
>>>> include/uapi/linux/neighbour.h                |    1 +
>>>> include/uapi/linux/rtnetlink.h                |    1 +
>>>> net/bridge/br_device.c                        |   34 ++-
>>>> net/bridge/br_fdb.c                           |  253 ++++++++++++---
>>>> net/bridge/br_forward.c                       |  160 ++++++++++
>>>> net/bridge/br_if.c                            |  404 ++++++++++++++++++++++++-
>>>> net/bridge/br_input.c                         |   65 ++++-
>>>> net/bridge/br_multicast.c                     |   71 +++--
>>>> net/bridge/br_netlink.c                       |  178 ++++++++++--
>>>> net/bridge/br_private.h                       |   71 ++++-
>>>> net/core/rtnetlink.c                          |   40 ++-
>>>> 16 files changed, 1190 insertions(+), 125 deletions(-)
>>>>
>>>> --
>>>> 1.7.7.6
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
