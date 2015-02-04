From: Steve Hill <steve@opendium.com>
Subject: MTU problems with GRE and IPv6
Date: Wed, 04 Feb 2015 12:31:21 +0000
Message-ID: <54D21119.6050609@opendium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from persephone.nexusuk.org ([217.172.134.9]:37789 "EHLO nexusuk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933347AbbBDNcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 08:32:09 -0500
Received: from [217.146.115.154] (helo=rivendell.nexusuk.org)
	by nexusuk.org with esmtpsa (TLSv1:AES128-SHA:128)
	(Exim 4.63)
	(envelope-from <steve@opendium.com>)
	id 1YIz74-0004KO-DD
	for netdev@vger.kernel.org; Wed, 04 Feb 2015 12:31:22 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm having some problems related to oversized IPv6 packets on a GRE 
tunnel under Scientific Linux 6.6 (Kernel 2.6.32-504.3.3.el6.x86_64).

I have a set of machines set up as follows:


         Client
            |
         Router
            |
         (Internet)
            |
         Physical KVM Host
            |
         Server (KVM virtual machine)

All of these machines have both IPv4 and IPv6 connectivity.

The Client<->Router connection is ethernet with a 1500 octet MTU and the 
virtual NIC between the KVM host and the server also has a 1500 octet MTU.

There is a GRE-over-IPv4 tunnel between Router and Server with an MTU of 
1476.  On Server, normally traffic is routed via the virtual NIC, but 
iptables/ip6tables sets a CONNMARK on any traffic arriving over the GRE 
tunnel and that mark is used to select a different routing table for the 
reply traffic so that it goes back over the GRE tunnel.

 From Client, I connect to port 80 on Server (which is running Apache) 
using IPv4 over the GRE tunnel and request a large object.  tcpdump 
shows a TCP packet larger than the GRE tunnel's MTU being sent over GRE, 
and with the GRE header this exceeds the virtual NIC's MTU too.  The KVM 
host drops the oversized GRE packet and replies with a ICMP "need to 
frag".  The TCP packet is resized and retransmitted and this gets 
through, everything works:

ethertype IPv4, length 1530: Server_ipv4 > Router_ipv4: GREv0, proto 
IPv4, length 1496: Server_ipv4.http > Client_ipv4.44247: Flags [.], seq 
1:1441, ack 51, win 114, options [nop,nop,TS val 607339847 ecr 
30576811], length 1440

ethertype IPv4, length 590: KVM_ipv4 > Server_ipv4: ICMP Router_ipv4 
unreachable - need to frag (mtu 1500), length 556

ethertype IPv4, length 1506: Server_ipv4 > Router_ipv4: GREv0, proto 
IPv4, length 1472: Server_ipv4.http > Client_ipv4.44247: Flags [.], seq 
1:1417, ack 51, win 114, options [nop,nop,TS val 607339867 ecr 
30577336], length 1416


But doing the same test using IPv6 over the GRE tunnel fails.  tcpdump 
shows an oversized TCP packet again, and again that gets passed on to 
the KVM host as an oversized GRE packet, which gets dropped and an ICMP 
"need to frag" returned.  However, the TCP packet is never resized and 
retransmitted, so the TCP session hangs:

ethertype IPv4, length 1530: Server_ipv4 > Router_ipv4: GREv0, proto 
IPv6, length 1496: Server_ipv6.http > Client_ipv6.35711: Flags [.], seq 
1:1421, ack 51, win 112, options [nop,nop,TS val 607991929 ecr 
31228911], length 1420
ethertype IPv4, length 590: KVM_ipv4 > Server_ipv4: ICMP Router_ipv4 
unreachable - need to frag (mtu 1500), length 556


So, it seems to me that initially the TCP packets are sized according to 
the virtual NIC's MTU, since that is where the default routing table 
says it will go.  After being generated, the packets are then sent to 
the GRE tunnel instead, which has a lower MTU.  My expectation is that:

1. An IPv4 packet that exceeds the GRE tunnel's MTU should be dropped by 
the GRE tunnel itself and an ICMP "need to frag" should be sent back to 
the TCP stack, which should retransmit a smaller packet.

2. The same should be true for IPv6 - an IPv6 packet that exceeds the 
GRE tunnel's MTU should be dropped by the GRE tunnel itself and an 
ICMPv6 "packet too big" should be sent up to the TCP stack, which should 
retransmit a smaller packet.

3. If a GRE packet causes an upstream router to return a "need to frag", 
the GRE tunnel's MTU should be reduced accordingly and (1) or (2) should 
happen.

As far as I can see, (1) and (2) aren't happening - oversized GRE 
packets containing oversized IP packets are ending up at the KVM host. 
(3) only seems to be working for IPv4 - the IPv6 stack never retransmits 
a resized TCP packet.


Is this a bug, or am I missing something about how it should work?

Many thanks.

-- 
  - Steve Hill
    Technical Director
    Opendium Limited     http://www.opendium.com

Direct contacts:
    Instant messager: xmpp:steve@opendium.com
    Email:            steve@opendium.com
    Phone:            sip:steve@opendium.com

Sales / enquiries contacts:
    Email:            sales@opendium.com
    Phone:            +44-1792-824568 / sip:sales@opendium.com

Support contacts:
    Email:            support@opendium.com
    Phone:            +44-1792-825748 / sip:support@opendium.com
