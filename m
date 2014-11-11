From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch iproute2] tc: add support for vlan tc action
Date: Tue, 11 Nov 2014 08:36:42 -0500
Message-ID: <546210EA.7090201@mojatatu.com>
References: <reply-to=1415700789-9171-2-git-send-email-jiri@resnulli.us> <1415700966-9225-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000808050709000303010509"
Cc: davem@davemloft.net, pshelar@nicira.com, therbert@google.com,
	edumazet@google.com, willemb@google.com, dborkman@redhat.com,
	mst@redhat.com, fw@strlen.de, Paul.Durrant@citrix.com,
	tgraf@suug.ch, Stephen Hemminger <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:33485 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022AbaKKNgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 08:36:45 -0500
Received: by mail-ie0-f170.google.com with SMTP id tp5so11483019ieb.15
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 05:36:45 -0800 (PST)
In-Reply-To: <1415700966-9225-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000808050709000303010509
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit


Ive run out of time - but will test; so far looks good.
Attached a small patchlet on top of yours.

cheers,
jamal

--------------000808050709000303010509
Content-Type: text/plain; charset=us-ascii;
 name="patch-for-jiri"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="patch-for-jiri"

diff --git a/tc/m_vlan.c b/tc/m_vlan.c
index 54c0ce7..2755e20 100644
--- a/tc/m_vlan.c
+++ b/tc/m_vlan.c
@@ -13,6 +13,7 @@
 #include <stdlib.h>
 #include <unistd.h>
 #include <string.h>
+#include <linux/if_ether.h>
 #include "utils.h"
 #include "rt_names.h"
 #include "tc_util.h"
@@ -22,6 +23,8 @@ static void explain(void)
 {
 	fprintf(stderr, "Usage: vlan pop\n");
 	fprintf(stderr, "       vlan push [ protocol VLANPROTO ] id VLANID\n");
+	fprintf(stderr, "       VLANPROTO is one of 802.1Q or 802.1ad\n");
+	fprintf(stderr, "            with default: 802.1Q\n");
 }
 
 static void usage(void)
@@ -121,7 +124,7 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 		if (matches(*argv, "index") == 0) {
 			NEXT_ARG();
 			if (get_u32(&parm.index, *argv, 10)) {
-				fprintf(stderr, "Pedit: Illegal \"index\"\n");
+				fprintf(stderr, "vlan: Illegal \"index\"\n");
 				return -1;
 			}
 			argc--;
@@ -141,8 +144,15 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 	addattr_l(n, MAX_MSG, TCA_VLAN_PARMS, &parm, sizeof(parm));
 	if (id_set)
 		addattr_l(n, MAX_MSG, TCA_VLAN_PUSH_VLAN_ID, &id, 2);
-	if (proto_set)
+	if (proto_set) {
+		if (proto != ETH_P_8021Q && proto != ETH_P_8021AD) {
+			fprintf(stderr, "protocol id 0x%x not supported\n", proto);
+			explain();
+			return -1;
+		}
+
 		addattr_l(n, MAX_MSG, TCA_VLAN_PUSH_VLAN_PROTOCOL, &proto, 2);
+	}
 	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
 
 	*argc_p = argc;

--------------000808050709000303010509--
