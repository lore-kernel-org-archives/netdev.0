From: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: d80211 deadlock with wpa_supplicant and rmmod
Date: Sat, 14 Jul 2007 15:24:14 +0200
Message-ID: <20070714152414.0d9d00ea@logostar.upir.cz>
References: <1caff7430707111617o70a534a5x2cf6b611a91f301a@mail.gmail.com>
	<20070711234153.GB5099@tuxdriver.com>
	<1184234538.6669.30.camel@johannes.berg>
	<1caff7430707130505r579ef08cmacc6c77f7535a66c@mail.gmail.com>
	<1184363116.3928.4.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: seventh guardian <seventhguardian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1184363116.3928.4.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Jul 2007 23:45:16 +0200, Johannes Berg wrote:
> On Fri, 2007-07-13 at 13:05 +0100, seventh guardian wrote:
> 
> > Hello, sorry for the delay but I only managed to try it out today..
> > I've applied the patch and tortured the system as far as I could, and
> > no hang at all :)
> > 
> > I've read the thread and it apparently replaces one bad problem for a
> > lesser one, so I understand if it's not applied.. But at least there
> > is a place in the code to point as the culprit :)
> 
> It definitely should be applied anyway :) I guess John just hasn't
> caught up with all threads yet.

That's my fault, I missed that patch. If everybody put [PATCH] to subject
of mails containing a patch... (sigh)

> John: This is about the patch in the "mac80211/bcm43xx deadlock" thread
> from Michael, it kills some rtnl_lock()/unlock() that causes this
> deadlock.

Yes, please apply (the patch is below). Of course, we'll need a proper fix
but until it is ready this should be applied to prevent deadlocks.

Thanks,

 Jiri

---

Subject: [PATCH] mac80211: remove rtnl locking in ieee80211_sta.c
From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>

The rtnl is held in ieee80211_sta.c to prevent some potential races with
userspace. Unfortunately, it also has the potential for deadlocks on
interface down. This patch removes the rtnl locking to eliminate the
deadlocks.

Signed-off-by: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
---

 net/mac80211/ieee80211_sta.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 91b545c..4862797 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -25,7 +25,6 @@
 #include <linux/wireless.h>
 #include <linux/random.h>
 #include <linux/etherdevice.h>
-#include <linux/rtnetlink.h>
 #include <net/iw_handler.h>
 #include <asm/types.h>
 
@@ -2073,12 +2072,9 @@ static int ieee80211_sta_config_auth(struct net_device *dev,
 	struct ieee80211_sta_bss *bss, *selected = NULL;
 	int top_rssi = 0, freq;
 
-	rtnl_lock();
-
 	if (!ifsta->auto_channel_sel && !ifsta->auto_bssid_sel &&
 	    !ifsta->auto_ssid_sel) {
 		ifsta->state = IEEE80211_AUTHENTICATE;
-		rtnl_unlock();
 		ieee80211_sta_reset_auth(dev, ifsta);
 		return 0;
 	}
@@ -2121,7 +2117,6 @@ static int ieee80211_sta_config_auth(struct net_device *dev,
 		ieee80211_sta_set_bssid(dev, selected->bssid);
 		ieee80211_rx_bss_put(dev, selected);
 		ifsta->state = IEEE80211_AUTHENTICATE;
-		rtnl_unlock();
 		ieee80211_sta_reset_auth(dev, ifsta);
 		return 0;
 	} else {
@@ -2132,7 +2127,6 @@ static int ieee80211_sta_config_auth(struct net_device *dev,
 		} else
 			ifsta->state = IEEE80211_DISABLED;
 	}
-	rtnl_unlock();
 	return -1;
 }
 

-- 
Jiri Benc
SUSE Labs
