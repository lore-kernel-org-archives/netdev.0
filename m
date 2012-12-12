From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Thu, 13 Dec 2012 00:54:43 +0200
Message-ID: <CAJZOPZL3grqtd-Tnhr-QxkdFWrhkgcp5+fOUZSaPJd3Ker_7GQ@mail.gmail.com>
References: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	mst@redhat.com, john.r.fastabend@intel.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f170.google.com ([209.85.210.170]:43875 "EHLO
	mail-ia0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754913Ab2LLWyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 17:54:44 -0500
Received: by mail-ia0-f170.google.com with SMTP id i1so1388762iaa.15
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 14:54:44 -0800 (PST)
In-Reply-To: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 12, 2012 at 10:01 PM, Vlad Yasevich <vyasevic@redhat.com> wrote:
> This series of patches provides an ability to add VLANs to the bridge
> ports.  This is similar to what can be found in most switches.

Vlad, I wasn't sure if these patches support both modes of switches
w.r.t vlans namely "access" and " trunk" or in virtualization terms
VST and VGT or in natural language, both the mode where the entity
(e.g VM) eventually using the bridge port uses untagged traffic and
the bridge does vlan tagging/marking and vlan untagging/stripping,
plus a mode where packets are tagged under a set of allowed vlans or a
third hybrid mode where there's a default vlan to be used when packets
arrive untagged and set of allowed vlans to be used as a filter for
tagged packets.

Also, does this patch set assumes that a certain port is actually an
uplink towards the the physical nework/external switch?

Or.

>  The bridge
> port may have any number of VLANs added to it including vlan 0 priority tagged
> traffic.  When vlans are added to the port, only traffic tagged with particular
> vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
> entries and become part of the lookup.  This way we correctly identify the FDB
> entry.
>
> A single vlan may also be designated as untagged.  Any untagged traffic
> recieved by the port will be assigned to this vlan.  Any traffic exiting
> the port with a VID matching the untagged vlan will exit untagged (the
> bridge will strip the vlan header).  This is similar to "Native Vlan" support
> available in most switches.
>
> The default behavior ofthe bridge is unchanged if no vlans have been
> configured.
>
> Changes since rfc v2:
>  - Per-port vlan bitmap is gone and is replaced with a vlan list.
>  - Added bridge vlan list, which is referenced by each port.  Entries in
>    the birdge vlan list have port bitmap that shows which port are parts
>    of which vlan.
>  - Netlink API changes.
>  - Dropped sysfs support for now.  If people think this is really usefull,
>    can add it back.
>  - Support for native/untagged vlans.
>
> Changes since rfc v1:
>  - Comments addressed regarding formatting and RCU usage
>  - iocts have been removed and changed over the netlink interface.
>  - Added support of user added ndb entries.
>  - changed sysfs interface to export a bitmap.  Also added a write interface.
>    I am not sure how much I like it, but it made my testing easier/faster.  I
>    might change the write interface to take text instead of binary.
>
> Vlad Yasevich (11):
>   bridge: Add vlan filtering infrastructure
>   bridge: Validate that vlan is permitted on ingress
>   bridge: Verify that a vlan is allowed to egress on give port
>   bridge: Cache vlan in the cb for faster egress lookup.
>   bridge: Add vlan to unicast fdb entries
>   bridge: Add vlan id to multicast groups
>   bridge: Add netlink interface to configure vlans on bridge ports
>   bridge: Add vlan support to static neighbors
>   bridge: Add the ability to configure untagged vlans
>   bridge: Implement untagged vlan handling
>   bridge: Dump vlan information from a bridge port
>
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +-
>  drivers/net/macvlan.c                         |    2 +-
>  drivers/net/vxlan.c                           |    3 +-
>  include/linux/netdevice.h                     |    4 +-
>  include/uapi/linux/if_bridge.h                |   24 ++-
>  include/uapi/linux/neighbour.h                |    1 +
>  include/uapi/linux/rtnetlink.h                |    1 +
>  net/bridge/br_device.c                        |   34 +++-
>  net/bridge/br_fdb.c                           |  199 +++++++++++++---
>  net/bridge/br_forward.c                       |  139 +++++++++++
>  net/bridge/br_if.c                            |  312 +++++++++++++++++++++++++
>  net/bridge/br_input.c                         |   65 +++++-
>  net/bridge/br_multicast.c                     |   71 ++++--
>  net/bridge/br_netlink.c                       |  154 +++++++++++--
>  net/bridge/br_private.h                       |   66 +++++-
>  net/core/rtnetlink.c                          |   40 +++-
>  16 files changed, 1010 insertions(+), 110 deletions(-)
>
> --
> 1.7.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
