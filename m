From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 2/2] team: avoid using variable-length array
Date: Thu, 17 Nov 2011 15:16:05 +0100
Message-ID: <1321539365-1125-2-git-send-email-jpirko@redhat.com>
References: <1321539365-1125-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59639 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932081Ab1KQOQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 09:16:15 -0500
In-Reply-To: <1321539365-1125-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apparently using variable-length array is not correct
(https://lkml.org/lkml/2011/10/23/25). So remove it.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 5b169c1..c48ef19 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -96,10 +96,13 @@ int team_options_register(struct team *team,
 			  size_t option_count)
 {
 	int i;
-	struct team_option *dst_opts[option_count];
+	struct team_option **dst_opts;
 	int err;
 
-	memset(dst_opts, 0, sizeof(dst_opts));
+	dst_opts = kzalloc(sizeof(struct team_option *) * option_count,
+			   GFP_KERNEL);
+	if (!dst_opts)
+		return -ENOMEM;
 	for (i = 0; i < option_count; i++, option++) {
 		struct team_option *dst_opt;
 
@@ -119,12 +122,14 @@ int team_options_register(struct team *team,
 	for (i = 0; i < option_count; i++)
 		list_add_tail(&dst_opts[i]->list, &team->option_list);
 
+	kfree(dst_opts);
 	return 0;
 
 rollback:
 	for (i = 0; i < option_count; i++)
 		kfree(dst_opts[i]);
 
+	kfree(dst_opts);
 	return err;
 }
 
-- 
1.7.6
