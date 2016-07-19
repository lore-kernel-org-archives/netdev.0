From: =?iso-8859-1?Q?Pommnitz_J=F6rg?= <Pommnitz@iabg.de>
Subject: IPv6 IPSec incompatibilities between 2.6.23 and 3.6.18 (and
 probably later)
Date: Tue, 19 Jul 2016 14:03:44 +0000
Message-ID: <DD56476BFBBCB94EA5C5CCFF543EBEC99A0DEB52@ExMbx1.iabg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.iabg.de ([62.245.167.132]:46218 "EHLO mail2.iabg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753599AbcGSOKB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 10:10:01 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail2.iabg.de (Mailserver 2 IABG OTN) with ESMTP id 7A0882A0491
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 16:03:25 +0200 (CEST)
Received: from [127.0.0.1] (helo=mail2.iabg.de)
	by localhost with ESMTP (eXpurgate 4.0.9)
	(envelope-from <Pommnitz@iabg.de>)
	id 578e332d-0430-7f0000012387-7f000001bc65-1
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 16:03:25 +0200
Received: from webmail.iabg.de (exhc1 [192.168.30.1])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail2.iabg.de (Mailserver 2 IABG OTN) with ESMTPS id 620CF2A032C
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 16:03:25 +0200 (CEST)
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
for years we have used the following manual IPsec rules to decrypt broa=
dcast (all host multicast) messages:

=3D=3D=3D=3D=3D snip =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

#!/bin/bash

IP6ANYADDR=3D::/0
IP6BCAST=3Dff0e::1
KEY=3D"0x7bef6ecaf06d29ef55b24aca6e19964b332e02e75be676a3"
IFNAME=3Dlan1
IP6ADDR=3Dfd01:1b10:1000::1
PREFIX6=3D64
SPI=3D0x1

ip link set dev ${IFNAME} up
ip addr add ${IP6ADDR}/${PREFIX6} dev ${IFNAME}
echo "flush; add ${IP6ADDR} ${IP6BCAST} esp ${SPI} -m tunnel -E aes-cbc=
 ${KEY};" | setkey -c
echo "spdflush; spdadd ${IP6ANYADDR} ${IP6BCAST} any -P in ipsec esp/tu=
nnel/${IP6ADDR}-${IP6BCAST}/require;" | setkey -c

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

The corresponding encryption rules still work perfectly fine:
=3D=3D=3D=3D=3D snip =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
#!/bin/bash


IP6ANYADDR=3D::/0
IP6BCAST=3Dff0e::1
KEY=3D"0x7bef6ecaf06d29ef55b24aca6e19964b332e02e75be676a3"
IFNAME=3Dlan1
IP6ADDR=3Dfd01:1b10:1000::2
PREFIX6=3D64
SPI=3D0x1

ip link set dev ${IFNAME} up
ip addr add ${IP6ADDR}/${PREFIX6} dev ${IFNAME}
echo "flush; add ${IP6ADDR} ${IP6BCAST} esp ${SPI} -m tunnel -E aes-cbc=
 ${KEY};" | setkey -c
echo "spdflush; spdadd ${IP6ANYADDR} ${IP6BCAST} any -P in ipsec esp/tu=
nnel/${IP6ADDR}-${IP6BCAST}/require;" | setkey -c
echo "spdadd ${IP6ANYADDR} ${IP6BCAST} any -P out ipsec esp/tunnel/${IP=
6ADDR}-${IP6BCAST}/require;" | setkey -c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Using "ping6 -I lan1 ff0e::1" I see outgoing ESP packets on the second =
host (e.g. with fd01:1b10:1000::2) with both, 2.6.23 and 3.6.18:

14:40:36.398471 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x5d4), length 136
14:40:37.398533 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x5d5), length 136
14:40:38.398596 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x5d6), length 136
14:40:39.398658 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x5d7), length 136
14:40:40.398721 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x5d8), length 136
14:40:41.398783 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x5d9), length 136
14:40:42.398846 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x5da), length 136


On the receiving side (e.g. fd01:1b10:1000::1) I see the decrypted pack=
ets with the 2.6.23 kernel:
18:17:58.517791 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x62c), length 136
18:17:58.517791 IP6 fd01:1b10:1000::2 > ff0e::1: ICMP6, echo request, s=
eq 119, length 64
18:17:59.517836 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x62d), length 136
18:17:59.517836 IP6 fd01:1b10:1000::2 > ff0e::1: ICMP6, echo request, s=
eq 120, length 64
18:18:00.517880 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x62e), length 136
18:18:00.517880 IP6 fd01:1b10:1000::2 > ff0e::1: ICMP6, echo request, s=
eq 121, length 64
18:18:01.518734 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x62f), length 136
18:18:01.518734 IP6 fd01:1b10:1000::2 > ff0e::1: ICMP6, echo request, s=
eq 122, length 64
18:18:02.518763 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x630), length 136
18:18:02.518763 IP6 fd01:1b10:1000::2 > ff0e::1: ICMP6, echo request, s=
eq 123, length 64
18:18:03.518790 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x631), length 136
18:18:03.518790 IP6 fd01:1b10:1000::2 > ff0e::1: ICMP6, echo request, s=
eq 124, length 64
but NOT with the newer kernel:
16:32:19.980862 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x98e), length 136
16:32:20.980925 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x98f), length 136
16:32:21.980987 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x990), length 136
16:32:22.981050 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x991), length 136
16:32:23.981112 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x992), length 136
16:32:24.981175 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x993), length 136
16:32:25.981237 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x994), length 136
16:32:26.981300 IP6 fd01:1b10:1000::2 > ff0e::1: ESP(spi=3D0x00000001,s=
eq=3D0x995), length 136


BTW, the equivalent IPv4 IPsec rules (basically 255.255.255.255 as broa=
dcast and 0.0.0.0/0 as any address works fine with both, 2.6.23 and 3.6=
=2E18.

Since my application depends on this, I'm kind of stuck. Is this a know=
n problem with a fix in a later kernel?


Thanks in advance and kind regards
  Joerg

________________________________
Industrieanlagen-Betriebsgesellschaft mbH

Sitz der Gesellschaft: Ottobrunn, Registergericht: Amtsgericht M=FCnche=
n, HRB 5499
Gesch=E4ftsf=FChrung: Prof. Dr.-Ing. Rudolf F. Schwarz
Vorsitzender des Aufsichtsrats: RA Engelbert Kupka MdL a.D.
