From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH iproute2/net-next 2/3] tc: man: Add man entry for the tc-sample action
Date: Sun,  5 Feb 2017 09:58:53 +0200
Message-ID: <1486281534-61663-3-git-send-email-yotamg@mellanox.com>
References: <1486281534-61663-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org,
        jiri@mellanox.com, eladr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55250 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752187AbdBEH4p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 02:56:45 -0500
In-Reply-To: <1486281534-61663-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In addition to general information about the tc action, the man entry
contains common usage examples and information about the tlv fields packed
within each sampled packet.

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 man/man8/Makefile    |   2 +-
 man/man8/tc-sample.8 | 125 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 126 insertions(+), 1 deletion(-)
 create mode 100644 man/man8/tc-sample.8

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 77d347c..18e76f2 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -17,7 +17,7 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
 	tc-tcindex.8 tc-u32.8 tc-matchall.8 \
 	tc-connmark.8 tc-csum.8 tc-mirred.8 tc-nat.8 tc-pedit.8 tc-police.8 \
 	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8  tc-ife.8 \
-	tc-tunnel_key.8 \
+	tc-tunnel_key.8 tc-sample.8 \
 	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8
 
 all: $(TARGETS)
diff --git a/man/man8/tc-sample.8 b/man/man8/tc-sample.8
new file mode 100644
index 0000000..3e03eba
--- /dev/null
+++ b/man/man8/tc-sample.8
@@ -0,0 +1,125 @@
+.TH "Packet sample action in tc" 8 "31 Jan 2017" "iproute2" "Linux"
+
+.SH NAME
+sample - packet sampling tc action
+.SH SYNOPSIS
+.in +8
+.ti -8
+
+.BR tc " ... " "action sample rate"
+.I RATE
+.BR "group"
+.I GROUP
+.RB "[ " trunc
+.IR SIZE " ] "
+.RB "[ " index
+.IR INDEX " ] "
+.ti -8
+
+.BR tc " ... " "action sample index "
+.I INDEX
+.ti -8
+
+.SH DESCRIPTION
+The
+.B sample
+action allows sampling packets matching classifier.
+
+The packets are chosen randomly according to the
+.B rate
+parameter, and are sampled using the
+.B psample
+generic netlink channel. The user can also specify packet truncation to save
+user-kernel traffic. Each sample includes some informative metadata about the
+original packet, which is sent using netlink attributes, alongside the original
+packet data.
+
+The user can either specify the sample action parameters as presented in the
+first form above, or use an existing sample action using its index, as presented
+in the second form.
+
+.SH SAMPLED PACKETS METADATA FIELDS
+The metadata are delivered to userspace applications using the
+.B psample
+generic netlink channel, where each sample includes the following netlink
+attributes:
+.TP
+.BI PSAMPLE_ATTR_IIFINDEX
+The input interface index of the packet, if there is one.
+.TP
+.BI PSAMPLE_ATTR_OIFINDEX
+The output interface index of the packet. This field is not relevant on ingress
+sampling
+.TP
+.BI PSAMPLE_ATTR_ORIGSIZE
+The size of the original packet (before truncation)
+.TP
+.BI PSAMPLE_ATTR_SAMPLE_GROUP
+The
+.B psample
+group the packet was sent to
+.TP
+.BI PSAMPLE_ATTR_GROUP_SEQ
+A sequence number of the sampled packet. This number is incremented with each
+sampled packet of the current
+.B psample
+group
+.TP
+.BI PSAMPLE_ATTR_SAMPLE_RATE
+The rate the packet was sampled with
+.RE
+
+.SH OPTIONS
+.TP
+.BI rate " RATE"
+The packet sample rate.
+.I "RATE"
+is the expected ratio between observed packets and sampled packets. For example,
+.I "RATE"
+of 100 will lead to an average of one sampled packet out of every 100 observed.
+.TP
+.BI trunc " SIZE"
+Upon set, defines the maximum size of the sampled packets, and causes truncation
+if needed
+.TP
+.BI group " GROUP"
+The
+.B psample
+group the packet will be sent to. The
+.B psample
+module defines the concept of groups, which allows the user to match specific
+sampled packets in the case of multiple sampling rules, thus identify only the
+packets that came from a specific rule.
+.TP
+.BI index " INDEX"
+Is a unique ID for an action. When creating new action instance, this parameter
+allows to set the new action index. When using existing action, this parameter
+allows to specify the existing action index.  The index must 32bit unsigned
+integer greater than zero.
+.SH EXAMPLES
+Sample one of every 100 packets flowing into interface eth0 to psample group 12:
+
+.RS
+.EX
+tc qdisc add dev eth0 handle ffff: ingress
+tc filter add dev eth0 parent ffff: matchall \\
+     action sample rate 100 group 12 index 19
+.EE
+.RE
+
+Use the same action instance to sample eth1 too:
+
+.RS
+.EX
+tc qdisc add dev eth1 handle ffff: ingress
+tc filter add dev eth1 parent ffff: matchall \\
+     action sample index 19
+.EE
+.RE
+
+.EE
+.RE
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-matchall (8)
+.BR psample (1)
-- 
2.4.11
