From: Rick Jones <rick.jones2@hp.com>
Subject: [PATCH] Make possible speeds known to ethtool
Date: Wed, 7 Jan 2009 18:03:31 -0800 (PST)
Message-ID: <200901080203.SAA19103@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=X-roman8
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:28742 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755523AbZAHCDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 21:03:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Certain Broadcom 10Gb Ethernet solutions (e.g. the 57711E) can have a
10Gb port split into multiple virtual NICs each with an instance of
the bnx2x driver.  These virtual NICs can be configured for any speed
which is an integer multiple of 100 Mb/s from 100 to 10,000 Mbit/s
inclusive.  Since this is "normal" for such systems an "Unknown!" is
not indicated.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Rather than make a wholesale change to the existing "speed vetting"
code, it seemed least invasive to escape-out to a new routine in the
default case.  Should other "unfamiliar" speeds surface in the future
the checks can be put there.

Where the original would say this:

	Speed: Unknown! (1600)

for a FlexNIC link set to 1600 Mbit/s the changed version will
say:

	Speed: 1600Mb/s

There is presently no way to alter this speed setting from within the
host, so there is no need/point to altering the ethtool "set" path.

--- ethtool.c.orig	2008-11-17 11:53:40.000000000 -0800
+++ ethtool.c	2008-11-17 13:14:55.000000000 -0800
@@ -806,6 +806,14 @@ static void dump_advertised(struct ethto
 		fprintf(stdout, "No\n");
 }
 
+static void vet_unfamiliar_speed(struct ethtool_cmd *ep)
+{
+	if ((!ep->speed) || (ep->speed % 100))
+		fprintf(stdout, "Unknown! (%i)\n", ep->speed);
+	else
+		fprintf(stdout,"%dMb/s\n",ep->speed); 
+}
+
 static int dump_ecmd(struct ethtool_cmd *ep)
 {
 	dump_supported(ep);
@@ -829,7 +837,7 @@ static int dump_ecmd(struct ethtool_cmd 
 		fprintf(stdout, "10000Mb/s\n");
 		break;
 	default:
-		fprintf(stdout, "Unknown! (%i)\n", ep->speed);
+		vet_unfamiliar_speed(ep);
 		break;
 	};
 
