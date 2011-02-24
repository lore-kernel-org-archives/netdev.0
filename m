From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/17] tipc: Improve handling of invalid link tolerance values
Date: Wed, 23 Feb 2011 20:26:33 -0500
Message-ID: <1298510805-20630-6-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34490 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755722Ab1BXB1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:07 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Enhances TIPC link code to ignore an invalid link tolerance value
contained in an incoming LINK_PROTOCOL message, rather than
processing the value and potentially causing a divide-by-zero error.

Also add a compile-time check that catches attempts to redefine
TIPC's minimum link tolerance value in a manner that might result
in the same divide-by-zero error at run-time.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc_config.h |    4 ++++
 net/tipc/link.c             |    3 +++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index 7d42460a..c14102d 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -193,6 +193,10 @@
 #define TIPC_DEF_LINK_TOL 1500
 #define TIPC_MAX_LINK_TOL 30000
 
+#if (TIPC_MIN_LINK_TOL < 16)
+#error "TIPC_MIN_LINK_TOL is too small (abort limit may be NaN)"
+#endif
+
 /*
  * Link window limits (min, default, max), in packets
  */
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 1c5c53a..3c1c28c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2617,6 +2617,9 @@ static void link_check_defragm_bufs(struct link *l_ptr)
 
 static void link_set_supervision_props(struct link *l_ptr, u32 tolerance)
 {
+	if ((tolerance < TIPC_MIN_LINK_TOL) || (tolerance > TIPC_MAX_LINK_TOL))
+		return;
+
 	l_ptr->tolerance = tolerance;
 	l_ptr->continuity_interval =
 		((tolerance / 4) > 500) ? 500 : tolerance / 4;
-- 
1.7.3.3

