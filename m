From: "gregory hoggarth" <gregory.hoggarth@alliedtelesis.co.nz>
Subject: Linux kernel patch: elide fib_validate_source() completely
 when possible - bad side effect?
Date: Fri, 17 Jan 2014 14:59:12 +1300
Message-ID: <52D945400200005D00047758@gwia2.atlnz.lc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.alliedtelesis.co.nz ([202.36.163.21]:34323 "EHLO
	gate.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbaAQCIu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 21:08:50 -0500
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by gate.alliedtelesis.co.nz (Postfix) with ESMTPS id CDE246110A
	for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 14:59:18 +1300 (NZDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I work for Allied Telesis, a company that manufactures and sells routers and switches.

Earlier in the year we upgraded the linux kernel on our L3 switch firmware to v3.6.2 which includes this patch. Our testers have picked up a change in behaviour which I have traced back to this patch and I'd like to get comments on whether this is a bug or not.

We found that in a configuration with a device under test (DUT) that has an IP address 192.168.0.1 / 24, sending an ICMP echo request with a source IP address of 192.168.0.255 will now be accepted by the DUT, which will send an ICMP echo reply back to the 192.168.0.255 address with a broadcast MAC address of FFFF.FFFF.FFFF, meaning any other devices in the L2 domain will pick up and process the ICMP reply.

Prior to the upgrade, our device was running on linux kernel 2.6.38.2, and in that version the DUT would reject the packet with a martian source address error:
11:20:54 awplus kernel: RxPkt(00001) Q:1 dev:8 lport:00000a00 cpuC:154 encap:0 len:98 bufs:1
11:20:54 awplus kernel: RxPkt(00001) vid:1 port2.0.23
11:20:54 awplus kernel: <7>   0000cd29 980d0000 cd27c1eb 08004500 
11:20:54 awplus kernel: <7>   00540000 40004001 b858c0a8 00ffc0a8 
11:20:54 awplus kernel: <7>   00010800 a4cf588c 000552dd c9990000 
11:20:54 awplus kernel: <7>   f3240809 0a0b0c0d 0e0f1011 12131415 
11:20:54 awplus kernel: <7>   (...)
11:20:54 awplus kernel: martian source 192.168.0.1 from 192.168.0.255, on dev vlan1
11:20:54 awplus kernel: ll header: 00:00:cd:29:98:0d:00:00:cd:27:c1:eb:08:00:45:00


Initially we were thinking that a device configured with 192.168.0.255 / 23 sending a ping to 192.168.0.1 / 24 should expect to get a reply, even though this is somewhat of a misconfiguration in that the subnets aren't matching and that some things may not work properly. For example ping from a device with IP address 192.168.0.254 would behave correctly, so it seemed correct that a ping from 192.168.0.255 should also work properly. However it appears that some other part of the kernel is detecting that the echo reply packet sent by the DUT has a destination IP address of the subnet broadcast, so instead of sending it with a unicast MAC address it sends it with the broadcast MAC address, which means all other devices on the subnet would process the ICMP echo reply. This therefore makes it s
 eem like the ICMP echo request should have been dropped in the first place.

The patch added the "if (!r && !fib_num_tclassid_users)" check to fib_validate_source, which for our devices evaluates to true, hence returning early and the source address check inside __fib_validate_source is not carried out.


Does anyone have comments as to what the correct behaviour should be in this case, and whether this is an unexpected side-effect from the patch or not?

Thanks,
Greg
