From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Thu, 02 Aug 2012 12:28:30 +0200
Message-ID: <1343903310.9299.184.camel@edumazet-glaptop>
References: <50160EEF.6050406@parallels.com> <87pq7dh6b2.fsf@xmission.com>
	 <87fw89h5zk.fsf@xmission.com> <50179F66.1000604@parallels.com>
	 <878ve0dtw3.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42256 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754086Ab2HBK2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 06:28:35 -0400
Received: by bkwj10 with SMTP id j10so4172860bkw.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 03:28:34 -0700 (PDT)
In-Reply-To: <878ve0dtw3.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-31 at 04:58 -0700, Eric W. Biederman wrote:

> Making lo the particularly interesting case.


BTW, I noticed in my benchmarks, that once I remove the contention on
dst refcnt (using a percpu cache of dsts), I have a strange performance
cost accessing net->loopback_dev->ifindex in ip_route_output_key.

Strange because I see no false sharing on this ifindex location for
loopback device.

So we probably can save some cycles adding a net->loopback_ifindex
to remove one dereference.

If ifindex are per network space, I guess we'll need to change
arp_hashfn() or else we'll use some slots more than others.

diff --git a/include/net/arp.h b/include/net/arp.h
index 7f7df93..37aac58 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -10,7 +10,7 @@ extern struct neigh_table arp_tbl;
 
 static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd)
 {
-	u32 val = key ^ dev->ifindex;
+	u32 val = key ^ (u32)(unsigned long)dev;
 
 	return val * hash_rnd;
 }
