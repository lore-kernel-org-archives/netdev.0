From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 8/8] man: tc-vlan.8: Describe CONTROL option
Date: Tue, 22 Mar 2016 15:48:39 +0100
Message-ID: <1458658119-25881-9-git-send-email-phil@nwl.cc>
References: <1458658119-25881-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51551 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932827AbcCVOtL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 10:49:11 -0400
In-Reply-To: <1458658119-25881-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should be made generic and part of a common tc-actions man page.
Though leave it here for now to not confuse readers of the example which
uses it.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-vlan.8 | 56 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 55 insertions(+), 1 deletion(-)

diff --git a/man/man8/tc-vlan.8 b/man/man8/tc-vlan.8
index e650b72d3b395..4bfd72b129aaf 100644
--- a/man/man8/tc-vlan.8
+++ b/man/man8/tc-vlan.8
@@ -6,13 +6,17 @@ vlan - vlan manipulation module
 .in +8
 .ti -8
 .BR tc " ... " "action vlan" " { " pop " |"
-.IR PUSH " }"
+.IR PUSH " } [ " CONTROL " ]"
 
 .ti -8
 .IR PUSH " := "
 .BR push " [ " protocol
 .IR VLANPROTO " ]"
 .BI id " VLANID"
+
+.ti -8
+.IR CONTROL " := { "
+.BR reclassify " | " pipe " | " drop " | " continue " | " pass " }"
 .SH DESCRIPTION
 The
 .B vlan
@@ -50,5 +54,55 @@ for hexadecimal interpretation, etc.).
 .BI protocol " VLANPROTO"
 Choose the VLAN protocol to use. At the time of writing, the kernel accepts only
 .BR 802.1Q " or " 802.1ad .
+.TP
+.I CONTROL
+How to continue after executing this action.
+.RS
+.TP
+.B reclassify
+Restarts classification by jumping back to the first filter attached to this
+action's parent.
+.TP
+.B pipe
+Continue with the next action, this is the default.
+.TP
+.B drop
+Packet will be dropped without running further actions.
+.TP
+.B continue
+Continue classification with next filter in line.
+.TP
+.B pass
+Return to calling qdisc for packet processing. This ends the classification
+process.
+.RE
+.SH EXAMPLES
+The following example encapsulates incoming ICMP packets on eth0 from 10.0.0.2
+into VLAN ID 123:
+
+.RS
+.EX
+#tc qdisc add dev eth0 handle ffff: ingress
+#tc filter add dev eth0 parent ffff: pref 11 protocol ip \\
+	u32 match ip protocol 1 0xff flowid 1:1 \\
+	u32 match ip src 10.0.0.2 flowid 1:1 \\
+	action vlan push id 123
+.EE
+.RE
+
+Here is an example of the
+.B pop
+function: Incoming VLAN packets on eth0 are decapsulated and the classification
+process then restarted for the plain packet:
+
+.RS
+.EX
+#tc qdisc add dev eth0 handle ffff: ingress
+#tc filter add dev $ETH parent ffff: pref 1 protocol 802.1Q \\
+	u32 match u32 0 0 flowid 1:1 \\
+	action vlan pop reclassify
+.EE
+.RE
+
 .SH SEE ALSO
 .BR tc (8)
-- 
2.7.2
