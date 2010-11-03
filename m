From: <Narendra_K@Dell.com>
Subject: [PATCH 0/1] UDEV - Rename onboard network interfaces to lomN if the
 user so desires
Date: Wed, 3 Nov 2010 22:19:12 +0530
Message-ID: <20101103164851.GA3269@fedora-14-r710.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <Matt_Domsch@Dell.com>,
	<Jordan_Hargrave@Dell.com>, <Charles_Rose@Dell.com>
To: <linux-hotplug@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:55573 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753513Ab0KCQwJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 12:52:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This patch adds support to udev's dynamic rule generation mechanism to
rename onboard network interfaces to lom1, lom2 etc if the user so
desires. (Please refer to this for more information -
http://marc.info/?l=linux-netdev&m=128646170613973&w=3).

From: Narendra K <narendra_k@dell.com>
Subject: [PATCH] UDEV - Rename onboard network interfaces to lomN if the user so desires

This patch adds support to udev's dynamic rule generation mechanism to
rename onboard network interfaces to lom1, lom2 etc if the user so
desires. (Please refer to this for more information -
http://marc.info/?l=linux-netdev&m=128646170613973&w=3).

It introduces a commad line parameter 'udevlom', which when passed
would rename onboard network interfaces to lomN. It would also generate
corresponding rules to make the names persistent across reboots.

With this patch, interface with firmware index=1 will be renamed to lom1,
index=2 will be rename to lom2 etc.(lom - Lan-On-Motherboard)

This patch is against Fedora 14 udev (version:161 release:4.fc14).
It requires the upstream commit 911e1c9b05a8e3559a7aa89083930700a0b9e7ee
for the firmware index to be available in sysfs.

With the patch applied, the network interfaces look like this on a
Dell PowerEdge R710 with four BCM5709 onboard NICs with firmware
indexes and four add-in interfaces.

[root@fedora-14-r710 ~]# ls /sys/class/net/
eth4  eth5  eth6  eth7  eth8  lo  lom1  lom2  lom3  lom4

/etc/udev/rules.d/70-persistent-net.rules would look like this -
[snippet attched]

SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:24:e8:2e:df:01", ATTR{dev_id}=="0x0", ATTR{type}=="1", ATTRS{index}=="2", KERNEL=="eth*", NAME="lom2"

SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:15:17:15:9b:eb", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="eth4"

SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:24:e8:2e:df:05", ATTR{dev_id}=="0x0", ATTR{type}=="1", ATTRS{index}=="4", KERNEL=="eth*", NAME="lom4"

SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:24:e8:2e:df:03", ATTR{dev_id}=="0x0", ATTR{type}=="1", ATTRS{index}=="3", KERNEL=="eth*", NAME="lom3"

SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:24:e8:2e:de:ff", ATTR{dev_id}=="0x0", ATTR{type}=="1", ATTRS{index}=="1", KERNEL=="eth*", NAME="lom1"

Signed-off-by: Narendra K <narendra_k@dell.com>
---
 .../75-persistent-net-generator.rules              |    4 ++++
 extras/rule_generator/write_net_rules              |   15 ++++++++++++++-
 2 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/extras/rule_generator/75-persistent-net-generator.rules b/extras/rule_generator/75-persistent-net-generator.rules
index 8119d0e..e138bd3 100644
--- a/extras/rule_generator/75-persistent-net-generator.rules
+++ b/extras/rule_generator/75-persistent-net-generator.rules
@@ -7,6 +7,7 @@
 #   MATCHID               bus_id used for the match
 #   MATCHDRV              driver name used for the match
 #   MATCHIFTYPE           interface type match
+#   MATCHINDEX            firmware index used for the match
 #   COMMENT               comment to add to the generated rule
 #   INTERFACE_NAME        requested name supplied by external tool
 #   INTERFACE_NEW         new interface name returned by rule writer
@@ -29,6 +30,9 @@ ENV{MATCHADDR}="$attr{address}"
 # match interface type
 ENV{MATCHIFTYPE}="$attr{type}"
 
+#read firmware index
+ATTRS{index}=="?*", ENV{MATCHINDEX}="$attr{index}"
+
 # ignore KVM virtual interfaces
 ENV{MATCHADDR}=="54:52:00:*", GOTO="persistent_net_generator_end"
 
diff --git a/extras/rule_generator/write_net_rules b/extras/rule_generator/write_net_rules
index 4379792..40aaa4b 100644
--- a/extras/rule_generator/write_net_rules
+++ b/extras/rule_generator/write_net_rules
@@ -11,6 +11,7 @@
 #   MATCHDEVID            dev_id used for the match
 #   MATCHDRV              driver name used for the match
 #   MATCHIFTYPE           interface type match
+#   MATCHINDEX            firmware index used for the match
 #   COMMENT               comment to add to the generated rule
 #   INTERFACE_NAME        requested name supplied by external tool
 #   INTERFACE_NEW         new interface name returned by rule writer
@@ -72,7 +73,11 @@ write_rule() {
 
 	echo ""
 	[ "$comment" ] && echo "# $comment"
-	echo "SUBSYSTEM==\"net\", ACTION==\"add\"$match, NAME=\"$name\""
+	if [ "$MATCHINDEX" -a "$UDEVLOM" ]; then
+        	echo "SUBSYSTEM==\"net\", ACTION==\"add\"$match, NAME=\"lom$MATCHINDEX\""
+	else
+		echo "SUBSYSTEM==\"net\", ACTION==\"add\"$match, NAME=\"$name\""
+	fi
 	} >> $RULES_FILE
 }
 
@@ -108,6 +113,10 @@ if [ "$MATCHIFTYPE" ]; then
 	match="$match, ATTR{type}==\"$MATCHIFTYPE\""
 fi
 
+if [ "$MATCHINDEX" -a "$UDEVLOM" ]; then
+	match="$match, ATTRS{index}==\"$MATCHINDEX\""
+fi
+
 if [ -z "$match" ]; then
 	echo "missing valid match" >&2
 	unlock_rules_file
@@ -134,6 +143,10 @@ else
 	fi
 fi
 
+if [ "$MATCHINDEX" -a "$UDEVLOM" ]; then
+	echo "INTERFACE_NEW=lom$MATCHINDEX"
+fi
+
 write_rule "$match" "$INTERFACE" "$COMMENT"
 
 unlock_rules_file
-- 
1.7.3.1

With regards,
Narendra K
