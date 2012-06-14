From: Marco Berizzi <pupilla@hotmail.com>
Subject: ipsec and snat: mtu question
Date: Thu, 14 Jun 2012 15:48:02 +0200
Message-ID: <DUB108-W612A6245764ED5BB0ECC90B2F40@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc1-s22.dub0.hotmail.com ([157.55.0.221]:46559 "EHLO
	dub0-omc1-s22.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756167Ab2FNNsE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 09:48:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello everybody.

Kindly, I would like to ask for explanations
about a linux ipsec gateway snatting packets.

Here is the network schema.

customer private network 10.16.0.0/16
|
|
+ipsec customer gateway (checkpoint)
||
||---ipsec tunnel 10.16.0.0/16<->172.16.128.0/28 (des3/md5)
||=A0=A0 mtu=3D1446
||
++ linux_gw_snat ipsec gateway (SNAT all packets from 172.22.1.0/24 to =
172.16.128.1)
||=20
||---ipsec tunnel 10.16.0.0/16<->172.22.1.0/24 (aes/sha1/ipcomp)
||=A0=A0 mtu=3D1430
||
+linux_final ipsec gateway
|
|
client 172.22.1.50

SYN packet start behind the linux_final (172.22.1.50)
for 10.16.237.66 customer network. MSS is 1460 byte.
DF flag is set on outgoing packets.
Packet travel inside the ipsec tunnel: tunnel mtu is
1430
At the linux_gw_snat, the packet get decryped, snatted
(ip src change from 172.22.1.50 to 172.16.128.1) and
encryped again.
Packets are delivered to the checkpoint: tunnel mtu is
1446
Checkpoint deliver the decryped packet to 10.16.237.66
So far, so good.

At some point, 10.16.237.66 will send a 1500 byte
packet for 172.16.128.1: checkpoint will reply with
an icmp packet too large need to frag: mtu is 1446

10.16.237.66 will send back a 1446 byte packet to
the checkpoint which will encrypt and deliver to the
linux_gw_snat which will decrypt and deSNAT. Now
linux_gw_snat must send this 1446 byte packet to
172.22.1.50 but mtu is only 1430: packet will be
dropped (DF is set).

Now, IMHO, linux_gw_snat should send an imcp message
to 10.16.237.66 telling that max mtu is 1430, but I
don't see any icmp packet.
Is this the expected behaviour?

TIA

PS: linux_gw_snat is 3.3.5


 		 	   		  