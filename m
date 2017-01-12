From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] tc: m_xt: Fix segfault with iptables-1.6.0
Date: Thu, 12 Jan 2017 15:22:49 +0100
Message-ID: <20170112142249.13041-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:40965 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750790AbdALOWq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 09:22:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Said iptables version introduced struct xtables_globals field
'compat_rev', a function pointer. Initializing it is mandatory as
libxtables calls it without existence check.

Without this, tc segfaults when using the xt action like so:

| tc filter add dev d0 parent ffff: u32 match u32 0 0 \
|	action xt -j MARK --set-mark 20

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_xt.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index dbb54981462ee..57ed40d7aa3a8 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -77,6 +77,9 @@ static struct xtables_globals tcipt_globals = {
 	.orig_opts = original_opts,
 	.opts = original_opts,
 	.exit_err = NULL,
+#if (XTABLES_VERSION_CODE >= 11)
+	.compat_rev = xtables_compatible_revision,
+#endif
 };
 
 /*
-- 
2.11.0
