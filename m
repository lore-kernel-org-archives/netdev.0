From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net: e100: ucode is optional in some cases
Date: Thu, 19 Jul 2012 11:33:13 +0200
Message-ID: <1342690393-18459-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:50722 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753684Ab2GSJdd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 05:33:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  commit 9ac32e1b firmware: convert e100 driver to request_firmware()

did a straight conversion of the in-driver ucode to external
files.  This introduced the possibility of the driver failing
to enable an interface due to missing ucode. There was no
evaluation of the importance of the ucode at the time.

Based on the information available from

 http://downloadmirror.intel.com/5154/eng/e100.htm
 http://www.freebsd.org/cgi/cvsweb.cgi/src/sys/dev/fxp/rcvbundl.h?rev=3D=
HEAD;content-type=3Dtext%2Fplain

we can assume that the ucode implements the "CPU Cycle Saver"
feature on the supported adapters.  Although generally wanted,
this is an optional feature.  The ucode source is not
available,  preventing it from being included in free
distributions.  This creates unnecessary problems for the end
users. Doing a network install based on a free distribution
installer requires the user to download and insert the ucode
into the installer.

Making the ucode optional when possible improves the user
experience and driver usability.

The ucode for some adapters include a bugfix, making it
essential.  We continue to fail for these adapters unless the
ucode is available.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
This was inspired by a recent bad experience trying to install
Debian wheezy on an older laptop using a Debian netboot image.=20
The image does of course not include any of the ucode files
due to the missing source.  The installer supports inserting
firmware from a floppy or other medium, but I find that to be
unnecessary hassle given that the device can work without it.



 drivers/net/ethernet/intel/e100.c |   41 +++++++++++++++++++++++++++++=
--------
 1 file changed, 32 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/i=
ntel/e100.c
index ada720b..81670d8 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -1249,20 +1249,36 @@ static const struct firmware *e100_request_firm=
ware(struct nic *nic)
 	const struct firmware *fw =3D nic->fw;
 	u8 timer, bundle, min_size;
 	int err =3D 0;
+	bool required =3D false;
=20
 	/* do not load u-code for ICH devices */
 	if (nic->flags & ich)
 		return NULL;
=20
-	/* Search for ucode match against h/w revision */
-	if (nic->mac =3D=3D mac_82559_D101M)
+	/* Search for ucode match against h/w revision
+	 *
+	 * The FIRMWARE_D102E ucode includes both CPUSaver and
+	 *
+	 *    "fixes for bugs in the B-step hardware (specifically, bugs
+	 *     with Inline Receive)."
+	 *
+	 * according to
+	 * http://www.freebsd.org/cgi/cvsweb.cgi/src/sys/dev/fxp/rcvbundl.h?r=
ev=3DHEAD;content-type=3Dtext%2Fplain
+	 * So we must fail if it cannot be loaded.
+	 *
+	 * The other microcode files are only required for the optional
+	 * CPUSaver feature.  Nice to have, but no reason to fail.
+	 */
+	if (nic->mac =3D=3D mac_82559_D101M) {
 		fw_name =3D FIRMWARE_D101M;
-	else if (nic->mac =3D=3D mac_82559_D101S)
+	} else if (nic->mac =3D=3D mac_82559_D101S) {
 		fw_name =3D FIRMWARE_D101S;
-	else if (nic->mac =3D=3D mac_82551_F || nic->mac =3D=3D mac_82551_10)
+	} else if (nic->mac =3D=3D mac_82551_F || nic->mac =3D=3D mac_82551_1=
0) {
 		fw_name =3D FIRMWARE_D102E;
-	else /* No ucode on other devices */
+		required =3D true;
+	} else { /* No ucode on other devices */
 		return NULL;
+	}
=20
 	/* If the firmware has not previously been loaded, request a pointer
 	 * to it. If it was previously loaded, we are reinitializing the
@@ -1273,10 +1289,17 @@ static const struct firmware *e100_request_firm=
ware(struct nic *nic)
 		err =3D request_firmware(&fw, fw_name, &nic->pdev->dev);
=20
 	if (err) {
-		netif_err(nic, probe, nic->netdev,
-			  "Failed to load firmware \"%s\": %d\n",
-			  fw_name, err);
-		return ERR_PTR(err);
+		if (required) {
+			netif_err(nic, probe, nic->netdev,
+				  "Failed to load firmware \"%s\": %d\n",
+				  fw_name, err);
+			return ERR_PTR(err);
+		} else {
+			netif_info(nic, probe, nic->netdev,
+				   "CPUSaver disabled. Needs \"%s\": %d\n",
+				   fw_name, err);
+			return NULL;
+		}
 	}
=20
 	/* Firmware should be precisely UCODE_SIZE (words) plus three bytes
--=20
1.7.10.4
