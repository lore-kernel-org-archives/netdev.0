From: Eric Paris <eparis@parisplace.org>
Subject: [PATCH] bonding using arp_ip_target may stay down with active path
Date: Mon, 16 May 2005 14:41:25 -0400
Message-ID: <1116268885.3738.19.camel@dhcp59-180.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The bonding module may get into a state in which an active path to the
network exists through at least one slave device but the bond remains
down forever.  This situation exists using the bonding options  mode=1
arp_interval=500 arp_ip_target=10.10.10.5.  mode=1 is the active/passive
bonding mode.  We determine link status using the reachability of other
network devices determined by if they respond to arp requests.

Reproducer:
The reproducer is not simple.  Easiest with 3 computers and two
crossover cables.  Configure one computer with bonding and each of the
other computers to have an address in the arp_ip_target entries for the
first machine.  In this way if both single nic computers are up bonding
should believe either of the slave interfaces are valid since each can
reach one of the arp_ip_target entries.  Shutdown the interface on the
single nic computer connected to eth0.  The bond should fail over to
eth1.  Shut down the interface connected to eth1.  The bond should
decide both the eth1 slave and the bond as a whole is down (it cannot
contact either of the arp_ip_target entries).  Run tcpdump on both of
the single nic machines and see that only the machine connected to eth0
is receiving arp requests.  Bring back up the interface connected to
eth1.  At this point we have a "valid" connection since eth1 can talk to
one of the arp targets.  But we are only sending arp requests on eth0
(verify with tcpdump)

The Problem:
The problem is in bond_activebackup_arp_mon where we say (in
bond_main.c)

if (!slave) {
        if (!bond->current_arp_slave) {
                bond->current_arp_slave = bond->first_slave;
        }
        if (bond->current_arp_slave) {
                bond_set_slave_inactive_flags(bond->current_arp_slave);

                /* search for next candidate */
                bond_for_each_slave_from(bond, slave, i,
bond->current_arp_slave) {
                        if (IS_UP(slave->dev)) {
                                slave->link = BOND_LINK_BACK;
                                bond_set_slave_active_flags(slave);
                                bond_arp_send_all(bond, slave);
                                slave->jiffies = jiffies;
                                bond->current_arp_slave = slave;
                                break;
                        }

What happens is that we set the current_arp_slave to the first interface
in the bond, bond->current_arp_slave = bond->first_slave; (in our case
eth0) and then if that slave IS_UP we send the arp requests.  IS_UP
checks only physical device information, so the NIC is up if it has
link.

We can make it fail over by pulling the cable, in which case we are !
IS_UP(eth0) and so the bond_for_each_slave_from loop continues to
IS_UP(eth1) and it finds eth1 is physically up.  It then sends the arp
requests on eth1, gets a response from the connected single nic machine
and marks the bond as a whole as up.

The patch below instead just uses bond_for_each_slave_from(bond, slave,
i, bond->current_arp_slave->next) which means that each time we enter
bond_activebackup_arp_mon without a bond->current_active_slave we will
try an interface (actually starting with the second in the list) and if
that interface does not get success the next go round
bond->current_arp_slave will be the next in the list.  This way we will
try all interfaces in turn.  I unconditionally use
current_arp_slave->next since it is a circular list and should always
have a next.

The patch below has been tested by me and appears to fix the problem.
All of the failover tests I performed seem to work including pulling
cables and stopping responses from the arp_ip_target entries.  

--- linux-2.6.11/drivers/net/bonding/bond_main.c.orig   2005-05-12 12:22:52.000000000 -0400
+++ linux-2.6.11/drivers/net/bonding/bond_main.c        2005-05-12 15:13:53.000000000 -0400
@@ -3046,7 +3046,7 @@ static void bond_activebackup_arp_mon(st
                        bond_set_slave_inactive_flags(bond->current_arp_slave);

                        /* search for next candidate */
-                       bond_for_each_slave_from(bond, slave, i, bond->current_arp_slave) {
+                       bond_for_each_slave_from(bond, slave, i, bond->current_arp_slave->next) {
                                if (IS_UP(slave->dev)) {
                                        slave->link = BOND_LINK_BACK;
                                        bond_set_slave_active_flags(slave);
