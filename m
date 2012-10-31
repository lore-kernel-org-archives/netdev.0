From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: fix divide by zero in tcp algorithm illinois
Date: Wed, 31 Oct 2012 12:17:22 +0100
Message-ID: <1351682242.32673.50.camel@edumazet-glaptop>
References: <20121031103630.18756.15685.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Petr Matousek <pmatouse@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54433 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965072Ab2JaLRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 07:17:25 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so667655eek.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 04:17:24 -0700 (PDT)
In-Reply-To: <20121031103630.18756.15685.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-31 at 11:37 +0100, Jesper Dangaard Brouer wrote:
> Reading TCP stats when using TCP Illinois congestion control algorithm
> can cause a divide by zero kernel oops.
> 
> The division by zero occur in tcp_illinois_info() at:
>  do_div(t, ca->cnt_rtt);
> where ca->cnt_rtt can become zero (when rtt_reset is called)
> 
> Steps to Reproduce:
>  1. Register tcp_illinois:
>      # sysctl -w net.ipv4.tcp_congestion_control=illinois
>  2. Monitor internal TCP information via command "ss -i"
>      # watch -d ss -i
>  3. Establish new TCP conn to machine
> 
> Either it fails at the initial conn, or else it needs to wait
> for a loss or a reset.
> 
> This is only related to reading stats.  The function avg_delay() also
> performs the same divide, but is guarded with a (ca->cnt_rtt > 0) at its
> calling point in update_params().  Thus, simply fix tcp_illinois_info().
> 

avg_delay() is called with socket locked so it is safe.

While get_info() is called with socket not locked.

> To be on the safe side, I use a local stack variable in tcp_illinois_info()
> to eliminate any race conditions.  I'm not sure this is needed, as this
> would also affect avg_delay(), if this race exists.  (Although this is likely
> already "fix" by compiler optimization and kept in a local register)

Hmm, this is certainly not a valid reason.

Compiler could do the reverse actually, even with a local var.

Could you please use info.tcpv_rttcnt to be on the safe side ?

diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 813b43a..d92ae7e 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -313,11 +313,13 @@ static void tcp_illinois_info(struct sock *sk, u32 ext,
 			.tcpv_rttcnt = ca->cnt_rtt,
 			.tcpv_minrtt = ca->base_rtt,
 		};
-		u64 t = ca->sum_rtt;
 
-		do_div(t, ca->cnt_rtt);
-		info.tcpv_rtt = t;
+		if (info.tcpv_rttcnt) {
+			u64 t = ca->sum_rtt;
 
+			do_div(t, info.tcpv_rttcnt);
+			info.tcpv_rtt = t;
+		}
 		nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
 	}
 }
