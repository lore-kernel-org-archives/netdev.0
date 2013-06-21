From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 0/6] bonding: prepare to and add arp_all_targets
Date: Fri, 21 Jun 2013 15:11:18 +0200
Message-ID: <1371820284-13280-1-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com, nikolay@redhat.com, mkubecek@suse.cz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52489 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030216Ab3FUNLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 09:11:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset does some cleanup, fixes a few flaws and adds a new parameter
to control whether the slave should stay up when any of arp_ip_targets are
up or all of them are up (i.e. if the slave should go down if even one
target from arp_ip_targets fail).

The patches 1-5 basically prepare the bonding code to work properly with this
new parameter, however it's not depending on them.

All comments are really welcome.

v2->v3:

Fix "[6/6] bonding: add helper function bond_get_targets_ip(targets, ip)",
per Nikolay's advice, to use _bh spinlock, remove useless rtnl_lock() and
use jiffies for new arp_ip_target last arp, instead of slave_last_rx(). As
Michal suggested, initialize the target_last_arp_rx[] the same as the
default last_arp_rx, to avoid flapping. Also, don't fail while removing the
last arp_ip_target, and instead just print a warning - otherwise it might
break existing scripts.

v1->v2:

Drop "[1/6] bonding: verify if bond has ip only once on arp validate", per
Jay's advice, it's really useless as a standalone patch (though the change
itself will appear in 2/6).

Fix "[2/6] bonding: add helper function bond_get_targets_ip(targets, ip)",
per Nikolay's advice, to verify if source ip != 0.0.0.0, otherwise we might
update 'null' arp_ip_targets' last_rx. Also, address style.

Drop "[5/6] bonding: don't swap arp's ips on validation for backup slave",
per Jay's advice, though it does address cyclic failover issue - it
disables a good optimization. Instead, update the documentation and fix the
cyclic loop issue in the following patch.

Add "bonding: don't trust arp requests unless active slave really works",
this patch fixes the cyclic loop that occurs when we can't reach
arp_ip_target and fool ourselves with our own generated arp requests. It's
done by checking if we currently have a current active slave and if this
slave received at least one arp reply after its 'nomination' to active.

Add "bonding: doc: some details on backup slave arp validation",
this patch describes a bit more in detail how the backup slave arp
validation works.

Fix "[6/6] bonding: add an option to fail when any of arp_ip_target is
inaccessible", per Nikolay's advice, to correctly handle adding/removing
hosts in arp_ip_target - we need to shift/initialize all slave's
target_last_arp_rx. Also, don't fail module loading on arp_all_targets
misconfiguration, just disable it, and some minor style fixes.

Thanks!

Veaceslav Falico (6):
      bonding: add helper function bond_get_targets_ip(targets, ip)
      bonding: don't add duplicate targets to arp_ip_target
      bonding: don't validate arp if we don't have to
      bonding: don't trust arp requests unless active slave really works
      bonding: doc: some details on backup slave arp validation
      bonding: add an option to fail when any of arp_ip_target is inaccessible

 Documentation/networking/bonding.txt |   23 ++++++
 drivers/net/bonding/bond_main.c      |   70 +++++++++++++++----
 drivers/net/bonding/bond_sysfs.c     |  125 ++++++++++++++++++++++++----------
 drivers/net/bonding/bonding.h        |   46 ++++++++++++-
 4 files changed, 212 insertions(+), 52 deletions(-)
