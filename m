From: John Valko <jovalko@cisco.com>
Subject: Bonding MAC failover behavior with VLAN interfaces
Date: Tue, 9 Feb 2016 21:33:03 -0500
Message-ID: <56BAA15F.4080609@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Dwight Frye (dfrye)" <dfrye@cisco.com>,
	Wally Dixon <wdixon@cisco.com>,
	"Leo Lee (lelee2)" <lelee2@cisco.com>,
	"Nishant Thakre (nthakre)" <nthakre@cisco.com>,
	"Parvez Shaikh (pshaikh)" <pshaikh@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-3.cisco.com ([173.37.142.90]:31197 "EHLO
	alln-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbcBJCdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 21:33:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have observed the following on CentOS 6 using the 
2.6.32-573.8.1.el6.x86_64 kernel as well as Ubuntu 15.10 with 
4.2.0-25-generic.. I have not yet tried with a vanilla kernel but with 
the large time/distro gap it didn't seem likely to be caused by distro 
changes.

We have a networking scenario that looks a bit like this:


      +---------+ +---------+ +---------+
      |         | |         | |         |
      | bond0.5 | | bond0.6 | | bond0.7 |  VLAN interfaces
      |         | |         | |         |
      +---+-----+ +---+-----+ +---+-----+
          +------+    |   +-------+
                 |    |   |
               +-+----+---+--+
               |             | type=active-backup
               |    bond0    | mac failover=active
               |             |
               +-+---------+-+
                 |         |
                 |         |
       +---------+-+     +-+---------+
       |           |     |           |
       |   eth0    |     |   eth1    |bond slaves
       |           |     |           |
       +-----------+     +-----------+

Our actual scenario is where eth0 and eth1 are SR-IOV VFs passed to kvm 
guest via PCI passthru.  However, I have been able to demonstrate the 
same behavior using the veth driver so I'm going to use that to 
illustrate my confusion.

_1) Load bomding module with opt__ions mentioned in the above diagram:_

# modprobe bonding mode=1 miimon=100 fail_over_mac=active

_2) Verify we got the mode we __wanted_

#  cat /sys/class/net/bond0/bonding/mode
active-backup 1
# cat /sys/class/net/bond0/bonding/fail_over_mac
active 1

_3) Create some veth interfaces just so we have something to bond and 
then bond them_

# ip link add name veth0 type veth peer name veth0.peer
# ip link add name veth1 type veth peer name veth1.peer
# ifconfig veth0 up
# ifconfig veth0.peer up
# ifconfig veth1 up
# ifconfig veth1.peer up
# ifconfig bond0 up
# ifenslave bond0 veth0 veth1

Note, MAC is taken from veth0:

# ip link show veth0
5: veth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc 
pfifo_fast master bond0 state UP qlen 1000
     link/ether *ca:d2:fb:b9:f9:b8* brd ff:ff:ff:ff:ff:ff
# ip link show veth1
7: veth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc 
pfifo_fast master bond0 state UP qlen 1000
     link/ether 16:a3:36:0b:c1:ec brd ff:ff:ff:ff:ff:ff
# ip link show bond0
3: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP
     link/ether *ca:d2:fb:b9:f9:b8* brd ff:ff:ff:ff:ff:ff

_4) Create a cou__ple VLAN interfaces_

# ip link add link bond0 name bond0.5 type vlan id 5
# ip link add link bond0 name bond0.6 type vlan id 6
# ip link add link bond0 name bond0.7 type vlan id 7
# ifconfig bond0.5 up
# ifconfig bond0.6 up
# ifconfig bond0.7 up

Note that these all have the sam MACs as bond0:

# ip link show bond0.5
8: bond0.5@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP
     link/ether ca:d2:fb:b9:f9:b8 brd ff:ff:ff:ff:ff:ff
# ip link show bond0.6
9: bond0.6@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP
     link/ether ca:d2:fb:b9:f9:b8 brd ff:ff:ff:ff:ff:ff
# ip link show bond0.7
10: bond0.7@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP
     link/ether ca:d2:fb:b9:f9:b8 brd ff:ff:ff:ff:ff:ff
# ip link show bond0
3: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP
     link/ether ca:d2:fb:b9:f9:b8 brd ff:ff:ff:ff:ff:ff

_5) __Take down veth0 to cause a failover to veth1_

# ifconfig veth0 down

Now note that bond0 takes the address of veth1 as expected:

# ip link show veth1
7: veth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc 
pfifo_fast master bond0 state UP qlen 1000
     link/ether 16:a3:36:0b:c1:ec brd ff:ff:ff:ff:ff:ff
# ip link show bond0
3: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP
     link/ether 16:a3:36:0b:c1:ec brd ff:ff:ff:ff:ff:ff

BUT... not the VLAN interfaces, they still have veth0's MAC:

# ip link show veth0
5: veth0: <BROADCAST,MULTICAST,SLAVE> mtu 1500 qdisc pfifo_fast master 
bond0 state DOWN qlen 1000
     link/ether *ca:d2:fb:b9:f9:b8* brd ff:ff:ff:ff:ff:ff
# ip link show veth1
7: veth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc 
pfifo_fast master bond0 state UP qlen 1000
     link/ether *16:a3:36:0b:c1:ec* brd ff:ff:ff:ff:ff:ff
# ip link show bond0
3: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP
     link/ether *16:a3:36:0b:c1:ec* brd ff:ff:ff:ff:ff:ff
# ip link show bond0.5
8: bond0.5@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP
     link/ether *ca:d2:fb:b9:f9:b8* brd ff:ff:ff:ff:ff:ff
# ip link show bond0.6
9: bond0.6@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP
     link/ether *ca:d2:fb:b9:f9:b8* brd ff:ff:ff:ff:ff:ff
# ip link show bond0.7
10: bond0.7@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue state UP
     link/ether *ca:d2:fb:b9:f9:b8* brd ff:ff:ff:ff:ff:ff

So, herein lies my confusion.  I expect that the VLAN interfaces should 
also pick up the new MAC address, but they don't.  It seems like a bug 
to me, but I don't want to be presumptuous so if in fact this is 
expected behavior, how do you recommend we approach making it switch 
when the bond fails over?  Right now, the MAC must be manually set for 
each vlan interface.

Right now I am looking at the current bonding code on master in 
drivers/net/bonding/bond_main.c:

    645  /* bond_do_fail_over_mac
    646   *
    647   * Perform special MAC address swapping for fail_over_mac settings
    648   *
    649   * Called with RTNL
    650   */
    651  static void bond_do_fail_over_mac(struct bonding *bond,
    652                                    struct slave *new_active,
    653                                    struct slave *old_active)
    654  {
    655          u8 tmp_mac[ETH_ALEN];
    656          struct sockaddr saddr;
    657          int rv;
    658
    659          switch (bond->params.fail_over_mac) {
    660          case BOND_FOM_ACTIVE:
    661                  if (new_active)
    662 bond_set_dev_addr(bond->dev, new_active->dev);
    663                  break;

I can see it set the mac of the bond to the new active slave MAC, but I 
don't see any indication of looping over vlan interfaces or anything, if 
that is expected... or would it be expected that the 8021q module 
receives an event that should make it change?

I am a kernel newbie, so I am not sure how this is really expected to 
work, but am very interested in your suggestions.

Thanks,

John
