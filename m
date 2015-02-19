From: Alex Pilon <alp@alexpilon.ca>
Subject: [PATCH] Allow specifying bridge port STP state by name rather than
 number.
Date: Thu, 19 Feb 2015 14:27:46 -0500
Message-ID: <20150219192726.GA17950@alexpilon.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alexpilon.ca ([69.165.220.233]:32769 "EHLO alexpilon.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751840AbbBSThW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2015 14:37:22 -0500
Received: from alexpilon.ca (out-on-180.wireless.telus.com [207.219.69.180])
	by alexpilon.ca (Postfix) with ESMTPSA id CB6294007F
	for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 14:27:57 -0500 (EST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing behaviour forces one to memorize the integer constants for
STP port states.

    # bridge link set dev dummy0 state 3

This patch makes it possible to use the lowercased port state name.

    # bridge link set dev dummy0 state forwarding

Invalid non-integer inputs now cause exit with status -1.

Signed-off-by: Alex Pilon <alp@alexpilon.ca>
---
 bridge/link.c     | 14 +++++++++++++-
 man/man8/bridge.8 |  4 +++-
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/bridge/link.c b/bridge/link.c
index c8555f8..a7bd85f 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -316,7 +316,19 @@ static int brlink_modify(int argc, char **argv)
 			priority = atoi(*argv);
 		} else if (strcmp(*argv, "state") == 0) {
 			NEXT_ARG();
-			state = atoi(*argv);
+			char *endptr;
+			size_t nstates = sizeof(port_states) / sizeof(*port_states);
+			state = strtol(*argv, &endptr, 10);
+			if (!(**argv != '\0' && *endptr == '\0')) {
+				for (state = 0; state < nstates; state++)
+					if (strcmp(port_states[state], *argv) == 0)
+						break;
+				if (state == nstates) {
+					fprintf(stderr,
+						"Error: invalid STP port state\n");
+					exit(-1);
+				}
+			}
 		} else if (strcmp(*argv, "hwmode") == 0) {
 			NEXT_ARG();
 			flags = BRIDGE_FLAGS_SELF;
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index e344db2..68ad71e 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -207,7 +207,9 @@ droot port selectio algorithms.
 .TP
 .BI state " STATE "
 the operation state of the port.  This is primarily used by user space STP/RSTP
-implementation.  The following is a list of valid values:
+implementation.  One may enter a lowercased port state name, or one of the
+numbers below.  Negative inputs are ignored, and unrecognized names return an
+error.
 
 .B 0
 - port is DISABLED.  Make this port completely inactive.
-- 
2.3.0
