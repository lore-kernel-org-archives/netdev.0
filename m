From: anuradhak@cumulusnetworks.com
Subject: =?UTF-8?q?=5BRFC=20PATCH=20net-next=20v3=200/4=5D=20net=3A=20Introduce=20IFF=5FPROTO=5FDOWN=20flag=2E?=
Date: Mon, 27 Apr 2015 10:38:20 -0700
Message-ID: <1430156304-13187-1-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33352 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbbD0Rib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 13:38:31 -0400
Received: by pdbnk13 with SMTP id nk13so135547978pdb.0
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 10:38:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

User space daemons can detect errors in the network that need to be
notified to the switch device drivers.=20

Drivers can react to this error state by doing a phy-down on the
switch-port which would result in a carrier-off locally and on the
directly connected switch. Doing that would prevent loops and
black-holes in the network.

One such use case is the multi-chassis LAG application -
1. The MLAG application runs on peer switches (say Switch0 and Switch1)
   synchronizing states, forwarding entries etc. between the two
   switches over the peer-link (this is a link directly connecting the
   two switches).
2. An MLAG election process designates one of the switches as a primary
   (for e.g. Switch0 is primary and Switch1 is secondary).=20
3. The peer link plays a critical role in allowing Switch0-Switch1 to
   function as a single LAG partner to the downstream dual-connected
   servers. When the peer-link between the switches goes down we have a
   split-brain situation. Switch0 and Switch1 are no longer in sync and
   are acting independently. This can result in traffic loops and
   traffic black-holing in the network.=20
4. To prevent these problems the MLAG application on the secondary
   switch phy-downs the MLAG ports on detecting the peer-link down.
   This will be seen as a carrier down on servers that are
   dual-connected to Switch0 and Switch1.
5. Specifically a dual-connected server will see a carrier-down on the
   port connected to the MLAG secondary, Switch1, and will stop using
   that port for traffic TX. So traffic black holing is prevented.

v2 to v3:
   In response to Dave=E2=80=99s comments I have tried to make IFF_PROT=
ODOWN
   more easily consumable by providing switchdev APIs to control the
   phy state of the switch port. The use case is relevant primarily to
   switch drivers at this point. That is the reason for making the
   change in rocker (commonly used switch driver example).

   One other change that could be done is to bring back the net-core
   change to hold the oper state down in response to IFF_PROTO_DOWN.
   This would be a driver agnostic change and the phy-down could be don=
e
   in addition by interested switch drivers.

v1 to v2:
   Based on Dave's suggestion I have moved out aggregating of error bit=
s
   across applications to a user space framework. This patch now simply
   notifies an aggregated error bit to drivers enabling them to handle
   the error gracefully.


Anuradha Karuppiah (4):
  net core: Add IFF_PROTO_DOWN support.
  switchdev: APIs for setting physical state of the switch port.
  rocker: Handle IFF_PROTODOWN by doing a PHYS-DOWN on the switch port.
  ip link: Config and display IFF_PROTO_DOWN flag.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>

 drivers/net/ethernet/rocker/rocker.c |   16 +++++++++++++++-
 include/net/switchdev.h              |   12 ++++++++++++
 include/uapi/linux/if.h              |    4 ++++
 net/8021q/vlan_dev.c                 |    3 ++-
 net/core/dev.c                       |    8 +++++++-
 net/switchdev/switchdev.c            |   23 +++++++++++++++++++++++
 6 files changed, 63 insertions(+), 3 deletions(-)

--=20
1.7.10.4
