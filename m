From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net 1/2] caif: Bugfix list_del_rcu race in cfmuxl_ctrlcmd.
Date: Thu,  2 Feb 2012 12:21:02 +0100
Message-ID: <1328181663-13853-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m020-f174.google.com ([209.85.217.174]:61150 "EHLO
	mail-lpp01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755314Ab2BBLVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 06:21:07 -0500
Received: by lbom4 with SMTP id m4so338134lbo.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 03:21:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always use cfmuxl_remove_uplayer when removing a up-layer.
cfmuxl_ctrlcmd() can be called independently and in parallel with
cfmuxl_remove_uplayer(). The race between them could cause list_del_rcu
to be called on a node which has been already taken out from the list.
That lead to a (rare) crash on accessing poisoned node->prev inside
list_del_rcu.

This fix ensures that deletion are done holding the same lock.

Reported-by: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>
Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfmuxl.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index b36f24a..94b0861 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -248,7 +248,6 @@ static void cfmuxl_ctrlcmd(struct cflayer *layr, en=
um caif_ctrlcmd ctrl,
 {
 	struct cfmuxl *muxl =3D container_obj(layr);
 	struct cflayer *layer;
-	int idx;
=20
 	rcu_read_lock();
 	list_for_each_entry_rcu(layer, &muxl->srvl_list, node) {
@@ -257,14 +256,9 @@ static void cfmuxl_ctrlcmd(struct cflayer *layr, e=
num caif_ctrlcmd ctrl,
=20
 			if ((ctrl =3D=3D _CAIF_CTRLCMD_PHYIF_DOWN_IND ||
 				ctrl =3D=3D CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND) &&
-					layer->id !=3D 0) {
-
-				idx =3D layer->id % UP_CACHE_SIZE;
-				spin_lock_bh(&muxl->receive_lock);
-				RCU_INIT_POINTER(muxl->up_cache[idx], NULL);
-				list_del_rcu(&layer->node);
-				spin_unlock_bh(&muxl->receive_lock);
-			}
+					layer->id !=3D 0)
+				cfmuxl_remove_uplayer(layr, layer->id);
+
 			/* NOTE: ctrlcmd is not allowed to block */
 			layer->ctrlcmd(layer, ctrl, phyid);
 		}
--=20
1.7.5.4
