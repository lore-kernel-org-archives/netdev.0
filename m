From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: Reset assoc and auth retry counters
Date: Wed, 29 Nov 2006 15:09:28 +0100
Message-ID: <20061129150928.63bf9f02@griffin.suse.cz>
References: <200611282056.05641.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:3535 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S967195AbWK2OJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 09:09:31 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200611282056.05641.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Nov 2006 20:56:05 +0100, Ivo van Doorn wrote:
> After a succesfull authentication and association the matching retry counter
> must be reset to 0.
> Failure to do so will result in failure to authenticate after the interface
> has been deauthenticated. This does not always happen after the first
> deauthentication, but after the interface has been several times been
> deauthenticated it will refuse to authenticate.

Thanks for spotting this, but your fix makes statistics about
authentication/association exported via sysfs useless. The counters
should be reset before a new authentication/association attempt (as is
done in ieee80211_sta_new_auth).

I think this is a more correct fix:

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/ieee80211_sta.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

--- dscape.orig/net/d80211/ieee80211_sta.c
+++ dscape/net/d80211/ieee80211_sta.c
@@ -382,6 +382,14 @@ static void ieee80211_set_associated(str
 	ifsta->last_probe = jiffies;
 }
 
+static void ieee80211_set_disassoc(struct net_device *dev,
+				   struct ieee80211_if_sta *ifsta, int deauth)
+{
+	if (deauth)
+		ifsta->auth_tries = 0;
+	ifsta->assoc_tries = 0;
+	ieee80211_set_associated(dev, ifsta, 0);
+}
 
 static void ieee80211_sta_tx(struct net_device *dev, struct sk_buff *skb,
 			     int encrypt, int probe_resp)
@@ -1023,7 +1031,7 @@ static void ieee80211_rx_mgmt_deauth(str
 				      IEEE80211_RETRY_AUTH_INTERVAL);
 	}
 
-	ieee80211_set_associated(dev, ifsta, 0);
+	ieee80211_set_disassoc(dev, ifsta, 1);
 	ifsta->authenticated = 0;
 }
 
@@ -1066,7 +1074,7 @@ static void ieee80211_rx_mgmt_disassoc(s
 				      IEEE80211_RETRY_AUTH_INTERVAL);
 	}
 
-	ieee80211_set_associated(dev, ifsta, 0);
+	ieee80211_set_disassoc(dev, ifsta, 0);
 }
 
 
@@ -1882,7 +1890,7 @@ void ieee80211_sta_work(void *ptr)
 		       "mixed-cell disabled - disassociate\n", dev->name);
 
 		ieee80211_send_disassoc(dev, ifsta, WLAN_REASON_UNSPECIFIED);
-		ieee80211_set_associated(dev, ifsta, 0);
+		ieee80211_set_disassoc(dev, ifsta, 0);
 	}
 }
 
@@ -2858,7 +2866,7 @@ int ieee80211_sta_deauthenticate(struct 
 		return -EINVAL;
 
 	ieee80211_send_deauth(dev, ifsta, reason);
-	ieee80211_set_associated(dev, ifsta, 0);
+	ieee80211_set_disassoc(dev, ifsta, 1);
 	return 0;
 }
 
@@ -2878,6 +2886,6 @@ int ieee80211_sta_disassociate(struct ne
 		return -1;
 
 	ieee80211_send_disassoc(dev, ifsta, reason);
-	ieee80211_set_associated(dev, ifsta, 0);
+	ieee80211_set_disassoc(dev, ifsta, 1);
 	return 0;
 }


-- 
Jiri Benc
SUSE Labs
