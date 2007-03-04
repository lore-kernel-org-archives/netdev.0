From: Pete Zaitcev <zaitcev@redhat.com>
Subject: VPN vs. conntrack
Date: Sat, 3 Mar 2007 22:22:12 -0800
Message-ID: <20070303222212.17758200.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: zaitcev@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49476 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898AbXCDGYD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2007 01:24:03 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l246O1pm027119
	for <netdev@vger.kernel.org>; Sun, 4 Mar 2007 01:24:01 -0500
Received: from pobox.devel.redhat.com (pobox.devel.redhat.com [10.11.255.8])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l246O1EA004226
	for <netdev@vger.kernel.org>; Sun, 4 Mar 2007 01:24:01 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear All:

Our IS/IT in their infinite wisdom made us to switch from ESP to UDP
encapsulation for the VPN. It worked ok for a while, but the following
seems to happen now (not sure how recently it started, sorry).
At first, everything works fine. A VPN client sends its packets through
a masquerading box to Cisco concentrator. Concentrator sends packets
back, and they get properly forwarded by the masquerading box.

Traffic looks like this (on the outside interface of the masquerading box):

22:05:50.383442 IP 65.181.30.74.ipsec-nat-t > 66.197.233.252.ipsec-nat-t: UDP-encap: ESP(spi=0x5e12c961,seq=0xb), length 76
22:05:50.414700 IP 66.197.233.252.ipsec-nat-t > 65.181.30.74.ipsec-nat-t: UDP-encap: ESP(spi=0x69017f05,seq=0x8), length 84

Conntrack looks like this:

udp      17 144 src=192.168.128.11 dst=66.197.233.252 sport=4500 dport=4500 packets=20 bytes=3704 src=66.197.233.252 dst=65.181.30.74 sport=4500 dport=4500 packets=14 bytes=4248 [ASSURED] mark=0 secmark=0 use=1

However, sometimes the masquerading box loses the conntrack entry. This
happens if there was not enough activity across VPN. Then, it cannot
re-establish the entry. I don't know how it manages that, but the mas-
querading system makes the concentrator to reply to port 1024:

21:56:51.136174 IP 65.181.30.74.ipsec-nat-t > 66.197.233.252.ipsec-nat-t: UDP-encap: ESP(spi=0x3d02e5ec,seq=0x26), length 92
21:56:51.224938 IP 66.197.233.252.ipsec-nat-t > 65.181.30.74.1024: UDP-encap: ESP(spi=0x7d35e369,seq=0x37), length 92

The conntrack entry looks like this (note port 1024):

udp      17 9 src=66.197.233.252 dst=65.181.30.74 sport=4500 dport=1024 packets=1 bytes=120 [UNREPLIED] src=65.181.30.74 dst=66.197.233.252 sport=1024 dport=4500 packets=0 bytes=0 mark=0 secmark=0 use=1

Restarting the client (!) makes conntrack to catch up and work again.
I looked at ip_conntrack code and I just don't understand anything...
Does anyone have any ideas?

Greetings,
-- Pete
