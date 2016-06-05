From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 resend PATCH 1/1] man: tc-ife.8: man page for ife action
Date: Sun,  5 Jun 2016 09:17:15 -0400
Message-ID: <1465132635-17117-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, lucasb@mojatatu.com, phil@nwl.cc,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34168 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbcFENR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 09:17:28 -0400
Received: by mail-io0-f196.google.com with SMTP id l9so16144879ioe.1
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 06:17:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Bates <lucasb@mojatatu.com>

Signed-off-by: Lucas Bates <lucasb@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-ife.8 | 117 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 117 insertions(+)
 create mode 100644 man/man8/tc-ife.8

diff --git a/man/man8/tc-ife.8 b/man/man8/tc-ife.8
new file mode 100644
index 0000000..7b3601e
--- /dev/null
+++ b/man/man8/tc-ife.8
@@ -0,0 +1,117 @@
+.TH "IFE action in tc" 8 "22 Apr 2016" "iproute2" "Linux"
+
+.SH NAME
+IFE - encapsulate/decapsulate metadata
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " ... " action ife"
+.I DIRECTION ACTION
+.RB "[ " dst
+.IR DMAC " ] "
+.RB "[ " src
+.IR SMAC " ] "
+.RB "[ " type
+.IR TYPE " ] "
+.R "[ "
+.IR CONTROL " ] "
+.RB "[ " index
+.IR INDEX " ] "
+
+.ti -8
+.IR DIRECTION " := { "
+.BR decode " | " encode " }"
+
+.ti -8
+.IR ACTION " := { "
+.BR allow " | " use " }"
+
+.ti -8
+.IR CONTROL " := { "
+.BR reclassify " | " use " | " pipe " | " drop " | " continue " | " ok " }"
+.SH DESCRIPTION
+The
+.B ife
+action allows for a sending side to encapsulate arbitrary metadata, which is
+then decapsulated by the receiving end. The sender runs in encoding mode and
+the receiver in decode mode. Both sender and receiver must specify the same
+ethertype. In the future, a registered ethertype may be available as a default.
+.SH OPTIONS
+.TP
+.B decode
+For the receiving side; decode the metadata if the packet matches.
+.TP
+.B encode
+For the sending side. Encode the specified metadata if the packet matches.
+.TP
+.B allow
+Encode direction only. Allows encoding specified metadata.
+.TP
+.B use
+Encode direction only. Enforce static encoding of specified metadata.
+.TP
+.BI dmac " DMAC"
+.TQ
+.BI smac " SMAC"
+Optional six byte destination or source MAC address to encode.
+.TP
+.BI type " TYPE"
+Optional 16-bit ethertype to encode.
+.TP
+.BI CONTROL
+Action to take following an encode/decode.
+.TP
+.BI index " INDEX"
+Assign a unique ID to this action instead of letting the kernel choose one
+automatically.
+.I INDEX
+is a 32bit unsigned integer greater than zero.
+.SH EXAMPLES
+
+On the receiving side, match packets with ethertype 0xdead and restart
+classification so that it will match ICMP on the next rule, at prio 3:
+.RS
+.EX
+# tc qdisc add dev eth0 handle ffff: ingress
+# tc filter add dev eth0 parent ffff: prio 2 protocol 0xdead \\
+	u32 match u32 0 0 flowid 1:1 \\
+	action ife decode reclassify
+# tc filter add dev eth0 parent ffff: priod 3 protocol ip \\
+	u32 match ip protocol 0xff flowid 1:1 \\
+	action continue
+.EE
+.RE
+
+Match with skb mark of 17:
+
+.RS
+.EX
+# tc filter add dev eth0 parent ffff: prio 4 protocol ip \\
+	handle 0x11 fw flowid 1:1 \\
+	action ok
+.EE
+.RE
+
+Configure the sending side to encode for the filters above. Use a destination
+IP address of 192.168.122.237/24, then tag with skb mark of decimal 17. Encode
+the packaet with ethertype 0xdead, add skb->mark to whitelist of metadatum to
+send, and rewrite the destination MAC address to 02:15:15:15:15:15.
+
+.RS
+.EX
+# tc qdisc add dev eth0 root handle 1: prio
+# tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \\
+	match ip dst 192.168.122.237/24 \\
+	match ip protocol 1 0xff \\
+	flowid 1:2 \\
+	action skbedit mark 17 \\
+	action ife encode \\
+	type 0xDEAD \\
+	allow mark \\
+	dst 02:15:15:15:15:15
+.EE
+.RE
+
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-u32 (8)
-- 
1.9.1
