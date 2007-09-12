From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 4/4] [IPROUTE2] iproute2: link_veth support bug fixes.
Date: Wed, 12 Sep 2007 07:01:06 -0600
Message-ID: <m1r6l4avhp.fsf_-_@ebiederm.dsl.xmission.com>
References: <m14pi0cac5.fsf@ebiederm.dsl.xmission.com>
	<m1zlzsavla.fsf@ebiederm.dsl.xmission.com>
	<m1veagavjr.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Pavel Emelyanov <xemul@openvz.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:48572 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbXILNBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 09:01:36 -0400
In-Reply-To: <m1veagavjr.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Wed, 12 Sep 2007 06:59:52 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com>
Date: Sat, 8 Sep 2007 10:17:43 -0600

This patch contains small compile and implementation
bug fixes for link_veth.c.

The compile fixes stop trying to build a shared object
when we can just as easily compile the code in.  Making
support of non arch/i386 architectures easier.

The documentation is fixed to not document the previous version
of the veth support.

The code is to initialize it's pointers before calling
iplink_parse, and we now set name = dev if name is not
passed.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 ip/Makefile    |    8 +++-----
 ip/link_veth.c |   12 +++++++++---
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/ip/Makefile b/ip/Makefile
index b46bce3..a98e1f3 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -3,14 +3,15 @@ IPOBJ=ip.o ipaddress.o iproute.o iprule.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o
 
+IPOBJ += link_veth.o
+
 RTMONOBJ=rtmon.o
 
 ALLOBJ=$(IPOBJ) $(RTMONOBJ)
 SCRIPTS=ifcfg rtpr routel routef
 TARGETS=ip rtmon
-LIBS=link_veth.so
 
-all: $(TARGETS) $(SCRIPTS) $(LIBS)
+all: $(TARGETS) $(SCRIPTS)
 
 ip: $(IPOBJ) $(LIBNETLINK) $(LIBUTIL)
 
@@ -25,6 +26,3 @@ clean:
 
 LDLIBS	+= -ldl
 LDFLAGS	+= -Wl,-export-dynamic
-
-%.so: %.c
-	$(CC) $(CFLAGS) -shared $< -o $@
diff --git a/ip/link_veth.c b/ip/link_veth.c
index ded2cdd..6f3931c 100644
--- a/ip/link_veth.c
+++ b/ip/link_veth.c
@@ -20,14 +20,16 @@
 
 static void usage(void)
 {
-	printf("Usage: ip link add ... type veth "
-			"[peer <peer-name>] [mac <mac>] [peer_mac <mac>]\n");
+	printf("Usage: ip link add ... type veth peer { ... }\n");
 }
 
 static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 		struct nlmsghdr *hdr)
 {
-	char *name, *type, *link, *dev;
+	char *dev = NULL;
+	char *name = NULL;
+	char *link = NULL;
+	char *type = NULL;
 	int err, len;
 	struct rtattr * data;
 
@@ -46,6 +48,10 @@ static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 	if (err < 0)
 		return err;
 
+	/* Allow "ip link add dev" and "ip link add name" */
+	if (!name)
+		name = dev;
+
 	if (name) {
 		len = strlen(name) + 1;
 		if (len > IFNAMSIZ)
-- 
1.5.3.rc6.17.g1911

