From: Andrey Mazo <mazo@telum.ru>
Subject: [PATCH 1/4] bridge-utils: Abort compilation on error in any subdirectory
Date: Mon, 24 Feb 2014 14:56:43 +0400
Message-ID: <1393239406-8504-2-git-send-email-mazo@telum.ru>
References: <1393239406-8504-1-git-send-email-mazo@telum.ru>
Cc: Andrey Mazo <mazo@telum.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.telum.ru ([62.141.76.179]:50891 "EHLO mail.telum.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751830AbaBXLCe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 06:02:34 -0500
In-Reply-To: <1393239406-8504-1-git-send-email-mazo@telum.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently bridge-utils makefile ignores compilation errors in
subdirectories, stepping into consecutive subdirs and finally
returning exit status of the last subdirectory's make.
The last subdirectory is now "doc", which has nothing to do for target "all",
so global `make all` always succeeds, effectively ignoring any build
errors in "libbridge" and "brctl" subdirectories.
This behaviour is odd as it breaks anyone relying on make's exit status.
For example, see Gentoo bug #483692 [1].

Fix this by simply aborting make on the first error.
Don't inspect MAKEFLAGS for -k for simplicity.

[1] https://bugs.gentoo.org/show_bug.cgi?id=483692

Signed-off-by: Andrey Mazo <mazo@telum.ru>
---
 Makefile.in | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 2f2fcba..5aed223 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -14,7 +14,7 @@ distdir = $(PACKAGE)-$(VERSION)
 SUBDIRS=libbridge brctl doc
 
 all:
-	for x in $(SUBDIRS); do $(MAKE) $(MFLAGS) -C $$x ; done
+	for x in $(SUBDIRS); do $(MAKE) $(MFLAGS) -C $$x || exit 1 ; done
 
 clean:
 	for x in $(SUBDIRS); do $(MAKE) $(MFLAGS) -C $$x clean ; done
@@ -28,5 +28,5 @@ maintainer-clean: distclean
 	rm -f brctl/Makefile libbridge/Makefile doc/Makefile
 
 install:
-	for x in $(SUBDIRS); do $(MAKE) $(MFLAGS) -C $$x install; done
+	for x in $(SUBDIRS); do $(MAKE) $(MFLAGS) -C $$x install || exit 1 ; done
 
-- 
1.8.4.5
