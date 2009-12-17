From: "Christian P. Schmidt" <schmidt@digadd.de>
Subject: IP policy routing & rule 0
Date: Thu, 17 Dec 2009 19:16:51 +0100
Message-ID: <4B2A7593.4040607@digadd.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.digadd.de ([195.47.195.236]:47591 "EHLO mx2.digadd.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936445AbZLQSoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2009 13:44:32 -0500
Received: from amsterdam-nat.juniper.net ([193.110.48.4] helo=[192.168.2.36])
	by mx2.digadd.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <charlie@digadd.de>)
	id 1NLKuw-0005Je-AK
	for netdev@vger.kernel.org; Thu, 17 Dec 2009 19:17:38 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to set up a test where I use a single PC to send traffic
across an external device (router, firewall, etc) and back to the same PC.

I am using two VLANs on a single interface, though it in principle
should not be different from using two physical interface. The setup
looks like this:

ip link add link eth0 name eth0.1 type vlan id 1
ip link add link eth0 name eth0.2 type vlan id 2

ip addr add dev eth0.1 10.3.0.2/24
ip link set dev eth0.1 up

ip addr add dev eth0.2 1.32.0.2/24
ip link set dev eth0.2 up

ip route del 10.32.0.0/24 dev eth0.1
ip route add 10.32.0.0/24 table 11 dev eth0.1
ip route add default table 11 via 10.32.0.1
ip rule add from 10.32.0.2 table 11

ip route del 1.32.0.0/24 dev eth0.2
ip route add 1.32.0.0/24 table 12 dev eth0.2
ip route add default table 12 via 1.32.0.1
ip rule add from 1.32.0.2 table 12

This works - mostly. I fail to force a packet from 10.3.0.2 to 1.32.0.2
using the ethernet port, instead it seems to go directly:

[~]>ping 1.32.0.1 -I 10.32.0.2 -c 1
PING 1.32.0.1 (1.32.0.1) from 10.32.0.2 : 56(84) bytes of data.
64 bytes from 1.32.0.1: icmp_seq=1 ttl=62 time=1.08 ms

vs.

[~]>ping 1.32.0.2 -I 10.32.0.2 -c 1
PING 1.32.0.2 (1.32.0.2) from 10.32.0.2 : 56(84) bytes of data.
64 bytes from 1.32.0.2: icmp_seq=1 ttl=64 time=0.043 ms

I have the feeling this is related to rule 0:
[~]>ip rule show
0:	from all lookup local
32763:	from 1.32.0.2 lookup 12
32764:	from 10.32.0.2 lookup 11
32765:	from 192.168.255.30 lookup 10
32766:	from all lookup main
32767:	from all lookup default

but deleting the route from the "local" table leads to a completely
unusable interface.

Is there a way to achieve what I want?

Regards,
Christian
