From: Alex Sidorenko <alexandre.sidorenko@hpe.com>
Subject: Bond recovery from BOND_LINK_FAIL state not working
Date: Wed, 1 Nov 2017 14:09:06 -0400
Message-ID: <f9a6457e-f575-e9c1-2519-7694e30c474f@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarod Wilson <jarod@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:40984 "EHLO
        g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751324AbdKASJJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 14:09:09 -0400
Received: from g4t3426.houston.hpe.com (g4t3426.houston.hpe.com [15.241.140.75])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id B6301E66
        for <netdev@vger.kernel.org>; Wed,  1 Nov 2017 18:09:08 +0000 (UTC)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem has been found while trying to deploy RHEL7 on HPE Synergy platform, it is 
seen both in customer's environment and in HPE test lab.

There are several bonds configured in TLB mode and miimon=100, all other options are 
default. Slaves are connected to VirtualConnect modules. Rebooting a VC module should 
bring one bond slave (ens3f0) down temporarily, but not another one (ens3f1). But what we 
see is

Oct 24 10:37:12 SYDC1LNX kernel: bond0: link status up again after 0 ms for interface ens3f1

and it never recovers. When VC reboot is complete, everything goes back to normal again.

Redhat has backported all recent upstream commits and instrumented the bonding driver. We 
have found the following (when VC goes down)

In bond_miimon_inspect() the first slave goes to
	bond_propose_link_state(slave, BOND_LINK_FAIL);
		and
	slave->new_link = BOND_LINK_DOWN;

The second slave is still
	slave->link = BOND_LINK_UP;
		and
         slave->new_link = BOND_LINK_NOCHANGE;

This is as expected. But in bond_miimon_commit() we see that _both_ slaves are in 
BOND_LINK_FAIL.  That is, something changes the state of the second slave from another 
thread. We suspect the NetworkManager, as the problem  is there _only_ when bonds are 
controlled by it, if we set NM_CONTROLLED=no everything starts working normally.

While we still do not understand how NM affects bond state, I think that bonding driver 
needs to be made reliable enough to recover even from this state.

At this moment when we enter bond_miimon_inspect() with
slave->link = BOND_LINK_FAIL and are in the following code

                         /*FALLTHRU*/
                 case BOND_LINK_BACK:
                         if (!link_state) {
                                 bond_propose_link_state(slave, BOND_LINK_DOWN);
                                 netdev_info(bond->dev, "link status down again after %d 
ms for interface %s\n",
                                             (bond->params.updelay - slave->delay) *
                                             bond->params.miimon,
                                             slave->dev->name);

                                 commit++;
                                 continue;
                         }


we propose a new state and do 'commit++', but we do not change slave->new_link from 
BOND_LINK_NOCHANGE. As a result, bond_miimon_commit() will not process this slave.

The following patch fixes the issue:

****
If we enter bond_miimon_inspect() with slave_link=BOND_LINK_FAIL
and recover, we do bond_propose_link_state(slave, BOND_LINK_UP);
but do not change slave->new_link, so it is left in
BOND_LINK_NOCHANGE. As a result, bond_miimon_commit() will not
process that slave and it never recovers. We need to set
slave->new_link = BOND_LINK_UP to make bond_miimon_commit() work
---
  drivers/net/bonding/bond_main.c | 1 +
  1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c99dc59..07aa7ba 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2072,6 +2072,7 @@ static int bond_miimon_inspect(struct bonding *bond)
                                             (bond->params.downdelay - slave->delay) *
                                             bond->params.miimon,
                                             slave->dev->name);
+                               slave->new_link = BOND_LINK_UP;
                                 commit++;
                                 continue;
                         }
-- 
2.7.4



-- 
------------------------------------------------------------------
Alex Sidorenko	email: asid@hpe.com
ERT  Linux 	Hewlett-Packard Enterprise (Canada)
------------------------------------------------------------------
