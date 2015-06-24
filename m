From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 0/4] net: dsa: mv88e6352: add support for VLAN Table Unit
Date: Wed, 24 Jun 2015 14:50:55 -0400
Message-ID: <1435171859-27012-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:51888 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753523AbbFXSvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 14:51:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patchset brings full support for hardware VLANs in DSA, and the Marvell
88E6352 and compatible switch chips.

Patches 1/4 to 3/4 are ready to be applied. However, patch 4/4 brought some
concerns about the management of the forwarding database [1]. That might be
updated in future patches though.

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
    VID  FID  SID  P0 P1 P2 P3 P4 P5 P6
    550  562  0    x  x  x  u  x  t  x
    1000 1012 0    x  x  t  x  x  t  x
    1200 1212 0    x  x  t  x  t  t  x

Cheers,
  -v

[1] https://lkml.org/lkml/2015/6/1/752

Vivien Didelot (4):
  net: dsa: mv88e6xxx: add debugfs interface for VTU
  net: dsa: add support for switchdev VLAN objects
  net: dsa: mv88e6xxx: add support to dump VLANs
  net: dsa: mv88e6xxx: add support to add/del VLANs

 drivers/net/dsa/mv88e6352.c |   3 +
 drivers/net/dsa/mv88e6xxx.c | 377 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  29 ++++
 include/net/dsa.h           |   9 ++
 net/dsa/dsa_priv.h          |   6 +
 net/dsa/slave.c             | 137 ++++++++++++++++
 6 files changed, 561 insertions(+)

-- 
2.4.4
