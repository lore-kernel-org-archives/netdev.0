From: Nithin Sujir <nsujir@tintri.com>
Subject: bond link state mismatch, rtnl_trylock() vs rtnl_lock()
Date: Tue, 23 May 2017 12:32:46 -0700
Message-ID: <24c0747b-df09-66da-f3ac-a393a5902a72@tintri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0023b501.pphosted.com ([208.84.65.102]:56093 "EHLO
        mx0a-0023b501.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S967061AbdEWTvj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 15:51:39 -0400
Received: from pps.filterd (m0099704.ppops.net [127.0.0.1])
        by mx0a-0023b501.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4NJVtfT005026
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 12:32:51 -0700
Received: from nam03-by2-obe.outbound.protection.outlook.com (mail-by2nam03lp0049.outbound.protection.outlook.com [216.32.180.49])
        by mx0a-0023b501.pphosted.com with ESMTP id 2ajn1gsy4w-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 12:32:51 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
We're encountering a problem in 4.4 LTS where, rarely, the bond link 
state is not updated when the slave link changes.

I've traced the issue to the arp monitor unable to get the rtnl lock. 
The sequence resulting in failure is as below.

bond_loadbalance_arp_mon() periodically called, if slave link is _down_, 
it checks if the slave is sending/receiving packets. If it is, it sets 
flags to be processed later down the function for bond link update. 
However, it sets the slave->link right away.

                 if (slave->link != BOND_LINK_UP) {
                         if (bond_time_in_interval(bond, trans_start, 1) &&
                             bond_time_in_interval(bond, slave->last_rx, 
1)) {

                                 slave->link  = BOND_LINK_UP;
                                 slave_state_changed = 1;


Later down the function, it tries to get the rtnl_lock. If it doesn't 
get it, it rearms and returns.

         if (do_failover || slave_state_changed) {
                 if (!rtnl_trylock())
                         goto re_arm; <-- returns here

                 if (slave_state_changed) {
                         bond_slave_state_change(bond);

This is the problem. The next time this function is called, the 
slave->link is already marked UP. And we will never update the bond link 
state to UP.

Changing the rtnl_trylock() -> rtnl_lock() _does_ fix the issue.

Is this the right way to fix it? If it is, I can submit this formally.

What are the guidelines around using rtnl_lock() vs rtnl_trylock()? Some 
places are using rtnl_lock() and other rtnl_trylock(). Sorry, I couldn't 
find much via a google search or in Documentation/.

Thanks,
Nithin.

--------------------

diff --git a/drivers/net/bonding/bond_main.c 
b/drivers/net/bonding/bond_main.c
index 5dca77e..1f60503 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2614,8 +2614,7 @@ static void bond_loadbalance_arp_mon(struct 
work_struct *work)
         rcu_read_unlock();

         if (do_failover || slave_state_changed) {
-               if (!rtnl_trylock())
-                       goto re_arm;
+               rtnl_lock();

                 if (slave_state_changed) {
                         bond_slave_state_change(bond);
