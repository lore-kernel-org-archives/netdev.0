From: Seved Torstendahl <seved.torstendahl@netinsight.net>
Subject: PROBLEM: can't initiate empty  e100 eeprom
Date: Thu, 22 Mar 2007 11:56:44 +0100
Message-ID: <460260EC.2040806@netinsight.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([212.247.11.2]:1237 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S934105AbXCVLHC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 07:07:02 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When we receive new CPU bourds the EEPROM for one Ethernet port is unpr=
ogrammed
i.e. contains only FF. The first thing to do is to perform some accepen=
ce tests
and to set the MAC address on this port using the tool eepro100-diag.
This worked with earlier kernels but now the e100.c driver refuses to d=
o this.

The new module parameter eeprom_bad_csum_allow solves half the problem =
but
the check is_valid_ether_addr(...) at line 2669 fails and then the devi=
ce
is removed (our line number due to other changes).

Suggestion: let the module parameter control this test as in the patch =
below.
We don't want to use a DOS tool!

Regards
Seved Torstendahl

--=20
Seved Torstendahl               Net Insight AB
Senior SW System Architect      Box 42093, S-126 14 Stockholm, SWEDEN
tel: + 46 8 685 04 38           Visiting Address: V=E4stberga All=E9 9,=
 H=E4gersten
fax: + 46 8 685 04 20           http://www.netinsight.net


Index: e100.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
RCS file: /cvs/new-sw/kernel/kernel/drivers/net/e100.c,v
retrieving revision 1.2
diff -u -r1.2 e100.c
--- e100.c      23 Oct 2006 13:58:36 -0000      1.2
+++ e100.c      22 Mar 2007 10:09:22 -0000
@@ -2666,7 +2666,8 @@

         memcpy(netdev->dev_addr, nic->eeprom, ETH_ALEN);
         memcpy(netdev->perm_addr, nic->eeprom, ETH_ALEN);
-       if(!is_valid_ether_addr(netdev->perm_addr)) {
+       /* invalid MAC address (ff:ff:ff:ff:ff:ff) accepted, changed at=
 installation */
+       if (!eeprom_bad_csum_allow && (!is_valid_ether_addr(netdev->per=
m_addr))) {
                 DPRINTK(PROBE, ERR, "Invalid MAC address from "
                         "EEPROM, aborting.\n");
                 err =3D -EAGAIN;



