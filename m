From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] tc: fix parallel build file with lex/yacc
Date: Tue, 18 Oct 2011 17:38:08 -0400
Message-ID: <1318973888-29496-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53834 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754265Ab1JRViI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Oct 2011 17:38:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building iproute2 in parallel might hit the race failure:
	emp_ematch.l:2:30: fatal error: emp_ematch.yacc.h:
		No such file or directory
	make[1]: *** [emp_ematch.lex.o] Error 1

This is because we currently allow the yacc/lex files to generate and
compile in parallel.  So add a simple dependency to make sure yacc has
finished before we attempt to compile the lex output.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 tc/Makefile |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tc/Makefile b/tc/Makefile
index 08aa4ce..b2ca165 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -136,6 +136,11 @@ m_xt_old.so: m_xt_old.c
 %.lex.c: %.l
 	$(LEX) $(LEXFLAGS) -o$@ $<
 
+# our lexer includes the header from yacc, so make sure
+# we don't attempt to compile it before the header has
+# been generated as part of the yacc step.
+emp_ematch.lex.o: emp_ematch.yacc.c
+
 ifneq ($(SHARED_LIBS),y)
 
 tc: static-syms.o
-- 
1.7.6.1
