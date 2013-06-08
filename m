From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/3] team: check return value of team_get_port_by_index_rcu() for NULL
Date: Sat,  8 Jun 2013 15:00:53 +0200
Message-ID: <1370696455-12221-2-git-send-email-jiri@resnulli.us>
References: <1370696455-12221-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:52830 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107Ab3FHNBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jun 2013 09:01:03 -0400
Received: by mail-ea0-f182.google.com with SMTP id d10so396970eaj.13
        for <netdev@vger.kernel.org>; Sat, 08 Jun 2013 06:01:01 -0700 (PDT)
In-Reply-To: <1370696455-12221-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

team_get_port_by_index_rcu() might return NULL due to race between port
removal and skb tx path. Panic is easily triggeable when txing packets
and adding/removing port in a loop.

introduced by commit 3d249d4ca "net: introduce ethernet teaming device"
and commit 753f993911b "team: introduce random mode" (for random mode)

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team_mode_random.c     | 2 ++
 drivers/net/team/team_mode_roundrobin.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/team/team_mode_random.c b/drivers/net/team/team_mode_random.c
index 5ca14d4..7f032e2 100644
--- a/drivers/net/team/team_mode_random.c
+++ b/drivers/net/team/team_mode_random.c
@@ -28,6 +28,8 @@ static bool rnd_transmit(struct team *team, struct sk_buff *skb)
 
 	port_index = random_N(team->en_port_count);
 	port = team_get_port_by_index_rcu(team, port_index);
+	if (unlikely(!port))
+		goto drop;
 	port = team_get_first_port_txable_rcu(team, port);
 	if (unlikely(!port))
 		goto drop;
diff --git a/drivers/net/team/team_mode_roundrobin.c b/drivers/net/team/team_mode_roundrobin.c
index d268e4d..472623f 100644
--- a/drivers/net/team/team_mode_roundrobin.c
+++ b/drivers/net/team/team_mode_roundrobin.c
@@ -32,6 +32,8 @@ static bool rr_transmit(struct team *team, struct sk_buff *skb)
 
 	port_index = rr_priv(team)->sent_packets++ % team->en_port_count;
 	port = team_get_port_by_index_rcu(team, port_index);
+	if (unlikely(!port))
+		goto drop;
 	port = team_get_first_port_txable_rcu(team, port);
 	if (unlikely(!port))
 		goto drop;
-- 
1.7.11.7
