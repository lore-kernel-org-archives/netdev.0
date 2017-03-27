From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 0/5] link-status fixes for mii-monitoring
Date: Mon, 27 Mar 2017 11:37:24 -0700
Message-ID: <20170327183725.30565-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33657 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751413AbdC0Shl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:37:41 -0400
Received: by mail-pg0-f66.google.com with SMTP id 79so15026364pgf.0
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:37:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

The mii monitoring is divided into two phases - inspect and commit. The
inspect phase technically should not make any changes to the state and
defer it to the commit phase. However detected link state inconsistencies
on several machines and discovered that it's the result of some
inconsistent update to link states and assumption that you *always* get
rtnl-mutex. In reality when trylock() fails to acquire rtnl-mutex, the
commit phase is postponed until next mii-mon run. At the next round
because of the state change performed in the previous inspect-run, this
round does not detect any changes and would skip calling commit phase.
This would result in an inconsistent state until next link event happens
(if it ever happens).

During the the commit phase, it's always assumed that speed and duplex
fetch is always successful, but that's always not the case. However the
slave state is marked UP irrespective of speed / duplex fetch operation.
If the speed / duplex fetch operation results in insane values for either
of these two fields, then keeping internal link state UP is not going to
provide fruitful results either.

Please see into individual patches for more details.

Mahesh Bandewar (5):
  bonding: split bond_set_slave_link_state into two parts
  bonding: improve link-status update in mii-monitoring
  bonding: make speed, duplex setting consistent with link state
  bonding: correctly update link status during mii-commit phase
  bonding: avoid printing while holding a spinlock

 drivers/net/bonding/bond_3ad.c  |  6 ++---
 drivers/net/bonding/bond_main.c | 49 ++++++++++++++++++++++++-----------------
 include/net/bonding.h           | 22 +++++++++++++-----
 3 files changed, 49 insertions(+), 28 deletions(-)

-- 
2.12.1.578.ge9c3154ca4-goog
