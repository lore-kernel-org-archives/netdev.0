From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] tests: Allow to run tests recursively
Date: Fri, 10 Oct 2014 09:27:19 +0300
Message-ID: <1412922439-28953-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:54261 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbaJJGgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 02:36:03 -0400
Received: by mail-la0-f47.google.com with SMTP id pv20so2627093lab.34
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 23:36:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Such approach allows to run *.t scripts from any
tests/ subdirectories.

One point is that tests from tests/cls/*.t (which are needed
by tests/cls-testbed.t but does not exist yet) will also
be ran aside with tests/cls-testbed.t which is not good
because in such case they will be ran twice, so renamed these
tests path to tests/cls/*.c in tests/cls-testbed.t

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 testsuite/Makefile            | 11 ++++++++++-
 testsuite/tests/cls-testbed.t |  2 +-
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/testsuite/Makefile b/testsuite/Makefile
index d1bf359..2ba9547 100644
--- a/testsuite/Makefile
+++ b/testsuite/Makefile
@@ -4,7 +4,11 @@ PREFIX := sudo -E
 RESULTS_DIR := results
 ## -- End Config --
 
-TESTS := $(patsubst tests/%,%,$(wildcard tests/*.t))
+rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
+
+TESTS := $(patsubst tests/%,%,$(call rwildcard,tests/,*.t))
+TESTS_DIR := $(dir $(TESTS))
+
 IPVERS := $(filter-out iproute2/Makefile,$(wildcard iproute2/*))
 
 ifneq (,$(wildcard /proc/config.gz))
@@ -34,6 +38,11 @@ distclean: clean
 
 $(TESTS):
 	@mkdir -p $(RESULTS_DIR)
+	
+	@for d in $(TESTS_DIR); do \
+	    mkdir -p $(RESULTS_DIR)/$$d; \
+	done
+	
 	@for i in $(IPVERS); do \
 		o=`echo $$i | sed -e 's/iproute2\///'`; \
 		echo -n "Running $@ [$$o/`uname -r`]: "; \
diff --git a/testsuite/tests/cls-testbed.t b/testsuite/tests/cls-testbed.t
index efae2a5..9fe86f5 100755
--- a/testsuite/tests/cls-testbed.t
+++ b/testsuite/tests/cls-testbed.t
@@ -8,7 +8,7 @@ QDISCS="cbq htb dsmark"
 for q in ${QDISCS}; do
 	ts_log "Preparing classifier testbed with qdisc $q"
 
-	for c in tests/cls/*.t; do
+	for c in tests/cls/*.c; do
 
 		case "$q" in
 		cbq)
-- 
2.1.0
