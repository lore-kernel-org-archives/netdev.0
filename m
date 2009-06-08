From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: bonds/vlan combinations and device features
Date: Mon, 8 Jun 2009 13:05:11 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0906081244140.7633@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:39940 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752825AbZFHKFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 06:05:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was looking on configurations which involve vlans and bonds, where so
far at least two problems were identified and handled through "zero features
for a vlan over bond" @ http://marc.info/?l=linux-netdev&m=124445367820790 and
"findings/questions on vlans/bonds" @ http://marc.info/?l=linux-netdev&m=124052070128649

Basically, there are at least two possible configs in that respect, where I believe
we want both of them to be supported (bond over vlans, or vlans over bond). Using Jay's
patches I have come into being able to bringup both configs and collect the features
exposed to the TCP stack by the "higher" interface, see details below (2.6.30-rc8 +
patch from Jay for vlan over bond).

Basically, things seem to make sense (to me...) and maybe one question to raise here
if its correct for bonding over vlan to advertize vlan accacceleration capabilites (HW_VLAN_XXX)?

Another questions which is more related to the vlan (8021q) driver, is the lack of
vlan passthrough (e.g setting dev->vlan_features) by most of the drivers (all expect
for the Intel ones...) as pointed by Jay earlier on these threads. Is there a real
issue for other HW vendors to support this or its something that got fogotten through
the introduction of the vlan_features? I traced 289c79a4... "vlan: Use bitmask of
feature flags instead of seperate feature bits" be to the 8021q patch and ad31c402...
"ixbge: allow vlan devices to use TSO and TCP CSUM offload" et al to be Intel drivers
patches, but I didn't see other drivers support.

Patrick, assuming that vlans are common and people expect NIC to support TCP offloads
such as checksum and large-send, what is the actual gap here per your view?

Or.


device		features	legend
======================================
bond0		0x111383	& ~GSO |  (HW_VLAN_TX/RX/FILTER | LLTX)
eth0.4001	0x110803	& ~(IPV6_CSUM | HIGHDMA | HW_VLAN_TX/RX/FILTER |GRO)
eth0		0x114bb3	(SG | IP/V6_CSUM | HIGHDMA | HW_VLAN_TX/RX/FILTER |GSO|GRO|TSO|TSO6)

bond0.4001	0x110803	& ~(IPV6_CSUM | HIGHDMA | HW_VLAN_TX/RX/FILTER| LLTX)
bond0		0x1113b3	& ~(GSO | GRO) | LLTX
eth0		0x114bb3	(SG | IP/V6_CSUM | HIGHDMA | HW_VLAN_TX/RX/FILTER |GSO|GRO|TSO|TSO6)

00	#define NETIF_F_SG		1	/* Scatter/gather IO. */
01	#define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
02	#define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack. */
03	#define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
----------------------------------------------------------------------------------
04	#define NETIF_F_IPV6_CSUM	16	/* Can checksum TCP/UDP over IPV6 */
05	#define NETIF_F_HIGHDMA		32	/* Can DMA to high memory. */
06	#define NETIF_F_FRAGLIST	64	/* Scatter/gather IO. */
07	#define NETIF_F_HW_VLAN_TX	128	/* Transmit VLAN hw acceleration */
----------------------------------------------------------------------------------
08	#define NETIF_F_HW_VLAN_RX	256	/* Receive VLAN hw acceleration */
09	#define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
10	#define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
11	#define NETIF_F_GSO		2048	/* Enable software GSO. */
----------------------------------------------------------------------------------
12	#define NETIF_F_LLTX		4096	/* LockLess TX - deprecated. Please */
13	#define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
14	#define NETIF_F_GRO		16384	/* Generic receive offload */
15	#define NETIF_F_LRO		32768	/* large receive offload */
----------------------------------------------------------------------------------
16	#define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
17	#define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
18	#define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
19	#define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
----------------------------------------------------------------------------------
20	#define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
21
22
23
----------------------------------------------------------------------------------
24	#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
----------------------------------------------------------------------------------
