From: David Michael <david.michael@coreos.com>
Subject: [PATCH] tc: make tc linking depend on libtc.a
Date: Tue, 03 Jan 2017 15:32:46 -0800
Message-ID: <87wpebu3c1.fsf@coreos.com>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33141 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761984AbdACXct (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 18:32:49 -0500
Received: by mail-pg0-f51.google.com with SMTP id g1so180620730pgn.0
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 15:32:49 -0800 (PST)
Received: from callisto ([2603:3024:1c06:3af3:bfa5:a6ff:8ac8:141d])
        by smtp.gmail.com with ESMTPSA id t25sm143864821pgo.9.2017.01.03.15.32.48
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Jan 2017 15:32:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was a race condition where the command to link the tc binary
could (rarely) run before the libtc.a archive existed.
---

Hi,

I've hit a random failure during parallel builds:

    ld: cannot find -ltc

The issue seems to be that both tc and libtc.a are permitted to build in
parallel, when tc actually depends on libtc.a.  This patch adjusts the
Make prerequisites accordingly.  Can something like this be applied?

Thanks.

David

 tc/Makefile | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tc/Makefile b/tc/Makefile
index bb90114..7fd0c4a 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -96,7 +96,7 @@ ifneq ($(TC_CONFIG_NO_XT),y)
 endif
 
 TCOBJ += $(TCMODULES)
-LDLIBS += -L. -ltc -lm
+LDLIBS += -L. -lm
 
 ifeq ($(SHARED_LIBS),y)
 LDLIBS += -ldl
@@ -124,13 +124,13 @@ MODDESTDIR := $(DESTDIR)$(LIBDIR)/tc
 	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic $< -o $@
 
 
-all: libtc.a tc $(TCSO)
+all: tc $(TCSO)
 
-tc: $(TCOBJ) $(TCLIB)
+tc: $(TCOBJ) libtc.a
 	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
 
 libtc.a: $(TCLIB)
-	$(QUIET_AR)$(AR) rcs $@ $(TCLIB)
+	$(QUIET_AR)$(AR) rcs $@ $^
 
 install: all
 	mkdir -p $(MODDESTDIR)
-- 
2.7.4
