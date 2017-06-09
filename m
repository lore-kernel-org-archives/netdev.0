From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Fix inconsistent teardown and release of private
 netdev state.
Date: Fri, 09 Jun 2017 14:45:25 +0200
Message-ID: <1497012325.2424.12.camel@sipsolutions.net>
References: <20170607.155411.201795978436906426.davem@davemloft.net>
         (sfid-20170607_215419_417472_E8ADEEB0)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55830 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751536AbdFIMp3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 08:45:29 -0400
In-Reply-To: <20170607.155411.201795978436906426.davem@davemloft.net> (sfid-20170607_215419_417472_E8ADEEB0)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I hope you don't mind a question or two for my understanding here.
Actually, this got pretty long... but I think there's a bug in here.


(For background, I'm looking into this because I'm interested in what
to do about backporting this to older kernels, or better, how to deal
with it in the backports project that tries to use the normal code as
is, backporting helper functions etc., which won't be possible here)


Under drivers/ in general, I count more than 400 calls to
register_netdev[ice](), but only 39 that set the new needs_free_netdev.
Some will overlap and have the same ops, but still, that's a rather
small portion of them. The logic means those that don't set
needs_free_netdev can't really use the new priv_destructor (previously
destructor), I think? It seems to me that priv_destructor should imply
needs_free_netdev (though not necessarily the other way around).

I guess this must mean that that all others are dealing with the
problem "manually", right? Perhaps needs_free_netdev isn't all that
necessary then?


So then the changes to net/mac80211/iface.c are just because you now
invoke priv_destructor in failure paths in register_netdevice, and that
would now double-free everything, since this was invoked already in the
failure paths - hence the change to only free the netdev in the failure
path.

I think you introduced a bug though - isn't this needed?

--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1816,6 +1816,7 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
                ret = dev_alloc_name(ndev, ndev->name);
                if (ret < 0) {
                        ieee80211_if_free(ndev);
+                       free_netdev(ndev);
                        return ret;
                }
 
There was another caller of ieee80211_if_free() which you modified, and
thus needs the free_netdev() that you removed from it.


Would an alternative have been to not use (priv_)destructor here, and
just free all the data after unregister_netdevice(_many)? This sets the
reg_state to NETREG_UNREGISTERING, so sysfs can no longer look at the
stats afterwards, and it's been unlisted (unlist_netdevice) so can't be
reached through any other means either.

IOW, this would also work and fix the bug above along the way?

diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 915d7e1b4545..23df973d5181 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1213,6 +1213,7 @@ static const struct net_device_ops ieee80211_monitorif_ops = {
 static void ieee80211_if_free(struct net_device *dev)
 {
 	free_percpu(dev->tstats);
+	free_netdev(dev);
 }
 
 static void ieee80211_if_setup(struct net_device *dev)
@@ -1220,8 +1221,6 @@ static void ieee80211_if_setup(struct net_device *dev)
 	ether_setup(dev);
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->netdev_ops = &ieee80211_dataif_ops;
-	dev->needs_free_netdev = true;
-	dev->priv_destructor = ieee80211_if_free;
 }
 
 static void ieee80211_if_setup_no_queue(struct net_device *dev)
@@ -1905,7 +1904,7 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 
 		ret = register_netdevice(ndev);
 		if (ret) {
-			free_netdev(ndev);
+			ieee80211_if_free(ndev);
 			return ret;
 		}
 	}
@@ -1932,6 +1931,7 @@ void ieee80211_if_remove(struct ieee80211_sub_if_data *sdata)
 
 	if (sdata->dev) {
 		unregister_netdevice(sdata->dev);
+		ieee80211_if_free(sdata->dev);
 	} else {
 		cfg80211_unregister_wdev(&sdata->wdev);
 		ieee80211_teardown_sdata(sdata);
@@ -1950,7 +1950,6 @@ void ieee80211_remove_interfaces(struct ieee80211_local *local)
 {
 	struct ieee80211_sub_if_data *sdata, *tmp;
 	LIST_HEAD(unreg_list);
-	LIST_HEAD(wdev_list);
 
 	ASSERT_RTNL();
 
@@ -1971,21 +1970,22 @@ void ieee80211_remove_interfaces(struct ieee80211_local *local)
 	     wiphy_name(local->hw.wiphy), local->open_count);
 
 	mutex_lock(&local->iflist_mtx);
-	list_for_each_entry_safe(sdata, tmp, &local->interfaces, list) {
-		list_del(&sdata->list);
-
+	list_for_each_entry(sdata, &local->interfaces, list) {
 		if (sdata->dev)
 			unregister_netdevice_queue(sdata->dev, &unreg_list);
-		else
-			list_add(&sdata->list, &wdev_list);
 	}
 	mutex_unlock(&local->iflist_mtx);
 	unregister_netdevice_many(&unreg_list);
 
-	list_for_each_entry_safe(sdata, tmp, &wdev_list, list) {
+	list_for_each_entry(sdata, &local->interfaces, list) {
 		list_del(&sdata->list);
-		cfg80211_unregister_wdev(&sdata->wdev);
-		kfree(sdata);
+
+		if (sdata->dev) {
+			ieee80211_if_free(sdata->dev);
+		} else {
+			cfg80211_unregister_wdev(&sdata->wdev);
+			kfree(sdata);
+		}
 	}
 }
 

(I might be tempted to put that in to ease the backporting)

Thanks,
johannes
