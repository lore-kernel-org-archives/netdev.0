From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 00/20] net: dsa: distribute switch events
Date: Mon, 22 May 2017 13:01:06 -0700
Message-ID: <ce634f83-35b0-abbf-a18b-61d3feccc097@gmail.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yo Vivien,

On 05/19/2017 02:00 PM, Vivien Didelot wrote:
> DSA is by nature the support for a switch fabric, which can be composed
> of a single, or multiple interconnected Ethernet switch chips.
> 
> The current DSA core behavior is to identify the slave port targeted by
> a request (e.g. adding a VLAN entry), and program the switch chip to
> which it belongs accordingly.
> 
> This is problematic in a multi-chip environment, since all chips of a
> fabric must be aware of most configuration changes. Here are some
> concrete examples in a 3-chip environment:
> 
>          [CPU].................... (mdio)
>     (eth0) |   :       :          :
>           _|_____    _______    _______
>          [__sw0__]--[__sw1__]--[__sw2__]
>           |  |  |    |  |  |    |  |  |
>           v  v  v    v  v  v    v  v  v
>           p1 p2 p3   p4 p5 p6   p7 p8 p9
> 
> If you add a VLAN entry on p7, sw2 gets programmed, but frames won't
> reach the CPU interface in a VLAN filtered setup. sw0 and sw1 also need
> to be programmed. The same problem comes with MAC addresses (FDB, MDB),
> or ageing time changes for instance.
> 
> This patch series uses the notification chain introduced for bridging,
> to notify not only bridge, but switchdev attributes and objects events
> to all switch chips of the fabric.
> 
> An ugly debug message printing the ignored event and switch info in the
> code handling the switch VLAN events would give us:
> 
>     # bridge vlan add dev p7 vid 42
>     sw0: ignoring DSA_NOTIFIER_VLAN_ADD for sw2 (prepare phase)
>     sw1: ignoring DSA_NOTIFIER_VLAN_ADD for sw2 (prepare phase)
>     sw0: ignoring DSA_NOTIFIER_VLAN_ADD for sw2 (commit phase)
>     sw1: ignoring DSA_NOTIFIER_VLAN_ADD for sw2 (commit phase)
> 
> To achieve that, patches 1-8 change the scope of the bridge and
> switchdev callbacks from the DSA slave device to the generic DSA port,
> so that the port-wide API can be used later for switch ports not exposed
> to userspace, such as CPU and DSA links.
> 
> Patches 9-15 move the DSA port specific functions in a new port.c file.
> 
> Patches 16-20 introduce new events to notify the fabric about switchdev
> attributes and objects manipulation.
> 
> This patch series only adds the plumbing to support a distributed
> configuration, but for the moment, each switch chip ignores events from
> other chips of the fabric, to keep the current behavior.
> 
> The next patch series will add support for cross-chip configuration of
> bridge ageing time, VLAN and MAC address databases operations, etc.

For this entire series:

Tested-by: Florian Fainelli <f.fainelli@gmail.com>

on a 7445 (bcm-sf2), normal bridging still worked, and bridging with
VLAN filtering also did, just like adding VLANs to user-facing ports
also did.

Great job!

> 
> 
> Vivien Didelot (20):
>   net: dsa: change scope of STP state setter
>   net: dsa: change scope of notifier call chain
>   net: dsa: change scope of bridging code
>   net: dsa: change scope of FDB handlers
>   net: dsa: change scope of MDB handlers
>   net: dsa: change scope of VLAN handlers
>   net: dsa: change scope of VLAN filtering setter
>   net: dsa: change scope of ageing time setter
>   net: dsa: move port state setters
>   net: dsa: move bridging routines
>   net: dsa: move VLAN filtering setter
>   net: dsa: move ageing time setter
>   net: dsa: move FDB handlers
>   net: dsa: move MDB handlers
>   net: dsa: move VLAN handlers
>   net: dsa: move notifier info to private header
>   net: dsa: add notifier for ageing time
>   net: dsa: add FDB notifier
>   net: dsa: add MDB notifier
>   net: dsa: add VLAN notifier
> 
>  include/net/dsa.h  |  10 --
>  net/dsa/Makefile   |   2 +-
>  net/dsa/dsa_priv.h |  83 +++++++++++++
>  net/dsa/port.c     | 260 +++++++++++++++++++++++++++++++++++++++
>  net/dsa/slave.c    | 354 +++++------------------------------------------------
>  net/dsa/switch.c   | 175 ++++++++++++++++++++++++++
>  6 files changed, 547 insertions(+), 337 deletions(-)
>  create mode 100644 net/dsa/port.c
> 


-- 
Florian
