From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix IXP4xx Ethernet RX with both IFF_ALLMULTI and
 IFF_PROMISC.
Date: Tue, 10 Mar 2015 13:32:34 -0400 (EDT)
Message-ID: <20150310.133234.1336283642054778106.davem@davemloft.net>
References: <m3pp8hvn8f.fsf@pm.waw.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbbCJRch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 13:32:37 -0400
In-Reply-To: <m3pp8hvn8f.fsf@pm.waw.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Halasa <khc@pm.waw.pl>
Date: Mon, 09 Mar 2015 23:07:28 +0100

> This long standing bug caused IFF_PROMISC to be ignored when
> IFF_ALLMULTI was requested.
>=20
> Also, without any multicast address configured, the driver will use
> device MAC address for the multicast filter, instead of accepting all
> inbound traffic.
>=20
> Signed-off-by: Krzysztof Ha=A9=A9asa <khc@pm.waw.pl>

One big consequence of not basing your patches on the correct tree, is
that you don't even notice when the bug you are fixing is already
fixed (whether partially or fully).

Please see:

commit f81edc6ac1e1e2e2cbe98bcd6ef5ebb7afb00807
Author: Derrick Pallas <pallas@meraki.com>
Date:   Wed Feb 18 00:50:25 2015 -0800

    ethernet/ixp4xx: prevent allmulti from clobbering promisc
   =20
    If both promisc and allmulti are set, promisc should trump allmulti=
 and
    disable the MAC filter; otherwise, the interface is not really prom=
isc.
   =20
    Previously, this code checked IFF_ALLMULTI prior to and without reg=
ard for
    IFF_PROMISC; if both were set, only multicast and direct unicast tr=
affic
    would make it through the filter.
   =20
    Signed-off-by: Derrick Pallas <pallas@meraki.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/eth=
ernet/xscale/ixp4xx_eth.c
index f7e0f0f..9e16a28 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -938,7 +938,7 @@ static void eth_set_mcast_list(struct net_device *d=
ev)
 	int i;
 	static const u8 allmulti[] =3D { 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 }=
;
=20
-	if (dev->flags & IFF_ALLMULTI) {
+	if ((dev->flags & IFF_ALLMULTI) && !(dev->flags & IFF_PROMISC)) {
 		for (i =3D 0; i < ETH_ALEN; i++) {
 			__raw_writel(allmulti[i], &port->regs->mcast_addr[i]);
 			__raw_writel(allmulti[i], &port->regs->mcast_mask[i]);
