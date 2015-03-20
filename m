From: anuradhak@cumulusnetworks.com
Subject: =?UTF-8?q?=5BPATCH=20net-next=200/3=5D=20net=3A=20introduce=20IFF=5FPROTO=5FDOWN=20flag=2E?=
Date: Fri, 20 Mar 2015 08:11:55 -0700
Message-ID: <1426864318-25132-1-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36579 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbbCTPMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 11:12:06 -0400
Received: by pdbcz9 with SMTP id cz9so111236939pdb.3
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 08:12:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

Applications can detect errors in the network that would require
disabling the device independent of the admin state. In the presence of
these errors traffic could be black holed or looped resulting in a
network meltdown. Clearing the IFF_UP flag for error disabling the
device can be problematic because -

1. The administrator cannot distinguish between a user space daemon=E2=80=
=99s
error-disable and a regular device disable.
2. Applications can monitor the error state and enable the device once
the error is removed. If IFF_UP is used for this purpose the applicatio=
n
may end up enabling a device that the administrator has intentionally
disabled for other reasons. This could result in network changes not
expected by the admin.

To avoid these problems this patch adds a distinct IFF_PROTO_DOWN flag
for error disabling a device.

This patch introduces a netdevice proto_down field to allow multiple
applications to disable a device independent of each other. This field
is a bitmap with two defined protocols currently, MLAG and STP. Bits
can be added in the future to define other protocols that may need to
disable the device. If any of the bits in the proto_down field are set
an oper DOWN is done on the device by setting IFF_PROTO_DOWN.

IFF_PROTO_DOWN is a netdevice flag that is used to control the oper
state and also used for notifying drivers that a protocol has disabled
the device. Switch drivers could use the IFF_PROTO_DOWN flag to further
handle the error condition; for e.g. they could carrier down the device
allowing directly connected switches to quickly learn about the error
state and stop forwarding traffic to this device.

STP applications can use the proto_down control to implement BPDU guard
functionality which requires shutting down access ports on detecting
rogue switches that could take over as the root bridge.

MLAG applications can use the proto_down control to hold devices down
on the secondary switch on detecting a split-brain situation between th=
e
MLAG-peers.

Anuradha Karuppiah (3):
  net core: Add support for netdevice proto_down.
  virtio net: Handle proto_down state by setting the carrier off.
  ip link: Config and display device proto_down bits.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>

 drivers/net/virtio_net.c     |   78 ++++++++++++++++++++++++++++++++++=
+++++---
 include/linux/netdevice.h    |    3 ++
 include/uapi/linux/if.h      |   29 +++++++++++++++-
 include/uapi/linux/if_link.h |    9 +++++
 net/8021q/vlan_dev.c         |    3 +-
 net/core/dev.c               |   36 +++++++++++++++++++
 net/core/link_watch.c        |    2 +-
 net/core/net-sysfs.c         |    2 ++
 net/core/rtnetlink.c         |   21 ++++++++++++
 9 files changed, 176 insertions(+), 7 deletions(-)

--=20
1.7.10.4
