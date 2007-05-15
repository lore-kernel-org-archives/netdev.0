From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Panic in ieee_80211_ibss_add_sta when trying to join ad-hoc network (rt2500pci)
Date: Tue, 15 May 2007 13:12:02 -0400
Message-ID: <20070515171202.GD15105@tuxdriver.com>
References: <20070515152842.GA26481@charon.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David LAMPARTER <lists@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2398 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757272AbXEORds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 13:33:48 -0400
Content-Disposition: inline
In-Reply-To: <20070515152842.GA26481@charon.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 15, 2007 at 05:28:42PM +0200, David LAMPARTER wrote:

> BUG: unable to handle kernel NULL pointer derference at virtual address 00000218
> [...]
> EIP is at ieee80211_ibss_add_sta+0xae/0x130
> [...]
> EIP: [<c05773fe>] ieee_80211_ibss_add_sta+0xae/0x130 SS:ESP 0068:f641dc38
> Kernel panic - not syncing: Fatal exception in interrupt
> 
> The bug seems to be triggered as soon as the stack tries to
> join my router's ad-hoc; it happen either directly when
> doing "ip l s wlan0 up" as well as when doing
> "iwconfig wlan0 essid equinox" (when it did not immediately
> find the network).

Probably because of this:

	struct ieee80211_sub_if_data *sdata = NULL;
...
	sta->supp_rates = sdata->u.sta.supp_rates_bits;

Patch below...does this work better?  Looks like upstream needs
it too...

John

---
Avoid sdata null pointer dereference in ieee80211_ibss_add_sta.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 net/mac80211/ieee80211_sta.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index a36c6f3..dd36cc6 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -3154,7 +3154,7 @@ struct sta_info * ieee80211_ibss_add_sta(struct net_device *dev,
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct sta_info *sta;
-	struct ieee80211_sub_if_data *sdata = NULL;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	/* TODO: Could consider removing the least recently used entry and
 	 * allow new one to be added. */

-- 
John W. Linville
linville@tuxdriver.com
