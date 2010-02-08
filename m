From: Ferenc Wagner <wferi@niif.hu>
Subject: netconsole dumbs the system (in initramfs with bonding and vlan)
Date: Mon, 08 Feb 2010 22:01:31 +0100
Message-ID: <87iqa74f2s.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:58147 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752130Ab0BHVBd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 16:01:33 -0500
Received: from wferi by tac.ki.iif.hu with local (Exim 4.69)
	(envelope-from <wferi@tac.ki.iif.hu>)
	id 1Neajc-00088O-1O
	for netdev@vger.kernel.org; Mon, 08 Feb 2010 22:01:32 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I set up networking from the initramfs like this:

----------------------------------------
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

ifup $BOND 10.0.0.6/24
ifup vlan39 10.253.1.103/24
----------------------------------------

which mostly works, apart from the occasional flood of "bonding: bond0:
doing slave updates when interface is down" messages as detailed in my
previous mail.  However, if I afterwards issue

# modprobe netconsole netconsole=@10.0.0.6/eth0,@10.0.0.7/

that kills off the consoles: past kernel messages start pouring over all
consoles, the new network console included, then it suddenly dies off in
the middle, with one more line on the VC than sent to the network.  At
this point, the machine still responds to ping, the keyboard leds work,
but otherwise it's impossible to interact with it.  No SysRq, even.
Being in the initramfs, there are no network services to test.  If I
load netconsole in the running system, there isn't much backlog to pour
out, and the problem doesn't appear.  What could be wrong here?
-- 
Thanks,
Feri.
