From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [REGRESSION 3.16-rc1] freescale/fec_main.c: IPv6 TCP fails
Date: Mon, 16 Jun 2014 12:24:32 +0100
Message-ID: <20140616112432.GZ23430@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org, Nimrod Andy <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:59154 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751149AbaFPLYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 07:24:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Starting with patch:

	96c50caa5148 (net: fec: Enable IP header hardware checksum)

IPv6 TCP no longer works - connections are not established, and because
of the behaviour, there is no fallback to IPv4.  Here is an example:

12:05:18.814143 IP6 (hlim 64, next-header TCP (6) payload length: 40) e0022681537dd.dyn.arm.linux.org.uk.58705 > fd8f:7570:feb6:1:d263:ff:fe00:0.ssh: Flags [S], cksum 0x5617 (incorrect -> 0x3d22), seq 1282590073, win 28800, options [mss 1440,sackOK,TS val 381695605 ecr 0,nop,wscale 7], length 0
        0x0000:  6000 0000 0028 0640 fd8f 7570 feb6 0001  `....(.@..up....
        0x0010:  0222 68ff fe15 37dd fd8f 7570 feb6 0001  ."h...7...up....
        0x0020:  d263 00ff fe00 0000 e551 0016 4c72 c579  .c.......Q..Lr.y
        0x0030:  0000 0000 a002 7080 5617 0000 0204 05a0  ......p.V.......
        0x0040:  0402 080a 16c0 3675 0000 0000 0103 0307  ......6u........
12:05:18.814483 IP6 (hlim 64, next-header TCP (6) payload length: 40) fd8f:0:feb6:1:d263:ff:fe00:0.ssh > e0022681537dd.dyn.arm.linux.org.uk.58705: Flags [S.], cksum 0xe2c7 (correct), seq 622926173, ack 1282590074, win 28560, options [mss 1440,sackOK,TS val 102954 ecr 381695605,nop,wscale 7], length 0
        0x0000:  6000 0000 0028 0640 fd8f 0000 feb6 0001  `....(.@........
                                          ^^^^
        0x0010:  d263 00ff fe00 0000 fd8f 7570 feb6 0001  .c........up....
        0x0020:  0222 68ff fe15 37dd 0016 e551 2521 195d  ."h...7....Q%!.]
        0x0030:  4c72 c57a a012 6f90 e2c7 0000 0204 05a0  Lr.z..o.........
        0x0040:  0402 080a 0001 922a 16c0 3675 0103 0307  .......*..6u....

The problem is that the driver/hardware is treating all packets as IPv4,
and overwriting the point in the packet which would be the IPv4 checksum.
With IPv6 packets, this results in the source address being corrupted,
and thus the initiator of the connection sees a reply from a different
IP address:

12:05:18.814510 IP6 (hlim 64, next-header TCP (6) payload length: 20) e0022681537dd.dyn.arm.linux.org.uk.58705 > fd8f:0:feb6:1:d263:ff:fe00:0.ssh: Flags [R], cksum 0xe092 (incorrect -> 0xd813), seq 1282590074, win 0, length 0
        0x0000:  6000 0000 0014 0640 fd8f 7570 feb6 0001  `......@..up....
        0x0010:  0222 68ff fe15 37dd fd8f 0000 feb6 0001  ."h...7.........
        0x0020:  d263 00ff fe00 0000 e551 0016 4c72 c57a  .c.......Q..Lr.z
        0x0030:  0000 0000 5004 0000 e092 0000            ....P.......

and sends a TCPv6 reset packet.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
