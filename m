From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH] kmod: don't load module unless req process has CAP_SYS_MODULE
Date: Fri, 12 May 2017 16:22:59 -0700
Message-ID: <20170512232259.10820-1-mahesh@bandewar.net>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>,
        Kees Cook <keescook@chromium.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Ingo Molnar <mingo@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35382 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754977AbdELXXU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 19:23:20 -0400
Received: by mail-pg0-f67.google.com with SMTP id i63so9186156pgd.2
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 16:23:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

A process inside random user-ns should not load a module, which is
currently possible. As demonstrated in following scenario -

  Create namespaces; especially a user-ns and become root inside.
  $ unshare -rfUp -- unshare -unm -- bash

  Try to load the bridge module. It should fail and this is expected!
  #  modprobe bridge
  WARNING: Error inserting stp (/lib/modules/4.11.0-smp-DEV/kernel/net/802/stp.ko): Operation not permitted
  FATAL: Error inserting bridge (/lib/modules/4.11.0-smp-DEV/kernel/net/bridge/bridge.ko): Operation not permitted

  Verify bridge module is not loaded.
  # lsmod | grep bridge
  #

  Now try to create a bridge inside this newly created net-ns which would
  mean bridge module need to be loaded.
  # ip link add br0 type bridge
  # echo $?
  0
  # lsmod | grep bridge
  bridge                110592  0
  stp                    16384  1 bridge
  llc                    16384  2 bridge,stp
  #

  After this patch -
  # ip link add br0 type bridge
  RTNETLINK answers: Operation not supported
  # echo $?
  2
  # lsmod | grep bridge
  #

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 kernel/kmod.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/kmod.c b/kernel/kmod.c
index 563f97e2be36..ac30157169b7 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -133,6 +133,9 @@ int __request_module(bool wait, const char *fmt, ...)
 #define MAX_KMOD_CONCURRENT 50	/* Completely arbitrary value - KAO */
 	static int kmod_loop_msg;
 
+	if (!capable(CAP_SYS_MODULE))
+		return -EPERM;
+
 	/*
 	 * We don't allow synchronous module loading from async.  Module
 	 * init may invoke async_synchronize_full() which will end up
-- 
2.13.0.rc2.291.g57267f2277-goog
