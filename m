From: Andreas Greve <andreas.greve@a-greve.de>
Subject: Bug: tc filter show .... raise segfault if more than one rule with
 action -j MARK exist
Date: Thu, 08 May 2014 13:48:19 +0200
Message-ID: <536B6F03.5040401@a-greve.de>
Reply-To: andreas.greve@a-greve.de
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050606080504050007040805"
Cc: andreas.greve@a-greve.de, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.217]:46652 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270AbaEHLtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 07:49:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050606080504050007040805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Dear Stephen Hemminger, Dear List Members,

the command

tc filter show dev eth1 parent ffff:

raise a segmentation fault if there are more than one filter rule with 
action -j MARK exists.

Reason:
In print_ipt(...) xtables will be initialzed with a pointer to the 
static struct tcipt_globals at xtables_init_all(). Later on the fields 
.opts and .options_offset of tcipt_globals are modified.  The call of 
xtables_free_opts(1) at the end of print_ipt(...) does not restore the 
original values of tcipt_globals for the modified fields. It only frees 
some allocated memory and sets .opts to NULL. This leads to a 
segmentation fault when print_ipt()
is called for the next filter rule with action -j MARK.

Fix: (patch attached)
Cloneing tcipt_globals on the stack as tmp_tcipt_globals and use it 
instead of tcipt_globals, so tcipt_globals will be not modified.

Tests:
I only have done limit tests for this fix ( action -j MARK ) on a debian 
wheezy iproute2 package build from source based on upstream/3.14.0. The 
system is a little bit special  kernel 3.12.17-xen on xen-4.4.1-pre.


Andreas Henriksson (debian iproute maintainer) give me an other idea of 
how to fix this bug by modifying  xtables_free_opts() so that it sets 
.opts = .orig_opts instead .opts = NULL. This should  avoid having to 
duplicate the entire struct each time.

I prefer the cloning  because:

1)  In my understanding the variable tcipt_globals is a complex 
"constant" that should never be modified. ( Is that right ?)

2) If we want to do the fix in xtables_free_opts we have to change the 
struct xtables_globals because we need for all fields .orig fields I 
think this will  make all things much more complicated.


additional Brainstorms:

a ) Perhaps we have to think about of a deep clone of tcipt_globals to 
protect the underlaying option array
b ) makes cloning of  tcipt_globals sense in  parse_ipt(...)
But for this two decisions my understanding of the whole system is not 
enough.


I hope the Information helps

Thanks

Best wishes


Andreas Greve








Andreas Henriksson


Stephen Hemminger


--------------050606080504050007040805
Content-Type: text/x-patch;
 name="0001-print_ipt-segfault-if-more-then-one-filter-with-acti.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-print_ipt-segfault-if-more-then-one-filter-with-acti.pa";
 filename*1="tch"

>From 2be366b5b534af61756e1eb69e26fcf9c4544aa7 Mon Sep 17 00:00:00 2001
From: Andreas Greve <andreas.greve@a-greve.de>
Date: Thu, 8 May 2014 12:03:16 +0200
Subject: [PATCH] print_ipt: segfault if more then one filter with action -j
 MARK.

tc fulter show ... produce a segmentation fault if more than one
filter rule with action -j MARK exists.

Reason: In print_ipt(...) xtables will be initialzed with a
pointer to the static struct tcipt_globals at xtables_init_all().
Later on the fields .opts and .options_offset of tcipt_globals are
modified. The call of xtables_free_opts(1) at the end of print(...)
does not restore the original values of tcipt_globals for the
modified fields. It only frees some allocated memory and sets
.opts to NULL. This leads to a segmentation fault when print_ipt()
is called for the next filter rule with action -j MARK.

Fix: Cloneing tcipt_globals on the stack as tmp_tcipt_globals and
use it instead of tcipt_globals, so tcipt_globals will be not
modified.

Signed-off-by: Andreas Greve <andreas.greve@a-greve.de>
---
 tc/m_xt.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index 27029c1..873adad 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -298,7 +298,15 @@ print_ipt(struct action_util *au,FILE * f, struct rtattr *arg)
 	if (arg == NULL)
 		return -1;
 
-	xtables_init_all(&tcipt_globals, NFPROTO_IPV4);
+	/* 
+	   clone tcipt_globals because .opts and .options_offset  will be modified later and not 
+           restored by iptables. If tcipt_globals is not cloned the modification tcipt_globals will 
+           cause a segmentation fault if more than one filter rule  with action -j  exists.
+        */
+	struct xtables_globals tmp_tcipt_globals;
+	memcpy (&tmp_tcipt_globals, &tcipt_globals, sizeof(struct xtables_globals) );
+
+	xtables_init_all(&tmp_tcipt_globals, NFPROTO_IPV4);
 	set_lib_dir();
 
 	parse_rtattr_nested(tb, TCA_IPT_MAX, arg);
@@ -333,12 +341,12 @@ print_ipt(struct action_util *au,FILE * f, struct rtattr *arg)
 			}
 
 #if (XTABLES_VERSION_CODE >= 6)
-		opts = xtables_options_xfrm(tcipt_globals.orig_opts,
-					    tcipt_globals.opts,
+		opts = xtables_options_xfrm(tmp_tcipt_globals.orig_opts,
+					    tmp_tcipt_globals.opts,
 					    m->x6_options,
 					    &m->option_offset);
 #else
-		opts = xtables_merge_options(tcipt_globals.opts,
+		opts = xtables_merge_options(tmp_tcipt_globals.opts,
 					     m->extra_opts,
 					     &m->option_offset);
 #endif
@@ -346,7 +354,7 @@ print_ipt(struct action_util *au,FILE * f, struct rtattr *arg)
 		fprintf(stderr, " failed to find aditional options for target %s\n\n", optarg);
 		return -1;
 	} else
-		tcipt_globals.opts = opts;
+		tmp_tcipt_globals.opts = opts;
 		} else {
 			fprintf(stderr, " failed to find target %s\n\n",
 				t->u.user.name);
-- 
1.7.10.4


--------------050606080504050007040805--
