From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH] iproute2: bridge: fix 'bridge link' setlink/getlink parsing
Date: Wed, 29 May 2013 09:20:53 -0700
Message-ID: <20130529162044.25906.79115.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:35690 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544Ab3E2QVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 12:21:13 -0400
Received: by mail-oa0-f48.google.com with SMTP id i4so11606614oah.7
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 09:21:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use IFLA_AF_SPEC nested attributes to lookup bridge mode and when
doing strcmp() check for equality.

These appear to be typos from the original commit,

commit 64108901b737b95247b53dec8c1b8217ca8505b7
Author: Vlad Yasevich <vyasevic@redhat.com>
Date:   Fri Mar 15 10:01:28 2013 -0700

    bridge: Add support for setting bridge port attributes

Also set flags to BRIDGE_FLAGS_SELF instead of using OR operation.
This allows setting the bridge mode when not being used with a
master device.

To allow setting both master and self devices simultaneously we
will need to add a {self|master} field similar to fdb commands.
For now the command sets are mutually exclusive as noted in the
original commit.

With this patch 'bridge link set' works now,

# ./bridge/bridge link set dev veth1 cost 3
# ./bridge/bridge link show
10: veth1 state UP : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master bridge0 state forwarding priority 3 cost 3

CC: Vlad Yasevich <vyasevic@redhat.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 bridge/link.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/bridge/link.c b/bridge/link.c
index 3188b85..38dfaea 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -198,8 +198,8 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 		parse_rtattr_nested(aftb, IFLA_BRIDGE_MAX, tb[IFLA_AF_SPEC]);
 
-		if (tb[IFLA_BRIDGE_MODE])
-			print_hwmode(fp, rta_getattr_u16(tb[IFLA_BRIDGE_MODE]));
+		if (aftb[IFLA_BRIDGE_MODE])
+			print_hwmode(fp, rta_getattr_u16(aftb[IFLA_BRIDGE_MODE]));
 	}
 
 	fprintf(fp, "\n");
@@ -281,18 +281,18 @@ static int brlink_modify(int argc, char **argv)
 			NEXT_ARG();
 			if (!on_off("root_block", &root_block, *argv))
 				exit(-1);
-		} else if (strcmp(*argv, "cost")) {
+		} else if (strcmp(*argv, "cost") == 0) {
 			NEXT_ARG();
 			cost = atoi(*argv);
-		} else if (strcmp(*argv, "priority")) {
+		} else if (strcmp(*argv, "priority") == 0) {
 			NEXT_ARG();
 			priority = atoi(*argv);
-		} else if (strcmp(*argv, "state")) {
+		} else if (strcmp(*argv, "state") == 0) {
 			NEXT_ARG();
 			state = atoi(*argv);
-		} else if (strcmp(*argv, "hwmode")) {
+		} else if (strcmp(*argv, "hwmode") == 0) {
 			NEXT_ARG();
-			flags |= BRIDGE_FLAGS_SELF;
+			flags = BRIDGE_FLAGS_SELF;
 			if (strcmp(*argv, "vepa") == 0)
 				mode = BRIDGE_MODE_VEPA;
 			else if (strcmp(*argv, "veb") == 0)
