From: =?iso-8859-1?Q?Esa-Pekka_Py=F6kkimies?=
	<esa-pekka.pyokkimies@stonesoft.com>
Subject: [PATCH] ethtool: Pause frame reporting fixes
Date: Tue, 24 May 2011 10:58:20 +0000
Message-ID: <42186456B4D1324A9EB53C74DBCBB1BB0657DE@HKI-EXC-1.stonesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hki-smtp-1a.stonesoft.com ([192.89.38.178]:44710 "EHLO
	hki-smtp-1a.stonesoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754896Ab1EXL1K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 07:27:10 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello. Our software needs to modify pause parameters dynamically.
For this to work reliably the SUPPORTED_Pause and SUPPORTED_Asym_Pause
flags need to be set correctly by the driver. As it turns out, some drivers
leave them at zero even though they implement pause frames.
This patch adds reporting for these flags to ethtool.
For some reason the current code reports ADVERTISED_Pause
but not SUPPORTED_Pause. Also there was a small bug
in the reporting for ADVERTISED_Pause.

Esa-Pekka Pyokkimies, Software Specialist, Stonesoft

 ethtool.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 34fe107..cf6c4b2 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1193,6 +1193,19 @@ static void dump_supported(struct ethtool_cmd *ep)
 		did1++; fprintf(stdout, "10000baseT/Full ");
 	}
 	fprintf(stdout, "\n");
+        
+	fprintf(stdout, "	Supported pause frame use: ");
+	if (mask & SUPPORTED_Pause) {
+		if (mask & SUPPORTED_Asym_Pause)
+			fprintf(stdout, "Receive-only\n");
+		else
+			fprintf(stdout, "Symmetric\n");
+	} else {
+		if (mask & SUPPORTED_Asym_Pause)
+			fprintf(stdout, "Transmit-only\n");
+		else
+			fprintf(stdout, "No\n");
+        }
 
 	fprintf(stdout, "	Supports auto-negotiation: ");
 	if (mask & SUPPORTED_Autoneg)
@@ -1255,10 +1268,10 @@ static void dump_advertised(struct ethtool_cmd *ep,
 
 	fprintf(stdout, "	%s pause frame use: ", prefix);
 	if (mask & ADVERTISED_Pause) {
-		fprintf(stdout, "Symmetric");
 		if (mask & ADVERTISED_Asym_Pause)
-			fprintf(stdout, " Receive-only");
-		fprintf(stdout, "\n");
+			fprintf(stdout, "Receive-only\n");
+                else
+			fprintf(stdout, "Symmetric\n");
 	} else {
 		if (mask & ADVERTISED_Asym_Pause)
 			fprintf(stdout, "Transmit-only\n");
