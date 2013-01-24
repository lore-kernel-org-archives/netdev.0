From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
Date: Wed, 23 Jan 2013 17:45:06 -0800
Message-ID: <1358991906.12374.1356.camel@edumazet-glaptop>
References: <50FDADF4.3060601@candelatech.com>
	 <50FDDE35.7070806@candelatech.com>
	 <1358829606.3464.3151.camel@edumazet-glaptop>
	 <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>
	 <1358875020.3464.4006.camel@edumazet-glaptop>
	 <1358875607.3464.4020.camel@edumazet-glaptop>
	 <50FF102F.2050008@candelatech.com> <50FF4BC9.1060206@candelatech.com>
	 <5100785D.8040101@candelatech.com>
	 <1358985688.12374.1247.camel@edumazet-glaptop>
	 <51007CA8.2050105@candelatech.com>
	 <1358987031.12374.1276.camel@edumazet-glaptop>
	 <51008294.2010201@candelatech.com>
	 <1358988358.12374.1303.camel@edumazet-glaptop>
	 <51008598.4000603@candelatech.com>
	 <1358989242.12374.1323.camel@edumazet-glaptop>
	 <51008900.2010803@candelatech.com>
	 <1358989843.12374.1334.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:41572 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531Ab3AXBpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 20:45:10 -0500
Received: by mail-pb0-f47.google.com with SMTP id wz17so5070808pbc.6
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 17:45:10 -0800 (PST)
In-Reply-To: <1358989843.12374.1334.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 17:10 -0800, Eric Dumazet wrote:

> Excellent, thats the bug.
> 
> I'll send a fix asap, thanks !

loopback device doesnt have a qdisc, and unsets IFF_XMIT_DST_RELEASE

Its hard to believe such an old bug never hit us in the past.

Probably because most of the time, the packet given to netif_rx() is
immediately processed (and loopback device is hard wired ?)


diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 81f8f9e..fcbf680 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -77,6 +77,11 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 
 	skb_orphan(skb);
 
+	/* Before queueing this packet to netif_rx(),
+	 * make sure dst is refcounted.
+	 */
+	skb_dst_force(skb);
+
 	skb->protocol = eth_type_trans(skb, dev);
 
 	/* it's OK to use per_cpu_ptr() because BHs are off */
