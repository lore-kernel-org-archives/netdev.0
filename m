From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/3] [IPV6]: Event type in addrconf_ifdown is mis-used.
Date: Tue, 18 Mar 2008 17:35:23 +0300
Message-ID: <1205850925-11736-1-git-send-email-den@openvz.org>
References: <1205850761.9163.21.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
        "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, benjamin.thery-6ktuUTfB/bM@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1205850761.9163.21.camel-aPCOdVxUTlgvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

addrconf_ifdown is broken in respect to the usage of how parameter. This
function is called with (event != NETDEV_DOWN) and (2) on the IPv6 stop.
It the latter case inet6_dev from loopback device should be destroyed.

Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 net/ipv6/addrconf.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4b86d38..d68e8f5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2457,7 +2457,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	/* Step 1: remove reference to ipv6 device from parent device.
 		   Do not dev_put!
 	 */
-	if (how == 1) {
+	if (how) {
 		idev->dead = 1;
 
 		/* protected by rtnl_lock */
@@ -2489,12 +2489,12 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	write_lock_bh(&idev->lock);
 
 	/* Step 3: clear flags for stateless addrconf */
-	if (how != 1)
+	if (!how)
 		idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD|IF_READY);
 
 	/* Step 4: clear address list */
 #ifdef CONFIG_IPV6_PRIVACY
-	if (how == 1 && del_timer(&idev->regen_timer))
+	if (how && del_timer(&idev->regen_timer))
 		in6_dev_put(idev);
 
 	/* clear tempaddr list */
@@ -2531,7 +2531,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 	/* Step 5: Discard multicast list */
 
-	if (how == 1)
+	if (how)
 		ipv6_mc_destroy_dev(idev);
 	else
 		ipv6_mc_down(idev);
@@ -2540,7 +2540,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 	/* Shot the device (if unregistered) */
 
-	if (how == 1) {
+	if (how) {
 		addrconf_sysctl_unregister(idev);
 		neigh_parms_release(&nd_tbl, idev->nd_parms);
 		neigh_ifdown(&nd_tbl, dev);
-- 
1.5.3.rc5
