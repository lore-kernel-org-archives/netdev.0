From: Marius Tomaschewski <mt@suse.de>
Subject: Re: [PATCH] ipv6: send NEWLINK on RA managed/otherconf changes
Date: Tue, 1 Sep 2015 01:43:39 +0200
Message-ID: <55E4E6AB.4040108@suse.de>
References: <20150831135922.GA24179@suse.de>
 <20150831.151351.228280334434841531.davem@davemloft.net>
Reply-To: mt@suse.de
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050303000204080604010803"
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51558 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752351AbbHaXnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2015 19:43:43 -0400
In-Reply-To: <20150831.151351.228280334434841531.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050303000204080604010803
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit

Am 01.09.2015 um 00:13 schrieb David Miller:
> From: Marius Tomaschewski <mt@suse.de>
> Date: Mon, 31 Aug 2015 15:59:22 +0200
> 
>> The kernel is applying the RA managed/otherconf flags silently and
>> forgets to send ifinfo notify to inform about their change when the
>> router provides a zero reachable_time and retrans_timer as dnsmasq
>> and many routers send it, which just means unspecified by this router
>> and the host should continue using whatever value it is already using.
>> Userspace may monitor the ifinfo notifications to activate dhcpv6.
>>
>> Signed-off-by: Marius Tomaschewski <mt@suse.de>
> 
> Applied, but more ideally this function should emit only a single
> NEWLINK message rather than potentially 3.

Yes, you're right of course.

I've attached a follow-up patch doing this. Please let me know if you
need it in a separate mail.

Gruesse / Regards,
 Marius Tomaschewski <mt@suse.de>, <mt@suse.com>
-- 
 SUSE Linux GmbH, GF: Felix Imendörffer, Jane Smithard,
 Dilip Upmanyu, Graham Norton, HRB 21284 (AG Nürnberg),
 Maxfeldstraße 5, 90409 Nürnberg, Germany

--------------050303000204080604010803
Content-Type: text/x-patch;
 name="0002-ipv6-send-only-one-NEWLINK-when-RA-causes-changes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0002-ipv6-send-only-one-NEWLINK-when-RA-causes-changes.patch"

>From b6b55b5383c9b89cfd5ad9b4584c044c6c8d3722 Mon Sep 17 00:00:00 2001
From: Marius Tomaschewski <mt@suse.de>
Date: Tue, 1 Sep 2015 01:40:57 +0200
Subject: [PATCH] ipv6: send only one NEWLINK when RA causes changes

Signed-off-by: Marius Tomaschewski <mt@suse.de>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 99ea9dd..7baca60 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1075,6 +1075,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	int optlen;
 	unsigned int pref = 0;
 	__u32 old_if_flags;
+	int send_ifinfo_notify = 0;
 
 	__u8 *opt = (__u8 *)(ra_msg + 1);
 
@@ -1154,7 +1155,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 					IF_RA_OTHERCONF : 0);
 
 	if (old_if_flags != in6_dev->if_flags)
-		inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
+		send_ifinfo_notify = 1;
 
 	if (!in6_dev->cnf.accept_ra_defrtr) {
 		ND_PRINTK(2, info,
@@ -1259,7 +1260,7 @@ skip_defrtr:
 				rtime = HZ/10;
 			NEIGH_VAR_SET(in6_dev->nd_parms, RETRANS_TIME, rtime);
 			in6_dev->tstamp = jiffies;
-			inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
+			send_ifinfo_notify = 1;
 		}
 
 		rtime = ntohl(ra_msg->reachable_time);
@@ -1276,11 +1277,17 @@ skip_defrtr:
 					      GC_STALETIME, 3 * rtime);
 				in6_dev->nd_parms->reachable_time = neigh_rand_reach_time(rtime);
 				in6_dev->tstamp = jiffies;
-				inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
+				send_ifinfo_notify = 1;
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


--------------050303000204080604010803--
