From: Tomas Vasko <vasko@truth.sk>
Subject: Problem with unregister_netdevice
Date: Fri, 4 Jan 2013 15:22:41 +0100
Message-ID: <20130104142241.GA17526@seeking.truth.sk>
Reply-To: Tomas Vasko <vasko@truth.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unreal.rainside.sk ([212.89.225.144]:53128 "HELO truth.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754613Ab3ADO3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2013 09:29:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

after upgrade from 3.5.7 to 3.6.x I am experiencing problem with
unregistering of network devices like:


  kernel:[ 1523.380066] unregister_netdevice: waiting for XX to become free. Usage count = YY


The XX seems to be an interface used for either ipsec transport or 
ipsec tunnel and YY seems to be number of recently active ipsec peers.
Problem occurs when multiple routing tables are used.

>From bisecting on .../git/torvalds/linux-2.6.git it seems the culprit is
this commit: 81166dd6fa8eb780b2132d32fbc77eb6ac04e44e

Steps to reproduce:

see setup-81166dd.sh script bellow, on two computers (say nodeA and nodeB)
run it with swapped arguments -- 
  on nodeA run: setup-81166dd.sh eth1 A B 
  on nodeB run: setup-81166dd.sh eth1 B A

Script assumes you are using 8139cp driver for your device, please change for
any other. I've used this one for one interface in kvm while cutting my system
down for this reproduction.

Finally on node A run:  ping6 -n fc00:B::1
and on node B run:      ping6 -n fc00:A::1 -f -c 1500 ; modprobe -r 8139cp

This usually triggers the bug immediately, sometimes more pinging or more time
(up to 2 minutes) is needed to trigger it.

Problem is present also in 3.8-rc2 although there is takes longer time to
trigger. I did not hit it on single core computer.

Please let me know if there is anything I can do to help fixing the problem.

thanks,
tomas

-------------- setup-81166dd.sh --------------
#!/bin/bash

#on node A run: $0 eth2 A B
#on node B run: $0 eth2 B A

[ $# -ne 3 ] && { echo usage: $0 dev A B; exit 1; }

dev=$1
A=$2
B=$3

modprobe 8139cp
sleep 1
ip l s $dev up
ip a a fc00:$A::1/128 dev $dev

ip -6 r a fc00::/16 dev $dev  table 2
ip -6 r a fe80::/64 dev $dev  table 2

ip -6 rule  add to fc00::/16 table 2

setkey -c  << __END__
flush;
spdflush;

add fc00:$A::1 fc00:$B::1 ah 0x2$A$B -A hmac-md5 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
add fc00:$B::1 fc00:$A::1 ah 0x2$B$A -A hmac-md5 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;

add fc00:$A::1 fc00:$B::1 esp 0x1$A$B -E 3des-cbc 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
add fc00:$B::1 fc00:$A::1 esp 0x1$B$A -E 3des-cbc 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;

spdadd fc00:$A::1 fc00:$B::1 any -P out ipsec
              esp/transport//require
              ah/transport//require;

spdadd fc00:$B::1 fc00:$A::1 any -P in ipsec
              esp/transport//require
              ah/transport//require;

__END__

exit 0
