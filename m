From: "Dmitry Semyonov" <dmitry_sem@mail.ru>
Subject: ethernet patch
Date: Tue, 2 Mar 2004 23:46:37 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002701c40097$bcc3d970$0107a8c0@dmitry>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0019_01C400B0.9A46C5B0"
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0019_01C400B0.9A46C5B0
Content-Type: text/plain;
	charset="koi8-r"
Content-Transfer-Encoding: 7bit

Hello,
It seems there is a problem in the network layer of the 2.6.3 kernel. When
IFF_NOARP is enabled on the device, the first outgoing packet is getting
lost.

I tried the following configuration: two computers are connected with the
network cable. On both sides ARP is switched off on the network adapters,
and MAC addresses are configured manually using the arp utility. When I ping
one computer from another, I am getting ping replies only starting from the
third one. The reason is the following: network layer is caching hardware
(ethernet) headers. When I send a packet, this cache is examined for the
proper header. If it is not found, the arp table is examined too. The data
from the arp table is used for constructing the header for the packet
(eth_header() in eth.c) and creating a cache entry (eth_hard_header() in
eth.c). The cache entry is created correctly, but the header for outgoing
packet in case of IFF_NOARP switched on the device is filled with zero
destination address (MAC). So this packet is then lost. Next time the cache
entry is used, and the packets are send correctly. So when I am pinging one
computer from another the first ping request is lost so there is no answer
for it. The second ping request gets to the other computer, and it sends a
reply, wich is lost on the other side. And only for the third packet I get a
reply from the other computer.

This causes for example internet pages open very slowly on the links with
ARP turned off, because the first request is lost, and it takes a while when
the client resends it.

Please, include the attached patch in the kernel. It fixes this problem on
the 2.6.3 kernel. The same problem is in the 2.4.18 kernel. I verified it on
both 2.6.3 and 2.4.18 kernels and they work fine after the correction.

Thank you.

Dmitry

------=_NextPart_000_0019_01C400B0.9A46C5B0
Content-Type: application/octet-stream;
	name="patch-2.6.3-ethernet"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="patch-2.6.3-ethernet"

--- linux-2.6.3/net/ethernet/eth.c	2004-02-18 06:58:03.000000000 +0300=0A=
+++ linux-2.6.3-patched/net/ethernet/eth.c	2004-03-02 21:15:46.000000000 =
+0300=0A=
@@ -31,6 +31,7 @@=0A=
  *				  older network drivers and IFF_ALLMULTI.=0A=
  *	Christer Weinigel	: Better rebuild header message.=0A=
  *             Andrew Morton    : 26Feb01: kill ether_setup() - use =
netdev_boot_setup().=0A=
+ *             Dmitry Semenov   : 29Feb04: eth_header() - bug fix for =
IFF_NOARP devices=0A=
  *=0A=
  *		This program is free software; you can redistribute it and/or=0A=
  *		modify it under the terms of the GNU General Public License=0A=
@@ -101,7 +102,7 @@=0A=
 	 *	Anyway, the loopback-device should never use this function... =0A=
 	 */=0A=
 =0A=
-	if (dev->flags & (IFF_LOOPBACK|IFF_NOARP)) =0A=
+	if (dev->flags & IFF_LOOPBACK) =0A=
 	{=0A=
 		memset(eth->h_dest, 0, dev->addr_len);=0A=
 		return ETH_HLEN;=0A=

------=_NextPart_000_0019_01C400B0.9A46C5B0--
