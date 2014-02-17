From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 0/12] bonding: add an option to rely on unvalidated arp packets
Date: Mon, 17 Feb 2014 14:39:09 +0100
Message-ID: <1392644361-8510-1-git-send-email-vfalico@redhat.com>
Cc: Rob Landley <rob@landley.net>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	dingtianhong <dingtianhong@huawei.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Cong Wang <amwang@redhat.com>, linux-doc@vger.kernel.org,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

v2 -> v3:
Per Jay's advise, use the 'filter' keyword instead of 'arp' one, and use
his text for documentation. Also, rebase on the latest net-next. Sorry for
the delay, didn't manage to send it before net-next was closed.

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
CC: dingtianhong <dingtianhong@huawei.com>
CC: Nikolay Aleksandrov <nikolay@redhat.com>
CC: Neil Horman <nhorman@tuxdriver.com>
CC: Cong Wang <amwang@redhat.com>
CC: linux-doc@vger.kernel.org
CC: netdev@vger.kernel.org
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 Documentation/networking/bonding.txt | 96 +++++++++++++++++++++++++-----------
 drivers/net/bonding/bond_main.c      | 56 +++++++++------------
 drivers/net/bonding/bond_options.c   | 16 +++---
 drivers/net/bonding/bonding.h        | 26 ++++++----
 include/linux/netdevice.h            |  8 +--
 5 files changed, 117 insertions(+), 85 deletions(-)
