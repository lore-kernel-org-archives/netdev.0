From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: TC-HTB issue : low throughput
Date: Fri, 6 Nov 2009 18:43:05 -0800
Message-ID: <20091107024305.GA32398@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:59683 "EHLO madara.hpl.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760010AbZKGC7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2009 21:59:35 -0500
Received: from masterns.hpl.hp.com (masterns.hpl.hp.com [15.0.48.4])
	by madara.hpl.hp.com (8.14.3/8.14.1/HPL-PA Relay) with ESMTP id nA72h6me021790
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 6 Nov 2009 18:43:06 -0800 (PST)
Received: from bougret.hpl.hp.com (bougret.hpl.hp.com [15.9.72.130])
	by masterns.hpl.hp.com (8.14.3/8.14.3/HPL-PA Hub) with ESMTP id nA72h5Oo009647
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 6 Nov 2009 18:43:06 -0800
Received: from jt by bougret.hpl.hp.com with local (Exim 4.69)
	(envelope-from <jt@bougret.hpl.hp.com>)
	id 1N6bGb-0008Rj-UJ
	for netdev@vger.kernel.org; Fri, 06 Nov 2009 18:43:05 -0800
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hi,

	I'm playing with a TC-HTB. I'm noticing that the throughput is
low. As the LARTC mailing list seems to be dead, I would welcome
suggestions...
	The example below may seem contrived, but I reduced it to
a simple testcase to make it easier to reproduce.

System :
------
	Debian Lenny with 2.6.30.9
	Quad Core 2.5 GHz Q9300
	Intel 1Gb/s NIC, e1000e driver

Setup :
-----
# brctl addbr br0
# brctl addif br0 eth5.33
# brctl addif br0 eth6.34
# brctl addif br0 eth7.38

#iptables -A FORWARD -t mangle -s 10.10.32.38 -j CLASSIFY --set-class 1:2

#tc qdisc add dev eth6.34 root handle 1: htb default 3
#tc class add dev eth6.34 parent 1: classid 1:1 htb rate 1000mbit ceil 1000mbit
#tc class add dev eth6.34 parent 1:1 classid 1:2 htb rate 3kbit ceil 1000mbit prio 1
#tc class add dev eth6.34 parent 1:1 classid 1:3 htb rate 3kbit ceil 1000mbit prio 2

Topology :
--------
Four PCs with Linux :
10.10.10.32 on br0
10.10.10.33 connected to eth5.33 (sender)
10.10.10.38 connected to eth7.38 (sender)
10.10.10.34 connected to eth6.34 (receiver)

Behaviour :
---------
	If I set only qdisc 1: and class 1:1, but *NOT* 1:2 and 1:3 :
	Each host independantly : ~935 Mb/s
	Both host together, for 10.10.10.38 : ~527 Mb/s ;
	Both host together, for 10.10.10.33 : ~443 Mb/s

	If I add classes 1:2 and 1:3 :
	Each host independantly : ~170 Mb/s.
	Both host together, for 10.10.10.38 : ~106 Mb/s ;
	Both host together, for 10.10.10.33 : ~135 Mb/s

	So, not only performance did drop significantely, but
prioritisation did not happen as expected.

Weird detail :
------------
	I've noticed that /sbin/tc calculates a very low burst
value. This is due to the content of /proc/net/psched. I'm wondering
if the burst calculation is what causes the issue here.
	However, I tried with "burst 50kb" and saw no difference...

Dump of TC
----------
# tc -s class show dev eth6.34
class htb 1:1 root rate 1000Mbit ceil 1000Mbit burst 1375b cburst 1375b 
 Sent 770653596 bytes 509070 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 82776Kbit 6835pps backlog 0b 0p requeues 0 
 lended: 509026 borrowed: 0 giants: 0
 tokens: 11 ctokens: 11

class htb 1:2 parent 1:1 prio 1 rate 3000bit ceil 1000Mbit burst 1599b cburst 13
75b 
 Sent 369190389 bytes 243876 pkt (dropped 3239, overlimits 0 requeues 0) 
 rate 44781Kbit 3698pps backlog 0b 0p requeues 0 
 lended: 20 borrowed: 243856 giants: 0
 tokens: -1384355 ctokens: 11

class htb 1:3 parent 1:1 prio 2 rate 3000bit ceil 1000Mbit burst 1599b cburst 13
75b 
 Sent 401463207 bytes 265194 pkt (dropped 3005, overlimits 0 requeues 0) 
 rate 37996Kbit 3137pps backlog 0b 0p requeues 0 
 lended: 24 borrowed: 265170 giants: 0
 tokens: -3719389 ctokens: 11

# tc -s qdisc show dev eth6.34
qdisc htb 1: root r2q 10 default 3 direct_packets_stat 0
 Sent 770653852 bytes 509071 pkt (dropped 6244, overlimits 25973 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 


	Thanks in advance for any help...

	Jean
