From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 0/12] bonding: add an option to rely on unvalidated arp packets
Date: Fri, 17 Jan 2014 17:58:48 +0100
Message-ID: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Cc: Rob Landley <rob@landley.net>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752899AbaAQREV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 12:04:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

v1 -> v2:
Don't remove the 'all traffic' functionality - rather, add new arp_validate
options to specify that we want *only* unvalidated arps.

Currently, if arp_validate is off (0), slave_last_rx() returns the
slave->dev->last_rx, which is always updated on *any* packet received by
slave, and not only arps. This means that, if the validation of arps is
off, we're treating *any* incoming packet as a proof of slave being up, and
not only arps.

This might seem logical at the first glance, however it can cause a lot of
troubles and false-positives, one example would be:

The arp_ip_target is NOT accessible, however someone in the broadcast domain
spams with any broadcast traffic. This way bonding will be tricked that the
slave is still up (as in - can access arp_ip_target), while it's not.

The net_device->last_rx is already used in a lot of drivers (even though the
comment states to NOT do it :)), and it's also ugly to modify it from bonding.

However, some loadbalance setups might rely on the fact that even non-arp
traffic is a sign of slave being up - and we definitely can't break anyones
config - so an extension to arp_validate is needed.

So, to fix this, add an option for the user to specify if he wants to
filter out non-arp traffic on unvalidated slaves, remove the last_rx from
bonding, *always* call bond_arp_rcv() in slave's rx_handler (which is
bond_handle_frame), and if we spot an arp there with this option on - update
the slave->last_arp_rx - and use it instead of net_device->last_rx. Finally,
rename last_arp_rx to last_rx to reflect the changes.

Also rename slave->jiffies to ->last_link_up, to reflect better its
meaning, add the new option's documentation and update the arp_validate one
to be a bit more descriptive.

CC: Rob Landley <rob@landley.net>
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>
CC: Nikolay Aleksandrov <nikolay@redhat.com>
CC: Ding Tianhong <dingtianhong@huawei.com>
CC: Neil Horman <nhorman@tuxdriver.com>
CC: netdev@vger.kernel.org
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 Documentation/networking/bonding.txt | 40 ++++++++++++++++++++++-----
 drivers/net/bonding/bond_main.c      | 53 ++++++++++++++++--------------------
 drivers/net/bonding/bond_options.c   | 18 ++----------
 drivers/net/bonding/bonding.h        | 26 ++++++++++++------
 include/linux/netdevice.h            |  8 +-----
 5 files changed, 77 insertions(+), 68 deletions(-)
