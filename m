From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [PATCH 3/9] d80211: better deallocation of mdev
Date: Tue, 18 Jul 2006 20:07:34 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F01565A43@dhost002-46.dex002.intermedia.net>
References: <20060718154523.E380E483BC@silver.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:20878 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932478AbWGSDHy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 23:07:54 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20060718154523.E380E483BC@silver.suse.cz>
To: "Jiri Benc" <jbenc@suse.cz>, <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

I have been thinking about a slightly different approach for the master
device. Since the master device represents the physical hardware, I am
thinking that the hardware driver could register the master device
directly itself. It would use the normal netdev_register call to do so.
Received frames would be marked as having a protocol type of 802.11, and
the 802.11 code would register itself as a protocol handler for this
protocol type. Now netif_rx() could be used within the hardware driver
to pass frames to the kernel 802.11 code - this has the benefit of
better performance for the hardirq/softirq transition than the current
scheme. On the transmit side - currently the 802.11 code does much
processing within the hard_start_xmit function on the master device. I
would move all this processing into the 802.11 qdisc - putting it into
the dequeue function. Now the hard_start_xmit function would be the real
hardware drivers transmit function.

What do you think?

Simon
 

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Jiri Benc
Sent: Tuesday, July 18, 2006 8:45 AM
To: netdev@vger.kernel.org
Subject: [PATCH 3/9] d80211: better deallocation of mdev

Master device and ieee80211_local are allocated separately now, so
master device can be freed by the same function as other virtual
interfaces.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |    2 +-
 net/d80211/ieee80211_iface.c |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

603ee5045dad050a66b94a847cd5385fc7678ce9
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c index
549c8a4..3d7091a 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4534,7 +4534,7 @@ void ieee80211_free_hw(struct net_device  {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 
-	free_netdev(dev);
+	ieee80211_if_free(dev);
 	ieee80211_dev_free(local);
 }
 
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 5abd713..566bb36 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -337,7 +337,8 @@ void ieee80211_if_free(struct net_device  {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 
-	BUG_ON(dev == local->mdev || dev == local->apdev);
+	/* local->apdev must be NULL when freeing management interface
*/
+	BUG_ON(dev == local->apdev);
 	free_netdev(dev);
 }
 
--
1.3.0

-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html

