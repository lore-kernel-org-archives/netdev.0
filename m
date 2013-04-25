From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [IPROUTE PATCH] iproute2: act_ipt fix xtables breakage on older
 versions.
Date: Thu, 25 Apr 2013 15:07:16 -0700
Message-ID: <20130425220716.6520.94862.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Hasan Chowdhury <shemonc@gmail.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27082 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932608Ab3DYWJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 18:09:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In trying to build on a RHEL6.3 I ran into several build issues that are
addressed in this patch.

The first is that xtables_options_xfrm only has 3 options.  It appears this is
how this code was originally.  As such for the case where the version is less
than 6 I am assuming it would be correct to maintain the original setup that
only had 3 parameters being passed instead of 4.

I also ran into an issue with the define for __ALIGN_KERNEL not being present.
I believe this may be due to the fact that __ALIGN_KERNEL was moved into a
separate header from ALIGN after the uapi changes.  In order to just cover all
of the bases I have moved the main definition for the macros into
__ALIGN_KERNEL_MASK and __ALIGN_KERNEL and if ALIGN is also needed then it is
just a direct redefine to __ALIGN_KERNEL.

Cc: Hasan Chowdhury <shemonc@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 tc/m_xt.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index 3edf520..e918670 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -38,9 +38,13 @@
 #       define XT_LIB_DIR "/lib/xtables"
 #endif
 
+#ifndef __ALIGN_KERNEL
+#define __ALIGN_KERNEL(x, a)		__ALIGN_KERNEL_MASK(x, (typeof(x))(a) - 1)
+#define __ALIGN_KERNEL_MASK(x, mask)	(((x) + (mask)) & ~(mask))
+#endif
+
 #ifndef ALIGN
-#define ALIGN(x,a)		__ALIGN_MASK(x,(typeof(x))(a)-1)
-#define __ALIGN_MASK(x,mask)	(((x)+(mask))&~(mask))
+#define ALIGN(x,a)	__ALIGN_KERNEL((x), (a))
 #endif
 
 static const char *tname = "mangle";
@@ -166,8 +170,7 @@ static int parse_ipt(struct action_util *a,int *argc_p,
 						    m->x6_options,
 						    &m->option_offset);
 #else
-			opts = xtables_merge_options(tcipt_globals.orig_opts,
-						     tcipt_globals.opts,
+			opts = xtables_merge_options(tcipt_globals.opts,
 						     m->extra_opts,
 						     &m->option_offset);
 #endif
@@ -335,8 +338,7 @@ print_ipt(struct action_util *au,FILE * f, struct rtattr *arg)
 					    m->x6_options,
 					    &m->option_offset);
 #else
-		opts = xtables_merge_options(tcipt_globals.orig_opts,
-					     tcipt_globals.opts,
+		opts = xtables_merge_options(tcipt_globals.opts,
 					     m->extra_opts,
 					     &m->option_offset);
 #endif
