From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC WIP 0/5] IGMP snooping for local traffic
Date: Mon, 28 Aug 2017 08:11:43 -0700
Message-ID: <20170828081143.035f0a0c@xeon-e3>
References: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        nikolay@cumulusnetworks.com, jiri@mellanox.com,
        roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36423 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdH1PLq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 11:11:46 -0400
Received: by mail-pg0-f44.google.com with SMTP id r133so2261273pgr.3
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 08:11:46 -0700 (PDT)
In-Reply-To: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Aug 2017 22:56:05 +0200
Andrew Lunn <andrew@lunn.ch> wrote:

> This is a WIP patchset i would like comments on from bridge, switchdev
> and hardware offload people.
> 
> The linux bridge supports IGMP snooping. It will listen to IGMP
> reports on bridge ports and keep track of which groups have been
> joined on an interface. It will then forward multicast based on this
> group membership.
> 
> When the bridge adds or removed groups from an interface, it uses
> switchdev to request the hardware add an mdb to a port, so the
> hardware can perform the selective forwarding between ports.
> 
> What is not covered by the current bridge code, is IGMP joins/leaves
> from the host on the brX interface. No such monitoring is
> performed. With a pure software bridge, it is not required. All
> mulitcast frames are passed to the brX interface, and the network
> stack filters them, as it does for any interface. However, when
> hardware offload is involved, things change. We should program the
> hardware to only send multcast packets to the host when the host has
> in interest in them.
> 
> Thus we need to perform IGMP snooping on the brX interface, just like
> any other interface of the bridge. However, currently the brX
> interface is missing all the needed data structures to do this. There
> is no net_bridge_port structure for the brX interface. This strucuture
> is created when an interface is added to the bridge. But the brX
> interface is not a member of the bridge. So this patchset makes the
> brX interface a first class member of the bridge. When the brX
> interface is opened, the interface is added to the bridge. A
> net_bridge_port is allocated for it, and IGMP snooping is performed as
> usual.
> 
> There are some complexities here. Some assumptions are broken, like
> the master interface of a port interface is the bridge interface. The
> brX interface cannot be its own master. The use of
> netdev_master_upper_dev_get() within the bridge code has been changed
> to reflecit this. The bridge receive handler needs to not process
> frames for the brX interface, etc.
> 
> The interface downward to the hardware is also an issue. The code
> presented here is a hack and needs to change. But that is secondary
> and can be solved once it is agreed how the bridge needs to change to
> support this use case.
> 
> Comment welcome and wanted.
> 
> 	Andrew
> 
> Andrew Lunn (5):
>   net: rtnetlink: Handle bridge port without upper device
>   net: bridge: Skip receive handler on brX interface
>   net: bridge: Make the brX interface a member of the bridge
>   net: dsa: HACK: Handle MDB add/remove for none-switch ports
>   net: dsa: Don't include CPU port when adding MDB to a port
> 
>  include/linux/if_bridge.h |  1 +
>  net/bridge/br_device.c    | 12 ++++++++++--
>  net/bridge/br_if.c        | 37 ++++++++++++++++++++++++-------------
>  net/bridge/br_input.c     |  4 ++++
>  net/bridge/br_mdb.c       |  2 --
>  net/bridge/br_multicast.c |  7 ++++---
>  net/bridge/br_private.h   |  1 +
>  net/core/rtnetlink.c      | 23 +++++++++++++++++++++--
>  net/dsa/port.c            | 19 +++++++++++++++++--
>  net/dsa/switch.c          |  2 +-
>  10 files changed, 83 insertions(+), 25 deletions(-)
> 

Sorry you can't change the semantics of the bridge like this.
There are likely to be scripts and management utilities that won't work after this.

Figure out another way. Such as adding IGMP updates in the local packet send/receive path.
