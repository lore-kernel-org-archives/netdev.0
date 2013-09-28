From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce SO_MAX_PACING_RATE
Date: Fri, 27 Sep 2013 17:28:14 -0700
Message-ID: <1380328094.30872.41.camel@edumazet-glaptop.roam.corp.google.com>
References: <1379949014.3165.24.camel@edumazet-glaptop>
	 <20130927211604.GA929@imap.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: "Steinar H. Gunderson" <sesse@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:41243 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525Ab3I1A2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 20:28:15 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so3177356pbc.25
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 17:28:15 -0700 (PDT)
In-Reply-To: <20130927211604.GA929@imap.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-27 at 23:16 +0200, Steinar H. Gunderson wrote:
> On Mon, Sep 23, 2013 at 08:10:14AM -0700, Eric Dumazet wrote:
> > SO_MAX_PACING_RATE offers the application the ability to cap the
> > rate computed by transport layer. Value is in bytes per second.
> 
> I tried this (the first version) on top of 3.12-rc2, but it doesn't actually
> appear to work.
> 
> The setsockopt goes through:
> 
>   [pid 30501] setsockopt(11, SOL_SOCKET, 0x2f /* SO_??? */, [1920000], 4) = 0
> 
> And the fq scheduler is active on the machine:

The socket option actually works, but FQ has a problem with non TSO
frames, because default quantum is 3028 (2 * 1514)

I am testing this patch :

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 32ad015..f7e45b0 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -473,7 +473,8 @@ begin:
 
 		rate = min(rate, q->flow_max_rate);
 		if (rate) {
-			u64 len = (u64)qdisc_pkt_len(skb) * NSEC_PER_SEC;
+			u32 plen = max(qdisc_pkt_len(skb), q->quantum);
+			u64 len = (u64)plen * NSEC_PER_SEC;
 
 			do_div(len, rate);
 			/* Since socket rate can change later,
