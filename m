From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: [PATCH] atl1: fix oops when changing tx/rx ring params
Date: Sat, 1 Jan 2011 09:02:12 -0600
Message-ID: <20110101090212.7149010d@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, stable@kernel.org, jussuf@linux.ee,
	chris.snook@gmail.com, kronos.it@gmail.com, Xiong.Huang@Atheros.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:44076 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752Ab1AAPCP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 10:02:15 -0500
Received: by gwj20 with SMTP id 20so5822094gwj.19
        for <netdev@vger.kernel.org>; Sat, 01 Jan 2011 07:02:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3f5a2a713aad28480d86b0add00c68484b54febc zeroes out the statisti=
cs
message block (SMB) and coalescing message block (CMB) when adapter rin=
g
resources are freed.  This is desirable behavior, but, as a side effect=
,
the commit leads to an oops when atl1_set_ringparam() attempts to alter
the number of rx or tx elements in the ring buffer (by using ethtool
-G, for example).  We don't want SMB or CMB to change during this
operation.

Modify atl1_set_ringparam() to preserve SMB and CMB when changing ring
parameters.

Cc: stable@kernel.org
Signed-off-by: Jay Cliburn <jcliburn@gmail.com>
Reported-by: T=F5nu Raitviir <jussuf@linux.ee>
---
 drivers/net/atlx/atl1.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 5336310..3acf512 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -3504,6 +3504,8 @@ static int atl1_set_ringparam(struct net_device *=
netdev,
 	struct atl1_rfd_ring rfd_old, rfd_new;
 	struct atl1_rrd_ring rrd_old, rrd_new;
 	struct atl1_ring_header rhdr_old, rhdr_new;
+	struct atl1_smb smb;
+	struct atl1_cmb cmb;
 	int err;
=20
 	tpd_old =3D adapter->tpd_ring;
@@ -3544,11 +3546,19 @@ static int atl1_set_ringparam(struct net_device=
 *netdev,
 		adapter->rrd_ring =3D rrd_old;
 		adapter->tpd_ring =3D tpd_old;
 		adapter->ring_header =3D rhdr_old;
+		/*
+		 * Save SMB and CMB, since atl1_free_ring_resources
+		 * will clear them.
+		 */
+		smb =3D adapter->smb;
+		cmb =3D adapter->cmb;
 		atl1_free_ring_resources(adapter);
 		adapter->rfd_ring =3D rfd_new;
 		adapter->rrd_ring =3D rrd_new;
 		adapter->tpd_ring =3D tpd_new;
 		adapter->ring_header =3D rhdr_new;
+		adapter->smb =3D smb;
+		adapter->cmb =3D cmb;
=20
 		err =3D atl1_up(adapter);
 		if (err)
--=20
1.7.2.3

