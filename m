From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] drop_monitor: allow more events per second
Date: Thu, 19 Apr 2012 19:16:21 +0200
Message-ID: <1334855781.2395.203.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35853 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755938Ab2DSRQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 13:16:29 -0400
Received: by wejx9 with SMTP id x9so5543405wej.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 10:16:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It seems there is a logic error in trace_drop_common(), since we store
only 64 drops, even if they are from same location.

This fix is a one liner, but we probably need more work to avoid useless
atomic dec/inc

Now I can watch 1 Mpps drops through dropwatch...

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
---
Neil, it seems this code is not SMP/preempt safe. Worker can free our
data under us, and genlmsg_new() can return NULL under stress.

 net/core/drop_monitor.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 7f36b38..5c3c81a 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -150,6 +150,7 @@ static void trace_drop_common(struct sk_buff *skb, void *location)
 	for (i = 0; i < msg->entries; i++) {
 		if (!memcmp(&location, msg->points[i].pc, sizeof(void *))) {
 			msg->points[i].count++;
+			atomic_inc(&data->dm_hit_count);
 			goto out;
 		}
 	}
