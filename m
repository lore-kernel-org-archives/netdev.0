From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 00/12] net: dsa: mv88e6xxx: misc probe improvements
Date: Tue, 14 Jun 2016 14:31:41 -0400
Message-ID: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58391 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932459AbcFNScV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 14:32:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some switch models have different way to access their internal registers
through SMI, and different places where to find the switch ID register.

This patchset abstracts these differences with a new SMI ops structure
and new data in the info structure: the port_base_addr member indicates
where start the ports registers and the MV88E6XXX_FLAG_MULTI_CHIP flag
indicates the need for an indirect SMI access.

The new MDIO probe code uses the compatible info data to detect the
device, and the legacy probe code iterate on compatible info table
(which currently only contains the 88E6085 info) to detect devices.

With these changes, the driver can easily support other switch models
with different register access. For instance, the 88E6060 uses a direct
SMI access even if the chip SMI address is non-zero and port registers
(where the switch ID registers is located) start at 0x8. The port
registers of the 88E6390X start at 0x10. Adding support to probe these
two models would basically look like this:

     static const struct mv88e6xxx_info mv88e6xxx_table[] = {
    +    [MV88E6060] = {
    +        .prod_num = PORT_SWITCH_ID_PROD_NUM_6060,
    +        .family = MV88E6XXX_FAMILY_6060,
    +        .name = "Marvell 88E6060",
    +        .num_databases = 16,
    +        .num_ports = 6,
    +        .port_base_addr = 0x8,
    +        .flags = ...,
    +    },
    +
         [MV88E6085] = {
             .prod_num = PORT_SWITCH_ID_PROD_NUM_6085,
             .family = MV88E6XXX_FAMILY_6097,
    ...
             .port_base_addr = 0x10,
             .flags = MV88E6XXX_FLAGS_FAMILY_6352,
         },
    +
    +    [MV88E6390] = {
    +        .prod_num = PORT_SWITCH_ID_PROD_NUM_6390,
    +        .family = MV88E6XXX_FAMILY_6390,
    +        .name = "Marvell 88E6390X",
    +        .num_databases = 4096,
    +        .num_ports = 11,
    +        .port_base_addr = 0x0,
    +        .flags = ... | MV88E6XXX_FLAG_MULTI_CHIP,
    +    },
     };
     
     static const struct of_device_id mv88e6xxx_of_id_table[] = {
         {
    +        .compatible = "marvell,mv88e6060",
    +        .data = &mv88e6xxx_table[MV88E6060],
    +    }, {
             .compatible = "marvell,mv88e6085",
             .data = &mv88e6xxx_table[MV88E6085],
    +    }, {
    +        .compatible = "marvell,mv88e6390",
    +        .data = &mv88e6xxx_table[MV88E6390],
         },
         { /* sentinel */ },
     };

This patchset also adds helpers to abstract common code of probe
functions and make them more readable before adding the changes
described above.

Changes since v1 [1]:

  - merge style fix from Ben Dooks
  - add Acked-by/Reviewed-by tags
  - drop one compatible string per model
  - detect the SMI device based on the compatible info
  - add an SMI ops structure

[1] https://lkml.org/lkml/2016/6/8/1201

Vivien Didelot (12):
  net: dsa: mv88e6xxx: fix style issues
  net: dsa: mv88e6xxx: remove redundant assignments
  net: dsa: mv88e6xxx: use already declared variables
  net: dsa: mv88e6xxx: do not increment bus refcount
  net: dsa: mv88e6xxx: add switch register helpers
  net: dsa: mv88e6xxx: add port base address to info
  net: dsa: mv88e6xxx: put chip info in ID table
  net: dsa: mv88e6xxx: read switch ID from info
  net: dsa: mv88e6xxx: add SMI detection helper
  net: dsa: mv88e6xxx: iterate on compatible info
  net: dsa: mv88e6xxx: add an SMI ops structure
  net: dsa: mv88e6xxx: add addressing mode to info

 drivers/net/dsa/mv88e6xxx.c | 342 ++++++++++++++++++++++++++++----------------
 drivers/net/dsa/mv88e6xxx.h |  26 +++-
 2 files changed, 244 insertions(+), 124 deletions(-)

-- 
2.8.3
