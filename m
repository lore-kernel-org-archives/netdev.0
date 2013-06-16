From: Zhe Wen <zhewen08-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Lose AP-STA connection on changing channel width
Date: Sat, 15 Jun 2013 19:18:58 -0700
Message-ID: <CAG=xfvNUkuQHQ8+PeOsL99zWhpVZtYkTZPbSSROB7J-4bxA4oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Developers!

I am trying to change channel type/width (HT20/HT40+) on the both STA
and AP side in a simple system consists of only 1 STA and the AP.

AP is started using hostapd under HT20 and STA thereafter connects to
it using also HT20. But when AP changes its channel type to HT40+
using ieee80211_set_channel_type() and ath9k_hw_set_channel_regs(), it
will lose connection to STA. The way I do channel type change
coordination is: STA sends an action frame to AP, AP sends back ACK
frame and changes its channel type; STA changes its channel type on
receiving the ACK.

I read about this solution
(http://eznemegy.blog.hu/2008/12/14/using_rt2x00_wireless_driver_with_hostapd/fullcommentlist/1)
of hacking into hostapd, which didn't work...

It would be great if you more experienced would love to help me with
this problem!

related code:

/* zhe: on receiving NCW action frame */
switch (mgmt->u.action.u.ht_ncw.action) {
case WLAN_HT_ACTION_NOTIFY_CHANWIDTH:
    printk("<1>zhe: ncw action frame received: %d\n",
mgmt->u.action.u.ht_ncw.ncw_control);
    // zhe: change channel width, init rate table
    struct ieee80211_supported_band *sband;
    sband = rx->local->hw.wiphy->bands[status->band];
    u8 ncw = mgmt->u.action.u.ht_ncw.ncw_control;
    enum nl80211_channel_type chantype;
    switch (mgmt->u.action.u.ht_ncw.ncw_control) {
    case WLAN_HT_NCW_CONTROL_20MHZ:
        printk("<1>zhe: change to 20MHZ BW\n");
        rx->sta->sta.ht_cap.cap &= ~IEEE80211_HT_CAP_SUP_WIDTH_20_40;
        rx->sta->sta.ht_cap.cap |= IEEE80211_HT_CAP_SGI_20;
        local->hw.conf.channel_type = NL80211_CHAN_HT20;
        chantype = NL80211_CHAN_HT20;
        break;
    case WLAN_HT_NCW_CONTROL_OTHER:
        printk("<1>zhe: change to 40MHZ BW\n");
        rx->sta->sta.ht_cap.cap &= ~IEEE80211_HT_CAP_SGI_20;
        rx->sta->sta.ht_cap.cap |= IEEE80211_HT_CAP_SUP_WIDTH_20_40;
        local->hw.conf.channel_type = NL80211_CHAN_HT40PLUS;
        chantype = NL80211_CHAN_HT40PLUS;
        break;
    }
    // on AP side, the implementation of RC_BW_CHANGED is exactly the same
    // with the dirver build-in code for STA rate update
    rate_control_rate_update(local, sband, rx->sta,IEEE80211_RC_BW_CHANGED);
    ieee80211_set_channel_type(local, sdata, chantype);

    int ret;
    // i add this function, which calls ath9k_hw_set_channel_regs() to
    // to config channel (e.g. CHANNEL_A_HT20, CHANNEL_A_HT40PLUS)
    ret = ieee80211_hw_set_channel_type(local, chantype);

    goto handled;


Thanks in advance!!
Zhe

--
Zhe Wen
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
