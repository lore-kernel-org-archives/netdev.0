From: weinholt@csbnet.se (=?utf-8?Q?G=C3=B6ran?= Weinholt)
Subject: Re: [Bugme-new] [Bug 30092] New: smsc911x.c drops long packets with VLAN tags
Date: Wed, 02 Mar 2011 15:07:21 +0100
Message-ID: <lnsjv58vl2.fsf@desktop3.csbnet.se>
References: <bug-30092-10286@https.bugzilla.kernel.org/>
	<20110301161547.13480e90.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.csbnet.se ([95.80.0.100]:36811 "EHLO mail2.csbnet.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138Ab1CBOQa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 09:16:30 -0500
In-Reply-To: <20110301161547.13480e90.akpm@linux-foundation.org> (Andrew
	Morton's message of "Tue, 1 Mar 2011 16:15:47 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> (switched to email.  Please respond via emailed reply-to-all, not via=
 the
> bugzilla web interface).
>
> On Mon, 28 Feb 2011 15:57:14 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D30092
>>=20
> Thanks.  Become famous, get more girls: send us a patch as per
> Documentation/SubmittingPatches :)

There's a register called VLAN1 that wasn't being configured. Setting i=
t
to 0x8100 fixes the problem I reported. There's also a VLAN2 register,
possibly meant for stacked VLANs, but the description in the datasheet
doesn't make sense to me, and I can't test stacked VLANs, so I'm not
going to change it.

Subject: [PATCH] net/smsc911x.c: Set the VLAN1 register to fix VLAN MTU=
 problem
=46rom: G=C3=B6ran Weinholt <weinholt@csbnet.se>

The smsc911x driver would drop frames longer than 1518 bytes, which is =
a
problem for networks with VLAN tagging. The VLAN1 tag register is used
to increase the legal frame size to 1522 when a VLAN tag is identified.

Signed-off-by: G=C3=B6ran Weinholt <weinholt@csbnet.se>
---
diff -uprN linux-2.6.36.4-vanilla/drivers/net/smsc911x.c linux-2.6.36.4=
/drivers/net/smsc911x.c
--- linux-2.6.36.4-vanilla/drivers/net/smsc911x.c	2011-02-18 00:14:38.0=
00000000 +0100
+++ linux-2.6.36.4/drivers/net/smsc911x.c	2011-03-02 14:29:11.884382251=
 +0100
@@ -1178,6 +1178,11 @@ static int smsc911x_open(struct net_devi
 	smsc911x_reg_write(pdata, HW_CFG, 0x00050000);
 	smsc911x_reg_write(pdata, AFC_CFG, 0x006E3740);
=20
+	/* Increase the legal frame size of VLAN tagged frames to 1522 bytes =
*/
+	spin_lock_irq(&pdata->mac_lock);
+	smsc911x_mac_write(pdata, VLAN1, ETH_P_8021Q);
+	spin_unlock_irq(&pdata->mac_lock);
+
 	/* Make sure EEPROM has finished loading before setting GPIO_CFG */
 	timeout =3D 50;
 	while ((smsc911x_reg_read(pdata, E2P_CMD) & E2P_CMD_EPC_BUSY_) &&



--=20
G=C3=B6ran Weinholt
Network Administrator
Chalmers Studentbost=C3=A4der (AS48514)
