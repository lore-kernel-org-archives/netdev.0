From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAPI: Polling function requesting extra calls - difference
 between 3.18.11 and 4.0.0
Date: Thu, 23 Apr 2015 11:33:58 -0700
Message-ID: <1429814038.22254.80.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACna6rzMMUA_MQemYyP93+TjP4aocL1WaYQUJFwQm3+DLNAefg@mail.gmail.com>
	 <1429813732.22254.78.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>
To: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:36665 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbbDWSeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 14:34:00 -0400
Received: by igblo3 with SMTP id lo3so30694714igb.1
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 11:33:59 -0700 (PDT)
In-Reply-To: <1429813732.22254.78.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-23 at 11:28 -0700, Eric Dumazet wrote:
> On Thu, 2015-04-23 at 20:18 +0200, Rafa=C5=82 Mi=C5=82ecki wrote:
>=20
> >=20
> > Can you help us with this, please? Does bgmac use NAPI incorrectly?
> > Were there some important changes in 3.19 or 4.0?
> >=20
>=20
> Right they were important changes in NAPI indeed :
>=20
> 3b47d30396ba net: gro: add a per device gro flush timer
> d75b1ade567f net: less interrupt masking in NAPI
> bc9ad166e38a net: introduce napi_schedule_irqoff()
>=20
> This requested some fixes in various drivers :
>=20
> commit f31ec95fa19e07a8beebcc0297284f23aa57967e
> commit 24e579c8898aa641ede3149234906982290934e5
> commit 6088beef3f7517717bd21d90b379714dd0837079
> commit f104fedc0da126abe93dd0f4a9fa13e5133bf9df
> commit 7a05dc64e2e4c611d89007b125b20c0d2a4d31a5
> commit 001ce546bb537bb5b7821f05633556a0c9787e32
> commit 3079c652141f9d6377417a7e8fd650c9948df65e
> commit 8acdf999accfd95093db17f33a58429a38782060
> commit 6a6dc08ff6395f58be3ee568cb970ea956f16819
>=20

It looks like following fix is needed :

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index de77d3a74abc..21e3c38c7c75 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1260,7 +1260,7 @@ static int bgmac_poll(struct napi_struct *napi, i=
nt weight)
=20
 	/* Poll again if more events arrived in the meantime */
 	if (bgmac_read(bgmac, BGMAC_INT_STATUS) & (BGMAC_IS_TX0 | BGMAC_IS_RX=
))
-		return handled;
+		return weight;
=20
 	if (handled < weight) {
 		napi_complete(napi);
