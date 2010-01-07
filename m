From: David Miller <davem@davemloft.net>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Wed, 06 Jan 2010 16:14:54 -0800 (PST)
Message-ID: <20100106.161454.193705075.davem@davemloft.net>
References: <20100105.163911.10233438.davem@davemloft.net>
	<20100106.002328.141253811.davem@davemloft.net>
	<20100106.150453.186399201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, ilpo.jarvinen@helsinki.fi
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56821
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750832Ab0AGAOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 19:14:48 -0500
In-Reply-To: <20100106.150453.186399201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 06 Jan 2010 15:04:53 -0800 (PST)

> Someone with access to a system exhibiting this will probably need to
> do some diagnostics to figure out what's going on.

To make this easier to diagnose, I cooked up a hack patch that
makes Linux emit BSD 4.2 style keepalives, and indeed a quick
test shows that we do indeed not ACK these for some reason:

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 383ce23..e0db52e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2727,6 +2727,19 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 	 * send it.
 	 */
 	tcp_init_nondata_skb(skb, tp->snd_una - !urgent, TCPCB_FLAG_ACK);
+#if 1
+	/* Construct BSD 4.2 style zero-window probe with one
+	 * out-of-window garbage data byte.
+	 *
+	 * XXX this does the wrong thing when 'urgent' is true
+	 */
+	{
+		unsigned char *garbage_byte = skb_put(skb, 1);
+
+		*garbage_byte = 0xff;
+		TCP_SKB_CB(skb)->end_seq++;
+	}
+#endif
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
 }

