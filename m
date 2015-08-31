From: Marius Tomaschewski <mt@suse.de>
Subject: [PATCH] ipv6: send only one NEWLINK when RA causes changes
Date: Tue, 1 Sep 2015 01:57:30 +0200
Message-ID: <20150831235706.GA17924@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51817 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128AbbHaX5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2015 19:57:55 -0400
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 57AEAAAC8
	for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 23:57:54 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marius Tomaschewski <mt@suse.de>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 99ea9dd..8456c75 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1075,6 +1075,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	int optlen;
 	unsigned int pref = 0;
 	__u32 old_if_flags;
+	bool send_ifinfo_notify = false;
 
 	__u8 *opt = (__u8 *)(ra_msg + 1);
 
@@ -1154,7 +1155,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 					IF_RA_OTHERCONF : 0);
 
 	if (old_if_flags != in6_dev->if_flags)
-		inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
+		send_ifinfo_notify = true;
 
 	if (!in6_dev->cnf.accept_ra_defrtr) {
 		ND_PRINTK(2, info,
@@ -1259,7 +1260,7 @@ skip_defrtr:
 				rtime = HZ/10;
 			NEIGH_VAR_SET(in6_dev->nd_parms, RETRANS_TIME, rtime);
 			in6_dev->tstamp = jiffies;
-			inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
+			send_ifinfo_notify = true;
 		}
 
 		rtime = ntohl(ra_msg->reachable_time);
@@ -1276,11 +1277,17 @@ skip_defrtr:
 					      GC_STALETIME, 3 * rtime);
 				in6_dev->nd_parms->reachable_time = neigh_rand_reach_time(rtime);
 				in6_dev->tstamp = jiffies;
-				inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
+				send_ifinfo_notify = true;
 			}
 		}
 	}
 
+	/*
+	 *	Send a notify if RA changed managed/otherconf flags or timer settings
+	 */
+	if (send_ifinfo_notify)
+		inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
+
 skip_linkparms:
 
 	/*
-- 
2.1.4
