From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 6/6] doc: fix parallel build of html/man pages
Date: Wed,  1 Aug 2012 11:45:28 -0400
Message-ID: <1343835928-21541-6-git-send-email-vapier@gentoo.org>
References: <1343835928-21541-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:51072 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755555Ab2HAPpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2012 11:45:32 -0400
In-Reply-To: <1343835928-21541-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The use of the same tempdir prevents building of these files in parallel.
So build all of them in unique tempdirs so we can do them in parallel.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 doc/Makefile |   37 ++++++++++++++++++++++++-------------
 1 file changed, 24 insertions(+), 13 deletions(-)

diff --git a/doc/Makefile b/doc/Makefile
index 7ec4f1c..a9c303e 100644
--- a/doc/Makefile
+++ b/doc/Makefile
@@ -12,29 +12,40 @@ man: $(MANFILES)
 # lots of some strange temporary junk directories and files.
 # So, scope it to a temporary dir and clean all after each run.
 
-$(HTMLFILES): index.db
-	@-rm -rf tmp.db2html
-	@mkdir tmp.db2html
-	@set -e; cd tmp.db2html; docbook2html ../$< ; mv *.html ..
-	@-rm -rf tmp.db2html
+SETUP_TMPDIR = \
+	t="tmp.db2html.$@"; \
+	rm -rf $$t; \
+	mkdir $$t; \
+	pushd $$t >/dev/null
+CLEAN_TMPDIR = \
+	popd >/dev/null; \
+	rm -rf $$t
+
+MAKE_HTML = \
+	@set -e; \
+	$(SETUP_TMPDIR); \
+	docbook2html ../$<; \
+	mv *.html ..; \
+	$(CLEAN_TMPDIR)
 
+$(HTMLFILES): index.db
+	$(MAKE_HTML)
 iputils.html: iputils.db
-	@-rm -rf tmp.db2html
-	@mkdir tmp.db2html
-	@set -e; cd tmp.db2html; docbook2html -u -o html ../$< ; mv html/$@ ..
-	@-rm -rf tmp.db2html
+	$(MAKE_HTML)
 
 # docbook2man produces utterly ugly output and I did not find
 # any way to customize this but hacking backend perl script a little.
 # Well, hence...
 
 $(MANFILES): index.db
-	@-mkdir tmp.db2man
-	@set -e; cd tmp.db2man; nsgmls ../$< | sgmlspl ../docbook2man-spec.pl ;	mv $@ ..
-	@-rm -rf tmp.db2man
+	@set -e; \
+	$(SETUP_TMPDIR); \
+	nsgmls ../$< | sgmlspl ../docbook2man-spec.pl; \
+	mv $@ ..; \
+	$(CLEAN_TMPDIR)
 
 clean:
-	@rm -rf $(MANFILES) $(HTMLFILES) iputils.html tmp.db2html tmp.db2man
+	@rm -rf $(MANFILES) $(HTMLFILES) iputils.html tmp.db2html* tmp.db2man*
 
 snapshot:
 	@date "+%y%m%d" > snapshot.db
-- 
1.7.9.7
