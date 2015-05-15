From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 6/6] tcp: halves tcp_mem[] limits
Date: Fri, 15 May 2015 07:53:58 -0700
Message-ID: <1431701638-24451-7-git-send-email-edumazet@google.com>
References: <1431701638-24451-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>, Jason Baron <jbaron@akamai.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f73.google.com ([209.85.192.73]:33687 "EHLO
	mail-qg0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754101AbbEOPBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 11:01:35 -0400
Received: by qgdq107 with SMTP id q107so318552qgd.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 08:01:34 -0700 (PDT)
In-Reply-To: <1431701638-24451-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allowing tcp to use ~19% of physical memory is way too much,
and allowed bugs to be hidden. Add to this that some drivers use a full
page per incoming frame, so real cost can be twice the advertized one.

Reduce tcp_mem by 50 % as a first step to sanity.

tcp_mem[0,1,2] defaults are now 4.68%, 6.25%, 9.37% of physical memory.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9eabfd3e0925..c724195e5862 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3068,11 +3068,12 @@ __setup("thash_entries=", set_thash_entries);
 
 static void __init tcp_init_mem(void)
 {
-	unsigned long limit = nr_free_buffer_pages() / 8;
+	unsigned long limit = nr_free_buffer_pages() / 16;
+
 	limit = max(limit, 128UL);
-	sysctl_tcp_mem[0] = limit / 4 * 3;
-	sysctl_tcp_mem[1] = limit;
-	sysctl_tcp_mem[2] = sysctl_tcp_mem[0] * 2;
+	sysctl_tcp_mem[0] = limit / 4 * 3;		/* 4.68 % */
+	sysctl_tcp_mem[1] = limit;			/* 6.25 % */
+	sysctl_tcp_mem[2] = sysctl_tcp_mem[0] * 2;	/* 9.37 % */
 }
 
 void __init tcp_init(void)
-- 
2.2.0.rc0.207.ga3a616c
