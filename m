From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: TCP performance problems - GSO/TSO, MSS, 8139cp related
Date: Fri, 11 Nov 2016 21:05:00 +0000
Message-ID: <20161111210500.GE1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:40192 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935596AbcKKVNE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 16:13:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I seem to have found a severe performance issue somewhere in the
networking code.

This involves ZenIV.linux.org.uk, which is a qemu-kvm guest instance
on ZenV, which is configured to use macvtap for ZenIV to gain its
network access, with ZenIV using the 8139cp driver.

My initial testing was from my laptop (running 4.5.7), through a
router box (also running 4.5.7) and out my FTTC link, across the
Internet to ZenV (4.4.8-300.fc23.x86_64) and then onto the ZenIV
(also 4.4.8-300.fc23.x86_64) guest.  Thinking that it may be an
issue with my crappy FTTC, I switched the routing at my end over
the ADSL line, which showed the same issues.

Eventually, what fixed it was disabling both TSO and GSO in the
ZenIV guest.

Now, both my FTTC and ADSL links have a reduced MTU, and I'm having
to use TCPMSS on the router box to clamp the MSS - which gets
clamped to 1452, 8 bytes lower than the usual 1460 for standard
ethernet.

With TSO on, I see the guest sending TCP packets with a 2880 byte
payload:

17:36:07.006009 IP (tos 0x0, ttl 52, id 17517, offset 0, flags [DF], proto TCP (6), length 60)
    84.xx.xxx.196.60846 > 195.92.253.2.http: Flags [S], cksum 0x2c25 (correct), seq 356291023, win 29200, options [mss 1452,sackOK,TS val 1372902818 ecr 0,nop,wscale 7], length 0
17:36:07.006122 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 60)
    195.92.253.2.http > 84.xx.xxx.196.60846: Flags [S.], cksum 0xed7f (incorrect -> 0x674a), seq 2784716623, ack 356291024, win 28960, options [mss 1460,sackOK,TS val 3358126141 ecr 1372902818,nop,wscale 7], length 0
17:36:07.035531 IP (tos 0x0, ttl 52, id 17518, offset 0, flags [DF], proto TCP (6), length 52)
    84.xx.xxx.196.60846 > 195.92.253.2.http: Flags [.], cksum 0x0634 (correct), ack 1, win 229, options [nop,nop,TS val 1372902848 ecr 3358126141], length 0
17:36:07.038233 IP (tos 0x0, ttl 52, id 17519, offset 0, flags [DF], proto TCP (6), length 205)
    84.xx.xxx.196.60846 > 195.92.253.2.http: Flags [P.], cksum 0x3a1e (correct), seq 1:154, ack 1, win 229, options [nop,nop,TS val 1372902848 ecr 3358126141], length 153: HTTP, length: 153
17:36:07.038356 IP (tos 0x0, ttl 64, id 38669, offset 0, flags [DF], proto TCP (6), length 52)
    195.92.253.2.http > 84.xx.xxx.196.60846: Flags [.], cksum 0xed77 (incorrect -> 0x0575), ack 154, win 235, options [nop,nop,TS val 3358126173 ecr 1372902848], length 0
17:36:07.039255 IP (tos 0x0, ttl 64, id 38670, offset 0, flags [DF], proto TCP (6), length 2932)
    195.92.253.2.http > 84.xx.xxx.196.60846: Flags [.], seq 1:2881, ack 154, win 235, options [nop,nop,TS val 3358126174 ecr 1372902848], length 2880: HTTP, length: 2880
17:36:07.039442 IP (tos 0x0, ttl 64, id 38672, offset 0, flags [DF], proto TCP (6), length 2932)
    195.92.253.2.http > 84.xx.xxx.196.60846: Flags [.], seq 2881:5761, ack 154, win 235, options [nop,nop,TS val 3358126174 ecr 1372902848], length 2880: HTTP
17:36:07.039579 IP (tos 0x0, ttl 64, id 38674, offset 0, flags [DF], proto TCP (6), length 2932)
    195.92.253.2.http > 84.xx.xxx.196.60846: Flags [.], seq 5761:8641, ack 154, win 235, options [nop,nop,TS val 3358126174 ecr 1372902848], length 2880: HTTP
...etc...

On the macvtap side, however, which is post-segmentation by the
virtualised 8139cp hardware (this taken at a later time):

18:59:38.782818 IP (tos 0x0, ttl 52, id 35619, offset 0, flags [DF], proto TCP (6), length 60)
    84.xx.xxx.196.61236 > 195.92.253.2.http: Flags [S], cksum 0x88db (correct), seq 158975430, win 29200, options [mss 1452,sackOK,TS val 1377914597 ecr 0,nop,wscale 7], length 0
18:59:38.783270 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 60)
    195.92.253.2.http > 84.xx.xxx.196.61236: Flags [S.], cksum 0x575d (correct), seq 4091022471, ack 158975431, win 28960, options [mss 1460,sackOK,TS val 3363137919 ecr 1377914597,nop,wscale 7], length 0
18:59:38.812089 IP (tos 0x0, ttl 52, id 35620, offset 0, flags [DF], proto TCP (6), length 52)
    84.xx.xxx.196.61236 > 195.92.253.2.http: Flags [.], cksum 0xf646 (correct), ack 1, win 229, options [nop,nop,TS val 1377914627 ecr 3363137919], length 0
18:59:38.814623 IP (tos 0x0, ttl 52, id 35621, offset 0, flags [DF], proto TCP (6), length 205)
    84.xx.xxx.196.61236 > 195.92.253.2.http: Flags [P.], cksum 0x2a31 (correct), seq 1:154, ack 1, win 229, options [nop,nop,TS val 1377914627 ecr 3363137919], length 153: HTTP, length: 153
18:59:38.815025 IP (tos 0x0, ttl 64, id 25878, offset 0, flags [DF], proto TCP (6), length 52)
    195.92.253.2.http > 84.xx.xxx.196.61236: Flags [.], cksum 0xf588 (correct), ack 154, win 235, options [nop,nop,TS val 3363137950 ecr 1377914627], length 0
18:59:38.816371 IP (tos 0x0, ttl 64, id 25879, offset 0, flags [DF], proto TCP (6), length 1500)
    195.92.253.2.http > 84.xx.xxx.196.61236: Flags [.], seq 1:1449, ack 154, win 235, options [nop,nop,TS val 3363137952 ecr 1377914627], length 1448: HTTP, length: 1448
18:59:38.816393 IP (tos 0x0, ttl 64, id 25880, offset 0, flags [DF], proto TCP (6), length 1484)
    195.92.253.2.http > 84.xx.xxx.196.61236: Flags [.], seq 1449:2881, ack 154, win 235, options [nop,nop,TS val 3363137952 ecr 1377914627], length 1432: HTTP
18:59:38.816471 IP (tos 0x0, ttl 64, id 25881, offset 0, flags [DF], proto TCP (6), length 1500)
    195.92.253.2.http > 84.xx.xxx.196.61236: Flags [.], seq 2881:4329, ack 154, win 235, options [nop,nop,TS val 3363137952 ecr 1377914627], length 1448: HTTP
18:59:38.816501 IP (tos 0x0, ttl 64, id 25882, offset 0, flags [DF], proto TCP (6), length 1484)
    195.92.253.2.http > 84.xx.xxx.196.61236: Flags [.], seq 4329:5761, ack 154, win 235, options [nop,nop,TS val 3363137952 ecr 1377914627], length 1432: HTTP
18:59:38.816660 IP (tos 0x0, ttl 64, id 25883, offset 0, flags [DF], proto TCP (6), length 1500)
    195.92.253.2.http > 84.xx.xxx.196.61236: Flags [.], seq 5761:7209, ack 154, win 235, options [nop,nop,TS val 3363137952 ecr 1377914627], length 1448: HTTP

Now, every packet which has 1448 bytes of payload is 1514 bytes in length,
which gets dropped on its way to me at the ISP end of the link, because
the PPPoE link seems unable to handle this sized packet (annoyingly.)

The result is that the oversized "200 OK" packet gets lost and has to be
re-transmitted - here it is on the guest side:

17:36:07.176351 IP (tos 0x0, ttl 64, id 38681, offset 0, flags [DF], proto TCP (6), length 1492)
    195.92.253.2.http > 84.xx.xxx.196.60846: Flags [.], seq 1:1441, ack 154, win 235, options [nop,nop,TS val 3358126311 ecr 1372902989], length 1440: HTTP, length: 1440

notice that it is 1440 bytes in size now... and of course it comes
through on the macvtap side correctly:

18:59:38.950513 IP (tos 0x0, ttl 64, id 25890, offset 0, flags [DF], proto TCP (6), length 1492)
    195.92.253.2.http > 84.xx.xxx.196.61236: Flags [.], seq 1:1441, ack 154, win 235, options [nop,nop,TS val 3363138086 ecr 1377914764], length 1440: HTTP, length: 1440

This kind of thing goes on throughout the transfer - whenever the guest
sends a GSO/TSO packet, it is incorrectly segmented, resulting in the
over-sized segments being dropped, and causing lots of retransmissions.

The result is that with TSO/GSO on, I get around 70-80KB/s, but with
TSO/GSO off, I get 723KB/s - around a factor of 10 faster.

Doing some local testing between the 4.5.7 laptop and a Marvell board
running 4.9-rc, and using TCPMSS to clamp the MSS To 1452 between these
(on both the SYN and SYNACK packets) shows that the laptop's E1000e
driver and the 4.5.7 net stack correctly segment - I end up with TCP
packets with 1440 byte payloads being spat out of the E1000e NIC.

So, my guess is there's something wrong with either 8139cp (and dwmw2's
commit says to scream at him if it breaks!) or something wrong in the
qemu 8139cp hardware emulation.

I've suggested to bryce (who setup the VM and knows it better than I)
to try switching ZenIV to E1000e to see whether that makes any
difference - that would point towards either the 8139cp driver or the
qemu 8139 hardware emulation being broken, rather than something in
the network stack.

However, it may be worth someone testing TSO/GSO with real 8139cp
hardware - the MSS can be clamped with:

# iptables -t mangle -I INPUT -p tcp --tcp-flags SYN,RST SYN \
	-j TCPMSS --set-mss 1452
# iptables -t mangle -I OUTPUT -p tcp --tcp-flags SYN,RST SYN \
	-j TCPMSS --set-mss 1452

and testing with something like wget/iperf.  You'll need to ensure
that GRO is disabled on the box receiving the TCP packets from the
8139cp machine to see the raw packets in tcpdump, otherwise you'll
get much larger packets reassembled by the GRO code.  You should
see the TCP packets with a data size of 1440 bytes, not alternating
between 1448 and 1432 bytes.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
