From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] team: fix port list dump for big number of ports
Date: Wed, 29 May 2013 17:02:57 +0200
Message-ID: <1369839777-19158-3-git-send-email-jiri@resnulli.us>
References: <1369839777-19158-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, sasha.levin@oracle.com,
	akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:53725 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966551Ab3E2PDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 11:03:07 -0400
Received: by mail-we0-f180.google.com with SMTP id t60so5358857wes.39
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 08:03:05 -0700 (PDT)
In-Reply-To: <1369839777-19158-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case the port list dump does not fit into one skb currently the
dump would start over again. Fix this by continue from the last dumped
port.

Introduced by commit d90f889e9c (team: handle sending port list in the
same way option list is sent)

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 7c43261..d016a76 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2374,7 +2374,8 @@ static int team_nl_send_port_list_get(struct team *team, u32 portid, u32 seq,
 	bool incomplete;
 	int i;
 
-	port = list_first_entry(&team->port_list, struct team_port, list);
+	port = list_first_entry_or_null(&team->port_list,
+					struct team_port, list);
 
 start_again:
 	err = __send_and_alloc_skb(&skb, team, portid, send_func);
@@ -2402,8 +2403,8 @@ start_again:
 		err = team_nl_fill_one_port_get(skb, one_port);
 		if (err)
 			goto errout;
-	} else {
-		list_for_each_entry(port, &team->port_list, list) {
+	} else if (port) {
+		list_for_each_entry_from(port, &team->port_list, list) {
 			err = team_nl_fill_one_port_get(skb, port);
 			if (err) {
 				if (err == -EMSGSIZE) {
-- 
1.7.11.7
