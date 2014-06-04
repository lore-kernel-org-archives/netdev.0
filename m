From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH iproute2] bridge: Make filter_index match in signedness
Date: Wed,  4 Jun 2014 19:40:37 +0200
Message-ID: <1401903637-21398-1-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Andreas Henriksson <andreas@fatal.se>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b22.telenor.se ([195.54.99.213]:59700 "EHLO
	smtprelay-b22.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbaFDSIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 14:08:47 -0400
Received: from ipb1.telenor.se (ipb1.telenor.se [195.54.127.164])
	by smtprelay-b22.telenor.se (Postfix) with ESMTP id 2BABBC9C4
	for <netdev@vger.kernel.org>; Wed,  4 Jun 2014 19:41:24 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From the original report at http://bugs.debian.org/749155
Michael Tautschnig wrote:

During a rebuild [...]. Please note that we use our research
compiler tool-chain (using tools from the cbmc package), which permits extended
reporting on type inconsistencies at link time.

[...]
gcc   bridge.o fdb.o monitor.o link.o mdb.o vlan.o ../lib/libnetlink.a ../lib/libutil.a  ../lib/libnetlink.a ../lib/libutil.a -o bridge
file link.c line 18: error: conflicting types for variable "filter_index"
old definition in module fdb file fdb.c line 29
signed int
new definition in module link file link.c line 18
unsigned int
<builtin>: recipe for target 'bridge' failed
make[3]: *** [bridge] Error 64
make[3]: Leaving directory '/srv/jenkins-slave/workspace/sid-goto-cc-iproute2/iproute2-3.14.0/bridge'
Makefile:45: recipe for target 'all' failed

While practical constraints may limit the value of filter_index to remain within
the bounds of a positive signed int, there is certainly no such guarantee here.
Also, a plain majority vote suggests that this really just a wrong declaration
in link.c as several declarations of filter_index as signed int exist.

[...]

My followup on this was:

I think the majority is wrong.

filter_index is assigned exclusively from if_nametoindex or ll_name_to_index
which both return unsigned int.

Changing it to unsigned everywhere seems better.

This has been minimally tested by using the bridge tool
to add vids and showing available vids on different devices.

Reported-by: Michael Tautschnig <mt@debian.org>
Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 bridge/fdb.c  | 2 +-
 bridge/link.c | 2 +-
 bridge/mdb.c  | 2 +-
 bridge/vlan.c | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 336cf9d..cca99ef 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -27,7 +27,7 @@
 #include "rt_names.h"
 #include "utils.h"
 
-int filter_index;
+static unsigned int filter_index;
 
 static void usage(void)
 {
diff --git a/bridge/link.c b/bridge/link.c
index e3fd6e6..90d9e7f 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -15,7 +15,7 @@
 #include "utils.h"
 #include "br_common.h"
 
-unsigned int filter_index;
+static unsigned int filter_index;
 
 static const char *port_states[] = {
 	[BR_STATE_DISABLED] = "disabled",
diff --git a/bridge/mdb.c b/bridge/mdb.c
index 81d479b..6c1c938 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -24,7 +24,7 @@
 	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct br_port_msg))))
 #endif
 
-int filter_index;
+static unsigned int filter_index;
 
 static void usage(void)
 {
diff --git a/bridge/vlan.c b/bridge/vlan.c
index 83c4088..3bd7b0d 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -13,7 +13,7 @@
 #include "br_common.h"
 #include "utils.h"
 
-int filter_index;
+static unsigned int filter_index;
 
 static void usage(void)
 {
-- 
2.0.0.rc2
