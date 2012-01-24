From: "Bishop, Mark" <Mark.Bishop@cooperindustries.com>
Subject: [BUG] smsc911x.c - writes are too fast into TX FIFO
Date: Tue, 24 Jan 2012 14:03:30 -0500
Message-ID: <5D308BD40154E4439D82454FE483A50205C33795@EVS4.nam.ci.root>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Onstine, Elliott" <Elliott.Onstine@cooperindustries.com>,
	"Bishop, Mark" <Mark.Bishop@cooperindustries.com>
To: <netdev@vger.kernel.org>, <janet.mccreary@g2sales.com>,
	<Thomas.Walter@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooperlighting-sw.cooperlighting.com ([216.130.131.68]:19427
	"EHLO cooperlighting-sw.cooperlighting.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751106Ab2AXTD7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jan 2012 14:03:59 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been running into all kinds of issues with this part (LAN9215) and=
 the final issue I've had was with the linux driver (smsc911x.c).

I was getting the "eth1: smsc911x_phy_check_loopbackpkt: Failed to tran=
smit during loopback test" and traced the issue to the PHY TX FIFO.

In an effort to try and figure out what was going on with the TX FIFO, =
I added the line of code between line 262 and 263 (Linux 3.3rc1).  Afte=
r I added it, things started working. =20

I do not see any min/max timing requirements for FIFO writes in the dat=
asheet.  I've included a SMSC technical contact in the hopes that he ca=
n get the factory to comment on those ranges.

Note: I am working on an embedded controller project based off 2.6, but=
 the driver looks essentially the same concerning this issue between ve=
rsions.

Adding a wait state, while quick and dirty doesn't seem like a long ter=
m solution.  I would appreciate any comments on a better way to resolve=
 it.

Thomas, the original diver was written back in Nov 2008 by Steve Glendi=
nning @ SMSC.  Not sure he is even still there, but if he is, he might =
be able to provide some insight.

Original code (line numbers from 3.3rc1):

smsc911x_tx_writefifo(...
=2E..
260 =A0=A0=A0=A0=A0=A0=A0=A0if=A0(pdata->config.flags=A0&=A0SMSC911X_US=
E_16BIT)=A0{
261 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0while=A0(wordcount-=
-)
262 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0__smsc911x_reg_write(pdata,=A0TX_DATA_FIFO,=A0*buf++);
263 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0goto=A0out;
264 =A0=A0=A0=A0=A0=A0=A0=A0}
265=20
266 =A0=A0=A0=A0=A0=A0=A0=A0BUG();


Modified Code:
260         if (pdata->config.flags & SMSC911X_USE_16BIT) {
261                 while (wordcount--){
262                         __smsc911x_reg_write(pdata, TX_DATA_FIFO, *=
buf++);
				    SMSC_TRACE(HW, "TX_STATUS_PEEK WRITE FIFO: 0x%x",smsc911x_reg_r=
ead(pdata, TX_STATUS_FIFO_PEEK));
			 }=09
263                 goto out;
264         }
265
266         BUG();

This was brought up a few years ago but no solution was provided to the=
 "eth1: smsc911x_phy_check_loopbackpkt: Failed to transmit during loopb=
ack test":

http://markmail.org/thread/lvt4l3hyufxbqzfb#query:+page:1+mid:lvt4l3hyu=
fxbqzfb+state:results

and adding the wait state could be one way to resolve this for some peo=
ple who are experiencing it.
