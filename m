From: mdsmith@partychief.com
Subject: Marvell DSA switch 88E6165 - CPU port in PHY mode
Date: Sun, 04 Mar 2012 19:09:10 +0100
Message-ID: <380acbbedb5de9bbaa01735b22eacc10@partychief.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpauth-vit.online.net ([88.190.253.76]:51582 "EHLO
	smtpauth-vit.online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518Ab2CDSJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 13:09:14 -0500
Received: from [88.190.253.75] (helo=rc.online.net)
	by smtpauth-vit.online.net with esmtpa (Exim 4.71)
	(envelope-from <mdsmith@partychief.com>)
	id 1S4Frq-000333-VN
	for netdev@vger.kernel.org; Sun, 04 Mar 2012 19:09:11 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello - have a question about the net/dsa driver code, how does one=20
bring up the CPU connected port on the switch when it isn't in RGMII=20
mode, i.e. with the built-in GPHY enabled.

Normally (at least according to Marvell documentation, existing=20
reference designs and Lennert's DSA driver code) the CPU Ethernet=20
interface is connected to the switch port as RGMII. Due to a hardware=20
design constraint our new platform has the following arrangement - both=
=20
Ethernet ports on the Kirkwood 6282 SoC are wired to a 1121 dual phy=20
(this is a system on module), the only way to connect to GE00 & GE01 is=
=20
via a copper interface. Reading the data sheet for the 6165 switch chip=
=20
we noticed that Port 4 can be configured as a copper interface using th=
e=20
built-in PHY (using P4_MODE[2:0]) so it seemed that the configuration=20
described below is feasible:

+-----------+          +-----------+
|           |          |           |
|           |   RGMII  |           | PHY
|       GE00+----------+           +--------------------------=20
1000baseT MDI eth0
|           |          |  88E1121R |
|           |          |  dual phy |       +-----------+
|           |   RGMII  |           | PHY  4|          0+------=20
1000baseT MDI lan0
|       GE01+----------+           +-------+  88E6165 1+------=20
1000baseT MDI lan1
|           |          |           |       |  switch  2+------=20
1000baseT MDI lan2
| 88F6282   |          |           |       |          3+------=20
1000baseT MDI lan3
| SoC       |          |           |       |  port5    |
|           |          | MDC/MDIO  |       |  disabled |
|        SMI+----------+[0:1]------+-------+[8]        |
|           |          |           |       |           |
+-----------+          +-----------+       +-----------+

To summarize:
- GE00's PHY is directly wired to an RJ45, this interface works fine.
- GE01's PHY is wired to switch port 4 (hardware strapped to GPHY=20
mode), cannot bring this link up.
- SMI bus is shared between the 1121 dual PHY and the 6165 switch, we=20
can talk to both chips fine (6165 via indirect register access)

I believe my Kirkwood platform initialization code is good as the=20
kernel finds GE00, GE01 and the switch. I did have to tweak the=20
mach-orion/common.c platform code slightly to associate GE01 with the=20
switch CPU port (d->netdev =3D &orion_ge01.dev;). Relevant kernel outpu=
t=20
(I have eth0 plugged into an upstream switch and lan0 connected to=20
another external standalone switch):

mv643xx_eth: MV-643xx 10/100/1000 ethernet driver version 1.4
mv643xx_eth smi: probed
mv643xx_eth_port mv643xx_eth_port.0: eth0: port 0 with MAC address=20
00:50:43:22:2
6:29
mv643xx_eth_port mv643xx_eth_port.1: eth1: port 0 with MAC address=20
00:50:43:72:2
6:29
<snip>
eth1[0]: detected a Marvell 88E6165 switch
dsa slave smi: probed
<snip>
ADDRCONF(NETDEV_UP): eth0: link is not ready
<snip>
mv643xx_eth_port mv643xx_eth_port.0: eth0: link up, 1000 Mb/s, full=20
duplex, flow
control disabled
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
<snip>
ADDRCONF(NETDEV_UP): eth1: link is not ready
<snip>
lan0: link up, 1000 Mb/s, full duplex, flow control disabled
ADDRCONF(NETDEV_CHANGE): lan0: link becomes ready

I see eth0 come up, good. I don't see eth1 come up which means that the=
=20
6165 switch Port 4 is not up. I see lan0 come up when I plug it into an=
=20
external switch.

mii-tool confirms that eth1 has no link.

root@testme:~# mii-tool -v eth1
eth1: 10 Mbit, full duplex, no link
product info: vendor 00:50:43, model 11 rev 3
basic mode:   10 Mbit, full duplex
basic status: no link
capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD=20
10baseT-FD 10baseT-HD
advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
root@testme:~# mii-tool -v lan0
lan0: negotiated 1000baseT-FD flow-control, link ok
product info: vendor 00:50:43, model 11 rev 1
basic mode:   autonegotiation enabled
basic status: autonegotiation complete, link ok
capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD=20
10baseT-FD 10baseT-HD
advertising:  1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD=20
10baseT-HD
link partner: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD=20
10baseT-FD 10baseT-HD flow-control

I've gone through the DSA code and cannot see exactly where one can=20
modify the CPU connected port to be PHY instead of RGMII. Nearest I=20
could find was in mv88e6123_61_65_setup_port where various registers ar=
e=20
written to to initialize the different ports, there is a reference to=20
forcing the CPU connected port to 1000Mb/s full duplex so I thought it=20
would be logical to add some register writes to power up the PHY.=20
However this still doesn't bring the PHY up...

Any ideas on how I can bring my board up correctly?
Or is this just not possible with this hardware configuration? I find=20
it hard to believe because DSA switches can be daisy chained across any=
=20
port using copper (or other media).

thanks for your help=E2=80=A6
Matthew D. Smith
