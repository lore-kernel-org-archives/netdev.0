From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: [PATCH] atl1: fix oops when changing tx/rx ring params
Date: Mon, 27 Dec 2010 09:54:02 -0600
Message-ID: <20101227095402.76f98027@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?B?VPVudQ==?= Raitviir <jussuf@linux.ee>,
	Luca Tettamanti <kronos.it@gmail.com>,
	Chris Snook <chris.snook@gmail.com>, netdev@vger.kernel.org,
	Xiong Huang <Xiong.Huang@Atheros.com>, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:33995 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754254Ab0L0PyH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Dec 2010 10:54:07 -0500
Received: by gyb11 with SMTP id 11so3501608gyb.19
        for <netdev@vger.kernel.org>; Mon, 27 Dec 2010 07:54:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3f5a2a713aad28480d86b0add00c68484b54febc zeroes out the statisti=
cs
message block (SMB) and coalescing message block (CMB) when adapter rin=
g
resources are freed.  This is desirable behavior, but, as a side effect=
,
the commit leads to an oops when atl1_set_ringparam() attempts to alter
the number of rx or tx descriptors in the ring buffer (by using ethtool
-G, for example).  We don't want SMB or CMB to change during this
operation.

Modify atl1_set_ringparam() to preserve SMB and CMB when changing ring
parameters.

Cc: stable@kernel.org
Signed-off-by: Jay Cliburn <jcliburn@gmail.com>
Reported-by: T=F5nu Raitviir <jussuf@linux.ee>
---
 drivers/net/atlx/atl1.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index def8df8..6d4f051 100644
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
@@ -3544,11 +3546,20 @@ static int atl1_set_ringparam(struct net_device=
 *netdev,
 		adapter->rrd_ring =3D rrd_old;
 		adapter->tpd_ring =3D tpd_old;
 		adapter->ring_header =3D rhdr_old;
+		/*
+ 		 * Save SMB and CMB, since atl1_free_ring_resources
+ 		 * will clear them as a result of commit
+ 		 * 3f5a2a713aad28480d86b0add00c68484b54febc
+ 		 */
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

