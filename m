From: Mandeep Singh Baines <msb@google.com>
Subject: ethtool: add support for block writing of EEPROMs
Date: Wed, 18 Jun 2008 10:38:02 -0700
Message-ID: <20080618173802.GA13834@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nil@google.com, thockin@google.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:29840 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464AbYFRRjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 13:39:07 -0400
Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m5IHd0ob031059
	for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 18:39:01 +0100
Received: from rv-out-0506.google.com (rvbg37.prod.google.com [10.140.83.37])
	by zps76.corp.google.com with ESMTP id m5IHcx1r014380
	for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 10:39:00 -0700
Received: by rv-out-0506.google.com with SMTP id g37so6065470rvb.35
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 10:38:59 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EEPROM write only supports byte writing. Add support for writing
an arbitrary number of bytes at an arbitrary offset.

Signed-off-by: Mandeep Singh Baines <msb@google.com>
---
 ethtool.8 |   12 ++++++++----
 ethtool.c |   58 ++++++++++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 52 insertions(+), 18 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index cc6a46e..90d160a 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -144,6 +144,8 @@ ethtool \- Display or change ethernet card settings
 .IR N ]
 .RB [ offset
 .IR N ]
+.RB [ length
+.IR N ]
 .RB [ value
 .IR N ]
 
@@ -265,10 +267,12 @@ length and offset parameters allow dumping certain portions of the EEPROM.
 Default is to dump the entire EEPROM.
 .TP
 .B \-E \-\-change\-eeprom
-Changes EEPROM byte for the specified ethernet device.  offset and value
-specify which byte and it's new value.  Because of the persistent nature
-of writing to the EEPROM, a device-specific magic key must be specified
-to prevent the accidental writing to the EEPROM.
+If value is specified, changes EEPROM byte for the specified ethernet device.
+offset and value specify which byte and it's new value. If value is not
+specified, stdin is read and written to the EEPROM. The length and offset
+parameters allow writing to certain portions of the EEPROM.
+Because of the persistent nature of writing to the EEPROM, a device-specific
+magic key must be specified to prevent the accidental writing to the EEPROM.
 .TP
 .B \-k \-\-show\-offload
 Queries the specified ethernet device for offload information.
diff --git a/ethtool.c b/ethtool.c
index a668b49..3fce21c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -163,6 +163,7 @@ static struct option {
     { "-E", "--change-eeprom", MODE_SEEPROM, "Change bytes in device EEPROM",
 		"		[ magic N ]\n"
 		"		[ offset N ]\n"
+		"		[ length N ]\n"
 		"		[ value N ]\n" },
     { "-r", "--negotiate", MODE_NWAY_RST, "Restart N-WAY negotation" },
     { "-p", "--identify", MODE_PHYS_ID, "Show visible port identification (e.g. blinking)",
@@ -264,8 +265,9 @@ static int geeprom_offset = 0;
 static int geeprom_length = -1;
 static int seeprom_changed = 0;
 static int seeprom_magic = 0;
-static int seeprom_offset = -1;
-static int seeprom_value = 0;
+static int seeprom_length = -1;
+static int seeprom_offset = 0;
+static int seeprom_value = EOF;
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -300,6 +302,7 @@ static struct cmdline_info cmdline_geeprom[] = {
 static struct cmdline_info cmdline_seeprom[] = {
 	{ "magic", CMDL_INT, &seeprom_magic, NULL },
 	{ "offset", CMDL_INT, &seeprom_offset, NULL },
+	{ "length", CMDL_INT, &seeprom_length, NULL },
 	{ "value", CMDL_INT, &seeprom_value, NULL },
 };
 
@@ -1920,22 +1923,49 @@ static int do_geeprom(int fd, struct ifreq *ifr)
 static int do_seeprom(int fd, struct ifreq *ifr)
 {
 	int err;
-	struct {
-		struct ethtool_eeprom eeprom;
-		u8 data;
-	} edata;
-
-	edata.eeprom.cmd = ETHTOOL_SEEPROM;
-	edata.eeprom.len = 1;
-	edata.eeprom.offset = seeprom_offset;
-	edata.eeprom.magic = seeprom_magic;
-	edata.data = seeprom_value;
-	ifr->ifr_data = (caddr_t)&edata.eeprom;
+	struct ethtool_drvinfo drvinfo;
+	struct ethtool_eeprom *eeprom;
+
+	drvinfo.cmd = ETHTOOL_GDRVINFO;
+	ifr->ifr_data = (caddr_t)&drvinfo;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0) {
+		perror("Cannot get driver information");
+		return 74;
+	}
+
+	if (seeprom_value != EOF)
+		seeprom_length = 1;
+
+	if (seeprom_length <= 0)
+		seeprom_length = drvinfo.eedump_len;
+
+	if (drvinfo.eedump_len < seeprom_offset + seeprom_length)
+		seeprom_length = drvinfo.eedump_len - seeprom_offset;
+
+	eeprom = calloc(1, sizeof(*eeprom)+seeprom_length);
+	if (!eeprom) {
+		perror("Cannot allocate memory for EEPROM data");
+		return 75;
+	}
+
+	eeprom->cmd = ETHTOOL_SEEPROM;
+	eeprom->len = seeprom_length;
+	eeprom->offset = seeprom_offset;
+	eeprom->magic = seeprom_magic;
+	eeprom->data[0] = seeprom_value;
+
+	/* Multi-byte write: read input from stdin */
+	if (seeprom_value == EOF)
+		eeprom->len = fread(eeprom->data, 1, eeprom->len, stdin);
+
+	ifr->ifr_data = (caddr_t)eeprom;
 	err = ioctl(fd, SIOCETHTOOL, ifr);
 	if (err < 0) {
 		perror("Cannot set EEPROM data");
-		return 87;
+		err = 87;
 	}
+	free(eeprom);
 
 	return err;
 }
-- 
1.5.2.5

