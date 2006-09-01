From: Hong Liu <hong.liu@intel.com>
Subject: Re: [PATCH 1/2]d80211: fix wpa_supplicant reassoc problem
Date: Fri, 01 Sep 2006 11:37:37 +0800
Message-ID: <1157081857.11040.39.camel@devlinux-hong>
References: <1156494728.21483.12.camel@devlinux-hong>
	 <20060830185710.2f6b300f@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16910 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750991AbWIADl5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 23:41:57 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060830185710.2f6b300f@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-31 at 00:57, Jiri Benc wrote:
> On Fri, 25 Aug 2006 16:32:08 +0800, Hong Liu wrote:
> > After key negotiation completed using wpa_supplicant, wpa_supplicant
> > can't reassoc with the AP if we reboot the AP. It always fails at the
> > 4-way handshake.
> > The problem is the key info is not cleared correctly. Thus when
> > wpa_supplicant send the EAPOL-KEY packet, the d80211 stack finds the old
> > key and uses it to encrypt the packet.
> >
> > The patch removes the sta_info when we disassociate with AP.
> 
> Please:
> - add proper Signed-off-by line
> - do not send patches as an attachment
> - Cc: John Linville <linville@tuxdriver.com> as well as me on d80211
>   patches
> 
> > diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
> > index 8caf352..2144b34 100644
> > --- a/net/d80211/ieee80211_sta.c
> > +++ b/net/d80211/ieee80211_sta.c
> > @@ -739,6 +739,14 @@ static void ieee80211_associated(struct
> >               wireless_send_event(dev, SIOCGIWAP, &wrqu, NULL);
> >               mod_timer(&ifsta->timer,
> >                         jiffies + IEEE80211_MONITORING_INTERVAL + 30 * HZ);
> > +
> > +             sta = sta_info_get(local, ifsta->bssid);
> > +             if (sta) {
> > +                     sta_info_free(sta, 0);
> > +                     sta_info_put(sta);
> > +             }
> > +
> > +             ifsta->probereq_poll = 0;
> 
> Wouldn't it be better to move this into the 'else' branch of previous
> 'if' statement (i.e. just before sta_info_put call in the
> ieee80211_associated function)?
> 

Rework the patch according to Jiri's comments.

Signed-off-by: Hong Liu <hong.liu@intel.com>

diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index a933d92..557ba17 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -710,6 +710,8 @@ static void ieee80211_associated(struct 
 				       "range\n",
 				       dev->name, MAC_ARG(ifsta->bssid));
 				disassoc = 1;
+				sta_info_free(sta, 0);
+				ifsta->probereq_poll = 0;
 			} else {
 				ieee80211_send_probe_req(dev, ifsta->bssid,
 							 local->scan_ssid,
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 622b234..5edbd0c 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -197,6 +197,12 @@ #ifdef CONFIG_D80211_VERBOSE_DEBUG
 	       local->mdev->name, MAC_ARG(sta->addr));
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
+	if (sta->key) {
+		ieee80211_key_sysfs_remove(sta->key);
+		ieee80211_key_free(sta->key);
+		sta->key = NULL;
+	}
+
 	rate_control_remove_sta_attrs(local, sta->rate_ctrl_priv, &sta->kobj);
 	ieee80211_sta_sysfs_remove(sta);
 
@@ -244,8 +250,6 @@ void sta_info_free(struct sta_info *sta,
 				kfree(key);
 			}
 		}
-		ieee80211_key_free(sta->key);
-		sta->key = NULL;
 	} else if (sta->key_idx_compression != HW_KEY_IDX_INVALID) {
 		struct ieee80211_key_conf conf;
 		memset(&conf, 0, sizeof(conf));
