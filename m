From: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Subject: [PATCH] 3Com PCI 3c905 causes annoying pci_set_power_state() messages
Date: Mon, 07 May 2007 09:30:23 +0200
Message-ID: <87y7k1jdkg.fsf@obelix.mork.no>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43300 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105AbXEGHoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 03:44:04 -0400
Received: from obelix.mork.no (Debian-exim@obelix.mork.no [148.122.252.2])
	by canardo.mork.no (8.13.8/8.13.8) with ESMTP id l477URRu001182
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 7 May 2007 09:30:28 +0200
Received: from bjorn by obelix.mork.no with local (Exim 4.63)
	(envelope-from <bjorn@mork.no>)
	id 1Hkxfr-0004Q6-NA
	for netdev@vger.kernel.org; Mon, 07 May 2007 09:30:23 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

[previously posted to linux-net@vger.kernel.org, but resent here after a
helpful hint that this is the proper list for such messages.  Thanks]

I don't know if this is the correct place for 3c59x bugs.  Couldn't find
a maintainer entry for it.  Please redirect as appropriate.

pci_set_power_state() is a bit weird, causing a failure if a device
doesn't support PM and the driver tries to

 1) save it's power_state,=20
 2) wake up and do something, and=20
 3) then reset to the saved state.

The 3c59x driver does this in it's ioctl function.


pci_set_power_state() will never set current_state for such devices,
causing them to remain in PCI_UNKNOWN (5) forever.  But if you try to
set the state to PCI_UNKNOWN, bounding will kick in, limiting the state
to PCI_D3hot (3).  Then pci_set_power_state() will complain because=20
PCI_D3hot < current_state, printing useless messages like this:

 pci_set_power_state(): 0000:00:09.0: state=3D3, current state=3D5
 pci_set_power_state(): 0000:00:09.0: state=3D3, current state=3D5

and returning -EINVAL.

I believe this is wrong because pci_set_power_state() is supposed to
return -EIO if device does not support PCI PM.

But the drivers should probably also take care, not to call=20
pci_set_power_state() requesting PCI_UNKNOWN as the new state.
The attached patch against 2.6.21.1 fixes this for 3c905.


Bj=F8rn


--=-=-=
Content-Type: text/x-diff
Content-Disposition: inline; filename=linux-2.6.21.1.3c59x.c.diff

--- linux-2.6.21.1/drivers/net/3c59x.c.orig	2007-04-27 14:18:23.000000000 +0200
+++ linux-2.6.21.1/drivers/net/3c59x.c	2007-05-05 00:00:41.000000000 +0200
@@ -2903,7 +2903,7 @@
 	unsigned long flags;
 	int state = 0;
 
-	if(VORTEX_PCI(vp))
+	if(VORTEX_PCI(vp) && pci_find_capability(VORTEX_PCI(vp), PCI_CAP_ID_PM)) 
 		state = VORTEX_PCI(vp)->current_state;
 
 	/* The kernel core really should have pci_get_power_state() */

--=-=-=--
