From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2] tc: add support for vlan tc action
Date: Tue, 11 Nov 2014 14:46:30 +0100
Message-ID: <20141111134630.GB1825@nanopsycho.lan>
References: <reply-to=1415700789-9171-2-git-send-email-jiri@resnulli.us>
 <1415700966-9225-1-git-send-email-jiri@resnulli.us>
 <546210EA.7090201@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38611 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbaKKNqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 08:46:32 -0500
Received: by mail-wi0-f178.google.com with SMTP id bs8so1666857wib.5
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 05:46:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <546210EA.7090201@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 11, 2014 at 02:36:42PM CET, jhs@mojatatu.com wrote:
>
>Ive run out of time - but will test; so far looks good.
>Attached a small patchlet on top of yours.

Will squash it in and send v2.

>
>cheers,
>jamal

>diff --git a/tc/m_vlan.c b/tc/m_vlan.c
>index 54c0ce7..2755e20 100644
>--- a/tc/m_vlan.c
>+++ b/tc/m_vlan.c
>@@ -13,6 +13,7 @@
> #include <stdlib.h>
> #include <unistd.h>
> #include <string.h>
>+#include <linux/if_ether.h>
> #include "utils.h"
> #include "rt_names.h"
> #include "tc_util.h"
>@@ -22,6 +23,8 @@ static void explain(void)
> {
> 	fprintf(stderr, "Usage: vlan pop\n");
> 	fprintf(stderr, "       vlan push [ protocol VLANPROTO ] id VLANID\n");
>+	fprintf(stderr, "       VLANPROTO is one of 802.1Q or 802.1ad\n");
>+	fprintf(stderr, "            with default: 802.1Q\n");
> }
> 
> static void usage(void)
>@@ -121,7 +124,7 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
> 		if (matches(*argv, "index") == 0) {
> 			NEXT_ARG();
> 			if (get_u32(&parm.index, *argv, 10)) {
>-				fprintf(stderr, "Pedit: Illegal \"index\"\n");
>+				fprintf(stderr, "vlan: Illegal \"index\"\n");
> 				return -1;
> 			}
> 			argc--;
>@@ -141,8 +144,15 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
> 	addattr_l(n, MAX_MSG, TCA_VLAN_PARMS, &parm, sizeof(parm));
> 	if (id_set)
> 		addattr_l(n, MAX_MSG, TCA_VLAN_PUSH_VLAN_ID, &id, 2);
>-	if (proto_set)
>+	if (proto_set) {
>+		if (proto != ETH_P_8021Q && proto != ETH_P_8021AD) {
>+			fprintf(stderr, "protocol id 0x%x not supported\n", proto);
>+			explain();
>+			return -1;
>+		}
>+
> 		addattr_l(n, MAX_MSG, TCA_VLAN_PUSH_VLAN_PROTOCOL, &proto, 2);
>+	}
> 	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
> 
> 	*argc_p = argc;
