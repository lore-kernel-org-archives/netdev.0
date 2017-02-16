From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH 1/2] gianfar: Deal with link state changes during
 GFAR_RESETTING dev state
Date: Thu, 16 Feb 2017 17:41:47 +0000
Message-ID: <AM5PR0401MB2561F965F201D25076AE30AC965A0@AM5PR0401MB2561.eurprd04.prod.outlook.com>
References: <1486988529-24924-1-git-send-email-thomas.graziadei@omicronenergy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Graziadei <thomas.graziadei@omicronenergy.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0043.outbound.protection.outlook.com ([104.47.2.43]:9280
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932254AbdBPRlu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 12:41:50 -0500
In-Reply-To: <1486988529-24924-1-git-send-email-thomas.graziadei@omicronenergy.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Thomas Graziadei [mailto:thomas.graziadei@omicronenergy.com]
>Sent: Monday, February 13, 2017 2:22 PM
>To: claudiu.manoil@freescale.com; netdev@vger.kernel.org; linux-
>kernel@vger.kernel.org
>Cc: Thomas Graziadei <thomas.graziadei@omicronenergy.com>
>Subject: [PATCH 1/2] gianfar: Deal with link state changes during GFAR_RES=
ETTING
>dev state
>
>From: Thomas Graziadei <thomas.graziadei@omicronenergy.com>
>

[...]

>
>To resolve the issue adjust_link is called after every GFAR_RESETTING lock
>section. Adjust_link itself checks if anything has changed and updates the
>link accordingly.
>

Calling adjust_link() from the ethernet driver, even if only following devi=
ce reset /=20
reconfig sections, is racy - the phylib state machine may run adjust_link()=
 at the=20
same time or the phydev state may be inconsistent - and may end up in more=
=20
subtle link state issues.  It also defeats the purpose of the adjust link h=
ook, which=20
is to be called by the phylib state machine.

I had a look at this, and I don't think there is an easy fix in the driver =
for your case.=20
However, the workaround should be straight forward: wait for the link to st=
abilize=20
to the requested parameters before applying other device configuration chan=
ges=20
that require device reset (like rx timestamping).  Given that the PHYLIB st=
ate machine=20
changed its behavior since adjust_link() in gianfar was last modified (i.e.=
 it used to be called
periodically before, from RUNNING<->CHANGELINK states) and given that there=
 is a good part=20
of legacy code in the current adjust_link() implementation, I think that dr=
iver part needs=20
considerable rework to correctly cover this usecase as well.

Thanks.
Claudiu
