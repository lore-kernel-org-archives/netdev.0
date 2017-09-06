From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: hung task in mac80211
Date: Wed, 6 Sep 2017 15:19:22 +0200
Message-ID: <20170906151922.4a320b1d@elisabeth>
References: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg@mail.gmail.com>
        <20170906144019.1c98a636@elisabeth>
        <1504702115.13457.16.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Matteo Croce <mcroce@redhat.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49862 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753494AbdIFNT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 09:19:29 -0400
In-Reply-To: <1504702115.13457.16.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 Sep 2017 14:48:35 +0200
Johannes Berg <johannes@sipsolutions.net> wrote:

> I'll look in a bit - but
> 
> > +			mutex_unlock(&sta->ampdu_mlme.mtx);
> >  			___ieee80211_stop_rx_ba_session(
> >  				sta, tid, WLAN_BACK_RECIPIENT,
> >  				WLAN_REASON_QSTA_TIMEOUT, true);  
> 
> This already has three underscores so shouldn't drop.

Right, of course.

> [...]
> > +			mutex_unlock(&sta->ampdu_mlme.mtx);
> >  			__ieee80211_start_rx_ba_session(sta, 0, 0,
> > 0, 1, tid,  
> 
> maybe this one needs a ___ version then?

Either that, or as it's a single call, perhaps just the following?
Matter of taste I guess...

diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index c92df492e898..377dd3c233d3 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -332,10 +332,13 @@ void ieee80211_ba_session_work(struct work_struct *work)
 				WLAN_REASON_UNSPECIFIED, true);
 
 		if (test_and_clear_bit(tid,
-				       sta->ampdu_mlme.tid_rx_manage_offl))
+				       sta->ampdu_mlme.tid_rx_manage_offl)) {
+			mutex_unlock(&sta->ampdu_mlme.mtx);
 			__ieee80211_start_rx_ba_session(sta, 0, 0, 0, 1, tid,
 							IEEE80211_MAX_AMPDU_BUF,
 							false, true);
+			mutex_lock(&sta->ampdu_mlme.mtx);
+		}
 
 		if (test_and_clear_bit(tid + IEEE80211_NUM_TIDS,
 				       sta->ampdu_mlme.tid_rx_manage_offl))
-- 
Stefano
