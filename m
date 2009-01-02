From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: 2.6.27.8 (+the idr fix) TCP Ack issue
Date: Fri, 2 Jan 2009 22:02:50 +0000
Message-ID: <20090102220250.GA3520@flint.arm.linux.org.uk>
References: <20081231171016.GA1901@flint.arm.linux.org.uk> <Pine.LNX.4.64.0812312215590.3247@wrl-59.cs.helsinki.fi> <20090102142608.GC26093@flint.arm.linux.org.uk> <20090102.133435.105577950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:54381 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813AbZABWDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 17:03:12 -0500
Content-Disposition: inline
In-Reply-To: <20090102.133435.105577950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 02, 2009 at 01:34:35PM -0800, David Miller wrote:
> From: Russell King <rmk@arm.linux.org.uk>
> Date: Fri, 2 Jan 2009 14:26:09 +0000
> 
> > Remote end sequence number is still at 1190.
> > 
> > 19:47:32.285397 IP (tos 0x0, ttl  64, id 30055, offset 0, flags [DF], proto: TCP (6), length: 40) dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: ., cksum 0x41e5 (correct), 3216:3216(0) ack 2215 win 10701
> > 19:47:32.320287 IP (tos 0x0, ttl 238, id 10, offset 0, flags [none], proto: TCP (6), length: 40) 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: ., cksum 0x45e6 (correct), 1190:1190(0) ack 3216 win 10701
> > 19:47:32.320300 IP (tos 0x0, ttl  64, id 30056, offset 0, flags [DF], proto: TCP (6), length: 40) dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: ., cksum 0x41e5 (correct), 3216:3216(0) ack 2215 win 10701
> > 19:47:32.353016 IP (tos 0x0, ttl 238, id 12, offset 0, flags [none], proto: TCP (6), length: 40) 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: ., cksum 0x45e6 (correct), 1190:1190(0) ack 3216 win 10701
> > ...
> > 
> > So it looks to me like the remote end doesn't like our ack of 2215 for
> > some reason.
> 
> Let's make sure the checksum is OK.  That's a reason the ACK might
> get dropped at the remote end.

I doubt the remote end will co-operate by tcpdumping my session as
received at their end, the best I can do is a dump from my firewall
(which is doing masq, public facing NIC is a 3c589 PCMCIA card.)

But, locally:

8139too Fast Ethernet driver 0.9.28
8139too 0000:01:05.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
eth0: RealTek RTL8139 at 0xf8914c00, 00:13:8f:cb:34:ef, IRQ 22
eth0:  Identified 8139 chip type 'RTL-8101'

# ethtool -k eth0
Offload parameters for eth0:
Cannot get device rx csum settings: Operation not supported
rx-checksumming: off
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off

Obtaining a tcpdump off my firewall shows that the checksums are correct:

21:48:42.629025 IP (tos 0x0, ttl  48, id 21841, offset 0, flags [DF], proto: TCP (6), length: 432) 193.108.74.209.http > caramon.arm.linux.org.uk.38519: P, cksum 0xb7de (correct), 44198:44590(392) ack 12652 win 26796
21:48:42.630359 IP (tos 0x0, ttl  48, id 21842, offset 0, flags [DF], proto: TCP (6), length: 595) 193.108.74.209.http > caramon.arm.linux.org.uk.38519: P, cksum 0xd18b (correct), 44590:45145(555) ack 12652 win 26796
21:48:42.633342 IP (tos 0x0, ttl  48, id 21843, offset 0, flags [DF], proto: TCP (6), length: 458) 193.108.74.209.http > caramon.arm.linux.org.uk.38519: P, cksum 0x5e49 (correct), 45145:45563(418) ack 13836 win 29348
21:48:42.637288 IP (tos 0x0, ttl  63, id 39663, offset 0, flags [DF], proto: TCP (6), length: 40) caramon.arm.linux.org.uk.38519 > 193.108.74.209.http: ., cksum 0x8d85 (correct), 13836:13836(0) ack 45145 win 62780
21:48:42.639376 IP (tos 0x0, ttl  63, id 39664, offset 0, flags [DF], proto: TCP (6), length: 1316) caramon.arm.linux.org.uk.38519 > 193.108.74.209.http: ., cksum 0x8978 (correct), 13836:15112(1276) ack 45145 win 62780
21:48:42.641154 IP (tos 0x0, ttl  63, id 39665, offset 0, flags [DF], proto: TCP (6), length: 47) caramon.arm.linux.org.uk.38519 > 193.108.74.209.http: P, cksum 0x0987 (correct), 15112:15119(7) ack 45563 win 62780
21:48:42.667103 IP (tos 0x0, ttl  48, id 21844, offset 0, flags [DF], proto: TCP (6), length: 446) 193.108.74.209.http > caramon.arm.linux.org.uk.38519: P, cksum 0x99e7 (correct), 45563:45969(406) ack 13836 win 29348
21:48:42.721132 IP (tos 0x0, ttl  63, id 39666, offset 0, flags [DF], proto: TCP (6), length: 40) caramon.arm.linux.org.uk.38519 > 193.108.74.209.http: ., cksum 0x854a (correct), 15119:15119(0) ack 45969 win 62780
21:48:42.739767 IP (tos 0x0, ttl 239, id 7, offset 0, flags [none], proto: TCP (6), length: 40) 193.108.74.209.http > caramon.arm.linux.org.uk.38519: ., cksum 0x86e0 (correct), 45563:45563(0) ack 15119 win 62780
21:48:42.741603 IP (tos 0x0, ttl  63, id 39667, offset 0, flags [DF], proto: TCP (6), length: 40) caramon.arm.linux.org.uk.38519 > 193.108.74.209.http: ., cksum 0x854a (correct), 15119:15119(0) ack 45969 win 62780
21:48:42.759254 IP (tos 0x0, ttl 239, id 6, offset 0, flags [none], proto: TCP (6), length: 40) 193.108.74.209.http > caramon.arm.linux.org.uk.38519: ., cksum 0x86e0 (correct), 45563:45563(0) ack 15119 win 62780
21:48:42.761080 IP (tos 0x0, ttl  63, id 39668, offset 0, flags [DF], proto: TCP (6), length: 40) caramon.arm.linux.org.uk.38519 > 193.108.74.209.http: ., cksum 0x854a (correct), 15119:15119(0) ack 45969 win 62780
21:48:42.779423 IP (tos 0x0, ttl 239, id 4, offset 0, flags [none], proto: TCP (6), length: 40) 193.108.74.209.http > caramon.arm.linux.org.uk.38519: ., cksum 0x86e0 (correct), 45563:45563(0) ack 15119 win 62780
21:48:42.781247 IP (tos 0x0, ttl  63, id 39669, offset 0, flags [DF], proto: TCP (6), length: 40) caramon.arm.linux.org.uk.38519 > 193.108.74.209.http: ., cksum 0x854a (correct), 15119:15119(0) ack 45969 win 62780

-- 
Russell King
