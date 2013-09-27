From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 0/9] bonding: remove bond_next_slave()
Date: Fri, 27 Sep 2013 16:11:56 +0200
Message-ID: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Cc: nikolay@redhat.com, bhutchings@solarflare.com,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29523 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329Ab3I0OLq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 10:11:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(on top of "[PATCH net-next 0/2] bonding: fix 3ad slave (de)init" - the
patchset is essential)

Hi,

As Ben Hutchings and Nikolay Aleksandrov correctly noted -
bond_next_slave() already is not O(1), but rather O(n), so it's only useful
for one-off operations and shouldn't be used widely - for example, for list
traversal, which will take O(n^2) time, which will be disastrous for any
hot path with a large number of slaves.

Currently, bond_next_slave() is used several times in 802.3ad and for
seq_read - bond_info_seq_next().

The 802.3ad part uses it only in constructs like:

for (X = __get_first_X(); X; X = __get_next_X()) {

where __get_next_X() uses bond_next_slave().

This for can (and should) actually be replaced by the standard

bond_for_each_slave(bond, slave, iter) {
	X = __get_X_by_slave(slave);

it's faster, easier to read, debug and maintain. Also, removes a lot of
code lines.

After replacing it, the only user of bond_next_slave() is
bond_info_seq_next() - which can, actually, implement it by itself, and not
call another function.

So, that way, we can completely remove the bond_next_slave(), cleanup and
optimize a bit.

p.s. the 802.3ad code is horrible, both style-wise and from the logical
point of view - so I've decided to *not* change anything except that what
this patch is intended to provide. The cleanup and some refactoring should
be done in another patchset, which I've began to work on already.

Thank you!

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 drivers/net/bonding/bond_3ad.c    | 137 ++++++++++++++------------------------
 drivers/net/bonding/bond_main.c   |   2 +-
 drivers/net/bonding/bond_procfs.c |  16 +++--
 drivers/net/bonding/bonding.h     |  31 ---------
 4 files changed, 62 insertions(+), 124 deletions(-)
