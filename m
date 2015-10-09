From: sfeldma@gmail.com
Subject: [PATCH net-next v3 0/4] switchdev: push bridge ageing_time attribute down
Date: Thu,  8 Oct 2015 19:23:16 -0700
Message-ID: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
Cc: davem@davemloft.net, jiri@resnulli.us, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35606 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbbJICUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 22:20:22 -0400
Received: by pabve7 with SMTP id ve7so12890465pab.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 19:20:22 -0700 (PDT)
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

v2->v3: Per Jiri review: push only ageing_time attr down at this time, and
don't pass raw bridge IFLA_BR_* values; rather use new switchdev attr ID for
ageing_time.

v1->v2: rebase w/ net-next


Scott Feldman (4):
  switchdev: add bridge ageing_time attribute
  switchdev: skip over ports returning -EOPNOTSUPP when recursing ports
  bridge: push bridge setting ageing_time down to switchdev
  rocker: handle setting bridge ageing_time

 drivers/net/ethernet/rocker/rocker.c |   16 ++++++++++++++++
 include/net/switchdev.h              |    3 +++
 net/bridge/br_ioctl.c                |    3 +--
 net/bridge/br_netlink.c              |    6 +++---
 net/bridge/br_private.h              |    1 +
 net/bridge/br_stp.c                  |   23 +++++++++++++++++++++++
 net/bridge/br_sysfs_br.c             |    3 +--
 net/switchdev/switchdev.c            |    9 ++++++++-
 8 files changed, 56 insertions(+), 8 deletions(-)

-- 
1.7.10.4
