From: Ferenc Wagner <wferi@niif.hu>
Subject: Flooded with bonding: bond0: doing slave updates when interface is down.
Date: Mon, 08 Feb 2010 14:20:54 +0100
Message-ID: <87mxzj6eyx.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:48810 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331Ab0BHN4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 08:56:44 -0500
Received: from wferi by tac.ki.iif.hu with local (Exim 4.69)
	(envelope-from <wferi@tac.ki.iif.hu>)
	id 1NeTXq-00041s-5u
	for netdev@vger.kernel.org; Mon, 08 Feb 2010 14:20:54 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On a system running Linux 2.6.32.7 I use the following initramfs script
to bring up some interfaces before mounting the root filesystem:

---------- /etc/initramfs-tools/scripts/init-premount/net_up ----------
#!/bin/sh

PREREQ="udev"
prereqs()
{
        echo "$PREREQ"
}

case $1 in
prereqs)
        prereqs
        exit 0
        ;;
esac

. /scripts/functions

maybe_break pre-netup

# Arguments: DEV IP/MASKLEN
ifup()
{
    ip addr add $2 dev $1
    ip link set up dev $1
    echo "Configured $1 with address $2"
}

BOND=bond0

modprobe bonding
cd /sys/class/net/$BOND/bonding

echo active-backup >mode
echo +eth0 >slaves
echo +eth1 >slaves
echo eth0 >primary
echo +10.0.0.1 >arp_ip_target
echo +10.0.0.2 >arp_ip_target
echo 1000 >arp_interval

vconfig set_name_type VLAN_PLUS_VID_NO_PAD
vconfig add $BOND 39

eval $(getprops) || { panic "MAC of eth0 unknown, aborting."; halt; }

ifup $BOND $MYVLAN2
ifup vlan39 $MYVLAN39

ip addr

maybe_break post-netup
-----------------------------------------------------------------------

The eval $(getprops) command sets the MYVLANx variables depending on the
MAC address of eth0.  This stuff mostly works as expected, but sometimes
I get this on the console:

[   27.792746] Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
[   27.831788] bonding: Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details.
[   27.935640] bonding: bond0: setting mode to active-backup (1).
[   27.970565] bonding: bond0: doing slave updates when interface is down.
[   28.010110] bonding: bond0: Adding slave eth0.
[   28.036651] bonding bond0: master_dev is not up in bond_enslave
[   28.137410] bonding: bond0: Warning: failed to get speed and duplex from eth0, assumed to be 100Mb/sec and Full.
[   28.198298] bonding: bond0: making interface eth0 the new active one.
[   28.236806] bonding: bond0: first active interface up!
[   28.267515] bonding: bond0: enslaving eth0 as an active interface with an up link.
[   28.312847] bonding: bond0: doing slave updates when interface is down.
[   28.352397] bonding: bond0: doing slave updates when interface is down.
[   28.391941] bonding: bond0: doing slave updates when interface is down.
[   28.431482] bonding: bond0: doing slave updates when interface is down.
[   28.471023] bonding: bond0: doing slave updates when interface is down.
[   28.510566] bonding: bond0: doing slave updates when interface is down.
[   28.550111] bonding: bond0: doing slave updates when interface is down.
[   28.589652] bonding: bond0: doing slave updates when interface is down.
[   28.629197] bonding: bond0: doing slave updates when interface is down.
[   28.668740] bonding: bond0: doing slave updates when interface is down.
[   28.708282] bonding: bond0: doing slave updates when interface is down.
[   28.749653] bonding: bond0: doing slave updates when interface is down.
[   28.789195] bonding: bond0: doing slave updates when interface is down.
[   28.828738] bonding: bond0: doing slave updates when interface is down.
[   28.868280] bonding: bond0: doing slave updates when interface is down.
[   28.907823] bonding: bond0: doing slave updates when interface is down.
[   28.947364] bonding: bond0: doing slave updates when interface is down.
[   28.986907] bonding: bond0: doing slave updates when interface is down.
[   29.026450] bonding: bond0: doing slave updates when interface is down.
[   29.065994] bonding: bond0: doing slave updates when interface is down.
[   29.105535] bonding: bond0: doing slave updates when interface is down.
[   29.145172] tg3: eth0: Link is up at 1000 Mbps, full duplex.
[   29.178990] tg3: eth0: Flow control is off for TX and off for RX.
[   29.215415] bonding: bond0: doing slave updates when interface is down.
[   29.254956] bonding: bond0: doing slave updates when interface is down.
[   29.294496] bonding: bond0: doing slave updates when interface is down.
[   29.334038] bonding: bond0: doing slave updates when interface is down.
[   29.373581] bonding: bond0: doing slave updates when interface is down.
[   29.413122] bonding: bond0: doing slave updates when interface is down.
[   29.452663] bonding: bond0: doing slave updates when interface is down.
[   29.492205] bonding: bond0: doing slave updates when interface is down.
[   29.531748] bonding: bond0: doing slave updates when interface is down.
[...]
[   78.580920] bonding: bond0: doing slave updates when interface is down.
[   78.620463] bonding: bond0: doing slave updates when interface is down.
[   78.660009] bonding: bond0: doing slave updates when interface is down.
[   78.699825] bonding: bond0: doing slave updates when interface is down.
[   78.739373] bonding: bond0: Adding slave eth1.
[   78.765914] bonding bond0: master_dev is not up in bond_enslave
[   78.817517] tg3 0000:05:01.1: firmware: requesting tigon/tg3_tso.bin
[   78.919759] bonding: bond0: Warning: failed to get speed and duplex from eth1, assumed to be 100Mb/sec and Full.
[   78.980658] bonding: bond0: enslaving eth1 as a backup interface with an up link.
[   79.025492] bonding: bond0: Setting eth0 as primary slave.
[   79.058351] bonding: bond0: adding ARP target 10.0.0.1.
[   79.089601] bonding: bond0: adding ARP target 10.0.0.2.
[   79.120855] bonding: bond0: Setting ARP monitoring interval to 1000.
[   79.167280] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
[   79.208621] All bugs added by David S. Miller <davem@redhat.com>
[   79.259000] bonding: bond0: no route to arp_ip_target 10.0.0.1

In the end, everything seems to be all right, but this occasional
interlude is disturbing and seems to indicate that something isn't quite
right.  Which may well be my abuse of the bonding driver, but then
please enlighten me, as I'd like to eliminate this 50-second delay from
the boot procedure.  I don't mind the couple of "doing slave updates
when interface is down" warnings which appear during the normal course
of actions, but the above is way too much in my opinion.
-- 
Thanks,
Feri.
