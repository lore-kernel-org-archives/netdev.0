From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] tcp: switch rtt estimations to usec
 resolution
Date: Mon, 24 Feb 2014 14:13:45 -0800
Message-ID: <1393280025.2316.76.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	  <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	  <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
	  <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393216927.2316.62.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393266251.2316.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402242240290.1941@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:35630 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbaBXWNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 17:13:47 -0500
Received: by mail-pd0-f172.google.com with SMTP id p10so2447019pdj.17
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 14:13:46 -0800 (PST)
In-Reply-To: <alpine.LFD.2.11.1402242240290.1941@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-24 at 22:47 +0200, Julian Anastasov wrote:
> 	Hello,
> 
> On Mon, 24 Feb 2014, Eric Dumazet wrote:
> 
> > v4: switch to ktime_get() instead of ktime_get_real()
> 
> 	May be you missed my last email. In tcpm_suck_dst()
> dst_metric_raw(dst, RTAX_RTT) returns msecs and we store
> it in tcpm_vals[] which is now in usec units. If we want to keep
> dst metrics in msec units we can fix this only in tcpm_suck_dst.
> Otherwise, similar attributes for dst metrics in ip/iproute.c
> are needed.

Well, I do not see an immediate need to support usec for these
attributes. This might be changed later if needed.

So I think we can simply do :


diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index d547075d8300..c8d0b1b18b8e 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
-static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst,
+static void tcpm_suck_dst(struct tcp_metrics_block *tm,
+                         const struct dst_entry *dst,
                          bool fastopen_clear)
 {
+       u32 msval;
        u32 val;
 
        tm->tcpm_stamp = jiffies;
@@ -121,8 +115,11 @@ static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst,
                val |= 1 << TCP_METRIC_REORDERING;
        tm->tcpm_lock = val;
 
-       tm->tcpm_vals[TCP_METRIC_RTT] = dst_metric_raw(dst, RTAX_RTT);
-       tm->tcpm_vals[TCP_METRIC_RTTVAR] = dst_metric_raw(dst, RTAX_RTTVAR);
+       msval = dst_metric_raw(dst, RTAX_RTT);
+       tm->tcpm_vals[TCP_METRIC_RTT] = msval * USEC_PER_MSEC;
+
+       msval = dst_metric_raw(dst, RTAX_RTTVAR);
+       tm->tcpm_vals[TCP_METRIC_RTTVAR] = msval * USEC_PER_MSEC;
        tm->tcpm_vals[TCP_METRIC_SSTHRESH] = dst_metric_raw(dst, RTAX_SSTHRESH);
        tm->tcpm_vals[TCP_METRIC_CWND] = dst_metric_raw(dst, RTAX_CWND);
        tm->tcpm_vals[TCP_METRIC_REORDERING] = dst_metric_raw(dst, RTAX_REORDERING);

Is that ok ?

Thanks !
