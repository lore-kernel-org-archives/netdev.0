From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Wed, 04 Sep 2013 18:23:05 -0700
Message-ID: <1378344185.11205.3.camel@edumazet-glaptop>
References: <1377816595.8277.54.camel@edumazet-glaptop>
	 <5226C4A0.6040709@redhat.com> <1378274376.7360.82.camel@edumazet-glaptop>
	 <5226D39C.9070401@redhat.com> <1378290638.7360.85.camel@edumazet-glaptop>
	 <1378294029.7360.92.camel@edumazet-glaptop>
	 <1378342226.11205.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:46535 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762674Ab3IEBXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 21:23:10 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so1196858pab.11
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 18:23:09 -0700 (PDT)
In-Reply-To: <1378342226.11205.1.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-04 at 17:50 -0700, Eric Dumazet wrote:

> 
> BTW what is your HZ value ?
> 
> We have a problem in TCP stack, because srtt is in HZ units.
> 
> Before we change to us units, I guess tcp_update_pacing_rate() should be
> changed a bit if HZ=250

Oh well, I feel dumb, please try this fix (If you have HZ != 1000) :

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 93d7e9d..fd96d8e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -700,7 +700,7 @@ static void tcp_update_pacing_rate(struct sock *sk)
 	u64 rate;
 
 	/* set sk_pacing_rate to 200 % of current rate (mss * cwnd / srtt) */
-	rate = (u64)tp->mss_cache * 2 * (HZ << 3);
+	rate = (u64)tp->mss_cache * 2 * ((USEC_PER_SEC/HZ) << 3);
 
 	rate *= max(tp->snd_cwnd, tp->packets_out);
 
