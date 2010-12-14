From: Ben Greear <greearb@candelatech.com>
Subject: question on ebtables and iptables, relating to conntrack-zones
Date: Mon, 13 Dec 2010 23:01:15 -0800
Message-ID: <4D07163B.5010301@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53678 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754719Ab0LNHBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 02:01:16 -0500
Received: from [71.117.12.23] (pool-71-117-12-23.sttlwa.dsl-w.verizon.net [71.117.12.23])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id oBE71Fb1008766
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 23:01:15 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to do something a bit weird with two bridges and a transparent
squid proxy.

I think I want the network diagram to look a bit like:

{ internet } -- eth0 - br0 - veth2 - veth1 - br1 - eth1 -- { client-side network }

The idea is to have br1 act just as a bridge, but have br0 have an IP and
do the squid re-direct logic.  This is because I need to see packets from clients
to squid on the two br1 ports, as if squid were somewhere in the {internet}.

I was thinking that setting br1 and it's ports to one conntrack zone
and br0 and it's ports to another would do the trick, but when I do
add those, the squid redirect nat seems to break.  I am thinking now
that maybe I'd need to implement conntrack zones for ebtables BROUTING, perhaps?

My current attempted setup file looks like:

#!/bin/bash

# Clean up any old rules.
/etc/init.d/stopbrouting

/sbin/ebtables -t broute -A BROUTING -i br0 -p IPv4 --ip-protocol 6 --ip-destination-port 80 -j redirect --redirect-target ACCEPT
/sbin/iptables -t nat -A PREROUTING -i br0 -p tcp --dport 80 -j REDIRECT --to-port 3128

echo 0 > /proc/sys/net/bridge/bridge-nf-call-arptables
echo 0 > /proc/sys/net/bridge/bridge-nf-call-ip6tables

echo 1 > /sys/class/net/br0/bridge/nf_call_ip6tables
echo 1 > /sys/class/net/br0/bridge/nf_call_iptables

/usr/local/sbin/iptables -t raw -A PREROUTING -i eth1 -j CT --zone 2
/usr/local/sbin/iptables -t raw -A PREROUTING -i veth1 -j CT --zone 2
/usr/local/sbin/iptables -t raw -A PREROUTING -i br1 -j CT --zone 2

/usr/local/sbin/iptables -t raw -A PREROUTING -i eth0 -j CT --zone 3
/usr/local/sbin/iptables -t raw -A PREROUTING -i veth2 -j CT --zone 3
/usr/local/sbin/iptables -t raw -A PREROUTING -i br0 -j CT --zone 3



Any ideas are welcome.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
