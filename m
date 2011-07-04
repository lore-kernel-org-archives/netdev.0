From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: Fix building xt module against xtables version 6
Date: Mon, 4 Jul 2011 17:17:42 +0200
Message-ID: <20110704151742.GA6819@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h21.telenor.se ([195.54.99.196]:54766 "EHLO
	smtprelay-h21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504Ab1GDPf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 11:35:57 -0400
Received: from ipb4.telenor.se (ipb4.telenor.se [195.54.127.167])
	by smtprelay-h21.telenor.se (Postfix) with ESMTP id A5195EA78F
	for <netdev@vger.kernel.org>; Mon,  4 Jul 2011 17:11:16 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iptables/xtables apparently changed API again.... Now you need to pass
and extra parameter (orig_opts) which was not needed before.

Sprinkle some lovely pre-processor magic to be compatible with both older
and new versions. In the beginning of times XTABLES_VERSION_CODE didn't
exist. Then it was (0x10000 * major + 0x100 * minor + patch) when it was
first introduced (according to git), but now it's at 6...
Don't know what official iptables releases has defined it to over time.
Lets just hope none of the older versions with is has the define
higher then 6 is still around.... so only the "current" versioning
scheme is supported.... lets see how long this lasts now.

For the API change in xtables, see:
http://git.netfilter.org/cgi-bin/gitweb.cgi?p=iptables.git;a=commitdiff;h=600f38db82548a683775fd89b6e136673e924097

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

---

Would be great if Jan could ack this change first...
I just tested that it atleast builds (against the new xtables version),
nothing more then that...


diff --git a/tc/m_xt.c b/tc/m_xt.c
index 651a59e..13bf19f 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -160,9 +160,13 @@ static int parse_ipt(struct action_util *a,int *argc_p,
 					return -1;
 				}
 				tcipt_globals.opts =
-				    xtables_merge_options(tcipt_globals.opts,
-				                          m->extra_opts,
-				                          &m->option_offset);
+				    xtables_merge_options(
+#if (XTABLES_VERSION_CODE >= 6)
+				        tcipt_globals.orig_opts,
+#endif
+				        tcipt_globals.opts,
+				        m->extra_opts,
+				        &m->option_offset);
 			} else {
 				fprintf(stderr," failed to find target %s\n\n", optarg);
 				return -1;
@@ -305,7 +309,11 @@ print_ipt(struct action_util *au,FILE * f, struct rtattr *arg)
 			}
 
 			tcipt_globals.opts =
-			    xtables_merge_options(tcipt_globals.opts,
+			    xtables_merge_options(
+#if (XTABLES_VERSION_CODE >= 6)
+				                  tcipt_globals.orig_opts,
+#endif
+				                  tcipt_globals.opts,
 			                          m->extra_opts,
 			                          &m->option_offset);
 		} else {
