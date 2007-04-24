From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 7/9] wext: reduce inline abuse
Date: Tue, 24 Apr 2007 20:07:39 +0200
Message-ID: <20070424180849.651555000@sipsolutions.net>
References: <20070424180732.371620000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	jt@hpl.hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:33727 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423077AbXDZJk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 05:40:27 -0400
Content-Disposition: inline; filename=wext-uninline.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes a bunch of inline abuse from wext. Most functions
that were marked inline are only used once so the compiler will inline
them anyway, others are used multiple times but there's no requirement
for them to be inline since they aren't in any fast paths.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
 net/wireless/wext.c |   29 ++++++++++-------------------
 1 file changed, 10 insertions(+), 19 deletions(-)

--- net-2.6.22.orig/net/wireless/wext.c	2007-04-24 19:13:50.288804911 +0200
+++ net-2.6.22/net/wireless/wext.c	2007-04-24 19:18:49.198804911 +0200
@@ -440,10 +440,8 @@ static const int event_type_pk_size[] = 
 /* ---------------------------------------------------------------- */
 /*
  * Return the driver handler associated with a specific Wireless Extension.
- * Called from various place, so make sure it remains efficient.
  */
-static inline iw_handler get_handler(struct net_device *dev,
-				     unsigned int cmd)
+static iw_handler get_handler(struct net_device *dev, unsigned int cmd)
 {
 	/* Don't "optimise" the following variable, it will crash */
 	unsigned int	index;		/* *MUST* be unsigned */
@@ -470,7 +468,7 @@ static inline iw_handler get_handler(str
 /*
  * Get statistics out of the driver
  */
-static inline struct iw_statistics *get_wireless_stats(struct net_device *dev)
+static struct iw_statistics *get_wireless_stats(struct net_device *dev)
 {
 	/* New location */
 	if ((dev->wireless_handlers != NULL) &&
@@ -500,7 +498,7 @@ static inline struct iw_statistics *get_
  * netif_running(dev) test. I'm open on that one...
  * Hopefully, the driver will remember to do a commit in "open()" ;-)
  */
-static inline int call_commit_handler(struct net_device *	dev)
+static int call_commit_handler(struct net_device *dev)
 {
 	if ((netif_running(dev)) &&
 	   (dev->wireless_handlers->standard[0] != NULL)) {
@@ -622,8 +620,8 @@ static int iw_handler_get_private(struct
 /*
  * Print one entry (line) of /proc/net/wireless
  */
-static __inline__ void wireless_seq_printf_stats(struct seq_file *seq,
-						 struct net_device *dev)
+static void wireless_seq_printf_stats(struct seq_file *seq,
+				      struct net_device *dev)
 {
 	/* Get stats from the driver */
 	struct iw_statistics *stats = get_wireless_stats(dev);
@@ -892,10 +890,8 @@ static int ioctl_standard_call(struct ne
  * a iw_handler but process it in your ioctl handler (i.e. use the
  * old driver API).
  */
-static inline int ioctl_private_call(struct net_device *	dev,
-				     struct ifreq *		ifr,
-				     unsigned int		cmd,
-				     iw_handler		handler)
+static int ioctl_private_call(struct net_device *dev, struct ifreq *ifr,
+			      unsigned int cmd, iw_handler handler)
 {
 	struct iwreq *			iwr = (struct iwreq *) ifr;
 	const struct iw_priv_args *	descr = NULL;
@@ -1134,11 +1130,8 @@ static DECLARE_TASKLET(wireless_nlevent_
  * current wireless config. Dumping the wireless config is far too
  * expensive (for each parameter, the driver need to query the hardware).
  */
-static inline int rtnetlink_fill_iwinfo(struct sk_buff *	skb,
-					struct net_device *	dev,
-					int			type,
-					char *			event,
-					int			event_len)
+static int rtnetlink_fill_iwinfo(struct sk_buff *skb, struct net_device *dev,
+				 int type, char *event, int event_len)
 {
 	struct ifinfomsg *r;
 	struct nlmsghdr  *nlh;
@@ -1172,9 +1165,7 @@ rtattr_failure:
  * Andrzej Krzysztofowicz mandated that I used a IFLA_XXX field
  * within a RTM_NEWLINK event.
  */
-static inline void rtmsg_iwinfo(struct net_device *	dev,
-				char *			event,
-				int			event_len)
+static void rtmsg_iwinfo(struct net_device *dev, char *event, int event_len)
 {
 	struct sk_buff *skb;
 	int size = NLMSG_GOODSIZE;

--

