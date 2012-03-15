From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] arp: allow arp processing to honor per interface arp_accept sysctl
Date: Thu, 15 Mar 2012 11:25:58 -0400
Message-ID: <1331825158-17584-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54716 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030543Ab2COP0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 11:26:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found recently that the arp_process function which handles all of our received
arp frames, is using IPV4_DEVCONF_ALL macro to check the state of the arp_process
flag.  This seems wrong, as it implies that either none or all of the network
interfaces accept gratuitous arps.  This patch corrects that, allowing
per-interface arp_accept configuration to deviate from the all setting.  Note
this also brings us into line with the way the arp_filter setting is handled
during arp_process execution.

Tested this myself on my home network, and confirmed it works as expected.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 include/linux/inetdevice.h |    1 +
 net/ipv4/arp.c             |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 5f81466..597f4a9 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -139,6 +139,7 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 	  IN_DEV_ORCONF((in_dev), ACCEPT_REDIRECTS)))
 
 #define IN_DEV_ARPFILTER(in_dev)	IN_DEV_ORCONF((in_dev), ARPFILTER)
+#define IN_DEV_ARP_ACCEPT(in_dev)	IN_DEV_ORCONF((in_dev), ARP_ACCEPT)
 #define IN_DEV_ARP_ANNOUNCE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_ANNOUNCE)
 #define IN_DEV_ARP_IGNORE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_IGNORE)
 #define IN_DEV_ARP_NOTIFY(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_NOTIFY)
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 63e4989..73f46d6 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -889,7 +889,7 @@ static int arp_process(struct sk_buff *skb)
 
 	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
 
-	if (IPV4_DEVCONF_ALL(dev_net(dev), ARP_ACCEPT)) {
+	if (IN_DEV_ARP_ACCEPT(in_dev)) {
 		/* Unsolicited ARP is not accepted by default.
 		   It is possible, that this option should be enabled for some
 		   devices (strip is candidate)
-- 
1.7.7.6
