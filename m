From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/3] bonding: Fix RTNL: assertion failed at net/core/rtnetlink.c
Date: Mon, 17 Feb 2014 16:35:48 +0800
Message-ID: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <cwang@twopensource.com>, <jiri@resnulli.us>,
	<thomas@glanzmann.de>, <eric.dumazet@gmail.com>,
	<sfeldma@cumulusnetworks.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:49262 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbaBQIge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 03:36:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem was introduced by the commit 1d3ee88ae0d
(bonding: add netlink attributes to slave link dev).
The bond_set_active_slave() and bond_set_backup_slave()
will use rtmsg_ifinfo to send slave's states, so these
two functions should be called in RTNL.

In 802.3ad mode, acquiring RTNL for the __enable_port and
__disable_port cases is difficult, as those calls generally
already hold the state machine lock, and cannot unconditionally
call rtnl_lock because either they already hold RTNL (for calls
via bond_3ad_unbind_slave) or due to the potential for deadlock
with bond_3ad_adapter_speed_changed, bond_3ad_adapter_duplex_changed,
bond_3ad_link_change, or bond_3ad_update_lacp_rate.  All four of
those are called with RTNL held, and acquire the state machine lock
second.  The calling contexts for __enable_port and __disable_port
already hold the state machine lock, and may or may not need RTNL.

According to the Jay's opinion, I don't think it is a problem that
the slave don't send notify message synchronously when the status
changed, normally the state machine is running every 100 ms, send
the notify message at the end of the state machine if the slave's
state changed should be better.

Ding Tianhong (3):
  bonding: add bond_set_slave_state/flags()
  bonding: add new slave param and  bond_slave_state_notify()
  bonding: Fix the RTNL assertion failed for 802.3ad state machine

 drivers/net/bonding/bond_3ad.c |  5 ++--
 drivers/net/bonding/bonding.h  | 68 +++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 70 insertions(+), 3 deletions(-)

-- 
1.8.0
