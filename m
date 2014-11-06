From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: am335x: cpsw: phy ignores max-speed setting
Date: Thu, 06 Nov 2014 09:28:23 -0800
Message-ID: <1415294903.13896.70.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAGm1_ktWK5ai85PZJTkq8Q1mAFH6JZ5XM1mDOHO3K_N2iGNLWg@mail.gmail.com>
	 <CAA93jw5=LDirktyC+rvpLi-kywUSosj6QV8-na5p3-f=PxKcWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yegor Yefremov <yegorslists@googlemail.com>,
	netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>, mpa@pengutronix.de,
	lsorense@csclub.uwaterloo.ca, Daniel Mack <zonque@gmail.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:46038 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbaKFR20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 12:28:26 -0500
Received: by mail-ig0-f181.google.com with SMTP id l13so4117819iga.14
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 09:28:25 -0800 (PST)
In-Reply-To: <CAA93jw5=LDirktyC+rvpLi-kywUSosj6QV8-na5p3-f=PxKcWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-06 at 08:51 -0800, Dave Taht wrote:
> ooh! ooh! I have a BQL enablement patch for the cpsw that I have no
> means of testing against multiple phys. Could
> you give the attached very small patch a shot along the way?
> 
> The results I get on the beaglebone vs netperf-wrapper are pretty
> spectacular - huge increase in throughput, big reduction in
> latency.

Please send this patch inline, so that we can comment, and start a new
thread.

@@ -1375,9 +1380,11 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
                skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
        skb_tx_timestamp(skb);
-
+       len = max(skb->len, CPSW_MIN_PACKET_SIZE);
+       netdev_sent_queue(ndev,len);
        ret = cpsw_tx_packet_submit(ndev, priv, skb);
        if (unlikely(ret != 0)) {
+               netdev_completed_queue(ndev,1,len);
<<you can not do that, its racy with other netdev_completed_queue() calls from TX completion >>
                cpsw_err(priv, tx_err, "desc submit failed\n");
                goto fail;
        }


You need to call netdev_sent_queue(ndev, len); at the correct place,
because we can not 'undo' it.
