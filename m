From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: fix softlockup in hw_scan card when rmmod
Date: Wed, 20 Dec 2006 13:21:06 +0100
Message-ID: <20061220132106.4634f818@griffin.suse.cz>
References: <1166597031.22413.11.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:36857 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754806AbWLTMUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 07:20:16 -0500
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1166597031.22413.11.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Dec 2006 14:43:51 +0800, Hong Liu wrote:
> The local->scan_work.data is not clear after scan is completed.
> 
> This will cause softlockup when removing driver module because 
> the local->scan_work is not initialized for hw_scan card
> and we are trying to cancel the scan_work with an uninitialized timer_list.

I think this is a better fix:
---
Subject: [PATCH] d80211: do not cancel uninitialized work

When ops->hw_scan is set, scan_work is never initialized thus canceling it
causes weird problems.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/ieee80211.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -2082,7 +2082,8 @@ void ieee80211_if_shutdown(struct net_de
 	case IEEE80211_IF_TYPE_IBSS:
 		sdata->u.sta.state = IEEE80211_DISABLED;
 		cancel_delayed_work(&sdata->u.sta.work);
-		if (local->scan_work.data == sdata->dev) {
+		if (!local->ops->hw_scan &&
+		    local->scan_work.data == sdata->dev) {
 			local->sta_scanning = 0;
 			cancel_delayed_work(&local->scan_work);
 			flush_scheduled_work();
@@ -4660,7 +4661,7 @@ void ieee80211_unregister_hw(struct ieee
 
 	if (local->stat_time)
 		del_timer_sync(&local->stat_timer);
-	if (local->scan_work.data) {
+	if (!local->ops->hw_scan && local->scan_work.data) {
 		local->sta_scanning = 0;
 		cancel_delayed_work(&local->scan_work);
 		flush_scheduled_work();


Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
