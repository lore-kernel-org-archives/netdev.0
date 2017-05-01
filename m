From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 00/18] net: dsa: mv88e6xxx: 802.1s and 88E6390 VTU
Date: Mon,  1 May 2017 14:05:09 -0400
Message-ID: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds support for the VLAN Table Unit (a.k.a. the VTU)
to the 88E6390 family of Marvell Ethernet switch chips. The plumbing for
the per VLAN Spanning Tree support is added as a side effect of the
necessary refactoring.

The patchset is split up so that no duplication of code is introduced.
With this patchset applied, the mv88e6xxx driver has 2 new function
pointers for the VTU GetNext and VTU Load/Purge operations (with 3
implementations), both handling programmation of 802.1q and 802.1s.

On a ZII Rev C board (featuring 2 88E6390X chips) with all ports bridged
together, we obtain the following hardware VLAN configuration:

    # cat /sys/class/net/br0/bridge/vlan_filtering 
    1
    # cat /sys/class/net/br0/bridge/default_pvid
    42
    # bridge vlan add dev lan3 vid 666
    # bridge vlan show
    port    vlan ids
    lan1     42 PVID Egress Untagged

    lan1     42 PVID Egress Untagged

    lan2     42 PVID Egress Untagged

    lan2     42 PVID Egress Untagged

    lan3     42 PVID Egress Untagged
             666

    lan3     42 PVID Egress Untagged
             666

    lan4     42 PVID Egress Untagged

    lan4     42 PVID Egress Untagged

    lan5     42 PVID Egress Untagged

    lan5     42 PVID Egress Untagged

    lan6     42 PVID Egress Untagged

    lan6     42 PVID Egress Untagged

    lan7     42 PVID Egress Untagged

    lan7     42 PVID Egress Untagged

    lan8     42 PVID Egress Untagged

    lan8     42 PVID Egress Untagged

    br0      42 PVID Egress Untagged

Below are the technical details for the different implementations.

All switch families have up to 3 dedicated VTU Data registers used to
program 802.1q and 802.1s, both using 2-bit values.

On 88E6185 and 88E6352 families, port membership and state are adjacent,
while the 88E6390 family share the same bits:

    Bits        88E6185/88E6352         88E6390
    -----       -----------------       --------------------------
    0-1         Port 0 membership       Port 0 membership or state
    2-3         Port 0 state            Port 1 membership or state
    4-5         Port 1 membership       Port 2 membership or state
    6-7         Port 1 state            Port 3 membership or state
    8-9         Port 2 membership       Port 4 membership or state
    10-11       Port 2 state            Port 5 membership or state
    ...         ...                     ...

The 88E6185 family programs all ports membership and state in a single
VTU GetNext or Load/Purge operation.

The 88E6352 family introduced an indirect Spanning Tree Unit table
(a.k.a. STU) which requires additional STU GetNext and Load/Purge
operations to read and write the ports state bits.

The 88E6390 family also has an STU and requires data bits to be accessed
before and after every single VTU or STU operation.

Finally, the 88E6390 family introduced a 13th bit for the VLAN ID, which
must be taken care of regardless the VTU operating mode. This means that
iterating over the VTU now starts or ends with value 8191, not 4095.

Patch 1 adds a max_vid field to the chip info structure.
Patch 2 adds 802.1q and 802.1s data to the generic VTU entry structure.
Patches 3 to 10 move helpers to a dedicated file (later made static).
Patches 11 and 12 abstract handling of the STU behind VTU operations.
Patches 13 and 14 add the new function pointers for VTU operations.
Patches 15 and 18 polish the VTU code and add VTU support for 88E6390.

Changes in v2:
  - add Reviewed-by tags
  - fix comments in 8/18

Vivien Didelot (18):
  net: dsa: mv88e6xxx: add max VID to info
  net: dsa: mv88e6xxx: split VTU entry data member
  net: dsa: mv88e6xxx: move VTU Operation accessors
  net: dsa: mv88e6xxx: move VTU flush
  net: dsa: mv88e6xxx: move VTU FID accessors
  net: dsa: mv88e6xxx: move VTU SID accessors
  net: dsa: mv88e6xxx: move VTU VID accessors
  net: dsa: mv88e6xxx: move generic VTU GetNext
  net: dsa: mv88e6xxx: move VTU Data accessors
  net: dsa: mv88e6xxx: move STU GetNext operation
  net: dsa: mv88e6xxx: get STU entry on VTU GetNext
  net: dsa: mv88e6xxx: load STU entry with VTU entry
  net: dsa: mv88e6xxx: add VTU GetNext operation
  net: dsa: mv88e6xxx: add VTU Load/Purge operation
  net: dsa: mv88e6xxx: make VTU helpers static
  net: dsa: mv88e6xxx: simplify VTU entry getter
  net: dsa: mv88e6xxx: support the VTU Page bit
  net: dsa: mv88e6xxx: add VTU support for 88E6390

 drivers/net/dsa/mv88e6xxx/Makefile      |   1 +
 drivers/net/dsa/mv88e6xxx/chip.c        | 568 +++++++++-----------------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  14 +
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 511 ++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   |  31 +-
 5 files changed, 690 insertions(+), 435 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/global1_vtu.c

-- 
2.12.2
