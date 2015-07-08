From: anuradhak@cumulusnetworks.com
Subject: [PATCH net-next v4 0/4] net: Introduce protodown flag.
Date: Wed,  8 Jul 2015 14:04:21 -0700
Message-ID: <1436389465-3077-1-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35664 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758261AbbGHVEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:04:35 -0400
Received: by pactm7 with SMTP id tm7so137742461pac.2
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 14:04:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

User space daemons can detect errors in the network that need to be
notified to the switch device drivers.

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
   (for e.g. Switch0 is primary and Switch1 is secondary).
3. The peer link plays a critical role in allowing Switch0-Switch1 to
   function as a single LAG partner to the downstream dual-connected
   servers. When the peer-link between the switches goes down we have a
   split-brain situation. Switch0 and Switch1 are no longer in sync and
   are acting independently. This can result in traffic loops and
   traffic black-holing in the network.
4. To prevent these problems the MLAG application on the secondary
   switch phy-downs the MLAG ports on detecting the peer-link down.
   This will be seen as a carrier down on servers that are
   dual-connected to Switch0 and Switch1.
5. Specifically a dual-connected server will see a carrier-down on the
   port connected to the MLAG secondary, Switch1, and will stop using
   that port for traffic TX. So traffic black holing is prevented.

v3 to v4:
   I have moved protodown out of IFF_XXX and introduced a separate
   proto_flags field with IF_PROTOF_DOWN bit being used by apps to notify
   switch port errors. This is in response to Stephen's comments that
   adding a new IFF_XXX may break user space.

   I have used rocker as the sample switch driver. And to test this
   functionality I used the qemu-rocker patch that Scott sent out in response
   to the v3 posting (needed to set link up/down when phy is
   enabled/disabled).

v1 to v2:
   Based on Dave's suggestion I have moved out aggregating of error bits
   across applications to a user space framework. This patch now simply
   notifies an aggregated error bit to drivers enabling them to handle
   the error gracefully.


Anuradha Karuppiah (4):
  net core: Add protodown support.
  netlink: changes for setting and clearing protodown via netlink.
  rocker: Handle protodown notifications.
  ip link: proto_down config and display.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>

 drivers/net/ethernet/rocker/rocker.c |   19 +++++++++++-
 include/linux/netdevice.h            |   13 ++++++++
 include/uapi/linux/if.h              |    6 ++++
 include/uapi/linux/if_link.h         |   10 ++++++
 net/core/dev.c                       |   20 ++++++++++++
 net/core/net-sysfs.c                 |   14 +++++++++
 net/core/rtnetlink.c                 |   57 +++++++++++++++++++++++++++++++++-
 7 files changed, 137 insertions(+), 2 deletions(-)

-- 
1.7.10.4
