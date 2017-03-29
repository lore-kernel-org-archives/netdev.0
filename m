From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [REGRESSION] mac80211: IBSS vif queue stopped when started
 after 11s vif
Date: Wed, 29 Mar 2017 13:53:06 +0200
Message-ID: <1490788386.7948.21.camel@sipsolutions.net>
References: <1978424.XTv2Qph05K@bentobox>
         <1490773761.7948.3.camel@sipsolutions.net> <5090047.94hdUy33Q8@bentobox>
         (sfid-20170329_130745_753898_724474CD)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
To: Sven Eckelmann <sven.eckelmann-lv6y7wLVQPlWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5090047.94hdUy33Q8@bentobox> (sfid-20170329_130745_753898_724474CD)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


>     if (local->ops->wake_tx_queue)
>     		return;
> 
> evaluates to true. The rest rest of the function is therefore always
> skipped for ath9k.

Ahh, yes, ok.

> Removing this is enough to fix the problem. And now you will propably
> say "hey, this is not my code". And this is the reason why I have now
> CC'ed the author of 80a83cfc434b ("mac80211: skip netdev queue
> control with software queuing"). This change in
> ieee80211_propagate_queue_wake is basically breaking 
> the (delayed) startup of the ibss netdev queue [1] when the device
> was offchan during the ieee80211_do_open of the ibss interface.
> 
> Not sure whether removing it in ieee80211_propagate_queue_wake will
> have other odd side effects with software queuing. Maybe Michal
> Kazior can tell us if it is safe to remove it.

No, it's the other way around.

Michal's patches correctly added a test for this to
__ieee80211_stop_queue(), the only missing thing is that this test
should also be in ieee80211_do_open() like this:

diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 40813dd3301c..5bb0c5012819 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -718,7 +718,8 @@ int ieee80211_do_open(struct wireless_dev *wdev, bool coming_up)
 	ieee80211_recalc_ps(local);
 
 	if (sdata->vif.type == NL80211_IFTYPE_MONITOR ||
-	    sdata->vif.type == NL80211_IFTYPE_AP_VLAN) {
+	    sdata->vif.type == NL80211_IFTYPE_AP_VLAN ||
+	    local->ops->wake_tx_queue) {
 		/* XXX: for AP_VLAN, actually track AP queues */
 		netif_tx_start_all_queues(dev);
 	} else if (dev) {

johannes
