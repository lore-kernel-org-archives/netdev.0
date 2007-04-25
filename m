From: "Ristuccia, Brian" <bristuccia@starentnetworks.com>
Subject: 2.6.20.7 mss negotiation and path mtu discovery mostly broken?
Date: Wed, 25 Apr 2007 16:09:25 -0400
Message-ID: <7CCD07160348804497EF29E9EA5560D7020F6212@exchtewks2.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.starentnetworks.com ([12.38.223.203]:42112 "EHLO
	mx0.starentnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993056AbXDYUJf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 16:09:35 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mx0.starentnetworks.com (Postfix) with ESMTP id D7D039005B
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2007 16:09:32 -0400 (EDT)
Received: from mx0.starentnetworks.com ([127.0.0.1])
	by localhost (mx0.starentnetworks.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 04811-09 for <netdev@vger.kernel.org>;
	Wed, 25 Apr 2007 16:09:28 -0400 (EDT)
Received: from exchtewks1.starentnetworks.com (exchtewks1.starentnetworks.com [12.33.233.52])
	by mx0.starentnetworks.com (Postfix) with ESMTP
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2007 16:09:28 -0400 (EDT)
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I had previously posted this message to linux-kernel, but David Miller
asked me to post here instead. Some replies to my message on l-k have
already been copied here. I'm seeing a problem where the kernel attempts
to send packets with a MSS larger than the one negotiated when the TCP
connection is established. Even after ICMP "can't fragment" messages
arrive, the kernel still attempts to increase the MSS rather
aggressively. The end result is extremely poor throughput when sending
to a network with a smaller MTU. 

In /proc/sys/net/ipv4:
ip_no_pmtu_disc:0
tcp_mtu_probing:0

The sending host (10.2.10.254) has an MTU of 9000. The destination host
(12.33.234.69) has an MTU of 1500. There is one router between the hosts
which will drop packets with the "DF" flag when they don't fit the
destination interface's MTU and generates the required icmp can't
fragment message. 

The dump shows the initial handshake with correct mss options sent:

08:39:55.493029 IP 12.33.234.69.35026 > 10.2.10.254.22: S
2768979373:2768979373(
0) win 5840 <mss 1460,sackOK,timestamp 3873837730 0,nop,wscale 2>
08:39:55.493119 IP 10.2.10.254.22 > 12.33.234.69.35026: S
963242385:963242385(0)
 ack 2768979374 win 17896 <mss 8960,sackOK,timestamp 413751
3873837730,nop,wscal
e 5>

Then I see the system send larger packets (larger than the mss),
provoking a "can't fragment" from the router. Now I suppose it might be
reasonable to occasionally probe a larger MSS when the current MSS is a
result of reductions due to path mtu discovery. After all, the path
taken could change over time. But when the current MSS is at the value
negotiated by the MSS option during the TCP handshake, it seems like
there's no sense in trying to send with a lager MSS. Even if there were,
there's certainly no justification for making such an attempt every
other packet (2.6.18) or every fourth packet (2.6.20.7). 

In the following dump, the system eventually gets in a state where it
oscillates between sendng undeliverable 2896 byte packets and
deliverable 1448 byte ones. 

08:39:55.649689 IP 10.2.10.254.22 > 12.33.234.69.35026: .
5906:10250(4344) ack 1
794 win 674 <nop,nop,timestamp 413790 3873837887>
08:39:55.650532 IP 10.2.10.1 > 10.2.10.254: icmp 92: 12.33.234.69
unreachable -
need to frag (mtu 1500)
08:39:55.689774 IP 12.33.234.69.35026 > 10.2.10.254.22: . ack 5906 win
4544 <nop
,nop,timestamp 3873837927 413790>
08:39:55.689784 IP 10.2.10.254.22 > 12.33.234.69.35026: .
10250:13146(2896) ack
1794 win 674 <nop,nop,timestamp 413800 3873837927>
08:39:55.690497 IP 10.2.10.1 > 10.2.10.254: icmp 92: 12.33.234.69
unreachable -
need to frag (mtu 1500)
08:39:55.902494 IP 10.2.10.254.22 > 12.33.234.69.35026: .
5906:7354(1448) ack 17
94 win 674 <nop,nop,timestamp 413853 3873837927>

Since any sane router will only generate can't fragment ICMP's at a
limited rate, for two hosts on gigabit ethernet, one on a MTU 1500
subnet and another on a MTU 9000 subnet, I can move only 40-50KB/sec
over an affected TCP connection. 

I was unable to find any reference to this problem in the kernel
changelogs, or even any reports of anyone else having a similar problem.
The above dumps are from 2.6.19.7. I could also reproduce the problem in
2.6.18, although the dumps looked slightly different. I was unable to
reproduce this problem with the 2.6.9-42.0.10.ELsmp kernel which ships
in RHEL4. 

I can send a pcap dump to anyone interested. 

-- 
Brian Ristuccia


"This email message and any attachments are confidential information of Starent Networks, Corp. The information transmitted may not be used to create or change any contractual obligations of Starent Networks, Corp.  Any review, retransmission, dissemination or other use of, or taking of any action in reliance upon this e-mail and its attachments by persons or entities other than the intended recipient is prohibited. If you are not the intended recipient, please notify the sender immediately -- by replying to this message or by sending an email to postmaster@starentnetworks.com -- and destroy all copies of this message and any attachments without reading or disclosing their contents. Thank you."
