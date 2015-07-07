From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v4 0/3] net: dsa: mv88e6xxx: add support for VLAN Table Unit
Date: Tue,  7 Jul 2015 17:18:17 -0400
Message-ID: <1436303900-24259-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:57662 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933267AbbGGVS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 17:18:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patchset brings full support for hardware VLANs in DSA, and the Marvell
88E6xxx compatible switch chips.

The first patch adds the VTU operations to the mv88e6xxx code, as well as a
"vtu" debugfs file to read and modify the hardware VLAN table.

The second patch adds the glue between DSA and the switchdev VLAN objects.

The third patch finally implements the necessary functions in the mv88e6xxx
code to interact with the hardware VLAN through switchdev, from userspace
commands such as "bridge vlan".

Below is an example of what can be done with this patchset.

    "VID 550: 1t 3u"
    "VID 1000: 2t"
    "VID 1200: 2t 4t"

The VLAN setup above can be achieved with the following bridge commands:

    bridge vlan add vid 550 dev swp1 master
    bridge vlan add vid 550 dev swp3 master untagged pvid
    bridge vlan add vid 1000 dev swp2 master
    bridge vlan add vid 1200 dev swp2 master
    bridge vlan add vid 1200 dev swp4 master

Removing the port 1 from VLAN 550 is done with:

    bridge vlan del vid 550 dev swp1

The bridge command would output the following setup:

    # bridge vlan
    port	vlan ids
    swp0	None
    swp0
    swp1	None
    swp1
    swp2	1000
		1200

    swp2	1000
		1200

    swp3	550 PVID Egress Untagged

    swp3	550 PVID Egress Untagged

    swp4	1200

    swp4	1200

    br0	None

Assuming that swp5 is the CPU port, the "vtu" debugfs file would show:

    # cat /sys/kernel/debug/dsa0/vtu
     VID  FID  SID  0  1  2  3  4  5  6
     550  550    0  x  x  x  u  x  t  x
    1000 1000    0  x  x  t  x  x  t  x
    1200 1200    0  x  x  t  x  t  t  x

v4: return -EOPNOTSUPP in switchdev prepare phase for unsupported objects;
handle num_ports in VTU GetNext / LoadPurge operations, instead of hardcoded 7.

Cheers,
  -v

Vivien Didelot (3):
  net: dsa: mv88e6xxx: add debugfs interface for VTU
  net: dsa: add support for switchdev VLAN objects
  net: dsa: mv88e6xxx: add switchdev VLAN operations

 drivers/net/dsa/mv88e6123_61_65.c |   3 +
 drivers/net/dsa/mv88e6131.c       |   3 +
 drivers/net/dsa/mv88e6171.c       |   3 +
 drivers/net/dsa/mv88e6352.c       |   3 +
 drivers/net/dsa/mv88e6xxx.c       | 476 ++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h       |  36 +++
 include/net/dsa.h                 |   9 +
 net/dsa/dsa_priv.h                |   6 +
 net/dsa/slave.c                   | 142 ++++++++++++
 9 files changed, 681 insertions(+)

-- 
2.4.5
