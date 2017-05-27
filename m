From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V6 net-next 0/2] rtnetlink: Updates to rtnetlink_event()
Date: Sat, 27 May 2017 10:14:33 -0400
Message-ID: <1495894476-9726-1-git-send-email-vyasevic@redhat.com>
Cc: dsahern@gmail.com, roopa@cumulusnetworks.com, jiri@resnulli.us,
        vfalico@gmail.com, andy@greyhouse.net,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36117 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756594AbdE0OOu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 10:14:50 -0400
Received: by mail-qt0-f193.google.com with SMTP id j13so4568935qta.3
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 07:14:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First is the patch to add IFLA_EVENT attribute to the netlink message.  It
supports only currently white-listed events.
Like before, this is just an attribute that gets added to the rtnetlink
message only when the messaged was generated as a result of a netdev event.
In my case, this is necessary since I want to trap NETDEV_NOTIFY_PEERS
event (also possibly NETDEV_RESEND_IGMP event) and perform certain actions
in user space.  This is not possible since the messages generated as
a result of netdev events do not usually contain any changed data.  They
are just notifications.  This patch exposes this notification type to
userspace.

Second, I remove duplicate messages that a result of a change to bonding
options.  If netlink is used to configure bonding options, 2 messages
are generated, one as a result NETDEV_CHANGEINFODATA event triggered by
bonding code and one a result of device state changes triggered by
netdev_state_change (called from do_setlink).


V6: Updated names and refactored to make it less tied to netdev events.
    (From David Ahern)
V5: Rebased.  Added iproute2 patch to the series.
V4:
  * Removed the patch the removed NETDEV_CHANGENAME from event whitelist.
    It doesn't trigger duplicate messages since name changes can only be
    done while device is down and netdev_state_change() doesn't report
    changes while device is down.
  * Added a patch to clean-up duplicate messages on bonding option changes.

V3: Rebased.  Cleaned-up duplicate event.

V2: Added missed events (from David Ahern)


Vladislav Yasevich (2):
  rtnl: Add support for netdev event to link messages
  bonding: Prevent duplicate userspace notification

 drivers/net/bonding/bond_main.c    |  3 +-
 drivers/net/bonding/bond_options.c | 27 ++++++++++++++--
 include/linux/rtnetlink.h          |  3 +-
 include/net/bond_options.h         |  2 ++
 include/uapi/linux/if_link.h       | 11 +++++++
 net/core/dev.c                     |  2 +-
 net/core/rtnetlink.c               | 65 ++++++++++++++++++++++++++++++++------
 7 files changed, 99 insertions(+), 14 deletions(-)

-- 
2.7.4
