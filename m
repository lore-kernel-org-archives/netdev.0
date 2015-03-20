From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/3] net: increase sk_[max_]ack_backlog
Date: Thu, 19 Mar 2015 19:04:21 -0700
Message-ID: <1426817061-21421-4-git-send-email-edumazet@google.com>
References: <1426817061-21421-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:34012 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbbCTCMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 22:12:54 -0400
Received: by ykq142 with SMTP id 142so3435747ykq.1
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 19:12:53 -0700 (PDT)
In-Reply-To: <1426817061-21421-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk_ack_backlog & sk_max_ack_backlog were 16bit fields, meaning
listen() backlog was limited to 65535.

It is time to increase the width to allow much bigger backlog,
if admins change /proc/sys/net/core/somaxconn &
/proc/sys/net/ipv4/tcp_max_syn_backlog default values.

Tested:

echo 5000000 >/proc/sys/net/core/somaxconn
echo 5000000 >/proc/sys/net/ipv4/tcp_max_syn_backlog

Ran a SYNFLOOD test against a listener using listen(fd, 5000000)

myhost~# grep request_sock_TCP /proc/slabinfo
request_sock_TCP  4185642 4411940    304   13    1 : tunables   54   27    8 : slabdata 339380 339380      0

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h         | 4 ++--
 net/core/sysctl_net_core.c | 2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index e0360f5a53e9..3f9b8ce56948 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -405,8 +405,8 @@ struct sock {
 	rwlock_t		sk_callback_lock;
 	int			sk_err,
 				sk_err_soft;
-	unsigned short		sk_ack_backlog;
-	unsigned short		sk_max_ack_backlog;
+	u32			sk_ack_backlog;
+	u32			sk_max_ack_backlog;
 	__u32			sk_priority;
 #if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
 	__u32			sk_cgrp_prioidx;
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 433424804284..e1c85db5216f 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -24,7 +24,6 @@
 
 static int zero = 0;
 static int one = 1;
-static int ushort_max = USHRT_MAX;
 
 static int net_msg_warn;	/* Unused, but still a sysctl */
 
@@ -401,7 +400,6 @@ static struct ctl_table netns_core_table[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.extra1		= &zero,
-		.extra2		= &ushort_max,
 		.proc_handler	= proc_dointvec_minmax
 	},
 	{ }
-- 
2.2.0.rc0.207.ga3a616c
