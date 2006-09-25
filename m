From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] small fix for d80211:sta_info
Date: Mon, 25 Sep 2006 18:04:03 +0200
Message-ID: <20060925180403.0d4c2ee9@griffin.suse.cz>
References: <4517DB26.8040008@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:28108 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750843AbWIYQEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 12:04:05 -0400
To: Savin Zlobec <savinz@users.sourceforge.net>
In-Reply-To: <4517DB26.8040008@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 25 Sep 2006 15:35:34 +0200, Savin Zlobec wrote:
> while testing the rt2x00 driver I've found a
> problem in d80211 stack which results in kernel panic.
> I experienced kernel panic every time I unloaded the
> rt2x00 driver module after associating with my AP.
> 
> The problem traced down to sta_info_proc_add_task
> being called with local->deleted_sta_list != empty
> and local->sta_list == empty which resulted in
> a call to ieee80211_sta_sysfs_add with a bogus sta.
> 
> Attached is a fix for the mentioned case.

Thanks for the patch!

I think this is a slightly better fix for the problem:

---
Subject: [PATCH] d80211: fix invalid pointer dereference

When deleted_sta_list is nonempty and sta_list is empty in
sta_info_proc_add_task, an invalid sta pointer was dereferenced.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/sta_info.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

--- dscape.orig/net/d80211/sta_info.c
+++ dscape/net/d80211/sta_info.c
@@ -354,13 +354,14 @@ static void sta_info_proc_add_task(void 
 	}
 
 	while (1) {
+		sta = NULL;
 		spin_lock_bh(&local->sta_lock);
-		list_for_each_entry_safe(sta, tmp, &local->sta_list, list) {
-			if (!sta->sysfs_registered) {
+		list_for_each_entry(tmp, &local->sta_list, list) {
+			if (!tmp->sysfs_registered) {
+				sta = tmp;
 				__sta_info_get(sta);
 				break;
 			}
-			sta = NULL;
 		}
 		spin_unlock_bh(&local->sta_lock);
 

-- 
Jiri Benc
SUSE Labs
