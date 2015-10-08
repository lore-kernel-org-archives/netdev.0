From: sfeldma@gmail.com
Subject: [PATCH net-next v2 0/4] switchdev: push bridge attributes down
Date: Wed,  7 Oct 2015 23:04:39 -0700
Message-ID: <1444284283-33601-1-git-send-email-sfeldma@gmail.com>
Cc: davem@davemloft.net, jiri@resnulli.us, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34092 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbbJHGBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 02:01:46 -0400
Received: by padhy16 with SMTP id hy16so44371675pad.1
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 23:01:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Push bridge-level attributes down to switchdev drivers.  This patchset
adds the infrastructure and then pushes, as an example, ageing_time attribute
down from bridge to switchdev (rocker) driver.  Add some range-checking
for ageing_time.

# ip link set dev br0 type bridge ageing_time 1000

# ip link set dev br0 type bridge ageing_time 999
RTNETLINK answers: Numerical result out of range

Up until now, switchdev attrs where port-level attrs, so the netdev used in
switchdev_attr_set() would be a switch port or bond of switch ports.  With
bridge-level attrs, the netdev passed to switchdev_attr_set() is the bridge
netdev.  The same recusive algo is used to visit the leaves of the stacked
drivers to set the attr, it's just in this case we start one layer higher in
the stack.  One note is not all ports in the bridge may support setting a
bridge-level attribute, so rather than failing the entire set, we'll skip over
those ports returning -EOPNOTSUPP.

v1->v2: rebase w/ net-next

Scott Feldman (4):
  switchdev: add bridge attributes
  switchdev: skip over ports returning -EOPNOTSUPP when recursing ports
  bridge: push bridge setting ageing_time down to switchdev
  rocker: handle setting bridge ageing_time

 drivers/net/ethernet/rocker/rocker.c |   22 ++++++++++++++++++++++
 include/net/switchdev.h              |    6 ++++++
 include/uapi/linux/if_link.h         |    2 +-
 net/bridge/br_ioctl.c                |    3 +--
 net/bridge/br_netlink.c              |    6 +++---
 net/bridge/br_private.h              |    1 +
 net/bridge/br_stp.c                  |   24 ++++++++++++++++++++++++
 net/bridge/br_sysfs_br.c             |    3 +--
 net/switchdev/switchdev.c            |    9 ++++++++-
 9 files changed, 67 insertions(+), 9 deletions(-)

-- 
1.7.10.4
