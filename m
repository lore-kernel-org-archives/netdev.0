From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH 2.6.16-rc5] S2io: Receive packet classification and steering mechanisms
Date: Tue, 18 Apr 2006 17:38:37 -0700
Message-ID: <MAEEKMLDLDFEGKHNIJHIAEIGCDAA.ravinandan.arakali@neterion.com>
References: <MAEEKMLDLDFEGKHNIJHICENMCCAA.ravinandan.arakali@neterion.com>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:10135 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1750837AbWDSAiz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 20:38:55 -0400
To: <jgarzik@pobox.com>, <netdev@vger.kernel.org>
In-Reply-To: <MAEEKMLDLDFEGKHNIJHICENMCCAA.ravinandan.arakali@neterion.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,
Any comments on the below patch ?

Thanks,
Ravi

-----Original Message-----
From: Ravinandan Arakali [mailto:Ravinandan.Arakali@neterion.com]
Sent: Friday, March 10, 2006 12:32 PM
To: jgarzik@pobox.com; netdev@vger.kernel.org
Cc: raghavendra.koushik@neterion.com; ravinandan.arakali@neterion.com;
leonid.grossman@neterion.com; rapuru.sriram@neterion.com;
ananda.raju@neterion.com; alicia.pena@neterion.com;
sivakumar.subramani@neterion.com
Subject: [PATCH 2.6.16-rc5] S2io: Receive packet classification and
steering mechanisms


Hi,
Attached below is a patch to several receive packet classification
and steering mechanisms for Xframe NIC hw channels. Current Xframe ASIC
supports one hardware channel per CPU, up to 8 channels. This number
will increase in the next ASIC release. A channel could be attached to a
specific MSI-X vector (with an independent interrupt moderation scheme),
which in turn can be bound to a CPU.

Follow-up patches will provide some enhancements for the default tcp
workload balancing across hw channels, as well as an optional hw channel
interface. The interface is intended to be very generic (not specific to
Xframe hardware).

The following mechanisms are supported in this patch:
Note: The steering type can be specified at load time with
parameter rx_steering_type. Values supported are 1(port based),
2(RTH), 4(SPDM), 8(MAC addr based). 
 
1. RTH(Receive traffic hashing):
Steering is based on socket tuple (or a subset) and the popular Jenkins
hash is used for RTH. This lets the receive processing to be spanned out
to multiple CPUs, thus reducing single CPU bottleneck on Rx path.
Hash-based steering can be used when it is desired to balance an
unlimited number or TCP sessions across multiple CPUs but the exact
mapping between a particular session and a particular cpu is not
important.

configuration: A mask(specified using loadable parameter rth_fn_and_mask)
can be used to select a subset of TCP/UDP tuple for hash calculation.
eg. To mask source port for TCP/IPv4 configuration,
# insmod s2io.ko rx_steering_type=2 rth_fn_and_mask=0x0101
LSB specifies RTH function type and MSB the mask. A full description
is provided at the beginning of s2io.c 

2. port based:
Steering is done based on source/destination TCP/UDP port number. 

configuration: Interface used is netlink sockets. Can specify port
number(s), TCP/UDP type, source/destination port.

3. MAC address-based:
Done based on destination MAC address of packet. Xframe can be
configured with multiple unicast MAC addresses.

configuration: Load-time parameters multi_mac_cnt and multi_macs
can be used to specify no. of MAC addresses and list of unicast
addresses.
eg. insmod s2io.ko rx_steering_type=8 multi_mac_cnt=3 
	multi_macs=00:0c:fc:00:00:22, 00:0c:fc:00:01:22, 00:0c:fc:00:02:22 
Packets received with default destination MAC address will be steered to 
ring0. Packets with destination MAC addresses specified by multi_macs are 
steered to ring1, ring2... respectively.

4. SPDM (Socket Pair Direct Match).
Steering is based on exact socket tuple (or a subset) match.
SPDM steering can be used when the exact mapping between a particular
session and a particular cpu is desired.

configuration: Interface used is netlink sockets. Can specify 
socket tuple values. If any of the values(say source port) needs
to be "don't care", specify 0xFFFF.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
---


