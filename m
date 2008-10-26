From: David Miller <davem@davemloft.net>
Subject: suspicious logic in tcp_make_synack()
Date: Sun, 26 Oct 2008 01:01:58 -0700 (PDT)
Message-ID: <20081026.010158.193698298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49476
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751753AbYJZICV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 04:02:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've been debugging something over the past few days and noticed
something I can't explain in your change:

commit 33ad798c924b4a1afad3593f2796d465040aadd5
Author: Adam Langley <agl@imperialviolet.org>
Date:   Sat Jul 19 00:04:31 2008 -0700

    tcp: options clean up

specifically this hunk of the change:

@@ -2244,18 +2295,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
 	else
 #endif
-	TCP_SKB_CB(skb)->when = tcp_time_stamp;
-	tcp_syn_build_options((__be32 *)(th + 1), dst_metric(dst, RTAX_ADVMSS), ireq->tstamp_ok,
-			      ireq->sack_ok, ireq->wscale_ok, ireq->rcv_wscale,
-			      TCP_SKB_CB(skb)->when,
-			      req->ts_recent,
-			      (
-#ifdef CONFIG_TCP_MD5SIG
-			       md5 ? &md5_hash_location :
-#endif
-			       NULL)
-			      );
-
+	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);

the code right above this stuff reads:

#ifdef CONFIG_SYN_COOKIES
	if (unlikely(req->cookie_ts))
		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
	else
#endif

The old code unconditionally built TCP options for the SYNACK, but now
it doesn't build those options if req->cookie_ts, that call falls into
the "else" branch, is that intentional?

That req->cookie_ts test is meant to only control how
TCP_SKB_CB(skb)->when gets calculated.

This looks like a bug to me.  It means also we now won't set ->when if
CONFIG_SYN_COOKIES is enabled and req->cookie_ts is false.
