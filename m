From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: bonding: sync netpoll code with bridge
Date: Wed, 25 Jul 2012 16:47:10 +0300
Message-ID: <20120725134710.GA25625@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:20681 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933007Ab2GYNrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 09:47:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Amerigo Wang,

The patch 8a8efa22f51b: "bonding: sync netpoll code with bridge" from 
Feb 17, 2011, leads to the following warning:
drivers/net/bonding/bond_main.c:1849 bond_enslave()
	 error: scheduling with locks held: 'read_lock:&bond->lock'

drivers/net/bonding/bond_main.c
  1301          read_lock(&bond->lock);
  1302          bond_for_each_slave(bond, slave, i) {
  1303                  err = slave_enable_netpoll(slave);
                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^
This can lead to a scheduling while atomic bug because it does a
GFP_KERNEL allocation and calls __netpoll_setup() which sleeps.

  1304                  if (err) {
  1305                          __bond_netpoll_cleanup(bond);
  1306                          break;
  1307                  }
  1308          }
  1309          read_unlock(&bond->lock);

Also later in the file:

  1848          if (slave_dev->npinfo) {
  1849                  if (slave_enable_netpoll(new_slave)) {
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
We are holding read_lock(&bond->lock);

  1850                          read_unlock(&bond->lock);
  1851                          pr_info("Error, %s: master_dev is using netpoll, "
  1852                                   "but new slave device does not support netpoll.\n",
  1853                                   bond_dev->name);
  1854                          res = -EBUSY;
  1855                          goto err_detach;
  1856                  }

The easy way to trigger this warning is to test with
CONFIG_DEBUG_ATOMIC_SLEEP=y.

regards,
dan carpenter
