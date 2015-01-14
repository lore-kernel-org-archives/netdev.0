From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] team: avoid possible underflow of count_pending value for notify_peers and mcast_rejoin
Date: Wed, 14 Jan 2015 18:15:30 +0100
Message-ID: <1421255730-10681-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:65429 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbbANRPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 12:15:33 -0500
Received: by mail-we0-f171.google.com with SMTP id u56so10050353wes.2
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 09:15:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is fixing a race condition that may cause setting
count_pending to -1, which results in unwanted big bulk of arp messages
(in case of "notify peers").

Consider following scenario:

count_pending == 2
   CPU0                                           CPU1
					team_notify_peers_work
					  atomic_dec_and_test (dec count_pending to 1)
					  schedule_delayed_work
 team_notify_peers
   atomic_add (adding 1 to count_pending)
					team_notify_peers_work
					  atomic_dec_and_test (dec count_pending to 1)
					  schedule_delayed_work
					team_notify_peers_work
					  atomic_dec_and_test (dec count_pending to 0)
   schedule_delayed_work
					team_notify_peers_work
					  atomic_dec_and_test (dec count_pending to -1)

Fix this race by using atomic_dec_if_positive - that will prevent
count_pending running under 0.

Fixes: fc423ff00df3a1955441 ("team: add peer notification")
Fixes: 492b200efdd20b8fcfd  ("team: add support for sending multicast rejoins")
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/team/team.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 43bcfff..4b2bfc5 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -622,6 +622,7 @@ static int team_change_mode(struct team *team, const char *kind)
 static void team_notify_peers_work(struct work_struct *work)
 {
 	struct team *team;
+	int val;
 
 	team = container_of(work, struct team, notify_peers.dw.work);
 
@@ -629,9 +630,14 @@ static void team_notify_peers_work(struct work_struct *work)
 		schedule_delayed_work(&team->notify_peers.dw, 0);
 		return;
 	}
+	val = atomic_dec_if_positive(&team->notify_peers.count_pending);
+	if (val < 0) {
+		rtnl_unlock();
+		return;
+	}
 	call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, team->dev);
 	rtnl_unlock();
-	if (!atomic_dec_and_test(&team->notify_peers.count_pending))
+	if (val)
 		schedule_delayed_work(&team->notify_peers.dw,
 				      msecs_to_jiffies(team->notify_peers.interval));
 }
@@ -662,6 +668,7 @@ static void team_notify_peers_fini(struct team *team)
 static void team_mcast_rejoin_work(struct work_struct *work)
 {
 	struct team *team;
+	int val;
 
 	team = container_of(work, struct team, mcast_rejoin.dw.work);
 
@@ -669,9 +676,14 @@ static void team_mcast_rejoin_work(struct work_struct *work)
 		schedule_delayed_work(&team->mcast_rejoin.dw, 0);
 		return;
 	}
+	val = atomic_dec_if_positive(&team->mcast_rejoin.count_pending);
+	if (val < 0) {
+		rtnl_unlock();
+		return;
+	}
 	call_netdevice_notifiers(NETDEV_RESEND_IGMP, team->dev);
 	rtnl_unlock();
-	if (!atomic_dec_and_test(&team->mcast_rejoin.count_pending))
+	if (val)
 		schedule_delayed_work(&team->mcast_rejoin.dw,
 				      msecs_to_jiffies(team->mcast_rejoin.interval));
 }
-- 
1.9.3
