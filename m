From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net PATCH] net: Do not allow negative values for busy_read and
 busy_poll sysctl interfaces
Date: Fri, 24 Mar 2017 09:38:03 -0700
Message-ID: <20170324163630.14764.75429.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33428 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751520AbdCXQiG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 12:38:06 -0400
Received: by mail-pg0-f67.google.com with SMTP id 79so1436285pgf.0
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 09:38:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change basically codifies what I think was already the limitations on
the busy_poll and busy_read sysctl interfaces.  We weren't checking the
lower bounds and as such could input negative values. The behavior when
that was used was dependent on the architecture. In order to prevent any
issues with that I am just disabling support for values less than 0 since
this way we don't have to worry about any odd behaviors.

By limiting the sysctl values this way it also makes it consistent with how
we handle the SO_BUSY_POLL socket option since the value appears to be
reported as a signed integer value and negative values are rejected.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/core/sysctl_net_core.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 4ead336e14ea..7f9cc400eca0 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -408,14 +408,16 @@ static int proc_do_rss_key(struct ctl_table *table, int write,
 		.data		= &sysctl_net_busy_poll,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
 	},
 	{
 		.procname	= "busy_read",
 		.data		= &sysctl_net_busy_read,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
 	},
 #endif
 #ifdef CONFIG_NET_SCHED
