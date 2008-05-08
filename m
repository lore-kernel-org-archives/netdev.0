From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 1/4][MAC80211]: Fix GFP_KERNEL allocation under read
	lock.
Date: Thu, 8 May 2008 14:51:23 -0400
Message-ID: <20080508185123.GA7250@tuxdriver.com>
References: <4820997E.1070305@openvz.org> <20080506.134047.86330538.davem@davemloft.net> <4821442D.8010801@openvz.org> <20080506.225950.181623233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xemul@openvz.org, johannes@sipsolutions.net, netdev@axxeo.de,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3477 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932859AbYEHTax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 15:30:53 -0400
Content-Disposition: inline
In-Reply-To: <20080506.225950.181623233.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2008 at 10:59:50PM -0700, David Miller wrote:

> Whether you should resubmit your patch is up to the wireless
> folks :-)

If you don't do it Ingo Oeser's way then it looks like you would need
a patch like the one below.  And with the patch below, the last hunk
of your patch will probably need to be fixed-up to match.

Should I apply the patch below and wait for you to rebase and
resubmit yours?

---

From: John W. Linville <linville@tuxdriver.com>
Subject: [PATCH] mac80211 mesh: add missing check for kmalloc failure

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 net/mac80211/mesh_pathtbl.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index 5845dc2..ab54f77 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -171,6 +171,12 @@ int mesh_path_add(u8 *dst, struct net_device *dev)
 	new_mpath->flags = 0;
 	skb_queue_head_init(&new_mpath->frame_queue);
 	new_node = kmalloc(sizeof(struct mpath_node), GFP_KERNEL);
+	if (!new_node) {
+		atomic_dec(&sdata->u.sta.mpaths);
+		kfree(new_mpath);
+		err = -ENOMEM;
+		goto endadd2;
+	}
 	new_node->mpath = new_mpath;
 	new_mpath->timer.data = (unsigned long) new_mpath;
 	new_mpath->timer.function = mesh_path_timer;
-- 
1.5.3.3

-- 
John W. Linville
linville@tuxdriver.com
