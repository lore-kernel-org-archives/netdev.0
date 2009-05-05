From: Deepjyoti Kakati <dkakati73@gmail.com>
Subject: duplicate arp request problem with bonding driver
Date: Tue, 5 May 2009 19:15:37 +0530
Message-ID: <9a2da8520905050645s31c62a9bhdd0a5b60ae9ce52c@mail.gmail.com>
References: <9a2da8520905050632sa9a4935md668387339c748a0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:23265 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbZEENph convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 09:45:37 -0400
Received: by qw-out-2122.google.com with SMTP id 5so3662041qwd.37
        for <netdev@vger.kernel.org>; Tue, 05 May 2009 06:45:37 -0700 (PDT)
In-Reply-To: <9a2da8520905050632sa9a4935md668387339c748a0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 I am having the following issue with a fedora10 (2.6.27) type installa=
tion.

setup: my bonding and vlan topology
 ----------------------------------------------------

qemu(eth0)-----tap0-----bridge0----bond3.vlan----bond3
                                                                   |---=
--bond2
                                                                   |
    + ---{eth3, eth4}
                                                                   |
             in
                                                                   |
    balance-rr mode}
  =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
                                                                   |

bond1--+{eth1, eth2}

in balance-rr mode}

bond3 enslaves the bond2 & bond1 in primary-backup bonding mode. I am
using miimon on all of bond1,2,3 interfaces

eth1,eth2 connect to switch1 via a etherchannel
eth3, eth4 connect to switch2 via a etherchannel
all these four ports allow the same vlans.

now I desired to put my qemu virtual machine eth0 into a particular vla=
n so
created the bond3.vlan and hooked it into the bridge.

problem:
------------
from the qemu I ping a IP address of a router beyond the two switches.

the ARP request goes out of bond1 which is the active_slave

due to same vlans, the ARP request =A0floods back into my box via the {=
eth3,eth4}
from the other switch.

my version of kernel is supposed to have the bonding driver fix which
discards broadcasts/multicasts except a few cases for the inactive slav=
e of a
primary-backup pair.(the skb_bond work)

but a tcpdump on the bridge0 or bond3.vlan indicates this 2nd arp
request pkt is also being seen - apparently bond3 isnt dropping them.

consequences
---------------------
as the qemu sends out its arp requests to resolve my ping, the bridge0
sees these with src_mac=3D(qemu eth0 macaddr) and thinks it is somewher=
e
in the bond3.vlan side. "brctl showmacs bridge0" clearly shows my
qemu MAC addr as now mapped to that port, instead of the tap0 port.

so when arp response comes back from my ping target the bridge0
does not forward it on the tap0 port - all my pings timeout and fail.

when the arp's stop, that entry is aged out and it again points back to=
 tap0
port but meantime all my pings have failed.

when I shut down the (eth3,eth4) portchannel things work fine because t=
his
misleading flooded arp request is not seen.

any clue why this might be happening? I am using the "sysfs" method of
configuring bonds per the bonding driver Howto document and my
bonding_masters file has bond1 bond2 bond3.

when I tried primary-backup with the slaves as pure eth interfaces it
seemed to work fine in a similar condition.

is there anything special if bond interfaces are enslaved below other
bond interfaces?

thanks
Deepjyoti Kakati
