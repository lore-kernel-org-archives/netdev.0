From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ppp: defer netns reference release for ppp channel
Date: Tue,  5 Jul 2016 22:12:36 -0700
Message-ID: <1467781956-2229-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Matt.Bennett@alliedtelesis.co.nz,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	Guillaume Nault <g.nault@alphalink.fr>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35413 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674AbcGFFOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 01:14:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt reported that we have a NULL pointer dereference
in ppp_pernet() from ppp_connect_channel(),
i.e. pch->chan_net is NULL.

This is due to that a parallel ppp_unregister_channel()
could happen while we are in ppp_connect_channel(), during
which pch->chan_net set to NULL. Since we need a reference
to net per channel, it makes sense to sync the refcnt
with the life time of the channel, therefore we should
release this reference when we destroy it.

Fixes: 1f461dcdd296 ("ppp: take reference on channels netns")
Reported-by: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Cc: Paul Mackerras <paulus@samba.org>
Cc: linux-ppp@vger.kernel.org
Cc: Guillaume Nault <g.nault@alphalink.fr>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/ppp/ppp_generic.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 8dedafa..a30ee42 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -2601,8 +2601,6 @@ ppp_unregister_channel(struct ppp_channel *chan)
 	spin_lock_bh(&pn->all_channels_lock);
 	list_del(&pch->list);
 	spin_unlock_bh(&pn->all_channels_lock);
-	put_net(pch->chan_net);
-	pch->chan_net = NULL;
 
 	pch->file.dead = 1;
 	wake_up_interruptible(&pch->file.rwait);
@@ -3136,6 +3134,9 @@ ppp_disconnect_channel(struct channel *pch)
  */
 static void ppp_destroy_channel(struct channel *pch)
 {
+	put_net(pch->chan_net);
+	pch->chan_net = NULL;
+
 	atomic_dec(&channel_count);
 
 	if (!pch->file.dead) {
-- 
1.8.4.5
